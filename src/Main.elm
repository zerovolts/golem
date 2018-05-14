module Main exposing (..)

import Array exposing (Array)
import Html
import Model exposing (Board, Model, Stone(..))
import Msg exposing (Msg)
import Update exposing (update)
import View exposing (view)


main : Program Never Model Msg
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
                    Nothing
                )
        )


placeStone : Stone -> Int -> Int -> Board -> Board
placeStone stone x y board =
    case Array.get x board of
        Just row ->
            Array.set y (Array.set x (Just stone) row) board

        Nothing ->
            board
