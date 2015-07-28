module Test.Main where

import Prelude
import Node.SimpleRequest
import qualified Network.HTTP as HTTP
import Data.Options
import Control.Alt
import Control.Monad.Eff
import Control.Monad.Eff.Console
import Control.Monad.Eff.Class
import Control.Monad.Aff
import Control.Monad.Aff.Par

foreign import logAnything :: forall a e. a -> Eff (console :: CONSOLE | e) Unit

optHeaders :: Options SimpleRequestHeader
optHeaders = srHeader HTTP.UserAgent := "purescript-simple-request testing"

opts :: Opts
opts = hostname := "www.reddit.com"
    <> path     := "/.json"
    <> method   := HTTP.GET
    <> headers  := optHeaders

main = launchAff $ do
  res <- runPar (Par (get "http://www.reddit.com/.json") <|>
                      Par (request opts ""))
  liftEff $ logAnything res.body
