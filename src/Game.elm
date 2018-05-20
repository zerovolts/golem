module Game exposing (..)

import Array
import Model exposing (Board, Point, Stone(..))
import Set exposing (Set)


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
findChain : Point -> Board -> List Point
findChain point board =
    Set.toList (findChainIntermediate point (getStone point board) board Set.empty)


findChainIntermediate : Point -> Maybe Stone -> Board -> Set Point -> Set Point
findChainIntermediate ( x, y ) stone board set =
    if (getStone ( x, y ) board == stone) && not (Set.member ( x, y ) set) then
        Set.insert ( x, y ) set
            |> findChainIntermediate ( x + 1, y ) stone board
            |> findChainIntermediate ( x - 1, y ) stone board
            |> findChainIntermediate ( x, y + 1 ) stone board
            |> findChainIntermediate ( x, y - 1 ) stone board
    else
        set


{-| TODO: Given a position, returns a list of all surrounding liberties
-}
findLiberties : List Point -> Board -> Set Point
findLiberties points board =
    points
        |> List.map (\point -> Set.toList (findStoneLiberties point board))
        |> List.concat
        |> Set.fromList


{-| TODO: Given a position, returns the set of adjacent liberties
-}
findStoneLiberties : Point -> Board -> Set Point
findStoneLiberties ( x, y ) board =
    Set.empty
        |> checkEmpty ( x + 1, y ) board
        |> checkEmpty ( x - 1, y ) board
        |> checkEmpty ( x, y + 1 ) board
        |> checkEmpty ( x, y - 1 ) board


checkEmpty : Point -> Board -> Set Point -> Set Point
checkEmpty ( x, y ) board set =
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
