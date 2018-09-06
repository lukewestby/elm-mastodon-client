module Session exposing (Session(..), decoder, default, encoder)

import Data.Mastodon.Client as Client exposing (Client)
import Data.Mastodon.Credentials as Credentials exposing (Credentials)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)


type Session
    = LoggedOut (List Client)
    | LoggedIn (List Client) Credentials


encoder : Session -> Value
encoder session =
    case session of
        LoggedOut clients ->
            Encode.object
                [ ( "tag", Encode.string "LoggedOut" )
                , ( "clients", Encode.list Client.encoder clients )
                ]

        LoggedIn clients credentials ->
            Encode.object
                [ ( "tag", Encode.string "LoggedIn" )
                , ( "clients", Encode.list Client.encoder clients )
                , ( "credentials", Credentials.encoder credentials )
                ]


decoder : Decoder Session
decoder =
    Decode.andThen
        (\tag ->
            case tag of
                "LoggedOut" ->
                    Decode.map LoggedOut
                        (Decode.field "clients" (Decode.list Client.decoder))

                "LoggedIn" ->
                    Decode.map2 LoggedIn
                        (Decode.field "clients" (Decode.list Client.decoder))
                        (Decode.field "credentials" Credentials.decoder)

                _ ->
                    Decode.fail (tag ++ " is not a valid Session tag")
        )
        (Decode.field "tag" Decode.string)


default : Session
default =
    LoggedOut []
