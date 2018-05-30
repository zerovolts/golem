module Game exposing (..)

import Array
import EverySet exposing (EverySet)
import Helpers exposing (getAllCombinations)
import Model exposing (Board, Point, Stone(..), Territory)


newBoard : Int -> Board
newBoard size =
    Array.initialize size
        (\_ ->
            Array.initialize size
                (\_ ->
                    Nothing
                )
        )


getStone : Point -> Board -> Maybe Stone
getStone ( x, y ) board =
    Array.get x board
        |> Maybe.andThen
            (\col ->
                Array.get y col
                    |> Maybe.withDefault Nothing
            )


{-| Given a position, returns a list of all positions connected to it.
-}
findChain : Point -> Board -> EverySet Point
findChain point board =
    findChainIntermediate point (getStone point board) board EverySet.empty


findChainIntermediate : Point -> Maybe Stone -> Board -> EverySet Point -> EverySet Point
findChainIntermediate ( x, y ) stone board set =
    if
        (getStone ( x, y ) board == stone)
            && not (EverySet.member ( x, y ) set)
            && (x >= 0)
            && (y >= 0)
            && (x < Array.length board)
            && (y < Array.length board)
    then
        EverySet.insert ( x, y ) set
            |> findChainIntermediate ( x + 1, y ) stone board
            |> findChainIntermediate ( x - 1, y ) stone board
            |> findChainIntermediate ( x, y + 1 ) stone board
            |> findChainIntermediate ( x, y - 1 ) stone board
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
findStoneLiberties ( x, y ) board =
    EverySet.empty
        |> addIfEmpty ( x + 1, y ) board
        |> addIfEmpty ( x - 1, y ) board
        |> addIfEmpty ( x, y + 1 ) board
        |> addIfEmpty ( x, y - 1 ) board


{-| Given a point and a set, add the point to the set if that point is empty and in-bounds
-}
addIfEmpty : Point -> Board -> EverySet Point -> EverySet Point
addIfEmpty ( x, y ) board set =
    if
        (getStone ( x, y ) board == Nothing)
            && (x >= 0)
            && (y >= 0)
            && (x < Array.length board)
            && (y < Array.length board)
    then
        EverySet.insert ( x, y ) set
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


placeStoneNoChecks : Stone -> Point -> Board -> Board
placeStoneNoChecks stone ( x, y ) board =
    case Array.get x board of
        Just row ->
            Array.set x (Array.set y (Just stone) row) board

        Nothing ->
            board


oppositeColor : Stone -> Stone
oppositeColor stone =
    case stone of
        Black ->
            White

        White ->
            Black


getAdjacentEnemyStones : Point -> Board -> EverySet Point
getAdjacentEnemyStones ( x, y ) board =
    let
        enemyColor =
            Maybe.map oppositeColor (getStone ( x, y ) board)
    in
    [ ( x + 1, y ), ( x - 1, y ), ( x, y + 1 ), ( x, y - 1 ) ]
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
        |> placeStoneNoChecks stone point
        |> removeAdjacentCaptured point
        |> preventSuicide point


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


findTerritoryBoundaries : EverySet Point -> Board -> EverySet Point
findTerritoryBoundaries points board =
    points
        |> EverySet.toList
        |> List.map (\point -> EverySet.toList (findPointBoundaries point board))
        |> List.concat
        |> EverySet.fromList


findPointBoundaries : Point -> Board -> EverySet Point
findPointBoundaries ( x, y ) board =
    EverySet.empty
        |> addIfStone ( x + 1, y ) board
        |> addIfStone ( x - 1, y ) board
        |> addIfStone ( x, y + 1 ) board
        |> addIfStone ( x, y - 1 ) board


{-| Possibly combine this with "addIfEmpty"
-}
addIfStone : Point -> Board -> EverySet Point -> EverySet Point
addIfStone ( x, y ) board set =
    if
        (getStone ( x, y ) board /= Nothing)
            && (x >= 0)
            && (y >= 0)
            && (x < Array.length board)
            && (y < Array.length board)
    then
        EverySet.insert ( x, y ) set
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
possibly store the territories in the model and
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
        (getAllCombinations (List.range 0 18))



{-
   - before placing a stone, find the chain of the selected intersection.
   - calculate the areas for the intersections adjacent to the placed stone.
   - remove the first chain from the model, then add the new ones
-}


territoryCount : Stone -> EverySet Territory -> Int
territoryCount stone territories =
    territories
        |> EverySet.filter (\territory -> territory.owner == Just stone)
        |> EverySet.foldl (\territory total -> total + EverySet.size territory.points) 0
