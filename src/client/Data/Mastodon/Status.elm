module Data.Mastodon.Status
    exposing
        ( Id
        , Status
        )


type Id
    = Id String


type alias Status =
    { username : String }
