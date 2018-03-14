module Test.Main where

import Prelude

import Data.String as String
import Test.Unit (suite, test)
import Test.Unit.Assert as Assert
import Test.Unit.Main (runTest)
import Toppokki as T

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
