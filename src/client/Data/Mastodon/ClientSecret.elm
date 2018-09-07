module Data.Mastodon.ClientSecret
    exposing
        ( ClientSecret
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


type ClientSecret
    = ClientSecret String


toQueryParameter : String -> ClientSecret -> Builder.QueryParameter
toQueryParameter name (ClientSecret string) =
    Builder.string name string


fromStringField : Field String a -> Field ClientSecret a
fromStringField field =
    Field.map ClientSecret field


toString : ClientSecret -> String
toString (ClientSecret string) =
    string


encoder : ClientSecret -> Value
encoder (ClientSecret string) =
    Encode.string string


decoder : Decoder ClientSecret
decoder =
    Decode.map ClientSecret Decode.string
