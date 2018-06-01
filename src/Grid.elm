module Grid exposing (..)

import Array exposing (Array)
import Point exposing (Point)


type alias Grid a =
    Array (Array a)


initialize : Point -> (Point -> a) -> Grid a
initialize ( width, height ) initializer =
    Array.initialize width
        (\x ->
            Array.initialize height
                (\y ->
                    initializer ( x, y )
                )
        )


width : Grid a -> Int
width grid =
    Array.length grid


{-| returns the length of the first column (assumes each column to be the same length)
-}
height : Grid a -> Int
height grid =
    case Array.get 0 grid of
        Just col ->
            Array.length col

        Nothing ->
            0


get : Point -> Grid a -> Maybe a
get ( x, y ) grid =
    Array.get x grid
        |> Maybe.andThen
            (\col ->
                Array.get y col
            )


set : Point -> a -> Grid a -> Grid a
set ( x, y ) value grid =
    case Array.get x grid of
        Just col ->
            Array.set x (Array.set y value col) grid

        Nothing ->
            grid


inBounds : Point -> Grid a -> Bool
inBounds ( x, y ) grid =
    (x >= 0) && (y >= 0) && (x < width grid) && (y < height grid)


{-| removes the out-of-bounds neighbors (possibly unnecessary)
-}
neighbors : Point -> Grid a -> List Point
neighbors point grid =
    Point.neighbors point
        |> List.filter (\point -> inBounds point grid)
