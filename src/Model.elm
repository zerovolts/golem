module Model exposing (..)

import Array exposing (Array)
import Set exposing (Set)


type Stone
    = Black
    | White


type Turn
    = PlaceStone Point
    | Pass


type GameStatus
    = Playing
    | OnePass
    | Over


type alias History =
    List Turn


type alias Point =
    ( Int, Int )


type alias Board =
    Array (Array (Maybe Stone))


type alias Territory =
    { owner : Stone
    , points : Set Point
    }


type alias Model =
    { board : Board
    , territories : Set Territory
    , history : History
    , turn : Stone
    , turnNumber : Int
    , gameStatus : GameStatus
    }
