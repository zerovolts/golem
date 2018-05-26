module Model exposing (..)

import Array exposing (Array)


type Stone
    = Black
    | White


type Turn
    = PlaceStone Point
    | Pass


type alias History =
    List Turn


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
    , history : History
    , turn : Stone
    , turnNumber : Int
    , chains : List Chain
    , passFlag : Bool
    , gameOver : Bool
    }
