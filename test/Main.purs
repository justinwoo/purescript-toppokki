module Test.Main where

import Prelude

import Data.Maybe (Maybe(..), isJust)
import Data.String as String
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Ref as Ref
import Effect.Uncurried as EU
import Node.Process (cwd)
import Test.Unit (suite, test)
import Test.Unit.Assert as Assert
import Test.Unit.Main (runTest)
import Toppokki as T
import Foreign as F
import Control.Monad.Except (runExcept)
import Data.Either (Either(..))

main :: Effect Unit
main = do
  dir <- liftEffect cwd
  tests dir

tests :: String -> Effect Unit
tests dir = runTest do
  suite "toppokki" do
    let crashUrl = T.URL
            $ "file://"
           <> dir
           <> "/test/crash.html"

    test "can screenshot and pdf output a loaded page" do
      browser <- T.launch {}
      page <- T.newPage browser
      T.goto crashUrl page
      content <- T.content page
      Assert.assert "content is non-empty string" (String.length content > 0)
      _ <- T.screenshot {path: "./test/test.png"} page
      _ <- T.pdf {path: "./test/test.pdf"} page
      T.close browser

    test "can listen for errors and page load" do
      browser <- T.launch {}
      page <- T.newPage browser
      ref <- liftEffect $ Ref.new Nothing
      liftEffect $ T.onPageError (EU.mkEffectFn1 $ (Ref.write <@> ref) <<< Just) page
      T.goto crashUrl page
      value <- liftEffect $ Ref.read ref
      Assert.assert "error occurs from crash.html" $ isJust value
      T.close browser

    test "can wait for selectors" do
      browser <- T.launch {}
      page <- T.newPage browser
      ref <- liftEffect $ Ref.new Nothing
      liftEffect $ T.onPageError (EU.mkEffectFn1 $ (Ref.write <@> ref) <<< Just) page
      T.goto crashUrl page
      _ <- T.pageWaitForSelector (T.Selector "h1") {} page
      T.close browser

    test "can get page title" do
      browser <- T.launch {}
      page <- T.newPage browser
      T.goto crashUrl page
      title <- T.title page
      Assert.assert "page title is correct" (title == "Page Title")
      T.close browser

    test "can set userAgent" do
      browser <- T.launch {}
      page <- T.newPage browser
      T.goto crashUrl page
      let customUserAgent = "Custom user agent"
      T.setUserAgent (T.UserAgent customUserAgent) page
      ua <- runExcept <$> F.readString <$>
            T.unsafeEvaluateStringFunction "navigator.userAgent" page
      Assert.assert "user agent is set" (Right customUserAgent == ua)
      T.close browser

    test "can set viewport" do
      browser <- T.launch {}
      page <- T.newPage browser
      T.goto crashUrl page
      T.setViewport { width: 100
                    , height: 200
                    , isMobile: false
                    , deviceScaleFactor: 1.0
                    , hasTouch: false
                    , isLandscape: false } page
      iw <- runExcept <$> F.readInt <$>
            T.unsafeEvaluateStringFunction "window.innerWidth" page
      ih <- runExcept <$> F.readInt <$>
            T.unsafeEvaluateStringFunction "window.innerHeight" page
      Assert.assert "viewport is correct" (Right 100 == iw && Right 200 == ih)
      T.close browser
