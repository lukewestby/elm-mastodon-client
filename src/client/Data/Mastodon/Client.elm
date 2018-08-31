module Data.Mastodon.Client
    exposing
        ( Client
        , ClientId
        , ClientSecret
        , Id
        , selection
        )

import Graphql.Field as Field
import Graphql.SelectionSet as SelectionSet
import Mastodon.Graphql.Object as ApiObject
import Mastodon.Graphql.Object.Client as ApiClient
import Mastodon.Graphql.Scalar as ApiScalar


type Id
    = Id String


type ClientId
    = ClientId String


type ClientSecret
    = ClientSecret String


type alias Client =
    { id : Id
    , clientId : ClientId
    , clientSecret : ClientSecret
    }


selection : SelectionSet.SelectionSet Client ApiObject.Client
selection =
    ApiClient.selection Client
        |> SelectionSet.with (Field.map (\(ApiScalar.Id string) -> Id string) ApiClient.id)
        |> SelectionSet.with (Field.map ClientId ApiClient.clientId)
        |> SelectionSet.with (Field.map ClientSecret ApiClient.clientSecret)
