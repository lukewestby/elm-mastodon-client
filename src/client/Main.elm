port module Main exposing (..)

import Browser
import Browser.Navigation
import Css.Global
import Effects exposing (Effect)
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attributes
import Html.Styled.Events as Events
import Json.Decode as Decode exposing (Decoder)
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
    , Effects.run effectsState ErrorOccured effect
    )


type Msg
    = ErrorOccured Effects.Error
    | GotInstanceSelectionMsg Page.InstanceSelection.Msg
    | ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | NoOp


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case ( msg, model.page ) of
        ( ErrorOccured error, _ ) ->
            ( model, Effects.none )

        ( NoOp, _ ) ->
            ( model, Effects.none )

        ( ChangedUrl url, _ ) ->
            changeRouteTo (Route.fromUrl url) model.session model.page
                |> Tuple.mapFirst (\m -> { model | page = m })

        ( ClickedLink urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , url
                        |> Route.fromUrl
                        |> Maybe.map Effects.pushRoute
                        |> Maybe.withDefault Effects.none
                    )

                Browser.External href ->
                    ( model
                    , href
                        |> Url.fromString
                        |> Maybe.map Effects.loadUrl
                        |> Maybe.withDefault Effects.none
                    )

        ( GotInstanceSelectionMsg subMsg, InstanceSelection subModel ) ->
            Page.InstanceSelection.update subMsg subModel
                |> Tuple.mapFirst (\m -> { model | page = InstanceSelection m })
                |> Tuple.mapSecond (Effects.map GotInstanceSelectionMsg)

        _ ->
            ( model, Effects.none )


changeRouteTo : Maybe Route.Route -> Session -> PageModel -> ( PageModel, Effect Msg )
changeRouteTo maybeRoute session page =
    case ( maybeRoute, session ) of
        ( Nothing, _ ) ->
            ( NotFound, Effects.none )

        ( Just Route.Root, Session.LoggedOut _ ) ->
            ( page, Effects.replaceRoute Route.InstanceSelection )

        ( Just Route.InstanceSelection, Session.LoggedOut _ ) ->
            Page.InstanceSelection.init
                |> Tuple.mapFirst InstanceSelection
                |> Tuple.mapSecond (Effects.map GotInstanceSelectionMsg)

        _ ->
            ( page, Effects.none )


title : Model -> String
title model =
    case model.page of
        InstanceSelection instanceSelectionModel ->
            Page.InstanceSelection.title instanceSelectionModel

        _ ->
            "Mastodon"


view : PageModel -> Html Msg
view model =
    case model of
        NotFound ->
            Html.div [] [ Html.text "Not Found" ]

        Redirect ->
            Html.text ""

        InstanceSelection subModel ->
            Page.InstanceSelection.view subModel
                |> Html.map GotInstanceSelectionMsg


styles : Model -> List Css.Global.Snippet
styles model =
    []


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.page of
        NotFound ->
            Sub.none

        Redirect ->
            Sub.none

        InstanceSelection subModel ->
            Page.InstanceSelection.subscriptions subModel
                |> Sub.map GotInstanceSelectionMsg


main : Program Value Model Msg
main =
    Browser.application
        { init = init
        , update = \msg model -> update msg model |> Tuple.mapSecond (Effects.run model.effects ErrorOccured)
        , subscriptions = subscriptions
        , onUrlRequest = \_ -> NoOp
        , onUrlChange = ChangedUrl
        , view =
            \m ->
                { title = title m
                , body =
                    [ Html.toUnstyled (Css.Global.global (styles m))
                    , Html.toUnstyled (view m.page)
                    ]
                }
        }
