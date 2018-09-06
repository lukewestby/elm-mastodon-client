module Route exposing (Route(..), fromUrl, toUrl)

import Constants
import Data.Mastodon.Code as Code exposing (Code)
import Url exposing (Url)
import Url.Builder as Builder
import Url.Parser as Parser exposing ((</>), (<?>), Parser)


type Route
    = Root
    | InstanceSelection



-- | InstanceValidation (Maybe Code)


fromUrl : Url -> Maybe Route
fromUrl url =
    Parser.parse parser url


toUrl : Route -> Url
toUrl route =
    case route of
        Root ->
            Builder.crossOrigin Constants.origin [] []
                |> Url.fromString
                |> Maybe.withDefault emptyUrl

        InstanceSelection ->
            Builder.crossOrigin Constants.origin [ "auth", "select" ] []
                |> Url.fromString
                |> Maybe.withDefault emptyUrl



-- InstanceValidation maybeAuthCode ->
--     maybeAuthCode
--         |> Maybe.map (Code.toQueryParameter "code" >> List.singleton)
--         |> Maybe.withDefault []
--         |> Builder.crossOrigin Constants.origin [ "auth", "validate" ]
--         |> Url.fromString
--         |> Maybe.withDefault emptyUrl
-- INTERNAL


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map Root Parser.top
        , Parser.map InstanceSelection (Parser.s "auth" </> Parser.s "select")

        -- , Parser.map InstanceValidation (Parser.s "auth" </> Parser.s "validate" <?> Code.queryParser "code")
        ]


emptyUrl : Url
emptyUrl =
    { host = ""
    , port_ = Nothing
    , protocol = Url.Http
    , path = "/"
    , query = Nothing
    , fragment = Nothing
    }
