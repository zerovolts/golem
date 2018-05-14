module Main exposing (..)

import Array exposing (Array)
import Html
import Model exposing (Board, Color(..), Model)
import Msg exposing (Msg)
import Update exposing (update)
import View exposing (view)


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }


init : ( Model, Cmd Msg )
init =
    ( { board = newBoard 19 }
    , Cmd.none
    )


newBoard : Int -> Board
newBoard size =
    Array.initialize size
        (\x ->
            Array.initialize size
                (\y ->
                    Black
                )
        )


placeStone : Color -> Int -> Int -> Board -> Board
placeStone c x y board =
    case Array.get x board of
        Just row ->
            Array.set y (Array.set x c row) board

        Nothing ->
            board
