module View exposing (..)

import Array exposing (Array)
import Constants exposing (boardPadding, stonePadding, stoneRadius, stoneSize)
import Html exposing (..)
import Html.Attributes exposing (href, rel)
import Model exposing (Board, Model, Stone(..))
import Msg exposing (Msg)
import Svg exposing (..)
import Svg.Attributes exposing (..)


stylesheet : String -> Html Msg
stylesheet name =
    Html.node "link"
        [ rel "stylesheet", href ("./styles/" ++ name ++ ".css") ]
        []


view : Model -> Html Msg
view model =
    div
        [ class "horizontal-container" ]
        [ div [ class "vertical-container" ]
            [ stylesheet "main"
            , svg
                [ class "game-board"
                , width (toString (Array.length model.board * stoneSize + (stoneSize * 2)))
                , height (toString (Array.length model.board * stoneSize + (stoneSize * 2)))
                ]
                ([ drawBoard model.board ]
                    ++ drawLines model.board
                    ++ drawStones model.board
                )
            ]
        ]


colorToHex : Stone -> String
colorToHex stone =
    case stone of
        White ->
            "#eee"

        Black ->
            "#333"


drawStone : Stone -> Int -> Int -> Svg Msg
drawStone stone x y =
    circle
        [ cx (toString (x * stoneSize + stoneSize + stoneRadius + 2))
        , cy (toString (y * stoneSize + stoneSize + stoneRadius + 2))
        , r (toString stoneRadius)
        , Svg.Attributes.style ("fill: " ++ colorToHex stone)
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
                    |> filterEmptyStones
                    |> List.indexedMap
                        (\y stone ->
                            drawStone stone x y
                        )
            )
        |> Array.toList
        |> List.concat


drawBoard : Board -> Svg Msg
drawBoard board =
    rect
        [ x "0"
        , y "0"
        , width (toString (Array.length board * stoneSize + (stoneSize * 2)))
        , height (toString (Array.length board * stoneSize + (stoneSize * 2)))
        , fill "#dc5"
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
