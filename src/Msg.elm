module Msg exposing (..)

import Point exposing (Point)


type Msg
    = PlaceStone Point
    | EnemyPlaceStone Point
    | Pass
    | ComputerMove
