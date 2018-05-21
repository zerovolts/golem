module Update exposing (..)

import Array
import Game exposing (oppositeColor, placeStone)
import Model exposing (Board, Model, Point, Stone(..))
import Msg exposing (Msg(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PlaceStone point ->
            ( case placeStone model.turn point model.board of
                Just board ->
                    { model
                        | board = board
                        , turn = oppositeColor model.turn
                        , turnNumber = model.turnNumber + 1
                    }

                Nothing ->
                    model
            , Cmd.none
            )

        Pass ->
            ( { model
                | turn = oppositeColor model.turn
                , turnNumber = model.turnNumber + 1
              }
            , Cmd.none
            )
