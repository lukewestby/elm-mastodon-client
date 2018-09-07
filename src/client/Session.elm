module Session
    exposing
        ( AwaitingCodeSession(..)
        , LoggedInSession(..)
        , LoggedOutSession(..)
        , Session
        , Updates
        , awaitCodeFrom
        , awaitingCode
        , decoder
        , default
        , encoder
        , logInAs
        , loggedIn
        , loggedOut
        , runUpdates
        , updates
        )

import Data.Mastodon.Client as Client exposing (Client)
import Data.Mastodon.Clients as Clients exposing (Clients)
import Data.Mastodon.Credentials as Credentials exposing (Credentials)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)


type LoggedOutSession
    = LoggedOutSession Clients


type LoggedInSession
    = LoggedInSession Credentials


type AwaitingCodeSession
    = AwaitingCodeSession Client


type Session
    = LoggedOut Clients
    | AwaitingCode Clients Client
    | LoggedIn Clients Credentials


loggedOut : Session -> Maybe LoggedOutSession
loggedOut session =
    case session of
        LoggedOut clients ->
            Just (LoggedOutSession clients)

        _ ->
            Nothing


awaitingCode : Session -> Maybe AwaitingCodeSession
awaitingCode session =
    case session of
        AwaitingCode _ client ->
            Just (AwaitingCodeSession client)

        _ ->
            Nothing


loggedIn : Session -> Maybe LoggedInSession
loggedIn session =
    case session of
        LoggedIn clients credentials ->
            Just (LoggedInSession credentials)

        _ ->
            Nothing


type Update
    = AwaitCodeFrom Client
    | LogInAs Credentials


type Updates
    = Updates (List Update)


updates : Updates
updates =
    Updates []


awaitCodeFrom : Client -> Updates -> Updates
awaitCodeFrom client (Updates list) =
    Updates (AwaitCodeFrom client :: list)


logInAs : Credentials -> Updates -> Updates
logInAs credentials (Updates list) =
    Updates (LogInAs credentials :: list)


runUpdates : Session -> Updates -> ( Session, Bool )
runUpdates session (Updates updateList) =
    case updateList of
        [] ->
            ( session, False )

        _ ->
            List.foldr
                (\nextUpdate ( currentSession, hasChanged ) ->
                    case ( nextUpdate, currentSession ) of
                        ( AwaitCodeFrom client, LoggedOut clients ) ->
                            ( AwaitingCode (Clients.add client clients) client, True )

                        ( AwaitCodeFrom client, AwaitingCode clients originalClient ) ->
                            if Clients.has client.instance clients && client == originalClient then
                                ( AwaitingCode clients originalClient, hasChanged )
                            else
                                ( AwaitingCode (Clients.add client clients) client, True )

                        ( AwaitCodeFrom client, LoggedIn clients credentials ) ->
                            ( AwaitingCode (Clients.add client clients) client, True )

                        ( LogInAs credentials, LoggedIn clients otherCredentials ) ->
                            if credentials == otherCredentials then
                                ( LoggedIn clients otherCredentials, hasChanged )
                            else
                                ( LoggedIn clients credentials, True )

                        ( LogInAs credentials, LoggedOut clients ) ->
                            ( LoggedIn clients credentials, True )

                        ( LogInAs credentials, AwaitingCode clients client ) ->
                            if credentials.instance == client.instance then
                                ( LoggedIn clients credentials, True )
                            else
                                ( AwaitingCode clients client, hasChanged )
                )
                ( session, False )
                updateList


encoder : Session -> Value
encoder session =
    case session of
        LoggedOut clients ->
            Encode.object
                [ ( "tag", Encode.string "LoggedOut" )
                , ( "clients", Clients.encoder clients )
                ]

        AwaitingCode clients client ->
            Encode.object
                [ ( "tag", Encode.string "AwaitingCode" )
                , ( "clients", Clients.encoder clients )
                , ( "client", Client.encoder client )
                ]

        LoggedIn clients credentials ->
            Encode.object
                [ ( "tag", Encode.string "LoggedIn" )
                , ( "clients", Clients.encoder clients )
                , ( "credentials", Credentials.encoder credentials )
                ]


decoder : Decoder Session
decoder =
    Decode.andThen
        (\tag ->
            case tag of
                "LoggedOut" ->
                    Decode.map LoggedOut
                        (Decode.field "clients" Clients.decoder)

                "AwaitingCode" ->
                    Decode.map2 AwaitingCode
                        (Decode.field "clients" Clients.decoder)
                        (Decode.field "client" Client.decoder)

                "LoggedIn" ->
                    Decode.map2 LoggedIn
                        (Decode.field "clients" Clients.decoder)
                        (Decode.field "credentials" Credentials.decoder)

                _ ->
                    Decode.fail (tag ++ " is not a valid Session tag")
        )
        (Decode.field "tag" Decode.string)


default : Session
default =
    LoggedOut Clients.empty
