module Test.Main where

import Prelude

import Data.Maybe (Maybe(..), isJust)
import Data.String as String
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Ref as Ref
import Effect.Uncurried as EU
import Foreign (unsafeFromForeign)
import Node.Process (cwd)
import Test.Unit (suite, test)
import Test.Unit.Assert as Assert
import Test.Unit.Main (runTest)
import Toppokki as T

main :: Effect Unit
main = do
  dir <- liftEffect cwd
  tests dir

tests :: String -> Effect Unit
tests dir = runTest do
  suite "toppokki" do
    let crashUrl = T.URL $ "file://" <> dir <> "/test/crash.html"
        testUrl = T.URL $ "file://" <> dir <> "/test/test.html"

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

    test "can run functions against a single element in the page" do
      browser <- T.launch {}
      page <- T.newPage browser
      T.goto testUrl page
      innerTextF <- T.unsafePageEval
        (T.Selector ".eval-one")
        "el => el.innerText"
        page
      let innerText = (unsafeFromForeign innerTextF) :: String
      Assert.equal "abc" innerText
      T.close browser

    test "can run functions against elements in the page" do
      browser <- T.launch {}
      page <- T.newPage browser
      T.goto testUrl page
      innerTextsF <- T.unsafePageEvalAll
        (T.Selector ".eval-many")
        "els => els.map(e => e.innerText)"
        page
      let innerTexts = (unsafeFromForeign innerTextsF) :: Array String
      Assert.equal ["abc","def"] innerTexts
      T.close browser
