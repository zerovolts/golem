module Update exposing (..)

import Game exposing (oppositeColor, placeStone)
import Model exposing (Board, Model, Point, Stone(..))
import Msg exposing (Msg(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PlaceStone point ->
            if model.gameOver == False then
                ( case placeStone model.turn point model.board of
                    Just board ->
                        { model
                            | board = board
                            , history = Model.PlaceStone point :: model.history
                            , turn = oppositeColor model.turn
                            , turnNumber = model.turnNumber + 1
                            , passFlag = False
                        }

                    Nothing ->
                        model
                , Cmd.none
                )
            else
                ( model, Cmd.none )

        Pass ->
            if model.passFlag == False then
                ( { model
                    | turn = oppositeColor model.turn
                    , history = Model.Pass :: model.history
                    , turnNumber = model.turnNumber + 1
                    , passFlag = True
                  }
                , Cmd.none
                )
            else
                ( { model
                    | turn = oppositeColor model.turn
                    , history = Model.Pass :: model.history
                    , turnNumber = model.turnNumber + 1
                    , passFlag = False
                    , gameOver = True
                  }
                , Cmd.none
                )
