module Data.Mastodon.Credentials
    exposing
        ( Credentials
        , decoder
        , encoder
        , selection
        )

import Data.Mastodon.Instance as Instance exposing (Instance)
import Data.Mastodon.Token as Token exposing (Token)
import Graphql.Field as Field
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Mastodon.Graphql.Object as ApiObject
import Mastodon.Graphql.Object.Credentials as ApiCredentials


type alias Credentials =
    { instance : Instance
    , token : Token
    }


selection : Instance -> SelectionSet Credentials ApiObject.Credentials
selection instance =
    ApiCredentials.selection Credentials
        |> SelectionSet.hardcoded instance
        |> SelectionSet.with (Token.fromStringField ApiCredentials.token)


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
