module Toppokki.Inject
       ( InjectedAff
       , inject
       , injectEffect
       , injectPure
       )
where

import Control.Promise (fromAff, Promise)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Unsafe (unsafePerformEffect)
import Prelude (pure, (>>>), Unit)

-- | InjectedAff is a `Promise` executing in the browser.
newtype InjectedAff r = InjectedAff (Unit -> Promise r)

inject :: forall r. Aff r -> InjectedAff r
inject aff = InjectedAff (\_ -> unsafePerformEffect (fromAff aff))

injectEffect :: forall r. Effect r -> InjectedAff r
injectEffect = liftEffect >>> inject

injectPure :: forall r. r -> InjectedAff r
injectPure = pure >>> inject
