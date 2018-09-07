module Extra.Url exposing (..)

import Url exposing (Url)


empty : Url
empty =
    { host = ""
    , port_ = Nothing
    , protocol = Url.Http
    , path = "/"
    , query = Nothing
    , fragment = Nothing
    }


toAbsoluteString : Url -> String
toAbsoluteString url =
    let
        query =
            case url.query of
                Just q ->
                    "?" ++ q

                Nothing ->
                    ""

        fragment =
            case url.fragment of
                Just f ->
                    "#" ++ f

                Nothing ->
                    ""
    in
    url.path ++ query ++ fragment
