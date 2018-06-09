module Update exposing (..)

import Array exposing (Array)
import Delay
import Game exposing (findAllTerritories, oppositeColor, placeStone)
import Model exposing (Board, BoardSize(..), Game, GameStatus(..), GameType(..), History, Model, Page(..), Stone(..), Turn)
import Msg exposing (Msg(..))
import Point exposing (Point)
import Random exposing (Generator)
import Time


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        game =
            model.game

        gameOptions =
            model.gameOptions
    in
    case msg of
        PlaceStone point ->
            case model.gameOptions.gameType of
                Local ->
                    ( placeStoneCmd point model, Cmd.none )

                Online ->
                    ( placeStoneIfPlayer game.player point model, Cmd.none )

                Computer ->
                    ( placeStoneIfPlayer game.player point model
                    , Delay.after 500 Time.millisecond ComputerMove
                    )

        -- only used for Computer or Online games
        EnemyPlaceStone point ->
            case model.gameOptions.gameType of
                Local ->
                    ( model, Cmd.none )

                Online ->
                    ( placeStoneIfPlayer (oppositeColor game.player) point model, Cmd.none )

                Computer ->
                    ( placeStoneIfPlayer (oppositeColor game.player) point model, Cmd.none )

        Pass ->
            ( { model
                | game =
                    { game
                        | turn = oppositeColor game.turn
                        , history = Model.Pass :: game.history
                        , turnCount = game.turnCount + 1
                        , gameStatus =
                            if game.gameStatus == Playing then
                                OnePass
                            else
                                Over
                    }
              }
            , Cmd.none
            )

        EndTurn ->
            ( { model
                | game =
                    { game
                        | turn = oppositeColor game.turn
                        , turnCount = game.turnCount + 1
                    }
              }
            , Cmd.none
            )

        ComputerMove ->
            ( model, Random.generate EnemyPlaceStone (randomFortification game) )

        StartGame ->
            ( { model
                | game =
                    { game
                        | player = gameOptions.preferredColor
                        , board = Game.newBoard gameOptions.boardSize
                    }
                , page = GameScreen
              }
            , if gameOptions.gameType == Computer && gameOptions.preferredColor == White then
                Delay.after 500 Time.millisecond ComputerMove
              else
                Cmd.none
            )

        ChangeGameType gameType ->
            ( { model | gameOptions = { gameOptions | gameType = gameType } }, Cmd.none )

        ChangeColor stone ->
            ( { model | gameOptions = { gameOptions | preferredColor = stone } }, Cmd.none )

        ChangeBoardSize boardPreset ->
            ( { model
                | gameOptions =
                    { gameOptions
                        | boardSize = boardPreset
                    }
              }
            , Cmd.none
            )


placeStoneCmd : Point -> Model -> Model
placeStoneCmd point model =
    let
        game =
            model.game
    in
    if game.gameStatus /= Over then
        case placeStone game.turn point game.board of
            Just board ->
                { model
                    | game =
                        { game
                            | board = board
                            , territories = findAllTerritories board
                            , history = Model.PlaceStone point :: game.history
                            , turn = oppositeColor game.turn
                            , turnCount = game.turnCount + 1
                            , gameStatus = Playing
                        }
                }

            Nothing ->
                model
    else
        model


placeStoneIfPlayer : Stone -> Point -> Model -> Model
placeStoneIfPlayer stone point model =
    if stone == model.game.turn then
        placeStoneCmd point model
    else
        model


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


previousMove : History -> Maybe Point
previousMove history =
    let
        getPointFromTurn : Turn -> Maybe Point
        getPointFromTurn =
            \turn ->
                case turn of
                    Model.PlaceStone point ->
                        Just point

                    Model.Pass ->
                        Nothing
    in
    history
        |> List.tail
        |> Maybe.andThen List.head
        |> Maybe.andThen getPointFromTurn


randomFortification : Game -> Generator Point
randomFortification game =
    let
        openNeighbors : Maybe (Array Point)
        openNeighbors =
            previousMove game.history
                |> Maybe.map
                    (\prevPoint ->
                        List.filter
                            (\point -> Game.getStone point game.board == Nothing)
                            (Point.neighbors prevPoint)
                    )
                |> Maybe.map Array.fromList

        openNeighborCount : Int
        openNeighborCount =
            Array.length (Maybe.withDefault Array.empty openNeighbors) - 1
    in
    if openNeighborCount > 1 then
        Random.map
            (\index ->
                Maybe.withDefault ( 0, 0 )
                    (Maybe.andThen (Array.get index) openNeighbors)
            )
            (Random.int 0 openNeighborCount)
    else
        randomEmptyPoint game.board



{-
   computerMove : Game -> Generator Point
   computerMove game =
       case randomFortification game of
           Just point ->
               point

           Nothing ->
               randomEmptyPoint game.board
-}
