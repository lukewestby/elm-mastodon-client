module Data.Mastodon.Instance
    exposing
        ( Instance
        , authorizeUrl
        , decoder
        , encoder
        , fromString
        , name
        )

import Char
import Data.Mastodon.ClientId as ClientId exposing (ClientId)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Url exposing (Url)
import Url.Builder as Builder


type Instance
    = Instance String


encoder : Instance -> Value
encoder (Instance string) =
    Encode.string string


decoder : Decoder Instance
decoder =
    Decode.andThen
        (\string ->
            string
                |> fromString
                |> Maybe.map Decode.succeed
                |> Maybe.withDefault (Decode.fail "Not a correctly formatted instance name")
        )
        Decode.string


name : Instance -> String
name (Instance string) =
    string


fromString : String -> Maybe Instance
fromString input =
    if validateInstance input then
        Just (Instance input)
    else
        Nothing


authorizeUrl : ClientId -> Instance -> Url
authorizeUrl clientId (Instance host) =
    { protocol = Url.Https
    , host = host
    , port_ = Nothing
    , fragment = Nothing
    , path = "/oauth/authorize"
    , query =
        Builder.toQuery
            [ Builder.string "response_type" "code"
            , ClientId.toQueryParameter "client_id" clientId
            , Builder.string "redirect_uri" "https://elm-mastodon-demo.now.sh/auth/redirect"
            , Builder.string "scope" "read write follow"
            ]
            |> String.dropLeft 1
            |> Just
    }



-- INTERNAL


validateInstance : String -> Bool
validateInstance input =
    case String.uncons input of
        Just ( first, rest ) ->
            (String.length rest >= 2)
                && Char.isAlphaNum first
                && String.contains "." rest
                && String.all (\c -> Char.isAlphaNum c || c == '.') rest
                && not (String.endsWith "." rest)

        Nothing ->
            False
