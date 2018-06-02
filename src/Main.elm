module Main exposing (..)

import EverySet
import Game exposing (newBoard)
import Html
import Model exposing (Board, Game, GameStatus(..), GameType(..), Model, Stone(..))
import Msg exposing (Msg(..))
import Point exposing (Point)
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
    ( { game = initializeGame 19 Black
      , gameType = Computer { player = White }
      }
    , Cmd.none
    )


initializeGame : Int -> Stone -> Game
initializeGame boardSize playerColor =
    { board = newBoard boardSize
    , territories = EverySet.empty
    , history = []
    , turn = Black
    , turnCount = 1
    , gameStatus = Playing
    }
