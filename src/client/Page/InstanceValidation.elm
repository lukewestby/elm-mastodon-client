module Page.InstanceValidation exposing (Model, Msg, init, subscriptions, title, update, view)

import Data.Mastodon.Client as Client exposing (Client)
import Data.Mastodon.Clients as Clients exposing (Clients)
import Data.Mastodon.Code as Code exposing (Code)
import Data.Mastodon.Credentials as Credentials exposing (Credentials)
import Data.Mastodon.Instance as Instance exposing (Instance)
import Data.Mastodon.Token as Token exposing (Token)
import Effects exposing (Effect)
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attributes
import Html.Styled.Events as Events
import Route
import Session exposing (AwaitingCodeSession(..))


type alias Model =
    { code : Code }


type Msg
    = CodeExchanged Credentials


update : AwaitingCodeSession -> Msg -> Model -> ( Model, Effect Msg, Session.Updates )
update (AwaitingCodeSession client) msg model =
    case msg of
        CodeExchanged credentials ->
            ( model
            , Effects.replaceRoute Route.Home
            , Session.updates
                |> Session.logInAs credentials
            )


init : AwaitingCodeSession -> Code -> ( Model, Effect Msg )
init (AwaitingCodeSession client) code =
    ( { code = code }
    , Effects.login client code
        |> Effects.map CodeExchanged
      -- , Effects.none
    )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.text "Hi"
        ]


title : Model -> String
title _ =
    "Logging in to Mastodon"
