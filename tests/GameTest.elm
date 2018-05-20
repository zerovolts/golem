module GameTest exposing (..)

import Expect exposing (Expectation)
import Game exposing (findChain, findLiberties, findStoneLiberties, getStone)
import Main exposing (newBoard)
import Model exposing (Board, Stone(..))
import Set
import Test exposing (..)
import Update exposing (placeStone)


{-| Board Layout

    - B W - -
    B B B W -
    - W B - B
    - - - - -
    - - - - -

-}
board : Board
board =
    newBoard 5
        |> placeStone Black ( 1, 0 )
        |> placeStone Black ( 0, 1 )
        |> placeStone Black ( 1, 1 )
        |> placeStone Black ( 2, 1 )
        |> placeStone Black ( 2, 2 )
        |> placeStone Black ( 4, 2 )
        |> placeStone White ( 2, 0 )
        |> placeStone White ( 3, 1 )
        |> placeStone White ( 1, 2 )


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
                        (Set.fromList (findChain ( 2, 2 ) board))
                        (Set.fromList [ ( 1, 0 ), ( 0, 1 ), ( 1, 1 ), ( 2, 1 ), ( 2, 2 ) ])
            ]
        , describe "Game.findStoneLiberties"
            [ test "returns all adjacent liberties" <|
                \_ ->
                    Expect.equal
                        (findStoneLiberties ( 3, 1 ) board)
                        (Set.fromList [ ( 3, 0 ), ( 4, 1 ), ( 3, 2 ) ])
            ]
        , describe "Game.findLiberties"
            [ test "returns all liberties for a chain" <|
                \_ ->
                    Expect.equal
                        (findLiberties (findChain ( 1, 1 ) board) board)
                        (Set.fromList [ ( 0, 0 ), ( 0, 2 ), ( 2, 3 ), ( 3, 2 ) ])
            ]
        ]
