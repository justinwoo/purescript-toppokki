# PureScript-Toppokki

[![Build Status](https://travis-ci.org/justinwoo/purescript-toppokki.svg?branch=master)](https://travis-ci.org/justinwoo/purescript-toppokki)

A binding to [puppeteer](https://github.com/GoogleChrome/puppeteer) to drive headless Chrome.

This module is incomplete, and you can help by submitting PRs.

Named for glorious Tteok-bokki.

![](https://i.imgur.com/KPSU9lY.png)

## Usage

Make sure [Puppeteer](https://github.com/GoogleChrome/puppeteer) is installed (e.g. `npm i puppeteer`).

```hs
module Main where

import Toppokki as T
import Prelude (bind, discard, (>))
import Effect.Aff (launchAff_)
import Test.Unit.Assert as Assert
import Data.String as String

main = launchAff_ do
  browser <- T.launch {}
  page <- T.newPage browser
  T.goto (T.URL "https://example.com") page
  content <- T.content page
  Assert.assert "content is non-empty string" (String.length content > 0)
  _ <- T.screenshot {path: "./test/test.png"} page
  _ <- T.pdf {path: "./test/test.pdf"} page
  T.close browser
```
