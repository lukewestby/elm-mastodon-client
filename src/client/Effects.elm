port module Effects
    exposing
        ( Effect
        , Error(..)
        , State
        , createApplication
        , loadUrl
        , login
        , map
        , none
        , pushRoute
        , replaceRoute
        , run
        , verifyInstance
        )

import Browser.Navigation
import Data.Mastodon.Client as Client exposing (Client)
import Data.Mastodon.ClientId as ClientId exposing (ClientId)
import Data.Mastodon.Instance as Instance exposing (Instance)
import Extra.Maybe as Maybe
import Graphql.Field as Field
import Graphql.Http
import Graphql.Http.GraphqlError as GraphqlError
import Graphql.Operation as Operation
import Graphql.SelectionSet as SelectionSet
import Http
import Json.Encode as Encode exposing (Value)
import Mastodon.Graphql.Enum.Scope as ApiScope
import Mastodon.Graphql.Mutation as ApiMutation
import Mastodon.Graphql.Query as ApiQuery
import Route
import Url exposing (Url)
import Url.Builder as Builder


verifyInstance : Instance -> Effect Bool
verifyInstance instance =
    GraphqlQuery
        { selection =
            ApiQuery.selection identity
                |> SelectionSet.with
                    (Field.map
                        (List.filterMap Instance.fromString)
                        (ApiQuery.instances { query = Instance.name instance })
                    )
                |> SelectionSet.map (List.member instance)
        , headers = []
        }


createApplication : Instance -> Effect ( Client.Id, Client )
createApplication instance =
    GraphqlMutation
        { selection =
            ApiMutation.selection identity
                |> SelectionSet.with
                    (ApiMutation.createApplication
                        identity
                        { clientName = "Elm Mastodon Example"
                        , redirectUri = "https://elm-mastadon-demo.now.sh"
                        , scopes = [ ApiScope.Read, ApiScope.Write, ApiScope.Follow ]
                        }
                        (Client.selection instance)
                    )
        , headers =
            [ ( "x-mastodon-instance", Instance.name instance ) ]
        }


login : Instance -> ClientId -> Effect msg
login instance clientId =
    instance
        |> Instance.authorizeUrl clientId
        |> Url.toString
        |> LoadUrl


loadUrl : Url -> Effect msg
loadUrl url =
    LoadUrl (Url.toString url)


pushRoute : Route.Route -> Effect msg
pushRoute route =
    route
        |> Route.toUrl
        |> Url.toString
        |> PushUrl


replaceRoute : Route.Route -> Effect msg
replaceRoute route =
    route
        |> Route.toUrl
        |> Url.toString
        |> ReplaceUrl


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
    | PushUrl String
    | ReplaceUrl String
    | LoadUrl String
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

        LoadUrl url ->
            LoadUrl url

        PushUrl url ->
            PushUrl url

        ReplaceUrl url ->
            ReplaceUrl url

        None ->
            None


type Error
    = HttpError Http.Error
    | GraphqlError (List GraphqlError.GraphqlError)


type alias State =
    { navKey : Browser.Navigation.Key
    }


run : State -> (Error -> msg) -> Effect msg -> Cmd msg
run state onError effect =
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

        LoadUrl url ->
            Browser.Navigation.load url

        PushUrl url ->
            Browser.Navigation.pushUrl state.navKey url

        ReplaceUrl url ->
            Browser.Navigation.replaceUrl state.navKey url

        None ->
            Cmd.none
