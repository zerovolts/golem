module Msg exposing (..)

import Model exposing (BoardSize, GameType, Stone(..))
import Point exposing (Point)


type Msg
    = PlaceStone Point
    | EnemyPlaceStone Point
    | Pass
    | EndTurn
    | ComputerMove
    | StartGame
    | ChangeGameType GameType
    | ChangeColor Stone
    | ChangeBoardSize BoardSize
