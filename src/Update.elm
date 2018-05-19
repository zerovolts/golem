module Update exposing (..)

import Array
import Model exposing (Board, Model, Point, Stone(..))
import Msg exposing (Msg(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PlaceStone point ->
            ( { model
                | board = placeStone model.turn point model.board
                , turn = alternateTurn model.turn
                , turnNumber = model.turnNumber + 1
              }
            , Cmd.none
            )

        Pass ->
            ( { model
                | turn = alternateTurn model.turn
                , turnNumber = model.turnNumber + 1
              }
            , Cmd.none
            )


alternateTurn : Stone -> Stone
alternateTurn stone =
    case stone of
        Black ->
            White

        White ->
            Black


placeStone : Stone -> Point -> Board -> Board
placeStone stone ( x, y ) board =
    case Array.get x board of
        Just row ->
            Array.set x (Array.set y (Just stone) row) board

        Nothing ->
            board
