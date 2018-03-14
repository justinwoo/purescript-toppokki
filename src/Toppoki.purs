module Toppokki where

import Prelude

import Control.Monad.Aff (Aff)
import Control.Monad.Eff (Eff)
import Control.Promise (Promise)
import Control.Promise as Promise
import Data.Function.Uncurried as FU
import Data.Newtype (class Newtype)
import Node.Buffer (Buffer)
import Unsafe.Coerce (unsafeCoerce)

foreign import data Puppeteer :: Type
foreign import data Browser :: Type
foreign import data Page :: Type

newtype URL = URL String
derive instance newtypeURL :: Newtype URL _

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

foreign import puppeteer :: Puppeteer
foreign import _launch :: forall e. Eff e (Promise Browser)
foreign import _newPage :: forall e. FU.Fn1 Browser (Eff e (Promise Page))
foreign import _goto :: forall e. FU.Fn2 URL Page (Eff e (Promise Unit))
foreign import _close :: forall e. FU.Fn1 Browser (Eff e (Promise Unit))
foreign import _content :: forall e. FU.Fn1 Page (Eff e (Promise String))
foreign import _screenshot :: forall options e. FU.Fn2 options Page (Eff e (Promise Buffer))
foreign import _pdf :: forall options e. FU.Fn2 options Page (Eff e (Promise Buffer))
