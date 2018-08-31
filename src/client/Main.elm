port module Main exposing (..)

import Browser
import Css.Global
import Effects exposing (Effect)
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attributes
import Html.Styled.Events as Events
import Json.Encode as Encode exposing (Value)
import Url exposing (Url)


type alias Model =
    { instanceName : String }


init : ( Model, Effect Msg )
init =
    ( { instanceName = "" }
    , Effects.none
    )


type Msg
    = ErrorOccured Effects.Error
    | InstanceNameChanged String
    | NoOp


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        InstanceNameChanged query ->
            ( { model | instanceName = query }
            , Effects.none
            )

        ErrorOccured error ->
            ( model, Effects.none )

        NoOp ->
            ( model, Effects.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.input
            [ Attributes.type_ "text"
            , Events.onInput InstanceNameChanged
            ]
            []
        ]


title : Model -> String
title model =
    "Title"


styles : Model -> List Css.Global.Snippet
styles model =
    []


main : Program () Model Msg
main =
    Browser.application
        { init =
            \_ _ _ ->
                init |> Tuple.mapSecond (Effects.run ErrorOccured)
        , update =
            \msg model ->
                update msg model |> Tuple.mapSecond (Effects.run ErrorOccured)
        , subscriptions = subscriptions
        , onUrlRequest = \_ -> NoOp
        , onUrlChange = \_ -> NoOp
        , view =
            \m ->
                { title = title m
                , body =
                    [ Html.toUnstyled (Css.Global.global (styles m))
                    , Html.toUnstyled (view m)
                    ]
                }
        }
