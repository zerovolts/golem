module Main exposing (..)

import Array exposing (Array)
import Html
import Model exposing (Board, Model, Stone(..))
import Msg exposing (Msg(..))
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
    ( { board = newBoard 19
      , turn = Black
      , turnNumber = 1
      , chains = []
      }
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
