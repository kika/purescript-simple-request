module Test.Main where

import Prelude
import Debug.Trace as Debug

import Control.Monad.Aff as Aff
import Control.Monad.Aff.Console (log, logShow)
import Control.Monad.Eff.Console as Console
import Control.Monad.Eff.Class (liftEff)

import Data.Either (either)
import Data.Options ((:=))
import Data.Tuple.Nested ((/\))
import Data.String (length)

import Network.HTTP as HTTP

import Node.Encoding (Encoding(..))
import Node.SimpleRequest as SR
import Node.Buffer as Buffer

testOpts = SR.hostname := "www.reddit.com"
        <> SR.path := "/r/purescript"
        <> SR.method := HTTP.GET
        <> SR.protocol := SR.HTTPS
        <> SR.headers := SR.headersFromFoldable [HTTP.UserAgent /\ "purescript-simple-request testing"]

testPost = SR.hostname := "httpbin.org"
        <> SR.path := "/post"
        <> SR.method := HTTP.POST
        <> SR.protocol := SR.HTTP

testCookie = SR.hostname := "httpbin.org"
        <> SR.path := "/cookies/set?name=value&name1=value1"
        <> SR.method := HTTP.GET
        <> SR.protocol := SR.HTTP

testBinary = SR.hostname := "httpbin.org"
        <> SR.path := "/bytes/1001"
        <> SR.method := HTTP.GET
        <> SR.protocol := SR.HTTP

simpleTest = do
  res1 <- Aff.attempt $ SR.requestURI "https://www.reddit.com/r/purescript.json"
  either (const $ log "aww :(") (const $ log "yay!") res1

optsTest = do
  res2 <- SR.request testOpts
  log "Body length:"
  logShow $ length res2.body
  log "Status code:"
  logShow res2.statusCode
  log "Status message:"
  logShow res2.statusMessage
  log "Response headers:"
  Debug.traceAnyA res2.responseHeaders -- responseHeaders aren't actually a StrMap string
  log "HTTP Version:"
  logShow res2.httpVersion

cookieTest = do
  res3 <- SR.request testCookie
  log "Cookies:"
  logShow $ res3.responseCookies

binaryTest = do
  res3 <- SR.requestB testBinary
  len <- liftEff (Buffer.size res3.body)
  log ("Binary: got " <> show len <> " bytes of binary data")

postTest = do
  postData <- liftEff $ Buffer.fromString "hello" UTF8
  res3 <- SR.simpleRequest testPost postData
  log "Body:"
  log res3.body

main = Aff.runAff_ (either Console.logShow pure) $ void do
  simpleTest
  optsTest
  postTest
  cookieTest
  binaryTest
