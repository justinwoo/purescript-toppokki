module Test.Main where

import Control.Monad.Except (runExcept)
import Data.Array as A
import Data.Array.ST as DAST
import Data.Bifunctor (lmap)
import Data.Either (Either(..), isLeft)
import Data.Maybe (Maybe(..), isJust, isNothing)
import Data.Newtype (wrap)
import Data.String as String
import Data.Traversable (for_, sequence)
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Aff (attempt, message, try)
import Effect.Class (liftEffect)
import Effect.Ref as Ref
import Effect.Uncurried as EU
import Foreign as F
import Node.Process (cwd)
import Prelude
import Test.Unit (suite, test)
import Test.Unit.Assert as Assert
import Test.Unit.Main (runTest)
import Toppokki as T
import Toppokki.Inject (inject, injectEffect, injectPure)
import Toppokki.Unsafe as Unsafe
import Web.DOM.Element (className, tagName, toParentNode)
import Web.DOM.Node as WDN
import Web.DOM.NodeList as WDNL
import Web.DOM.ParentNode (querySelectorAll)
import Web.HTML (window)
import Web.HTML.HTMLDocument (title)
import Web.HTML.Window (document)

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
      _ <- T.waitForSelector (wrap "h1") {} page
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

    test "can use `query`" do
      browser <- T.launch {}
      page <- T.newPage browser
      T.goto crashUrl page
      unique <- T.query (wrap "#unique") page
      Assert.assert "`query` finds element by selector" (isJust unique)
      nonexistent <- T.query (wrap "#nonexistent") page
      Assert.assert "`query` does not find nonexistent element" (isNothing nonexistent)
      invalidResult <- attempt $ T.query (wrap "invalid!") page
      Assert.assert "`queryMany` throws on invalid selector" (isLeft invalidResult)

      let message = "`query` is able to query `ElementHandle`s"
      T.query (wrap "#outer-container") page >>= case _ of
        Nothing -> Assert.assert message false
        Just outer -> do
          T.query (wrap "#middle-container") outer >>= case _ of
            Nothing -> Assert.assert message false
            Just middle -> do
              inner <- T.query (wrap "#inner-container") middle
              Assert.assert message (isJust inner)
      T.close browser

    test "can use `queryMany`" do
      browser <- T.launch {}
      page <- T.newPage browser
      T.goto crashUrl page
      somethings <- T.queryMany (wrap ".something") page
      Assert.assert
        "`queryMany` finds elements by selector"
        (A.length somethings == 3)
      nothings <- T.queryMany (wrap ".nothing") page
      Assert.assert
        "`queryMany` finds elements by selector"
        (A.length nothings == 0)
      invalidResult <- attempt $ T.queryMany (wrap "invalid!") page
      Assert.assert
        "`queryMany` throws on invalid selector"
        (isLeft invalidResult)
      T.close browser

    test "can use `queryEvalViaBrowserify`" do
      browser <- T.launch {}
      page <- T.newPage browser
      T.goto crashUrl page
      text <- F.unsafeFromForeign <$> Unsafe.queryEvalViaBrowserify (wrap "#unique")
              (\elem -> inject $ pure $ tagName elem)
              page
      Assert.assert "`queryEvalViaBrowserify` works" (text == "SPAN")

      maybeNonExistent <- attempt $ Unsafe.queryEvalViaBrowserify (wrap "#nonexistent")
                                    (\elem -> inject $ pure $ tagName elem)
                                    page
      Assert.assert
        "`queryEvalViaBrowserify` fails on non-existent elements"
        (isLeft maybeNonExistent)

      invalidResult <- attempt $ Unsafe.queryEvalViaBrowserify (wrap "invalid!")
                                 (injectPure <<< const 0)
                                 page
      Assert.assert
        "`queryEvalViaBrowserify` throws on invalid selector"
        (isLeft invalidResult)

      T.close browser

    test "can use `queryEvalManyViaBrowserify`" do
      browser <- T.launch {}
      page <- T.newPage browser
      T.goto crashUrl page

      tagNames <- F.unsafeFromForeign <$> Unsafe.queryEvalManyViaBrowserify
                  (wrap ".something")
                  (\elems -> injectEffect $ sequence $ map className elems)
                  page
      Assert.assert
        "`queryEvalManyViaBrowserify` works"
        (tagNames == ["something", "something", "something"])

      nonexistentCount <- F.unsafeFromForeign <$> Unsafe.queryEvalManyViaBrowserify
                          (wrap "#nonexistent")
                          (\elems -> inject $ pure $ A.length elems)
                          page
      Assert.assert
        "`queryEvalViaBrowserifyMany` does not fail on non-existent elements"
        (nonexistentCount == 0)

      invalidResult <- attempt $ Unsafe.queryEvalManyViaBrowserify (wrap "invalid!")
                                 (\_ -> injectPure 0)
                                 page
      Assert.assert
        "`queryEvalViaBrowserify` throws on invalid selector"
        (isLeft invalidResult)

      T.close browser

    test "can use `_jsReflect`" do
      browser <- T.launch {}
      page <- T.newPage browser
      T.goto crashUrl page

      value1 <- F.unsafeFromForeign <$> Unsafe.queryEvalManyViaBrowserify (wrap "#unique")
                (\elems -> inject do
                    let res1 = "val"
                    let res2 = "ue1"
                    pure $ res1 <> res2)
                page
      Assert.assert
        "`_jsReflect` does not break with local variable bindings"
        (value1 == "value1")

      value2 <- F.unsafeFromForeign <$> Unsafe.queryEvalViaBrowserify (wrap "#unique")
                (\_ -> inject do
                    let res = \x -> x
                    pure (res "value2"))
                page
      Assert.assert
        "`_jsReflect` does not break with local function definitions"
        (value2 == "value2")

      -- A complex example
      len1 <- F.unsafeFromForeign <$> Unsafe.queryEvalViaBrowserify (wrap "body")
              (\body -> injectEffect do
                  nodeArray <- (querySelectorAll (wrap "*") >=> WDNL.toArray)
                               (toParentNode body)
                  taggedNodes <- sequence $
                    nodeArray <#> \node ->
                    WDN.hasChildNodes node <#> \hasChildren ->
                    Tuple hasChildren node
                  pure $ A.length $ DAST.run do
                    ref <- DAST.empty
                    for_ taggedNodes
                      (\(Tuple hasChildren node) ->
                        when hasChildren do
                          void (DAST.push 0 ref))
                    pure ref)
              page
      len2 <- F.unsafeFromForeign <$> Unsafe.queryEvalManyViaBrowserify (wrap "* > * *")
              (injectPure <<< A.length)
              page
      Assert.assert
        ("`_jsReflect`: a complex example (" <>
         show len1 <> ", " <> show len2 <> ")")
        (len1 + 1 == len2) -- +1 for <body> itself

      T.close browser

    test "can use `unsafeEvaluate`" do
      browser <- T.launch {}
      page <- T.newPage browser
      T.goto crashUrl page

      title1 <- F.unsafeFromForeign <$> Unsafe.evalViaBrowserify page
                (\_ -> injectEffect (window >>= document >>= title))

      failing1 <- (map <<< map) F.unsafeFromForeign <$> try $ Unsafe.evalViaBrowserify page
                  (injectEffect <<< const (window >>= document >>= title))

      failing2 <- (map <<< map) F.unsafeFromForeign <$> try $ Unsafe.evalViaBrowserify page
                  (const (injectEffect (window >>= document >>= title)))

      Assert.assert
        ("point-free style is forbidden #0")
        ((lmap message failing1 :: Either String String) ==
         Left ("Toppokki internal error: are you trying to use " <>
               "point-free style in a callback function?  (see " <>
               "docs/unsafe.md)"))

      Assert.assert
        ("point-free style is forbidden #1")
        ((lmap message failing2 :: Either String String) ==
         Left ("Toppokki internal error: are you trying to use " <>
               "point-free style in a callback function?  (see " <>
               "docs/unsafe.md)"))

      Assert.assert
        ("can get window title using `evalViaBrowserify`" <> title1)
        (title1 == "Page Title")

      T.close browser
