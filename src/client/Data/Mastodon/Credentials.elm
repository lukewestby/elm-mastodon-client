module Data.Mastodon.Credentials
    exposing
        ( Credentials
        , decoder
        , encoder
        )

import Data.Mastodon.Instance as Instance exposing (Instance)
import Data.Mastodon.Token as Token exposing (Token)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)


type alias Credentials =
    { instance : Instance
    , token : Token
    }


encoder : Credentials -> Value
encoder credentials =
    Encode.object
        [ ( "instance", Instance.encoder credentials.instance )
        , ( "token", Token.encoder credentials.token )
        ]


decoder : Decoder Credentials
decoder =
    Decode.map2 Credentials
        (Decode.field "instance" Instance.decoder)
        (Decode.field "token" Token.decoder)
