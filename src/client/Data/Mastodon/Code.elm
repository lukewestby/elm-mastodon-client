module Data.Mastodon.Code
    exposing
        ( Code
        , queryParser
        , toQueryParameter
        )

import Url.Builder as Builder
import Url.Parser.Query as Query


type Code
    = Code String


queryParser : String -> Query.Parser (Maybe Code)
queryParser name =
    Query.map (Maybe.map Code) (Query.string name)


toQueryParameter : String -> Code -> Builder.QueryParameter
toQueryParameter name (Code string) =
    Builder.string name string
