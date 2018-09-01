module Session exposing (Session, decoder, default, encoder)

import Data.Mastodon.Credentials as Credentials exposing (Credentials)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)


type alias Session =
    { credentials : Maybe Credentials
    }


encoder : Session -> Value
encoder session =
    Encode.object
        [ ( "crendentials"
          , case session.credentials of
                Just credentials ->
                    Credentials.encoder credentials

                Nothing ->
                    Encode.null
          )
        ]


decoder : Decoder Session
decoder =
    Decode.map Session
        (Decode.field "credentials" (Decode.nullable Credentials.decoder))


default : Session
default =
    { credentials = Nothing
    }
