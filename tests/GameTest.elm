module GameTest exposing (..)

import EverySet
import Expect exposing (Expectation)
import Game
    exposing
        ( findAreaOwner
        , findChain
        , findLiberties
        , findStoneLiberties
        , getStone
        , newBoard
        , placeStoneNoChecks
        )
import Model exposing (Board, Stone(..))
import Test exposing (..)


{-| Board Layout

    - B W - -
    B B B W -
    - W B - W
    - - - - -
    - - - - -

-}
board : Board
board =
    newBoard 5
        |> placeStoneNoChecks Black ( 1, 0 )
        |> placeStoneNoChecks Black ( 0, 1 )
        |> placeStoneNoChecks Black ( 1, 1 )
        |> placeStoneNoChecks Black ( 2, 1 )
        |> placeStoneNoChecks Black ( 2, 2 )
        |> placeStoneNoChecks White ( 4, 2 )
        |> placeStoneNoChecks White ( 2, 0 )
        |> placeStoneNoChecks White ( 3, 1 )
        |> placeStoneNoChecks White ( 1, 2 )


suite : Test
suite =
    describe "The game functions"
        [ describe "Game.getStone"
            [ test "correctly returns black pieces" <|
                \_ -> Expect.equal (getStone ( 1, 0 ) board) (Just Black)
            , test "correctly returns white pieces" <|
                \_ -> Expect.equal (getStone ( 2, 0 ) board) (Just White)
            , test "correctly returns nothing" <|
                \_ -> Expect.equal (getStone ( 1, 3 ) board) Nothing
            ]
        , describe "Game.findChain"
            [ test "returns all connected pieces" <|
                \_ ->
                    Expect.equal
                        (findChain ( 2, 2 ) board)
                        (EverySet.fromList [ ( 1, 0 ), ( 0, 1 ), ( 1, 1 ), ( 2, 1 ), ( 2, 2 ) ])
            , test "returns all connected empty intersections" <|
                \_ ->
                    Expect.equal
                        (findChain ( 3, 0 ) board)
                        (EverySet.fromList [ ( 3, 0 ), ( 4, 0 ), ( 4, 1 ) ])
            ]
        , describe "Game.findStoneLiberties"
            [ test "returns all adjacent liberties" <|
                \_ ->
                    Expect.equal
                        (findStoneLiberties ( 3, 1 ) board)
                        (EverySet.fromList [ ( 3, 0 ), ( 4, 1 ), ( 3, 2 ) ])
            ]
        , describe "Game.findLiberties"
            [ test "returns all liberties for a chain" <|
                \_ ->
                    Expect.equal
                        (findLiberties ( 1, 1 ) board)
                        (EverySet.fromList [ ( 0, 0 ), ( 0, 2 ), ( 2, 3 ), ( 3, 2 ) ])
            ]
        , describe "Game.findAreaOwner"
            [ test "returns Black when area is surrounded by Black pieces" <|
                \_ ->
                    Expect.equal
                        (findAreaOwner (findChain ( 0, 0 ) board) board)
                        (Just Black)
            , test "returns White when area is surrounded by White pieces" <|
                \_ ->
                    Expect.equal
                        (findAreaOwner (findChain ( 3, 0 ) board) board)
                        (Just White)
            , test "returns Nothing when area is surrounded by both White and Black pieces" <|
                \_ ->
                    Expect.equal
                        (findAreaOwner (findChain ( 0, 4 ) board) board)
                        Nothing
            ]
        ]
