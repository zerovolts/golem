module Model exposing (..)

import Array exposing (Array)


type Stone
    = Black
    | White


type alias Point =
    ( Int, Int )


type alias Board =
    Array (Array (Maybe Stone))


type alias Chain =
    { stones : List Point
    , liberties : List Point
    }


type alias Model =
    { board : Board
    , turn : Stone
    , turnNumber : Int
    , chains : List Chain
    , passFlag : Bool
    , gameOver : Bool
    }
