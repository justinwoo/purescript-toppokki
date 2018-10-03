# PureScript-Toppokki

[![Build Status](https://dev.azure.com/justinw2/justin-project/_apis/build/status/justinwoo.purescript-toppokki)](https://dev.azure.com/justinw2/justin-project/_build/latest?definitionId=3)

A binding to [puppeteer](https://github.com/GoogleChrome/puppeteer) to drive headless Chrome.

This module is "incomplete", and you can help by submitting PRs. You may find that `goto`, `pageWaitForSelector`, `click`, and `unsafeEvaluateStringFunction` already provide the functionality you need.

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

## More examples

You might also find this example from the [vidtracker](https://github.com/justinwoo/vidtracker/blob/37c511ed82f209e0236147399e8a91999aaf754c/src/GetIcons.purs) project useful:

```hs
downloadIconIfNotExist :: T.Browser -> Set String -> String -> Aff Unit
downloadIconIfNotExist browser existing name =
  unless (member name existing) do
    page <- T.newPage browser
    let
      name' = S.replace (S.Pattern " ") (S.Replacement "+") name
      pageURL = "https://duckduckgo.com/?iax=images&ia=images&q=" <> name' <> "+anime+wiki"
    T.goto (T.URL pageURL) page
    _ <- T.pageWaitForSelector (T.Selector ".tile--img__img") {} page
    result <- T.unsafeEvaluateStringFunction "document.querySelector('.tile--img__img').src" page
    case JSON.read result of
      Right (url :: String) -> do
        log $ "downloading from " <> url
        curl url (iconsPath <> "/" <> name)
        pure unit
      Left e -> do
        log $ "could not handle " <> name <> " with url " <> pageURL
```
