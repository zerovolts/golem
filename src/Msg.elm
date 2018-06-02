module Msg exposing (..)

import Model exposing (Stone(..))
import Point exposing (Point)


type Msg
    = PlaceStone Point
    | EnemyPlaceStone Point
    | Pass
    | EndTurn
    | ComputerMove
