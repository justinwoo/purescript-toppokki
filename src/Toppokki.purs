module Toppokki
       ( Puppeteer
       , Browser
       , URL(..)
       , UserAgent(..)
       , LaunchOptions
       , launch
       , newPage
       , query
       , queryMany
       , goto
       , close
       , content
       , title
       , setUserAgent
       , ViewportOptions
       , setViewport
       , ScreenshotOptions
       , screenshot
       , PDFMargin
       , PDFMarginOptions
       , makePDFMargin
       , pdf
       , onPageError
       , onLoad
       , class WaitForSelector
       , waitForSelector
       , focus
       , type_
       , click
       , WaitUntilOption
       , networkIdle
       , waitForNavigation
       , getLocationRef
       , unsafeEvaluateStringFunction
       , module ReExports
       )
where

import Control.Monad.Except (runExcept)
import Control.Promise (Promise)
import Control.Promise as Promise
import Data.Either (Either(..))
import Data.Function.Uncurried as FU
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Exception (Error)
import Effect.Uncurried as EU
import Foreign (Foreign, readNull, unsafeFromForeign)
import Node.Buffer (Buffer)
import Prelude
import Prim.Row as Row
import Prim.TypeError (class Fail, Text)
import Unsafe.Coerce (unsafeCoerce)
import Web.DOM.ParentNode (QuerySelector)
import Toppokki.Unsafe (class Queryable, Page, Frame, ElementHandle) as ReExports
import Toppokki.Unsafe (class Queryable, Page, Frame, ElementHandle)

foreign import data Puppeteer :: Type
foreign import data Browser :: Type

newtype URL = URL String
derive instance newtypeURL :: Newtype URL _

newtype UserAgent = UserAgent String
derive instance newtypeUserAgent :: Newtype UserAgent _

type LaunchOptions =
  ( headless :: Boolean
  )

launch
  :: forall options trash
   . Row.Union options trash LaunchOptions
  => { | options }
  -> Aff Browser
launch = runPromiseAffE1 _launch

newPage :: Browser -> Aff Page
newPage = runPromiseAffE1 _newPage

-- | Query the element using `.$(selector)`
query :: forall el. Queryable el => QuerySelector -> el -> Aff (Maybe ElementHandle)
query s el = map unsafeNullOr (runPromiseAffE2 _query s el)

-- | Query the element using `.$$(selector)`
queryMany :: forall el. Queryable el => QuerySelector -> el -> Aff (Array ElementHandle)
queryMany = runPromiseAffE2 _queryMany

goto :: URL -> Page -> Aff Unit
goto = runPromiseAffE2 _goto

close :: Browser -> Aff Unit
close = runPromiseAffE1 _close

content :: Page -> Aff String
content = runPromiseAffE1 _content

title :: Page -> Aff String
title = runPromiseAffE1 _title

setUserAgent :: UserAgent -> Page -> Aff Unit
setUserAgent = runPromiseAffE2 _setUserAgent

type ViewportOptions =
  ( deviceScaleFactor :: Number
  , isMobile :: Boolean
  , hasTouch :: Boolean
  , isLandscape :: Boolean
  )

setViewport
  :: forall options trash
  . Row.Union options trash ViewportOptions
  => { width :: Int
     , height :: Int
     | options
     }
  -> Page
  -> Aff Unit
setViewport o p = runPromiseAffE2 _setViewport o p

type ScreenshotOptions =
  ( path :: String
  , type :: String
  , quality :: Int
  , fullPage :: Boolean
  , clip ::
      { x :: Int
      , y :: Int
      , width :: Int
      , height :: Int
      }
  , omitBackground :: Boolean
  )

screenshot
  :: forall options trash
   . Row.Union options trash ScreenshotOptions
  => { | options }
  -> Page
  -> Aff Buffer
screenshot o p = runPromiseAffE2 _screenshot o p

foreign import data PDFMargin :: Type

type PDFMarginOptions =
  ( top :: String
  , right :: String
  , bottom :: String
  , left :: String
  )

makePDFMargin
  :: forall options trash
   . Row.Union options trash PDFMarginOptions
  => { | options }
  -> PDFMargin
makePDFMargin = unsafeCoerce

type PDFOptions =
  ( path :: String
  , scale :: Int
  , displayHeaderFooter :: Boolean
  , headerTemplate :: String
  , footerTemplate :: String
  , printBackground :: Boolean
  , landscape :: Boolean
  , pageRanges :: String
  , format :: String
  , width :: String
  , height :: String
  , margin :: PDFMargin
  )

pdf
  :: forall options trash
   . Row.Union options trash PDFOptions
  => { | options }
  -> Page
  -> Aff Buffer
pdf = runPromiseAffE2 _pdf

onPageError :: EU.EffectFn1 Error Unit -> Page -> Effect Unit
onPageError = EU.runEffectFn3 _on "pageerror"

onLoad :: EU.EffectFn1 Unit Unit -> Page -> Effect Unit
onLoad = EU.runEffectFn3 _on "load"


class WaitForSelector a

instance waitForSelectorPage :: WaitForSelector Page
else instance waitForSelectorFrame :: WaitForSelector Frame
else instance waitForSelectorClose :: (Fail (Text "WaitForSelector class is closed")) => WaitForSelector a

waitForSelector
  :: forall options trash a
   . Row.Union options trash
       ( visible :: Boolean
       , hidden :: Boolean
       , timeout :: Int
       )
  => WaitForSelector a
  => QuerySelector
  -> { | options }
  -> a
  -> Aff ElementHandle
waitForSelector =
  runPromiseAffE3 _waitForSelector

focus :: QuerySelector -> Page -> Aff Unit
focus = runPromiseAffE2 _focus

type_
  :: forall options trash
   . Row.Union options trash
       ( delay :: Int
       )
  => QuerySelector
  -> String
  -> { | options }
  -> Page
  -> Aff Unit
type_ = runPromiseAffE4 _type

click :: QuerySelector -> Page -> Aff Unit
click = runPromiseAffE2 _click

foreign import data WaitUntilOption :: Type

networkIdle :: WaitUntilOption
networkIdle = unsafeCoerce $ "networkidle"

networkIdle0 :: WaitUntilOption
networkIdle0 = unsafeCoerce $ "networkidle0"

networkIdle2 :: WaitUntilOption
networkIdle2 = unsafeCoerce $ "networkidle2"

waitForNavigation
  :: forall options trash
   . Row.Union options trash
       ( waitUntil :: WaitUntilOption
       )
  => { | options }
  -> Page
  -> Aff Unit
waitForNavigation = runPromiseAffE2 _waitForNavigation

getLocationRef :: Page -> Aff String
getLocationRef p = Promise.toAffE $ FU.runFn1 _getLocationHref p

unsafeEvaluateStringFunction :: String -> Page -> Aff Foreign
unsafeEvaluateStringFunction = runPromiseAffE2 _unsafeEvaluateStringFunction

runPromiseAffE1 :: forall a o. FU.Fn1 a (Effect (Promise o)) -> a -> Aff o
runPromiseAffE1 f a = Promise.toAffE $ FU.runFn1 f a

runPromiseAffE2 :: forall a b o. FU.Fn2 a b (Effect (Promise o)) -> a -> b -> Aff o
runPromiseAffE2 f a b = Promise.toAffE $ FU.runFn2 f a b

runPromiseAffE3 :: forall a b c o. FU.Fn3 a b c (Effect (Promise o)) -> a -> b -> c -> Aff o
runPromiseAffE3 f a b c =  Promise.toAffE $ FU.runFn3 f a b c

runPromiseAffE4 :: forall a b c d o. FU.Fn4 a b c d (Effect (Promise o)) -> a -> b -> c -> d -> Aff o
runPromiseAffE4 f a b c d =  Promise.toAffE $ FU.runFn4 f a b c d

foreign import puppeteer :: Puppeteer
foreign import _launch :: forall options. FU.Fn1 options (Effect (Promise Browser))
foreign import _newPage :: FU.Fn1 Browser (Effect (Promise Page))
foreign import _query :: forall el. FU.Fn2 QuerySelector el (Effect (Promise Foreign))
foreign import _queryMany :: forall el. FU.Fn2 QuerySelector el (Effect (Promise (Array ElementHandle)))
foreign import _goto :: FU.Fn2 URL Page (Effect (Promise Unit))
foreign import _close :: FU.Fn1 Browser (Effect (Promise Unit))
foreign import _content :: FU.Fn1 Page (Effect (Promise String))
foreign import _title :: FU.Fn1 Page (Effect (Promise String))
foreign import _setUserAgent :: FU.Fn2 UserAgent Page (Effect (Promise Unit))
foreign import _setViewport :: forall options. FU.Fn2 options  Page (Effect (Promise Unit))
foreign import _screenshot :: forall options. FU.Fn2 options Page (Effect (Promise Buffer))
foreign import _pdf :: forall options. FU.Fn2 options Page (Effect (Promise Buffer))
foreign import _on :: forall a. EU.EffectFn3 String (EU.EffectFn1 a Unit) Page Unit
foreign import _waitForSelector :: forall options p. FU.Fn3 QuerySelector options p (Effect (Promise ElementHandle))
foreign import _focus :: FU.Fn2 QuerySelector Page (Effect (Promise Unit))
foreign import _type :: forall options. FU.Fn4 QuerySelector String options Page (Effect (Promise Unit))
foreign import _click :: FU.Fn2 QuerySelector Page (Effect (Promise Unit))
foreign import _waitForNavigation :: forall options. FU.Fn2 options Page (Effect (Promise Unit))
foreign import _getLocationHref :: FU.Fn1 Page (Effect (Promise String))
foreign import _unsafeEvaluateStringFunction :: FU.Fn2 String Page (Effect (Promise Foreign))

unsafeNullOr :: forall a. Foreign -> Maybe a
unsafeNullOr sth =
  case runExcept (readNull sth) of
    Right (Just sth') -> Just (unsafeFromForeign sth')
    _ -> Nothing
