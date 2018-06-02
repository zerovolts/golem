module View.Board exposing (..)

import Array exposing (Array)
import Constants exposing (boardPadding, stonePadding, stoneRadius, stoneSize)
import EverySet exposing (EverySet)
import Game exposing (getPointTerritory)
import Html.Events exposing (onClick)
import Model exposing (Board, Model, Stone(..), Territory)
import Msg exposing (Msg(..))
import Point exposing (Point)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Util


drawBoard : Board -> EverySet Territory -> Svg Msg
drawBoard board territories =
    svg
        [ class "game-board"
        , width (toString (Array.length board * stoneSize + (stoneSize * 2)))
        , height (toString (Array.length board * stoneSize + (stoneSize * 2)))
        ]
        ([ drawBoardBackground board ]
            ++ drawLines board
            ++ drawDots board
            ++ drawStones board territories
        )


colorToHex : Stone -> String
colorToHex stone =
    case stone of
        White ->
            "#eee"

        Black ->
            "#333"


drawTerritory : Point -> EverySet Territory -> String
drawTerritory point territories =
    case getPointTerritory point territories of
        Just White ->
            "white-territory"

        Just Black ->
            "black-territory"

        Nothing ->
            "empty-space"


drawStone : Maybe Stone -> Point -> EverySet Territory -> Svg Msg
drawStone maybeStone ( x, y ) territories =
    case maybeStone of
        Just stone ->
            g []
                [ rect
                    [ Svg.Attributes.x (toString (x * stoneSize + stoneSize))
                    , Svg.Attributes.y (toString (y * stoneSize + stoneSize))
                    , width (toString stoneSize)
                    , height (toString stoneSize)
                    , class "intersection empty-space"
                    ]
                    []
                , circle
                    [ cx (toString (x * stoneSize + stoneSize + stoneRadius + 2))
                    , cy (toString (y * stoneSize + stoneSize + stoneRadius + 2))
                    , r (toString stoneRadius)
                    , Svg.Attributes.style ("fill: " ++ colorToHex stone)
                    , class "stone"
                    ]
                    []
                ]

        Nothing ->
            rect
                [ Svg.Attributes.x (toString (x * stoneSize + stoneSize))
                , Svg.Attributes.y (toString (y * stoneSize + stoneSize))
                , width (toString stoneSize)
                , height (toString stoneSize)
                , class ("intersection " ++ drawTerritory ( x, y ) territories)
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


drawStones : Board -> EverySet Territory -> List (Svg Msg)
drawStones board territories =
    board
        |> Array.indexedMap
            (\x col ->
                col
                    |> Array.indexedMap
                        (\y stone ->
                            drawStone stone ( x, y ) territories
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


drawDot : Point -> Svg Msg
drawDot ( x, y ) =
    circle
        [ cx (toString (x * stoneSize + boardPadding))
        , cy (toString (y * stoneSize + boardPadding))
        , r "3px"
        , Svg.Attributes.style "fill: #333"
        ]
        []


drawDots : Board -> List (Svg Msg)
drawDots board =
    let
        boardLen =
            Array.length board - 1
    in
    List.map
        (\point -> drawDot point)
        (Util.getAllCombinations [ 3, boardLen // 2, boardLen - 3 ])
