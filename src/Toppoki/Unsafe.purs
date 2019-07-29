module Toppokki.Unsafe
       ( class Queryable
       , class Evaluate
       , evalViaBrowserify
       , queryEvalViaBrowserify
       , queryEvalManyViaBrowserify
       , Page
       , Frame
       , ElementHandle
       )
where

import Toppokki.Inject (InjectedAff)
import Data.Function.Uncurried as FU
import Effect (Effect)
import Effect.Aff (Aff)
import Control.Promise (Promise)
import Control.Promise as Promise
import Web.DOM.ParentNode (QuerySelector)
import Prelude
import Web.DOM.Element (Element)
import Prim.TypeError (class Fail, Text)
import Foreign (Foreign, readNull, unsafeFromForeign)

foreign import data Page :: Type
foreign import data Frame :: Type
foreign import data ElementHandle :: Type

-- | Values which can be queried by selectors.
class Queryable el

instance queryablePage :: Queryable Page
else instance queryableFrame :: Queryable Frame
else instance queryableElementHandle :: Queryable ElementHandle
else instance queryableClose :: (Fail (Text "Queryable class is closed")) => Queryable a

class Evaluate a

instance evaluatePage :: Evaluate Page
else instance evaluateFrame :: Evaluate Frame
else instance evaluateClose :: (Fail (Text "Evaluate class is closed")) => Evaluate a

-- | Execute a function in the browser context. The function will be bundled using `browserify`.
evalViaBrowserify
  :: forall ctx r
  .  Evaluate ctx
  => ctx
  -> (Unit -> InjectedAff r)
  -> Aff Foreign
evalViaBrowserify ctx callback = do
  jsCode <- Promise.toAffE (_jsReflect callback)
  Promise.toAffE (FU.runFn2 _evaluate jsCode ctx)

-- | Query the element using `.$eval(selector, pageFunction)`.
-- |
-- | If there's no element matching `selector`, the method throws an error.
-- |
-- | `pageFunction` will be bundled using `browserify` and executed in the browser context.
queryEvalViaBrowserify
  :: forall el r
  .  Queryable el
  => QuerySelector
  -> (Element -> InjectedAff r)
  -> el
  -> Aff Foreign
queryEvalViaBrowserify qs callback el = do
  jsCode <- Promise.toAffE (_jsReflect callback)
  Promise.toAffE (FU.runFn3 _queryEval qs jsCode el)

-- | Query the element using `.$$eval(selector, pageFunction)`.
-- |
-- | `pageFunction` will be bundled using `browserify` and executed in the browser context.
queryEvalManyViaBrowserify
  :: forall el r
  .  Queryable el
  => QuerySelector
  -> (Array Element -> InjectedAff r)
  -> el
  -> Aff Foreign
queryEvalManyViaBrowserify qs callback el = do
  jsCode <- Promise.toAffE (_jsReflect callback)
  Promise.toAffE (FU.runFn3 _queryEvalMany qs jsCode el)

foreign import _jsReflect :: forall a. a -> Effect (Promise String)
foreign import _queryEval :: forall el. FU.Fn3 QuerySelector String el (Effect (Promise Foreign))
foreign import _queryEvalMany :: forall el. FU.Fn3 QuerySelector String el (Effect (Promise Foreign))
foreign import _evaluate :: forall ctx. FU.Fn2 String ctx (Effect (Promise Foreign))
