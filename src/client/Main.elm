port module Main exposing (..)

import Browser
import Browser.Navigation
import Css.Global
import Effects exposing (Effect)
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attributes
import Html.Styled.Events as Events
import Json.Decode as Decode exposing (Value)
import Json.Encode as Encode exposing (Value)
import Page.InstanceSelection
import Route exposing (Route)
import Session exposing (Session)
import Url exposing (Url)


type PageModel
    = NotFound
    | Redirect
    | InstanceSelection Page.InstanceSelection.Model


type alias Model =
    { effects : Effects.State
    , session : Session
    , page : PageModel
    }


init : Value -> Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init flags url navKey =
    let
        session =
            flags
                |> Decode.decodeValue Session.decoder
                |> Result.withDefault Session.default

        effectsState =
            { navKey = navKey }

        ( page, effect ) =
            changeRouteTo
                (Route.fromUrl url)
                session
                Redirect
    in
    ( { session = session, page = page, effects = effectsState }
    , Effects.run effectsState effect
    )


type Msg
    = ErrorOccured Effects.Error
    | NoOp


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ErrorOccured error ->
            ( model, Effects.none )

        NoOp ->
            ( model, Effects.none )


changeRouteTo : Maybe Route.Route -> Session -> PageModel -> ( PageModel, Effect Msg )
changeRouteTo maybeRoute session page =
    case (maybeRoute,  of
        Nothing ->
            ( NotFound, Effects.none )

        Just InstanceSelection ->

        Just (InstanceValidation maybeCode) ->
            ( )




--     Just Route.Root ->
--         ( model, Effects.replaceRoute Route.Home )
--     Just Route.Logout ->
--         ( model, Api.logout )
--     Just Route.NewArticle ->
--         Editor.initNew session
--             |> updateWith (Editor Nothing) GotEditorMsg model
--     Just (Route.EditArticle slug) ->
--         Editor.initEdit session slug
--             |> updateWith (Editor (Just slug)) GotEditorMsg model
--     Just Route.Settings ->
--         Settings.init session
--             |> updateWith Settings GotSettingsMsg model
--     Just Route.Home ->
--         Home.init session
--             |> updateWith Home GotHomeMsg model
--     Just Route.Login ->
--         Login.init session
--             |> updateWith Login GotLoginMsg model
--     Just Route.Register ->
--         Register.init session
--             |> updateWith Register GotRegisterMsg model
--     Just (Route.Profile username) ->
--         Profile.init session username
--             |> updateWith (Profile username) GotProfileMsg model
--     Just (Route.Article slug) ->
--         Article.init session slug
--             |> updateWith Article GotArticleMsg model


title : Model -> String
title model =
    case model.page of
        InstanceSelection instanceSelectionModel ->
            Page.InstanceSelection.title instanceSelectionModel

        _ ->
            "Mastodon"


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
        , subscriptions = \_ -> Sub.none
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
