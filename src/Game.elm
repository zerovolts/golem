module Game exposing (..)

import Array exposing (Array)
import EverySet exposing (EverySet)
import Grid exposing (Grid)
import Model exposing (Board, Stone(..), Territory)
import Point exposing (Point)
import Util


newBoard : Point -> Board
newBoard size =
    Grid.initialize size (always Nothing)


getStone : Point -> Board -> Maybe Stone
getStone point board =
    Grid.get point board
        |> Maybe.withDefault Nothing


getEmptyPoints : Board -> Array Point
getEmptyPoints board =
    Util.getAllCombinations (List.range 0 18)
        |> List.filter (\point -> getStone point board == Nothing)
        |> Array.fromList


{-| Given a position, returns a list of all positions connected to it.
-}
findChain : Point -> Board -> EverySet Point
findChain point board =
    findChainIntermediate point (getStone point board) board EverySet.empty


findChainIntermediate : Point -> Maybe Stone -> Board -> EverySet Point -> EverySet Point
findChainIntermediate point stone board set =
    if
        (getStone point board == stone)
            && not (EverySet.member point set)
            && Grid.inBounds point board
    then
        List.foldl (\neighbor set -> findChainIntermediate neighbor stone board set)
            (EverySet.insert point set)
            (Point.neighbors point)
    else
        set


findLiberties : Point -> Board -> EverySet Point
findLiberties point board =
    findChainLiberties (findChain point board) board


{-| Given a chain, returns a list of all surrounding liberties
-}
findChainLiberties : EverySet Point -> Board -> EverySet Point
findChainLiberties points board =
    points
        |> EverySet.toList
        |> List.map (\point -> EverySet.toList (findStoneLiberties point board))
        |> List.concat
        |> EverySet.fromList


{-| Given a position, returns the set of adjacent liberties
-}
findStoneLiberties : Point -> Board -> EverySet Point
findStoneLiberties point board =
    List.foldl (\neighbor set -> addIfEmpty neighbor board set)
        EverySet.empty
        (Point.neighbors point)


{-| Given a point and a set, add the point to the set if that point is empty and in-bounds
-}
addIfEmpty : Point -> Board -> EverySet Point -> EverySet Point
addIfEmpty point board set =
    if (getStone point board == Nothing) && Grid.inBounds point board then
        EverySet.insert point set
    else
        set


removeStone : Point -> Board -> Board
removeStone ( x, y ) board =
    case Array.get x board of
        Just row ->
            Array.set x (Array.set y Nothing row) board

        Nothing ->
            board


removeChain : EverySet Point -> Board -> Board
removeChain points board =
    List.foldl (\point board -> removeStone point board) board (EverySet.toList points)


placeStoneIfFree : Stone -> Point -> Board -> Maybe Board
placeStoneIfFree stone point board =
    case getStone point board of
        Nothing ->
            Just (Grid.set point (Just stone) board)

        _ ->
            Nothing


oppositeColor : Stone -> Stone
oppositeColor stone =
    case stone of
        Black ->
            White

        White ->
            Black


getAdjacentEnemyStones : Point -> Board -> EverySet Point
getAdjacentEnemyStones point board =
    let
        enemyColor =
            Maybe.map oppositeColor (getStone point board)
    in
    Point.neighbors point
        |> EverySet.fromList
        |> EverySet.filter (\point -> getStone point board == enemyColor)


adjacentCapturedEnemyChains : Point -> Board -> List (EverySet Point)
adjacentCapturedEnemyChains point board =
    EverySet.toList (getAdjacentEnemyStones point board)
        |> List.map (\point -> findChain point board)
        |> List.filter (\chain -> EverySet.size (findChainLiberties chain board) == 0)


removeAdjacentCaptured : Point -> Board -> Board
removeAdjacentCaptured point board =
    List.foldl
        (\chain board -> removeChain chain board)
        board
        (adjacentCapturedEnemyChains point board)


preventSuicide : Point -> Board -> Maybe Board
preventSuicide point board =
    if EverySet.size (findLiberties point board) == 0 then
        Nothing
    else
        Just board


{-| Place stone
Check liberties on all chains adjacent to the placed stone
Capture (remove) any such chains that no longer have any liberties
Check liberties of placed stone
Cancel move if no liberties (suicide)
TODO: Prevent Ko
-}
placeStone : Stone -> Point -> Board -> Maybe Board
placeStone stone point board =
    board
        |> placeStoneIfFree stone point
        |> Maybe.map (removeAdjacentCaptured point)
        |> Maybe.andThen (preventSuicide point)


determineOwner : ( List Stone, List Stone ) -> Maybe Stone
determineOwner stoneGroups =
    case stoneGroups of
        ( _, [] ) ->
            Just White

        ( [], _ ) ->
            Just Black

        _ ->
            Nothing


findTerritory : Point -> Board -> Territory
findTerritory point board =
    let
        points =
            findChain point board
    in
    { owner = findTerritoryOwner points board
    , points = points
    }


findTerritoryOwner : EverySet Point -> Board -> Maybe Stone
findTerritoryOwner points board =
    findTerritoryBoundaries points board
        |> EverySet.toList
        |> List.map (\point -> getStone point board)
        |> List.foldl
            (\maybePoint points ->
                case maybePoint of
                    Just point ->
                        point :: points

                    Nothing ->
                        points
            )
            []
        |> List.partition (\stone -> stone == White)
        |> determineOwner


{-| possibly combine this with "findChainLiberties"
only difference is "findPointBoundaries" rather than "findStoneLiberties"
-}
findTerritoryBoundaries : EverySet Point -> Board -> EverySet Point
findTerritoryBoundaries points board =
    points
        |> EverySet.toList
        |> List.map (\point -> EverySet.toList (findPointBoundaries point board))
        |> List.concat
        |> EverySet.fromList


{-| possibly combine this with "findStoneLiberties"
only difference is "addIfStone" rather than "addIfEmpty"
-}
findPointBoundaries : Point -> Board -> EverySet Point
findPointBoundaries point board =
    List.foldl (\neighbor set -> addIfStone neighbor board set)
        EverySet.empty
        (Point.neighbors point)


{-| possibly combine this with "addIfEmpty"
only difference is "/= Nothing" rather than "== Nothing"
-}
addIfStone : Point -> Board -> EverySet Point -> EverySet Point
addIfStone point board set =
    if (getStone point board /= Nothing) && Grid.inBounds point board then
        EverySet.insert point set
    else
        set


pointIsInTerritories : Point -> EverySet Territory -> Bool
pointIsInTerritories point territories =
    EverySet.size
        (EverySet.filter
            (\territory -> EverySet.member point territory.points)
            territories
        )
        > 0


getPointTerritory : Point -> EverySet Territory -> Maybe Stone
getPointTerritory point territories =
    let
        maybeTerritory =
            EverySet.filter
                (\territory -> EverySet.member point territory.points)
                territories
                |> EverySet.toList
                |> List.head
    in
    Maybe.withDefault Nothing (Maybe.map .owner maybeTerritory)


{-| generate all territories from the board state
-}
findAllTerritories : Board -> EverySet Territory
findAllTerritories board =
    List.foldl
        (\point territories ->
            if pointIsInTerritories point territories || getStone point board /= Nothing then
                territories
            else
                EverySet.insert (findTerritory point board) territories
        )
        EverySet.empty
        (Util.getAllCombinations (List.range 0 18))


territoryCount : Stone -> EverySet Territory -> Int
territoryCount stone territories =
    territories
        |> EverySet.filter (\territory -> territory.owner == Just stone)
        |> EverySet.foldl (\territory total -> total + EverySet.size territory.points) 0
