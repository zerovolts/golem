module Computer exposing (computerMove)

import Array exposing (Array)
import Game exposing (findAllTerritories, oppositeColor, placeStone)
import Model exposing (Board, BoardSize(..), Game, GameStatus(..), GameType(..), History, Model, Page(..), Stone(..), Turn)
import Point exposing (Point)
import Random exposing (Generator)


computerMove : Game -> Generator Point
computerMove game =
    let
        openNeighbors =
            findOpenNeighbors (previousMove game.history) game.board

        openNeighborCount : Int
        openNeighborCount =
            Array.length (Maybe.withDefault Array.empty openNeighbors) - 1
    in
    if openNeighborCount > 1 then
        randomFortification openNeighbors openNeighborCount game
    else
        randomEmptyPoint game.board


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


randomFortification : Maybe (Array Point) -> Int -> Game -> Generator Point
randomFortification openNeighbors openNeighborCount game =
    Random.map
        (\index ->
            Maybe.withDefault ( 0, 0 )
                (Maybe.andThen (Array.get index) openNeighbors)
        )
        (Random.int 0 openNeighborCount)


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


findOpenNeighbors : Maybe Point -> Board -> Maybe (Array Point)
findOpenNeighbors point board =
    point
        |> Maybe.map
            (\prevPoint ->
                List.filter
                    (\point -> Game.getStone point board == Nothing)
                    (Point.neighbors prevPoint)
            )
        |> Maybe.map Array.fromList
