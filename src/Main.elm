module Main exposing (..)

import Game exposing (newBoard)
import Html
import Model exposing (Board, GameStatus(..), Model, Stone(..))
import Msg exposing (Msg(..))
import Set
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
      , territories = Set.empty
      , history = []
      , turn = Black
      , turnCount = 1
      , gameStatus = Playing
      }
    , Cmd.none
    )
