module Main exposing (..)

import Array exposing (Array)
import Game exposing (newBoard)
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
      , history = []
      , turn = Black
      , turnNumber = 1
      , chains = []
      , passFlag = False
      , gameOver = False
      }
    , Cmd.none
    )
