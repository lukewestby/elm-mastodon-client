port module Effects
    exposing
        ( Effect
        , Error(..)
        , State
        , batch
        , createApplication
        , loadUrl
        , login
        , map
        , none
        , pushRoute
        , replaceRoute
        , run
        , saveSession
        , verifyInstance
        )

import Browser.Navigation
import Data.Mastodon.Client as Client exposing (Client)
import Data.Mastodon.ClientId as ClientId exposing (ClientId)
import Data.Mastodon.ClientSecret as ClientSecret exposing (ClientSecret)
import Data.Mastodon.Code as Code exposing (Code)
import Data.Mastodon.Credentials as Credentials exposing (Credentials)
import Data.Mastodon.Instance as Instance exposing (Instance)
import Extra.Maybe as Maybe
import Extra.Url as Url
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
import Session exposing (Session)
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


createApplication : Instance -> Effect Client
createApplication instance =
    GraphqlMutation
        { selection =
            ApiMutation.selection identity
                |> SelectionSet.with
                    (ApiMutation.createApplication
                        identity
                        { clientName = "Elm Mastodon Example"
                        , scopes = [ ApiScope.Read, ApiScope.Write, ApiScope.Follow ]
                        , redirectUri =
                            Route.InstanceValidation Nothing
                                |> Route.toUrl
                                |> Url.toString
                        }
                        (Client.selection instance)
                    )
        , headers =
            [ ( "x-mastodon-instance", Instance.name instance ) ]
        }


login : Client -> Code -> Effect Credentials
login client code =
    GraphqlMutation
        { selection =
            ApiMutation.selection identity
                |> SelectionSet.with
                    (ApiMutation.login
                        { clientId = ClientId.toString client.clientId
                        , clientSecret = ClientSecret.toString client.clientSecret
                        , redirectUri = Url.toString client.redirect
                        , code = Code.toString code
                        }
                        (Credentials.selection client.instance)
                    )
        , headers =
            [ ( "x-mastodon-instance", Instance.name client.instance ) ]
        }


loadUrl : Url -> Effect msg
loadUrl url =
    LoadUrl (Url.toString url)


pushRoute : Route.Route -> Effect msg
pushRoute route =
    route
        |> Route.toUrl
        |> Url.toAbsoluteString
        |> PushUrl


replaceRoute : Route.Route -> Effect msg
replaceRoute route =
    route
        |> Route.toUrl
        |> Url.toAbsoluteString
        |> ReplaceUrl


saveSession : Session -> Effect msg
saveSession session =
    PortSend
        { tag = "SaveSession"
        , data = Session.encoder session
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
    | PushUrl String
    | ReplaceUrl String
    | LoadUrl String
    | Batch (List (Effect msg))
    | None


none : Effect msg
none =
    None


batch : List (Effect msg) -> Effect msg
batch =
    Batch


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

        Batch list ->
            Batch (List.map (map tagger) list)

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

        Batch list ->
            Cmd.batch (List.map (run state onError) list)

        None ->
            Cmd.none
