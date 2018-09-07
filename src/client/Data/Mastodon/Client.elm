module Data.Mastodon.Client
    exposing
        ( Client
        , Id
        , decoder
        , encoder
        , oauthUrl
        , selection
        )

import Data.Mastodon.ClientId as ClientId exposing (ClientId)
import Data.Mastodon.ClientSecret as ClientSecret exposing (ClientSecret)
import Data.Mastodon.Instance as Instance exposing (Instance)
import Extra.Url as Url
import Graphql.Field as Field
import Graphql.SelectionSet as SelectionSet
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Mastodon.Graphql.Object as ApiObject
import Mastodon.Graphql.Object.Client as ApiClient
import Mastodon.Graphql.Scalar as ApiScalar
import Url exposing (Url)
import Url.Builder as Builder


type Id
    = Id String


type alias Client =
    { clientId : ClientId
    , clientSecret : ClientSecret
    , instance : Instance
    , name : String
    , redirect : Url
    }


oauthUrl : Client -> Url
oauthUrl client =
    Builder.crossOrigin ("https://" ++ Instance.name client.instance)
        [ "oauth", "authorize" ]
        [ Builder.string "response_type" "code"
        , ClientId.toQueryParameter "client_id" client.clientId
        , Builder.string "redirect_uri" (Url.toString client.redirect)
        , Builder.string "scope" "read write follow"
        ]
        |> Url.fromString
        |> Maybe.withDefault Url.empty


selection : Instance -> SelectionSet.SelectionSet Client ApiObject.Client
selection instance =
    ApiClient.selection Client
        |> SelectionSet.with (ClientId.fromStringField ApiClient.clientId)
        |> SelectionSet.with (ClientSecret.fromStringField ApiClient.clientSecret)
        |> SelectionSet.hardcoded instance
        |> SelectionSet.with ApiClient.name
        |> SelectionSet.with (Field.mapOrFail (Url.fromString >> Result.fromMaybe "Not a valid URL") ApiClient.redirect)


decoder : Decoder Client
decoder =
    Decode.map5 Client
        (Decode.field "clientId" ClientId.decoder)
        (Decode.field "clientSecret" ClientSecret.decoder)
        (Decode.field "instance" Instance.decoder)
        (Decode.field "name" Decode.string)
        (Decode.field "redirect"
            (Decode.andThen
                (Url.fromString >> Maybe.map Decode.succeed >> Maybe.withDefault (Decode.fail "Not a valid URL"))
                Decode.string
            )
        )


encoder : Client -> Value
encoder client =
    Encode.object
        [ ( "clientId", ClientId.encoder client.clientId )
        , ( "clientSecret", ClientSecret.encoder client.clientSecret )
        , ( "redirect", Encode.string (Url.toString client.redirect) )
        , ( "instance", Instance.encoder client.instance )
        , ( "name", Encode.string client.name )
        ]
