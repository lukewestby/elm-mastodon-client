module Data.Mastodon.Client
    exposing
        ( Client
        , Id
        , decoder
        , encoder
        , selection
        )

import Data.Mastodon.ClientId as ClientId exposing (ClientId)
import Data.Mastodon.ClientSecret as ClientSecret exposing (ClientSecret)
import Data.Mastodon.Instance as Instance exposing (Instance)
import Graphql.Field as Field
import Graphql.SelectionSet as SelectionSet
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Mastodon.Graphql.Object as ApiObject
import Mastodon.Graphql.Object.Client as ApiClient
import Mastodon.Graphql.Scalar as ApiScalar


type Id
    = Id String


type alias Client =
    { clientId : ClientId
    , clientSecret : ClientSecret
    , instance : Instance
    }


selection : Instance -> SelectionSet.SelectionSet ( Id, Client ) ApiObject.Client
selection instance =
    ApiClient.selection (\id clientId clientSecret -> ( id, Client clientId clientSecret instance ))
        |> SelectionSet.with (Field.map (\(ApiScalar.Id string) -> Id string) ApiClient.id)
        |> SelectionSet.with (ClientId.fromStringField ApiClient.clientId)
        |> SelectionSet.with (ClientSecret.fromStringField ApiClient.clientSecret)


decoder : Decoder ( Id, Client )
decoder =
    Decode.map4
        (\id clientId clientSecret instance -> ( id, Client clientId clientSecret instance ))
        (Decode.field "id" (Decode.map Id Decode.string))
        (Decode.field "clientId" ClientId.decoder)
        (Decode.field "clientSecret" ClientSecret.decoder)
        (Decode.field "instance" Instance.decoder)


encoder : ( Id, Client ) -> Value
encoder ( Id id, client ) =
    Encode.object
        [ ( "id", Encode.string id )
        , ( "clientId", ClientId.encoder client.clientId )
        , ( "clientSecret", ClientSecret.encoder client.clientSecret )
        , ( "instance", Instance.encoder client.instance )
        ]
