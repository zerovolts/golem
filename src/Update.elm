module Update exposing (..)

import Array
import Model exposing (Board, Model, Stone(..))
import Msg exposing (Msg(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PlaceStone x y ->
            ( { model
                | board = placeStone model.turn x y model.board
                , turnNumber = model.turnNumber + 1
                , turn =
                    case model.turn of
                        Black ->
                            White

                        White ->
                            Black
              }
            , Cmd.none
            )


placeStone : Stone -> Int -> Int -> Board -> Board
placeStone stone x y board =
    case Array.get x board of
        Just row ->
            Array.set x (Array.set y (Just stone) row) board

        Nothing ->
            board
