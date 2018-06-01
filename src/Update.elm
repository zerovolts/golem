module Update exposing (..)

import Game exposing (findAllTerritories, oppositeColor, placeStone)
import Model exposing (Board, GameStatus(..), GameType(..), Model, Stone(..))
import Msg exposing (Msg(..))
import Point exposing (Point)
import Random


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PlaceStone point ->
            case model.gameType of
                Local ->
                    ( placeStoneCmd point model, Cmd.none )

                Online { player } ->
                    ( placeStoneIfPlayer player point model, Cmd.none )

                Computer { player } ->
                    update ComputerMove (placeStoneIfPlayer player point model)

        -- only used for Computer or Online games
        EnemyPlaceStone point ->
            case model.gameType of
                Local ->
                    ( model, Cmd.none )

                Online { player } ->
                    ( placeStoneIfPlayer (oppositeColor player) point model, Cmd.none )

                Computer { player } ->
                    ( placeStoneIfPlayer (oppositeColor player) point model, Cmd.none )

        Pass ->
            ( { model
                | turn = oppositeColor model.turn
                , history = Model.Pass :: model.history
                , turnCount = model.turnCount + 1
                , gameStatus =
                    if model.gameStatus == Playing then
                        OnePass
                    else
                        Over
              }
            , Cmd.none
            )

        ComputerMove ->
            ( model, Random.generate EnemyPlaceStone (Random.pair (Random.int 0 18) (Random.int 0 18)) )


placeStoneCmd : Point -> Model -> Model
placeStoneCmd point model =
    if model.gameStatus /= Over then
        case placeStone model.turn point model.board of
            Just board ->
                { model
                    | board = board
                    , territories = findAllTerritories board
                    , history = Model.PlaceStone point :: model.history
                    , turn = oppositeColor model.turn
                    , turnCount = model.turnCount + 1
                    , gameStatus = Playing
                }

            Nothing ->
                model
    else
        model


placeStoneIfPlayer : Stone -> Point -> Model -> Model
placeStoneIfPlayer stone point model =
    if stone == model.turn then
        placeStoneCmd point model
    else
        model
