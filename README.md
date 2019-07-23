# PureScript-Toppokki

[![Build Status](https://dev.azure.com/justinw2/justin-project/_apis/build/status/justinwoo.purescript-toppokki)](https://dev.azure.com/justinw2/justin-project/_build/latest?definitionId=3)

A binding to [puppeteer](https://github.com/GoogleChrome/puppeteer) to drive headless Chrome.

This module is "incomplete" (but useful for regular work projects), and you can help by submitting PRs. You may find that `goto`, `waitForSelector`, `click`, and `unsafeEvaluateStringFunction` already provide the functionality you need.

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
    _ <- T.waitForSelector (T.Selector ".tile--img__img") {} page
    result <- T.unsafeEvaluateStringFunction "document.querySelector('.tile--img__img').src" page
    case JSON.read result of
      Right (url :: String) -> do
        log $ "downloading from " <> url
        curl url (iconsPath <> "/" <> name)
        pure unit
      Left e -> do
        log $ "could not handle " <> name <> " with url " <> pageURL
```

## API

Check out [the docs for `unsafe*` functions](docs/unsafe.md) before you use them.

### class: Puppeteer

| puppeteer                       | Toppokki |                   |        |
|---------------------------------|----------|-------------------|--------|
| connect(options)                |          |                   |        |
| createBrowserFetcher([options]) |          |                   |        |
| defaultArgs([options])          |          |                   |        |
| executablePath()                |          | launch([options]) | launch |
|                                 |          |                   |        |


### class: BrowserFetcher

| puppeteer                              | Toppokki |
|----------------------------------------|----------|
| canDownload(revision)                  |          |
| download(revision[, progressCallback]) |          |
| localRevisions()                       |          |
| platform()                             |          |
| remove(revision)                       |          |
| revisionInfo(revision)                 |          |

### class: Browser

| puppeteer                           | Toppokki |
|-------------------------------------|----------|
| event: 'disconnected'               |          |
| event: 'targetchanged'              |          |
| event: 'targetcreated'              |          |
| event: 'targetdestroyed'            |          |
| browserContexts()                   |          |
| close()                             | close    |
| xcreateIncognitoBrowserContext()    |          |
| defaultBrowserContext()             |          |
| disconnect()                        |          |
| newPage()                           | newPage  |
| pages()                             |          |
| process()                           |          |
| target()                            |          |
| targets()                           |          |
| userAgent()                         |          |
| version()                           |          |
| waitForTarget(predicate[, options]) |          |
| wsEndpoint()                        |          |

### class: BrowserContext

| puppeteer                                | Toppokki |
|------------------------------------------|----------|
| event: 'targetchanged'                   |          |
| event: 'targetcreated'                   |          |
| event: 'targetdestroyed'                 |          |
| browser()                                |          |
| clearPermissionOverrides()               |          |
| close()                                  |          |
| isIncognito()                            |          |
| newPage()                                |          |
| overridePermissions(origin, permissions) |          |
| pages()                                  |          |
| targets()                                |          |
| waitForTarget(predicate[, options])      |          |

### class: Page

| puppeteer                                                  | Toppokki                                     |
|------------------------------------------------------------|----------------------------------------------|
| event: 'close'                                             |                                              |
| event: 'console'                                           |                                              |
| event: 'dialog'                                            |                                              |
| event: 'domcontentloaded'                                  |                                              |
| event: 'error'                                             |                                              |
| event: 'frameattached'                                     |                                              |
| event: 'framedetached'                                     |                                              |
| event: 'framenavigated'                                    |                                              |
| event: 'load'                                              |                                              |
| event: 'metrics'                                           |                                              |
| event: 'pageerror'                                         |                                              |
| event: 'popup'                                             |                                              |
| event: 'request'                                           |                                              |
| event: 'requestfailed'                                     |                                              |
| event: 'requestfinished'                                   |                                              |
| event: 'response'                                          |                                              |
| event: 'workercreated'                                     |                                              |
| event: 'workerdestroyed'                                   |                                              |
| $(selector)                                                | query                                        |
| $$(selector)                                               | queryMany                                    |
| $$eval(selector, pageFunction[, ...args])                  | unsafeQueryEvalMany                          |
| $eval(selector, pageFunction[, ...args])                   | unsafeQueryEval                              |
| $x(expression)                                             |                                              |
| accessibility                                              |                                              |
| addScriptTag(options)                                      |                                              |
| addStyleTag(options)                                       |                                              |
| authenticate(credentials)                                  |                                              |
| bringToFront()                                             |                                              |
| browser()                                                  |                                              |
| browserContext()                                           |                                              |
| click(selector[, options])                                 | click                                        |
| close([options])                                           |                                              |
| content()                                                  | content                                      |
| cookies([...urls])                                         |                                              |
| coverage                                                   |                                              |
| deleteCookie(...cookies)                                   |                                              |
| emulate(options)                                           |                                              |
| emulateMedia(mediaType)                                    |                                              |
| evaluate(pageFunction[, ...args])                          | unsafeEvaluate, unsafeEvaluateStringFunction |
| evaluateHandle(pageFunction[, ...args])                    |                                              |
| evaluateOnNewDocument(pageFunction[, ...args])             |                                              |
| exposeFunction(name, puppeteerFunction)                    |                                              |
| focus(selector)                                            | focus                                        |
| frames()                                                   |                                              |
| goBack([options])                                          |                                              |
| goForward([options])                                       |                                              |
| goto(url[, options])                                       | goto                                         |
| hover(selector)                                            |                                              |
| isClosed()                                                 |                                              |
| keyboard                                                   |                                              |
| mainFrame()                                                |                                              |
| metrics()                                                  |                                              |
| mouse                                                      |                                              |
| pdf([options])                                             | pdf                                          |
| queryObjects(prototypeHandle)                              |                                              |
| reload([options])                                          |                                              |
| screenshot([options])                                      | screenshot                                   |
| select(selector, ...values)                                |                                              |
| setBypassCSP(enabled)                                      |                                              |
| setCacheEnabled([enabled])                                 |                                              |
| setContent(html[, options])                                |                                              |
| setCookie(...cookies)                                      |                                              |
| setDefaultNavigationTimeout(timeout)                       |                                              |
| setDefaultTimeout(timeout)                                 |                                              |
| setExtraHTTPHeaders(headers)                               |                                              |
| setGeolocation(options)                                    |                                              |
| setJavaScriptEnabled(enabled)                              |                                              |
| setOfflineMode(enabled)                                    |                                              |
| setRequestInterception(value)                              |                                              |
| setUserAgent(userAgent)                                    |                                              |
| setViewport(viewport)                                      | setViewport                                  |
| tap(selector)                                              |                                              |
| target()                                                   |                                              |
| title()                                                    | title                                        |
| touchscreen                                                |                                              |
| tracing                                                    |                                              |
| type(selector, text[, options])                            |                                              |
| url()                                                      |                                              |
| viewport()                                                 |                                              |
| waitFor(selectorOrFunctionOrTimeout[, options[, ...args]]) |                                              |
| waitForFunction(pageFunction[, options[, ...args]])        |                                              |
| waitForNavigation([options])                               | waitForNavigation                            |
| waitForRequest(urlOrPredicate[, options])                  |                                              |
| waitForResponse(urlOrPredicate[, options])                 |                                              |
| waitForSelector(selector[, options])                       | waitForSelector                              |
| waitForXPath(xpath[, options])                             |                                              |
| workers()                                                  |                                              |

### class: Worker

| puppeteer                               | Toppokki       |
|-----------------------------------------|----------------|
| evaluate(pageFunction[, ...args])       | unsafeEvaluate |
| evaluateHandle(pageFunction[, ...args]) |                |
| executionContext()                      |                |
| url()                                   |                |

### class: Accessibility

| puppeteer           | Toppokki |
|---------------------|----------|
| snapshot([options]) |          |

### class: Keyboard

| puppeteer             | Toppokki |
|-----------------------|----------|
| down(key[, options])  |          |
| press(key[, options]) |          |
| sendCharacter(char)   |          |
| type(text[, options]) |          |
| up(key)               |          |

### class: Mouse

| puppeteer              | Toppokki |
|------------------------|----------|
| click(x, y[, options]) |          |
| down([options])        |          |
| move(x, y[, options])  |          |
| up([options])          |          |

### class: Touchscreen

| puppeteer | Toppokki |
|-----------|----------|
| tap(x, y) |          |
|           |          |

### class: Tracing

| puppeteer      | Toppokki |
|----------------|----------|
| start(options) |          |
| stop()         |          |

### class: Dialog

| puppeteer            | Toppokki |
|----------------------|----------|
| accept([promptText]) |          |
| defaultValue()       |          |
| dismiss()            |          |
| message()            |          |
| type()               |          |

### class: ConsoleMessage

| puppeteer  | Toppokki |
|------------|----------|
| args()     |          |
| location() |          |
| text()     |          |
| type()     |          |

### class: Frame

| puppeteer                                                  | Toppokki            |
|------------------------------------------------------------|---------------------|
| $(selector)                                                | query               |
| $$(selector)                                               | queryMany           |
| $$eval(selector, pageFunction[, ...args])                  | unsafeQueryEvalMany |
| $eval(selector, pageFunction[, ...args])                   | unsafeQueryEval     |
| $x(expression)                                             |                     |
| addScriptTag(options)                                      |                     |
| addStyleTag(options)                                       |                     |
| childFrames()                                              |                     |
| click(selector[, options])                                 |                     |
| content()                                                  |                     |
| evaluate(pageFunction[, ...args])                          | unsafeEvaluate      |
| evaluateHandle(pageFunction[, ...args])                    |                     |
| executionContext()                                         |                     |
| focus(selector)                                            |                     |
| goto(url[, options])                                       |                     |
| hover(selector)                                            |                     |
| isDetached()                                               |                     |
| name()                                                     |                     |
| parentFrame()                                              |                     |
| select(selector, ...values)                                |                     |
| setContent(html[, options])                                |                     |
| tap(selector)                                              |                     |
| title()                                                    |                     |
| type(selector, text[, options])                            |                     |
| url()                                                      |                     |
| waitFor(selectorOrFunctionOrTimeout[, options[, ...args]]) |                     |
| waitForFunction(pageFunction[, options[, ...args]])        |                     |
| waitForNavigation([options])                               |                     |
| waitForSelector(selector[, options])                       | waitForSelector     |
| waitForXPath(xpath[, options])                             |                     |

### class: ExecutionContext

| puppeteer                               | Toppokki       |
|-----------------------------------------|----------------|
| evaluate(pageFunction[, ...args])       | unsafeEvaluate |
| evaluateHandle(pageFunction[, ...args]) |                |
| frame()                                 |                |
| queryObjects(prototypeHandle)           |                |

### class: JSHandle

| puppeteer                 | Toppokki |
|---------------------------|----------|
| asElement()               |          |
| dispose()                 |          |
| executionContext()        |          |
| getProperties()           |          |
| getProperty(propertyName) |          |
| jsonValue()               |          |

### class: ElementHandle

| puppeteer                                 | Toppokki            |
|-------------------------------------------|---------------------|
| $(selector)                               | query               |
| $$(selector)                              | queryMany           |
| $$eval(selector, pageFunction[, ...args]) | unsafeQueryEvalMany |
| $eval(selector, pageFunction[, ...args])  | unsafeQueryEval     |
| $x(expression)                            |                     |
| asElement()                               |                     |
| boundingBox()                             |                     |
| boxModel()                                |                     |
| click([options])                          |                     |
| contentFrame()                            |                     |
| dispose()                                 |                     |
| executionContext()                        |                     |
| focus()                                   |                     |
| getProperties()                           |                     |
| getProperty(propertyName)                 |                     |
| hover()                                   |                     |
| isIntersectingViewport()                  |                     |
| jsonValue()                               |                     |
| press(key[, options])                     |                     |
| screenshot([options])                     |                     |
| tap()                                     |                     |
| toString()                                |                     |
| type(text[, options])                     |                     |
| uploadFile(...filePaths)                  |                     |

### class: Request

| puppeteer             | Toppokki |
|-----------------------|----------|
| abort([errorCode])    |          |
| continue([overrides]) |          |
| failure()             |          |
| frame()               |          |
| headers()             |          |
| isNavigationRequest() |          |
| method()              |          |
| postData()            |          |
| redirectChain()       |          |
| resourceType()        |          |
| respond(response)     |          |
| response()            |          |
| url()                 |          |

### class: Response

| puppeteer           | Toppokki |
|---------------------|----------|
| buffer()            |          |
| frame()             |          |
| fromCache()         |          |
| fromServiceWorker() |          |
| headers()           |          |
| json()              |          |
| ok()                |          |
| remoteAddress()     |          |
| request()           |          |
| securityDetails()   |          |
| status()            |          |
| statusText()        |          |
| text()              |          |
| url()               |          |

### class: SecurityDetails

| puppeteer     | Toppokki |
|---------------|----------|
| issuer()      |          |
| protocol()    |          |
| subjectName() |          |
| validFrom()   |          |
| validTo()     |          |

### class: Target

| puppeteer          | Toppokki |
|--------------------|----------|
| browser()          |          |
| browserContext()   |          |
| createCDPSession() |          |
| opener()           |          |
| page()             |          |
| type()             |          |
| url()              |          |

### class: CDPSession

| puppeteer              | Toppokki |
|------------------------|----------|
| detach()               |          |
| send(method[, params]) |          |

### class: Coverage

| puppeteer                   | Toppokki |
|-----------------------------|----------|
| startCSSCoverage([options]) |          |
| startJSCoverage([options])  |          |
| stopCSSCoverage()           |          |
| stopJSCoverage()            |          |

### class: TimeoutError
