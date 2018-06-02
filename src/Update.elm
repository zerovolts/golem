module Update exposing (..)

import Array
import Delay
import Game exposing (findAllTerritories, oppositeColor, placeStone)
import Model exposing (Board, Game, GameStatus(..), GameType(..), Model, Stone(..))
import Msg exposing (Msg(..))
import Point exposing (Point)
import Random exposing (Generator)
import Time


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        game =
            gameUpdate msg model
    in
    ( { model | game = Tuple.first game }, Tuple.second game )


gameUpdate : Msg -> Model -> ( Game, Cmd Msg )
gameUpdate msg model =
    let
        game =
            model.game
    in
    case msg of
        PlaceStone point ->
            case model.gameType of
                Local ->
                    ( placeStoneCmd point game, Cmd.none )

                Online { player } ->
                    ( placeStoneIfPlayer player point game, Cmd.none )

                Computer { player } ->
                    ( placeStoneIfPlayer player point game
                    , Delay.after 500 Time.millisecond ComputerMove
                    )

        -- only used for Computer or Online games
        EnemyPlaceStone point ->
            case model.gameType of
                Local ->
                    ( game, Cmd.none )

                Online { player } ->
                    ( placeStoneIfPlayer (oppositeColor player) point game, Cmd.none )

                Computer { player } ->
                    ( placeStoneIfPlayer (oppositeColor player) point game, Cmd.none )

        Pass ->
            ( { game
                | turn = oppositeColor game.turn
                , history = Model.Pass :: game.history
                , turnCount = game.turnCount + 1
                , gameStatus =
                    if game.gameStatus == Playing then
                        OnePass
                    else
                        Over
              }
            , Cmd.none
            )

        EndTurn ->
            ( { game
                | turn = oppositeColor game.turn
                , turnCount = game.turnCount + 1
              }
            , Cmd.none
            )

        ComputerMove ->
            ( game, Random.generate EnemyPlaceStone (randomEmptyPoint game.board) )


placeStoneCmd : Point -> Game -> Game
placeStoneCmd point game =
    if game.gameStatus /= Over then
        case placeStone game.turn point game.board of
            Just board ->
                { game
                    | board = board
                    , territories = findAllTerritories board
                    , history = Model.PlaceStone point :: game.history
                    , turn = oppositeColor game.turn
                    , turnCount = game.turnCount + 1
                    , gameStatus = Playing
                }

            Nothing ->
                game
    else
        game


placeStoneIfPlayer : Stone -> Point -> Game -> Game
placeStoneIfPlayer stone point game =
    if stone == game.turn then
        placeStoneCmd point game
    else
        game


{-| TODO: if there are no empty spaces, this will return (0, 0)
in practice, the board should never be completely full, but it's worth fixing for completeness.
-}
randomEmptyPoint : Board -> Generator Point
randomEmptyPoint board =
    let
        emptyPoints =
            Game.getEmptyPoints board
    in
    Random.map
        (\index -> Maybe.withDefault ( 0, 0 ) (Array.get index emptyPoints))
        (Random.int 0 (Array.length emptyPoints))
