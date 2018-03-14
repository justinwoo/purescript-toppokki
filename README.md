# PureScript-Toppokki

A binding to [puppeteer](https://github.com/GoogleChrome/puppeteer) to drive headless Chrome.

This module is incomplete, and you can help by submitting PRs.

Named for glorious Tteok-bokki.

![](https://i.imgur.com/KPSU9lY.png)

## Usage

```hs
import Toppokki as T

main = launchAff_ do
  browser <- T.launch
  page <- T.newPage browser
  T.goto (T.URL "https://example.com") page
  content <- T.content page
  Assert.assert "content is non-empty string" (String.length content > 0)
  _ <- T.screenshot {path: "./test/test.png"} page
  _ <- T.pdf {path: "./test/test.pdf"} page
  T.close browser
```
