module View.Board exposing (..)

import Array exposing (Array)
import Constants exposing (boardPadding, stonePadding, stoneRadius, stoneSize)
import Html.Events exposing (onClick)
import Model exposing (Board, Model, Point, Stone(..))
import Msg exposing (Msg(..))
import Svg exposing (..)
import Svg.Attributes exposing (..)


drawBoard : Board -> Svg Msg
drawBoard board =
    svg
        [ class "game-board"
        , width (toString (Array.length board * stoneSize + (stoneSize * 2)))
        , height (toString (Array.length board * stoneSize + (stoneSize * 2)))
        ]
        ([ drawBoardBackground board ]
            ++ drawLines board
            ++ drawStones board
        )


colorToHex : Stone -> String
colorToHex stone =
    case stone of
        White ->
            "#eee"

        Black ->
            "#333"


drawStone : Maybe Stone -> Point -> Svg Msg
drawStone maybeStone ( x, y ) =
    case maybeStone of
        Just stone ->
            circle
                [ cx (toString (x * stoneSize + stoneSize + stoneRadius + 2))
                , cy (toString (y * stoneSize + stoneSize + stoneRadius + 2))
                , r (toString stoneRadius)
                , Svg.Attributes.style ("fill: " ++ colorToHex stone)
                ]
                []

        Nothing ->
            rect
                [ Svg.Attributes.x (toString (x * stoneSize + stoneSize))
                , Svg.Attributes.y (toString (y * stoneSize + stoneSize))
                , width (toString stoneSize)
                , height (toString stoneSize)
                , class "empty-space"
                , onClick (PlaceStone ( x, y ))
                ]
                []


filterEmptyStones : Array (Maybe Stone) -> List Stone
filterEmptyStones stones =
    stones
        |> Array.toList
        |> List.filterMap
            (\maybeStone ->
                case maybeStone of
                    Just stone ->
                        Just stone

                    Nothing ->
                        Nothing
            )


drawStones : Board -> List (Svg Msg)
drawStones board =
    board
        |> Array.indexedMap
            (\x col ->
                col
                    |> Array.indexedMap
                        (\y stone ->
                            drawStone stone ( x, y )
                        )
                    |> Array.toList
            )
        |> Array.toList
        |> List.concat


drawBoardBackground : Board -> Svg Msg
drawBoardBackground board =
    rect
        [ x "0"
        , y "0"
        , width (toString (Array.length board * stoneSize + (stoneSize * 2)))
        , height (toString (Array.length board * stoneSize + (stoneSize * 2)))
        , fill "#da5"
        ]
        []


drawVerticalLine : Board -> Int -> Svg Msg
drawVerticalLine board y =
    line
        [ x1 (toString boardPadding)
        , y1 (toString (y * stoneSize + boardPadding))
        , x2 (toString (Array.length board * stoneSize + stoneRadius + stonePadding))
        , y2 (toString (y * stoneSize + boardPadding))
        , stroke "#333"
        ]
        []


drawHorizontalLine : Board -> Int -> Svg Msg
drawHorizontalLine board y =
    line
        [ x1 (toString (y * stoneSize + boardPadding))
        , y1 (toString boardPadding)
        , x2 (toString (y * stoneSize + boardPadding))
        , y2 (toString (Array.length board * stoneSize + stoneRadius + stonePadding))
        , stroke "#333"
        ]
        []


drawLines : Board -> List (Svg Msg)
drawLines board =
    (Array.toList (Array.initialize (Array.length board) identity)
        |> List.map
            (\x ->
                drawVerticalLine board x
            )
    )
        ++ (Array.toList
                (Array.initialize (Array.length board) identity)
                |> List.map
                    (\x ->
                        drawHorizontalLine board x
                    )
           )
