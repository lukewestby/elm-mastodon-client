module Extra.Maybe exposing (..)


traverse : (a -> Maybe b) -> List a -> Maybe (List b)
traverse f list =
    List.foldr
        (\e acc ->
            case f e of
                Nothing ->
                    Nothing

                Just x ->
                    Maybe.map ((::) x) acc
        )
        (Just [])
        list
