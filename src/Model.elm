module Model exposing (..)

import EverySet exposing (EverySet)
import Grid exposing (Grid)
import Point exposing (Point)


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


type GameType
    = Local
    | Computer { player : Stone }
    | Online { player : Stone }


type alias History =
    List Turn


type alias Board =
    Grid (Maybe Stone)


type alias Territory =
    { owner : Maybe Stone
    , points : EverySet Point
    }


type alias Model =
    { board : Board
    , territories : EverySet Territory
    , gameType : GameType
    , history : History
    , turn : Stone
    , turnCount : Int
    , gameStatus : GameStatus
    }
