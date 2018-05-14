module Model exposing (..)

import Array exposing (Array)


type Color
    = Black
    | White
    | Empty


type alias GamePiece =
    { color : Color
    , x : Int
    , y : Int
    }


type alias Board =
    Array (Array Color)


type alias Model =
    { board : Board }
