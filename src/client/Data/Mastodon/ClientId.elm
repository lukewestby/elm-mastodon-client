module Data.Mastodon.ClientId
    exposing
        ( ClientId
        , decoder
        , encoder
        , fromStringField
        , toQueryParameter
        , toString
        )

import Graphql.Field as Field exposing (Field)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Url.Builder as Builder


type ClientId
    = ClientId String


toQueryParameter : String -> ClientId -> Builder.QueryParameter
toQueryParameter name (ClientId string) =
    Builder.string name string


fromStringField : Field String a -> Field ClientId a
fromStringField field =
    Field.map ClientId field


toString : ClientId -> String
toString (ClientId string) =
    string


encoder : ClientId -> Value
encoder (ClientId string) =
    Encode.string string


decoder : Decoder ClientId
decoder =
    Decode.map ClientId Decode.string
