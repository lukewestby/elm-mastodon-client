module Page.InstanceSelection exposing (Model, Msg, init, subscriptions, title, update, view)

import Data.Mastodon.Instance as Instance exposing (Instance)
import Effects exposing (Effect)
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attributes
import Html.Styled.Events as Events


type Model
    = UserTyping String
    | Verifying Instance
    | Verified Instance


inputText : Model -> String
inputText model =
    case model of
        UserTyping string ->
            string

        Verifying instance ->
            Instance.name instance

        Verified instance ->
            Instance.name instance


type Msg
    = InstanceInputChanged String
    | InstanceSelected
    | InstanceVerified Bool


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case ( msg, model ) of
        ( InstanceInputChanged input, UserTyping _ ) ->
            ( UserTyping input
            , Effects.none
            )

        ( InstanceSelected, UserTyping input ) ->
            case Instance.fromString input of
                Just instance ->
                    ( Verifying instance
                    , Effects.verifyInstance instance
                        |> Effects.map InstanceVerified
                    )

                Nothing ->
                    ( UserTyping input
                    , Effects.none
                    )

        ( InstanceVerified result, Verifying instance ) ->
            if result then
                ( Verified instance, Effects.none )
            else
                ( UserTyping (Instance.name instance), Effects.none )

        _ ->
            ( model, Effects.none )


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
        , case model of
            Verified _ ->
                Html.div [] [ Html.text "This is a real instance" ]

            _ ->
                Html.text ""
        ]


title : Model -> String
title _ =
    "Log in to Mastodon"
