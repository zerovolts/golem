module Update exposing (..)

import Game exposing (oppositeColor, placeStone)
import Model exposing (Board, GameStatus(..), Model, Point, Stone(..))
import Msg exposing (Msg(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PlaceStone point ->
            if model.gameStatus /= Over then
                ( case placeStone model.turn point model.board of
                    Just board ->
                        { model
                            | board = board
                            , history = Model.PlaceStone point :: model.history
                            , turn = oppositeColor model.turn
                            , turnCount = model.turnCount + 1
                            , gameStatus = Playing
                        }

                    Nothing ->
                        model
                , Cmd.none
                )
            else
                ( model, Cmd.none )

        Pass ->
            if model.gameStatus == Playing then
                ( { model
                    | turn = oppositeColor model.turn
                    , history = Model.Pass :: model.history
                    , turnCount = model.turnCount + 1
                    , gameStatus = OnePass
                  }
                , Cmd.none
                )
            else
                ( { model
                    | turn = oppositeColor model.turn
                    , history = Model.Pass :: model.history
                    , turnCount = model.turnCount + 1
                    , gameStatus = Over
                  }
                , Cmd.none
                )
