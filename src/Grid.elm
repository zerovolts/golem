module Grid exposing (..)

import Array exposing (Array)


type alias Grid a =
    Array (Array a)


initialize : ( Int, Int ) -> (( Int, Int ) -> a) -> Grid a
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


height : Grid a -> Int
height grid =
    case Array.get 0 grid of
        Just col ->
            Array.length col

        Nothing ->
            0


get : ( Int, Int ) -> Grid a -> Maybe a
get ( x, y ) grid =
    Array.get x grid
        |> Maybe.andThen
            (\col ->
                Array.get y col
            )


set : ( Int, Int ) -> a -> Grid a -> Grid a
set ( x, y ) value grid =
    case Array.get x grid of
        Just col ->
            Array.set x (Array.set y value col) grid

        Nothing ->
            grid
