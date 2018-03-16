module Test.Main where

import Prelude

import Control.Monad.Aff (launchAff_, makeAff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Ref (newRef, readRef, writeRef)
import Control.Monad.Eff.Uncurried as EU
import Data.Maybe (Maybe(..), isJust)
import Data.Monoid (mempty)
import Data.String as String
import Node.Process (cwd)
import Test.Unit (suite, test)
import Test.Unit.Assert as Assert
import Test.Unit.Main (runTest)
import Toppokki as T

gotoAndLoad' url page aff = makeAff \cb -> do
  T.onLoad (EU.mkEffFn1 \_ -> launchAff_ do
    aff
    liftEff $ cb $ pure unit
    ) page
  launchAff_ $ T.goto url page
  pure mempty

main :: _
main = runTest do
  suite "toppokki" do

    test "can screenshot and pdf output a loaded page" do
      browser <- T.launch
      page <- T.newPage browser
      T.goto (T.URL "https://example.com") page
      content <- T.content page
      Assert.assert "content is non-empty string" (String.length content > 0)
      _ <- T.screenshot {path: "./test/test.png"} page
      _ <- T.pdf {path: "./test/test.pdf"} page
      T.close browser

    test "can listen for errors and page load" do
      browser <- T.launch
      page <- T.newPage browser
      dir <- liftEff cwd
      let url = T.URL
              $ "file://"
             <> dir
             <> "/test/crash.html"
      ref <- liftEff $ newRef Nothing
      liftEff $ T.onPageError (EU.mkEffFn1 $ writeRef ref <<< Just) page
      gotoAndLoad' url page do
        value <- liftEff $ readRef ref
        Assert.assert "error occurs from crash.html" $ isJust value
        T.close browser

    test "can wait for selectors" do
      browser <- T.launch
      page <- T.newPage browser
      dir <- liftEff cwd
      let url = T.URL
              $ "file://"
             <> dir
             <> "/test/crash.html"
      ref <- liftEff $ newRef Nothing
      liftEff $ T.onPageError (EU.mkEffFn1 $ writeRef ref <<< Just) page
      T.goto (T.URL "https://example.com") page
      _ <- T.pageWaitForSelector (T.Selector "h1") {} page
      T.close browser
