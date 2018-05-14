module Model exposing (..)

import Array exposing (Array)


type Stone
    = Black
    | White


type alias Board =
    Array (Array (Maybe Stone))


type alias Model =
    { board : Board
    , turn : Stone
    , turnNumber : Int
    }
