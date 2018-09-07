module Data.Mastodon.Clients
    exposing
        ( Clients
        , add
        , decoder
        , empty
        , encoder
        , get
        , has
        , remove
        )

import Data.Mastodon.Client as Client exposing (Client)
import Data.Mastodon.Instance as Instance exposing (Instance)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)


type Clients
    = Clients (List Client)


has : Instance -> Clients -> Bool
has instance (Clients clients) =
    List.any (\client -> client.instance == instance) clients


get : Instance -> Clients -> Maybe Client
get instance (Clients clients) =
    clients
        |> List.filter (\client -> client.instance == instance)
        |> List.head


add : Client -> Clients -> Clients
add client ((Clients list) as clients) =
    if has client.instance clients then
        clients
    else
        Clients (client :: list)


remove : Instance -> Clients -> Clients
remove instance (Clients list) =
    Clients <| List.filter (\client -> client.instance /= instance) list


empty : Clients
empty =
    Clients []


encoder : Clients -> Value
encoder (Clients list) =
    Encode.list Client.encoder list


decoder : Decoder Clients
decoder =
    Decode.map Clients (Decode.list Client.decoder)
