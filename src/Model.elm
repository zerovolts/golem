module Model exposing (..)

import Array exposing (Array)
import EverySet exposing (EverySet)


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
    { owner : Maybe Stone
    , points : EverySet Point
    }


type alias Model =
    { board : Board
    , territories : EverySet Territory
    , history : History
    , turn : Stone
    , turnCount : Int
    , gameStatus : GameStatus
    }
