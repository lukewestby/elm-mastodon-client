module Page.InstanceSelection exposing (Model, Msg, init, subscriptions, title, update, view)

import Data.Mastodon.Client as Client exposing (Client)
import Data.Mastodon.Clients as Clients exposing (Clients)
import Data.Mastodon.Instance as Instance exposing (Instance)
import Effects exposing (Effect)
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attributes
import Html.Styled.Events as Events
import Session exposing (LoggedOutSession(..))


type Model
    = UserTyping String
    | VerifyingInstance Instance
    | CreatingClient Instance
    | LoggingIn Client


inputText : Model -> String
inputText model =
    case model of
        UserTyping string ->
            string

        VerifyingInstance instance ->
            Instance.name instance

        CreatingClient instance ->
            Instance.name instance

        LoggingIn client ->
            Instance.name client.instance


type Msg
    = InstanceInputChanged String
    | InstanceSelected
    | InstanceVerified Bool
    | ClientCreated Client


update : LoggedOutSession -> Msg -> Model -> ( Model, Effect Msg, Session.Updates )
update (LoggedOutSession clients) msg model =
    case ( msg, model ) of
        ( InstanceInputChanged input, UserTyping _ ) ->
            ( UserTyping input
            , Effects.none
            , Session.updates
            )

        ( InstanceSelected, UserTyping input ) ->
            case Instance.fromString input of
                Just instance ->
                    case Clients.get instance clients of
                        Just client ->
                            ( LoggingIn client
                            , Effects.loadUrl (Client.oauthUrl client)
                            , Session.updates
                                |> Session.awaitCodeFrom client
                            )

                        Nothing ->
                            ( VerifyingInstance instance
                            , Effects.verifyInstance instance
                                |> Effects.map InstanceVerified
                            , Session.updates
                            )

                Nothing ->
                    ( UserTyping input
                    , Effects.none
                    , Session.updates
                    )

        ( InstanceVerified result, VerifyingInstance instance ) ->
            if result then
                ( CreatingClient instance
                , Effects.createApplication instance
                    |> Effects.map ClientCreated
                , Session.updates
                )
            else
                ( UserTyping (Instance.name instance)
                , Effects.none
                , Session.updates
                )

        ( ClientCreated client, CreatingClient instance ) ->
            ( LoggingIn client
            , Effects.loadUrl (Client.oauthUrl client)
            , Session.updates
                |> Session.awaitCodeFrom client
            )

        _ ->
            ( model
            , Effects.none
            , Session.updates
            )


init : ( Model, Effect Msg )
init =
    ( UserTyping ""
    , Effects.none
    )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.input
            [ Attributes.type_ "text"
            , Events.onInput InstanceInputChanged
            , Attributes.value (inputText model)
            ]
            []
        , Html.button
            [ Events.onClick InstanceSelected ]
            [ Html.text "Log In" ]
        ]


title : Model -> String
title _ =
    "Log in to Mastodon"
