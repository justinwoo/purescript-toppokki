module Toppokki where

import Prelude

import Control.Monad.Aff (Aff)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Exception (Error)
import Control.Monad.Eff.Uncurried as EU
import Control.Promise (Promise)
import Control.Promise as Promise
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

launch :: forall e. Aff e Browser
launch = Promise.toAffE _launch

newPage :: forall e. Browser -> Aff e Page
newPage = Promise.toAffE <<< FU.runFn1 _newPage

goto :: forall e. URL -> Page -> Aff e Unit
goto u p = Promise.toAffE $ FU.runFn2 _goto u p

close :: forall e. Browser -> Aff e Unit
close = Promise.toAffE <<< FU.runFn1 _close

content :: forall e. Page -> Aff e String
content = Promise.toAffE <<< FU.runFn1 _content

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
screenshot o p = Promise.toAffE $ FU.runFn2 _screenshot o p

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
pdf o p = Promise.toAffE $ FU.runFn2 _pdf o p

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
pageWaitForSelector s o p = Promise.toAffE $ FU.runFn3 _pageWaitForSelector s o p

focus :: forall e. Page -> Selector -> Aff e Unit
focus p s = Promise.toAffE $ FU.runFn2 _focus p s

type_
  :: forall options trash e
   . Union options trash
       ( delay :: Int
       )
  => Page
  -> String
  -> { | options }
  -> Aff e Unit
type_ p c o = Promise.toAffE $ FU.runFn3 _type p c o

click :: forall e. Page -> Selector -> Aff e Unit
click p s = Promise.toAffE $ FU.runFn2 _click p s

foreign import data WaitUntilOption :: Type

waitUntil :: WaitUntilOption
waitUntil = unsafeCoerce $ "networkidle"

waitForNavigation
  :: forall options trash e
   . Union options trash
       ( waitUntil :: String
       )
  => Page
  -> { | options }
  -> Aff e Unit
waitForNavigation p o = Promise.toAffE $ FU.runFn2 _waitForNavigation p o

getLocationRef :: forall e. Page -> Aff e Unit
getLocationRef p = Promise.toAffE $ FU.runFn1 _getLocationHref p

foreign import puppeteer :: Puppeteer
foreign import _launch :: forall e. Eff e (Promise Browser)
foreign import _newPage :: forall e. FU.Fn1 Browser (Eff e (Promise Page))
foreign import _goto :: forall e. FU.Fn2 URL Page (Eff e (Promise Unit))
foreign import _close :: forall e. FU.Fn1 Browser (Eff e (Promise Unit))
foreign import _content :: forall e. FU.Fn1 Page (Eff e (Promise String))
foreign import _screenshot :: forall options e. FU.Fn2 options Page (Eff e (Promise Buffer))
foreign import _pdf :: forall options e. FU.Fn2 options Page (Eff e (Promise Buffer))
foreign import _on :: forall a e. EU.EffFn3 e String (EU.EffFn1 e a Unit) Page Unit
foreign import _pageWaitForSelector :: forall options e. FU.Fn3 Selector options Page (Eff e (Promise ElementHandle))
foreign import _focus :: forall e. FU.Fn2 Page Selector (Eff e (Promise Unit))
foreign import _type :: forall options e. FU.Fn3 Page String options (Eff e (Promise Unit))
foreign import _click :: forall e. FU.Fn2 Page Selector (Eff e (Promise Unit))
foreign import _waitForNavigation :: forall options e. FU.Fn2 Page options (Eff e (Promise Unit))
foreign import _getLocationHref :: forall e. FU.Fn1 Page (Eff e (Promise Unit))
