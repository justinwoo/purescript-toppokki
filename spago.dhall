{ sources = [ "src/**/*.purs", "test/**/*.purs" ]
, name = "toppokki"
, dependencies =
  [ "aff-promise"
  , "functions"
  , "milkis"
  , "node-buffer"
  , "node-fs-aff"
  , "node-http"
  , "node-process"
  , "prelude"
  , "record"
  , "test-unit"
  ]
, packages = ./packages.dhall
}
