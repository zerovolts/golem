module Game exposing (..)

import Array
import Model exposing (Board, Point, Stone(..))
import Set exposing (Set)


newBoard : Int -> Board
newBoard size =
    Array.initialize size
        (\x ->
            Array.initialize size
                (\y ->
                    Nothing
                )
        )


getStone : Point -> Board -> Maybe Stone
getStone ( x, y ) board =
    case Array.get x board of
        Just col ->
            case Array.get y col of
                Just stone ->
                    stone

                Nothing ->
                    Nothing

        Nothing ->
            Nothing


{-| Given a position, returns a list of all positions connected to it.
-}
findChain : Point -> Board -> Set Point
findChain point board =
    findChainIntermediate point (getStone point board) board Set.empty


findChainIntermediate : Point -> Maybe Stone -> Board -> Set Point -> Set Point
findChainIntermediate ( x, y ) stone board set =
    if
        (getStone ( x, y ) board == stone)
            && not (Set.member ( x, y ) set)
            && (x >= 0)
            && (y >= 0)
            && (x < Array.length board)
            && (y < Array.length board)
    then
        Set.insert ( x, y ) set
            |> findChainIntermediate ( x + 1, y ) stone board
            |> findChainIntermediate ( x - 1, y ) stone board
            |> findChainIntermediate ( x, y + 1 ) stone board
            |> findChainIntermediate ( x, y - 1 ) stone board
    else
        set


findLiberties : Point -> Board -> Set Point
findLiberties point board =
    findChainLiberties (findChain point board) board


{-| Given a chain, returns a list of all surrounding liberties
-}
findChainLiberties : Set Point -> Board -> Set Point
findChainLiberties points board =
    points
        |> Set.toList
        |> List.map (\point -> Set.toList (findStoneLiberties point board))
        |> List.concat
        |> Set.fromList


{-| Given a position, returns the set of adjacent liberties
-}
findStoneLiberties : Point -> Board -> Set Point
findStoneLiberties ( x, y ) board =
    Set.empty
        |> addIfEmpty ( x + 1, y ) board
        |> addIfEmpty ( x - 1, y ) board
        |> addIfEmpty ( x, y + 1 ) board
        |> addIfEmpty ( x, y - 1 ) board


{-| Given a point and a set, add the point to the set if that point is empty and in-bounds
-}
addIfEmpty : Point -> Board -> Set Point -> Set Point
addIfEmpty ( x, y ) board set =
    if
        (getStone ( x, y ) board == Nothing)
            && (x >= 0)
            && (y >= 0)
            && (x < Array.length board)
            && (y < Array.length board)
    then
        Set.insert ( x, y ) set
    else
        set


checkLegal : Stone -> Point -> Board -> Bool
checkLegal stone point board =
    True


checkCapture : Stone -> Point -> Board -> Board
checkCapture stone point board =
    board


removeStone : Point -> Board -> Board
removeStone ( x, y ) board =
    case Array.get x board of
        Just row ->
            Array.set x (Array.set y Nothing row) board

        Nothing ->
            board


removeChain : Set Point -> Board -> Board
removeChain points board =
    List.foldl (\point board -> removeStone point board) board (Set.toList points)


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


getAdjacentEnemyStones : Point -> Board -> Set Point
getAdjacentEnemyStones ( x, y ) board =
    let
        enemyColor =
            Maybe.map oppositeColor (getStone ( x, y ) board)
    in
    [ ( x + 1, y ), ( x - 1, y ), ( x, y + 1 ), ( x, y - 1 ) ]
        |> Set.fromList
        |> Set.filter (\point -> getStone point board == enemyColor)


adjacentCapturedEnemyChains : Point -> Board -> List (Set Point)
adjacentCapturedEnemyChains point board =
    Set.toList (getAdjacentEnemyStones point board)
        |> List.map (\point -> findChain point board)
        |> List.filter (\chain -> Set.size (findChainLiberties chain board) == 0)


removeAdjacentCaptured : Point -> Board -> Board
removeAdjacentCaptured point board =
    List.foldl
        (\chain board -> removeChain chain board)
        board
        (adjacentCapturedEnemyChains point board)


preventSuicide : Point -> Board -> Maybe Board
preventSuicide point board =
    if Set.size (findLiberties point board) == 0 then
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


findAreaOwner : Set Point -> Board -> Maybe Stone
findAreaOwner points board =
    findAreaBoundaries points board
        |> Set.toList
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


findAreaBoundaries : Set Point -> Board -> Set Point
findAreaBoundaries points board =
    points
        |> Set.toList
        |> List.map (\point -> Set.toList (findPointBoundaries point board))
        |> List.concat
        |> Set.fromList


findPointBoundaries : Point -> Board -> Set Point
findPointBoundaries ( x, y ) board =
    Set.empty
        |> addIfStone ( x + 1, y ) board
        |> addIfStone ( x - 1, y ) board
        |> addIfStone ( x, y + 1 ) board
        |> addIfStone ( x, y - 1 ) board


{-| Possibly combine this with "addIfEmpty"
-}
addIfStone : Point -> Board -> Set Point -> Set Point
addIfStone ( x, y ) board set =
    if
        (getStone ( x, y ) board /= Nothing)
            && (x >= 0)
            && (y >= 0)
            && (x < Array.length board)
            && (y < Array.length board)
    then
        Set.insert ( x, y ) set
    else
        set
