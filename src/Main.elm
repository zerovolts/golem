module Main exposing (..)

import Array exposing (Array)
import Html exposing (..)
import Html.Attributes exposing (href, rel)
import Svg exposing (..)
import Svg.Attributes exposing (..)


stoneRadius : Int
stoneRadius =
    12


stonePadding : Int
stonePadding =
    2


stoneSize : Int
stoneSize =
    (stoneRadius * 2) + (stonePadding * 2)


main =
    Html.beginnerProgram { model = model, view = view, update = update }


type Color
    = Black
    | White
    | Empty


type alias GamePiece =
    { color : Color
    , x : Int
    , y : Int
    }


type alias Board =
    Array (Array Color)


type alias Model =
    { board : Board }


model : Model
model =
    { board = newBoard 19 }


type Msg
    = None


newBoard : Int -> Board
newBoard size =
    Array.initialize size
        (\x ->
            Array.initialize size
                (\y ->
                    Black
                )
        )


placeStone : Color -> Int -> Int -> Board -> Board
placeStone c x y board =
    case Array.get x board of
        Just row ->
            Array.set y (Array.set x c row) board

        Nothing ->
            board


update : Msg -> Model -> Model
update msg model =
    case msg of
        None ->
            model


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


colorToHex : Color -> String
colorToHex c =
    case c of
        White ->
            "#eee"

        Black ->
            "#333"

        Empty ->
            "#000"



-- diameter: 24px + 4px padding


drawStone : Color -> Int -> Int -> Svg Msg
drawStone c x y =
    circle
        [ cx (toString (x * stoneSize + stoneSize + stoneRadius + 2))
        , cy (toString (y * stoneSize + stoneSize + stoneRadius + 2))
        , r (toString stoneRadius)
        , Svg.Attributes.style ("fill: " ++ colorToHex c)
        ]
        []


drawStones : Board -> List (Svg Msg)
drawStones board =
    List.concat
        (Array.toList
            (board
                |> Array.indexedMap
                    (\i col ->
                        Array.toList
                            (Array.indexedMap
                                (\j piece ->
                                    drawStone piece i j
                                )
                                col
                            )
                    )
            )
        )


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
        [ x1 (toString (stoneSize + stoneRadius + stonePadding))
        , y1 (toString (y * stoneSize + (stoneSize + stoneRadius + stonePadding)))
        , x2 (toString (Array.length board * stoneSize + stoneRadius + stonePadding))
        , y2 (toString (y * stoneSize + (stoneSize + stoneRadius + stonePadding)))
        , stroke "#333"
        ]
        []


drawHorizontalLine : Board -> Int -> Svg Msg
drawHorizontalLine board y =
    line
        [ x1 (toString (y * stoneSize + (stoneSize + stoneRadius + stonePadding)))
        , y1 (toString (stoneSize + stoneRadius + stonePadding))
        , x2 (toString (y * stoneSize + (stoneSize + stoneRadius + stonePadding)))
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
