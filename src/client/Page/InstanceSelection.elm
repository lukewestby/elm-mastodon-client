module Page.InstanceSelection exposing (Model, Msg, init, subscriptions, title, update, view)

import Effects exposing (Effect)
import Html.Styled as Html exposing (Html)


type alias Model =
    { instanceInput : String
    }


type Msg
    = InstanceInputChanged String


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        InstanceInputChanged input ->
            ( { model | instanceInput = input }
            , Effects.none
            )


init : ( Model, Effect Msg )
init =
    ( { instanceInput = "" }
    , Effects.none
    )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.text "hi"
        ]


title : Model -> String
title _ =
    "Log in to Mastodon"
