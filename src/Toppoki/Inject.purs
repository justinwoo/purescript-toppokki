module Toppoki.Inject
       ( InjectedAff
       , inject
       , injectEffect
       , injectPure
       )
where

import Control.Promise as Promise
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Unsafe (unsafePerformEffect)
import Prelude (pure, (>>>))
import Unsafe.Coerce (unsafeCoerce)

-- | InjectedAff is a `Promise` executing in the browser.
foreign import data InjectedAff :: Type -> Type

inject :: forall r. Aff r -> InjectedAff r
inject = Promise.fromAff >>> unsafePerformEffect >>> unsafeCoerce

injectEffect :: forall r. Effect r -> InjectedAff r
injectEffect = liftEffect >>> inject

injectPure :: forall r. r -> InjectedAff r
injectPure = pure >>> inject
