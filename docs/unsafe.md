# unsafe* functions

`unsafeQueryEval`, `unsafeQueryEvalMany` and `unsafeEvaluate` are direct bindings to [`.$eval`](https://github.com/GoogleChrome/puppeteer/blob/master/docs/api.md#frameevalselector-pagefunction-args-1), [`.$$eval`](https://github.com/GoogleChrome/puppeteer/blob/master/docs/api.md#frameevalselector-pagefunction-args) and [`.evaluate`](https://github.com/GoogleChrome/puppeteer/blob/master/docs/api.md#pageevaluatepagefunction-args) methods, respectively.

In JS, you are supposed to write something like this:

```javascript
await page.$$eval(
  '.my-class',
  els => els.map(el => el.tagName)
);
```

Function passed as the second argument will be executed within the browser context. That is, it is impossible to reference variables from outside of the browser's global scope, e.g. this code will throw:

```javascript
var local = true;
await page.$$eval(
  '.my-class',
  () => {
    if (typeof local == 'undefined') {
      throw new Error();
    }
  }
);
```

This is the reason why PS bindings to functions like `$$eval` can't be implemented in a straightforward way: PureScript runtime itself will be erased during context switch.

In this library these limitations are bypassed by inspecting given function's code and inserting all the necessary runtime dependencies using `browserify` before actually passing the function as a callback.

`Toppoki.js` defines `_jsReflect :: forall a. a -> Effect (Promise String)`, which is not exported. This function accepts a purescript value and returns its bundled equivalent which can be injected into the browser. Let's see how it is possible.

Suppose we want to get a tag name of the first element matching a given selector.

It can be done by passing `\elem -> injectPure $ tagName elem` to `unsafeQueryEval` (where `injectPure` is from `Toppoki.Inject`).

`_jsReflect` will first retrieve a runtime representation of the given function using `Function.prototype.toString`:

```javascript
function (elem) {
  return Toppoki_Inject.inject(
    Control_Applicative.pure(Effect_Aff.applicativeAff)(Web_DOM_Element.tagName(elem))
  );
}
```

Then it will extract free variables' names using  `extractDefinitions`:

```javascript
[ 'Toppoki_Inject',
  'Control_Applicative',
  'Effect_Aff',
  'Web_DOM_Element' ]
```

(`extractDefinitions` uses `TreeWalker` from `uglify-js` to traverse the AST).

After that, it will trivially map these names to subdirectories of `./output/`, generate some wrapping code and feed it to `browserify`.

Finally, browserify output is used to constuct a new function that can be safely converted to a string and passed to the browser runtime.

## Cautions

Of course this method is not perfect since it relies on unsafe assumptions about the format in which `purs` outputs JS code. It may break someday, possibly without any chances to get it working again.

## Limitations

1. `browserify`ing is relatively slow.

2. Accessing purescript values defined locally is still impossible and will result in a runtime error (this perfectly matches JS behavior). Only using what is directly imported from other modules is allowed.

3. Note that it is impossible to use `const` to hide unused argument in `unsafe*` callbacks.

```purescript
-- good
(\_ -> injectEffect
  (window >>= document >>= title))

-- bad
(const $ injectEffect
  (window >>= document >>= title))
```

It is clear why the latter does not work - because `Function.prototype.toString` returns the "inner part" of the `const` definition instead of the needed function. The following code may help to understand what's going on:

```
> var f = function (x) { return function(y) { return x; } } // `const` equivalent
> f.toString()
'function (x) { return function(y) { return x; } }'
> f(function(z) { return z; }).toString()
'function(y) { return x; }'
```

However, using `const` combined with `compose` is acceptable:

```purescript
(injectEffect <<< const (window >>= document >>= title))
```

There is a built-in detection of incorrect `const` usage (see `extractDefinitions`). When there are free variables which appear to be function parameters erased during evaluation, the user will see an error message:

> Toppokki internal error: are you trying to use point-free style in a callback function? (see docs/unsafe.md)
