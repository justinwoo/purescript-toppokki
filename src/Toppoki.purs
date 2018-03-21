module Toppokki where

import Prelude

import Control.Monad.Aff (Aff)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Exception (Error)
import Control.Monad.Eff.Uncurried as EU
import Control.Promise (Promise)
import Control.Promise as Promise
import Data.Foreign (Foreign)
import Data.Function.Uncurried as FU
import Data.Newtype (class Newtype)
import Node.Buffer (Buffer)
import Unsafe.Coerce (unsafeCoerce)

foreign import data Puppeteer :: Type
foreign import data Browser :: Type
foreign import data Page :: Type
foreign import data ElementHandle :: Type

newtype URL = URL String
derive instance newtypeURL :: Newtype URL _

newtype Selector = Selector String
derive instance newtypeSelector :: Newtype Selector _

type LaunchOptions =
  ( headless :: Boolean
  )

launch
  :: forall options trash e
   . Union options trash LaunchOptions
  => { | options }
  -> Aff e Browser
launch = runPromiseAffE1 _launch

newPage :: forall e. Browser -> Aff e Page
newPage = runPromiseAffE1 _newPage

goto :: forall e. URL -> Page -> Aff e Unit
goto = runPromiseAffE2 _goto

close :: forall e. Browser -> Aff e Unit
close = runPromiseAffE1 _close

content :: forall e. Page -> Aff e String
content = runPromiseAffE1 _content

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
  :: forall options trash e
   . Union options trash ScreenshotOptions
  => { | options }
  -> Page
  -> Aff e Buffer
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
   . Union options trash PDFMarginOptions
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
  :: forall options trash e
   . Union options trash PDFOptions
  => { | options }
  -> Page
  -> Aff e Buffer
pdf = runPromiseAffE2 _pdf

onPageError :: forall e. EU.EffFn1 e Error Unit -> Page -> Eff e Unit
onPageError = EU.runEffFn3 _on "pageerror"

onLoad :: forall e. EU.EffFn1 e Unit Unit -> Page -> Eff e Unit
onLoad = EU.runEffFn3 _on "load"

pageWaitForSelector
  :: forall options trash e
   . Union options trash
       ( visible :: Boolean
       , hidden :: Boolean
       , timeout :: Int
       )
  => Selector
  -> { | options }
  -> Page
  -> Aff e ElementHandle
pageWaitForSelector = runPromiseAffE3 _pageWaitForSelector

focus :: forall e. Selector -> Page -> Aff e Unit
focus = runPromiseAffE2 _focus

type_
  :: forall options trash e
   . Union options trash
       ( delay :: Int
       )
  => Selector
  -> String
  -> { | options }
  -> Page
  -> Aff e Unit
type_ = runPromiseAffE4 _type

click :: forall e. Selector -> Page -> Aff e Unit
click = runPromiseAffE2 _click

foreign import data WaitUntilOption :: Type

networkIdle :: WaitUntilOption
networkIdle = unsafeCoerce $ "networkidle"

waitForNavigation
  :: forall options trash e
   . Union options trash
       ( waitUntil :: WaitUntilOption
       )
  => { | options }
  -> Page
  -> Aff e Unit
waitForNavigation = runPromiseAffE2 _waitForNavigation

getLocationRef :: forall e. Page -> Aff e String
getLocationRef p = Promise.toAffE $ FU.runFn1 _getLocationHref p

unsafeEvaluateStringFunction :: forall e. String -> Page -> Aff e Foreign
unsafeEvaluateStringFunction = runPromiseAffE2 _unsafeEvaluateStringFunction

runPromiseAffE1 :: forall a o e. FU.Fn1 a (Eff e (Promise o)) -> a -> Aff e o
runPromiseAffE1 f a = Promise.toAffE $ FU.runFn1 f a

runPromiseAffE2 :: forall a b o e. FU.Fn2 a b (Eff e (Promise o)) -> a -> b -> Aff e o
runPromiseAffE2 f a b = Promise.toAffE $ FU.runFn2 f a b

runPromiseAffE3 :: forall a b c o e. FU.Fn3 a b c (Eff e (Promise o)) -> a -> b -> c -> Aff e o
runPromiseAffE3 f a b c =  Promise.toAffE $ FU.runFn3 f a b c

runPromiseAffE4 :: forall a b c d o e. FU.Fn4 a b c d (Eff e (Promise o)) -> a -> b -> c -> d -> Aff e o
runPromiseAffE4 f a b c d =  Promise.toAffE $ FU.runFn4 f a b c d

foreign import puppeteer :: Puppeteer
foreign import _launch :: forall options e. FU.Fn1 options (Eff e (Promise Browser))
foreign import _newPage :: forall e. FU.Fn1 Browser (Eff e (Promise Page))
foreign import _goto :: forall e. FU.Fn2 URL Page (Eff e (Promise Unit))
foreign import _close :: forall e. FU.Fn1 Browser (Eff e (Promise Unit))
foreign import _content :: forall e. FU.Fn1 Page (Eff e (Promise String))
foreign import _screenshot :: forall options e. FU.Fn2 options Page (Eff e (Promise Buffer))
foreign import _pdf :: forall options e. FU.Fn2 options Page (Eff e (Promise Buffer))
foreign import _on :: forall a e. EU.EffFn3 e String (EU.EffFn1 e a Unit) Page Unit
foreign import _pageWaitForSelector :: forall options e. FU.Fn3 Selector options Page (Eff e (Promise ElementHandle))
foreign import _focus :: forall e. FU.Fn2 Selector Page (Eff e (Promise Unit))
foreign import _type :: forall options e. FU.Fn4 Selector String options Page (Eff e (Promise Unit))
foreign import _click :: forall e. FU.Fn2 Selector Page (Eff e (Promise Unit))
foreign import _waitForNavigation :: forall options e. FU.Fn2 options Page (Eff e (Promise Unit))
foreign import _getLocationHref :: forall e. FU.Fn1 Page (Eff e (Promise String))
foreign import _unsafeEvaluateStringFunction :: forall e. FU.Fn2 String Page (Eff e (Promise Foreign))
