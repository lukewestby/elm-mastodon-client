module Data.Mastodon.Token
    exposing
        ( Token
        , decoder
        , encoder
        )

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Url.Builder as Builder
import Url.Parser.Query as Query


type Token
    = Token String


encoder : Token -> Value
encoder (Token string) =
    Encode.string string


decoder : Decoder Token
decoder =
    Decode.map Token Decode.string
