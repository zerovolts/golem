module Point exposing (Point, neighbors)


type alias Point =
    ( Int, Int )


{-| returns the 4 adjacent neighbors in clockwise order, starting from the top
-}
neighbors : Point -> List Point
neighbors ( x, y ) =
    [ ( x, y - 1 ), ( x + 1, y ), ( x, y + 1 ), ( x - 1, y ) ]
