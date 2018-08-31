port module Effects
    exposing
        ( Effect
        , Error(..)
        , createApplication
        , map
        , none
        , openWindow
        , run
        , searchInstances
        )

import Data.Mastodon.Client as Client exposing (Client)
import Extra.Maybe as Maybe
import Graphql.Field as Field
import Graphql.Http
import Graphql.Http.GraphqlError as GraphqlError
import Graphql.Operation as Operation
import Graphql.SelectionSet as SelectionSet
import Http
import Json.Encode as Encode exposing (Value)
import Mastodon.Graphql.Mutation as ApiMutation
import Mastodon.Graphql.Query as ApiQuery
import Url exposing (Url)


searchInstances : String -> Effect (List Url)
searchInstances query =
    GraphqlQuery
        { selection =
            ApiQuery.selection identity
                |> SelectionSet.with
                    (Field.mapOrFail
                        (Maybe.traverse Url.fromString >> Result.fromMaybe "Bad Url")
                        (ApiQuery.instances { query = query })
                    )
        , headers = []
        }


createApplication : Url -> Effect Client
createApplication instance =
    GraphqlMutation
        { selection =
            ApiMutation.selection identity
                |> SelectionSet.with (ApiMutation.createApplication Client.selection)
        , headers =
            [ ( "x-mastodon-instance", instance.host ) ]
        }


openWindow : Url -> Effect msg
openWindow url =
    PortSend
        { tag = "OpenWindow"
        , data = Encode.string (Url.toString url)
        }


port outbound : { tag : String, data : Value } -> Cmd msg


type Effect msg
    = GraphqlQuery
        { selection : SelectionSet.SelectionSet msg Operation.RootQuery
        , headers : List ( String, String )
        }
    | GraphqlMutation
        { selection : SelectionSet.SelectionSet msg Operation.RootMutation
        , headers : List ( String, String )
        }
    | PortSend
        { tag : String
        , data : Value
        }
    | None


none : Effect msg
none =
    None


map : (a -> b) -> Effect a -> Effect b
map tagger effect =
    case effect of
        GraphqlQuery stuff ->
            GraphqlQuery
                { selection = SelectionSet.map tagger stuff.selection
                , headers = stuff.headers
                }

        GraphqlMutation stuff ->
            GraphqlMutation
                { selection = SelectionSet.map tagger stuff.selection
                , headers = stuff.headers
                }

        PortSend stuff ->
            PortSend stuff

        None ->
            None


type Error
    = HttpError Http.Error
    | GraphqlError (List GraphqlError.GraphqlError)


run : (Error -> msg) -> Effect msg -> Cmd msg
run onError effect =
    case effect of
        GraphqlQuery stuff ->
            List.foldl
                (\( key, value ) req -> Graphql.Http.withHeader key value req)
                (Graphql.Http.queryRequest "/virtual/api" stuff.selection)
                stuff.headers
                |> Graphql.Http.send
                    (\result ->
                        case result of
                            Ok msg ->
                                msg

                            Err (Graphql.Http.GraphqlError _ errors) ->
                                onError (GraphqlError errors)

                            Err (Graphql.Http.HttpError httpError) ->
                                onError (HttpError httpError)
                    )

        GraphqlMutation stuff ->
            List.foldl
                (\( key, value ) req -> Graphql.Http.withHeader key value req)
                (Graphql.Http.mutationRequest "/virtual/api" stuff.selection)
                stuff.headers
                |> Graphql.Http.send
                    (\result ->
                        case result of
                            Ok msg ->
                                msg

                            Err (Graphql.Http.GraphqlError _ errors) ->
                                onError (GraphqlError errors)

                            Err (Graphql.Http.HttpError httpError) ->
                                onError (HttpError httpError)
                    )

        PortSend stuff ->
            outbound stuff

        None ->
            Cmd.none
