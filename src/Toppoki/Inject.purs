module Toppoki.Inject where

import Effect.Aff (Aff)
import Effect.Unsafe (unsafePerformEffect)
import Prelude ((>>>))
import Unsafe.Coerce (unsafeCoerce)
import Control.Promise as Promise

foreign import data InjectedAff :: Type -> Type

inject :: forall r. Aff r -> InjectedAff r
inject = Promise.fromAff >>> unsafePerformEffect >>> unsafeCoerce
