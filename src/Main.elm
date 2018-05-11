module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (href, rel)
import Svg exposing (..)
import Svg.Attributes exposing (..)


main =
    Html.beginnerProgram { model = model, view = view, update = update }


type alias Model =
    Int


model : Int
model =
    0


type Msg
    = Nothing


update : Msg -> Model -> Model
update msg model =
    case msg of
        Nothing ->
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
                , width "320"
                , height "320"
                ]
                [ board
                , stone White 32 32
                , stone Black 100 100
                ]
            ]
        ]


type Color
    = Black
    | White


colorToHex : Color -> String
colorToHex c =
    case c of
        White ->
            "#eee"

        Black ->
            "#333"


stone : Color -> Int -> Int -> Svg Msg
stone c x y =
    circle
        [ cx (toString x)
        , cy (toString y)
        , r "16"
        , Svg.Attributes.style ("fill: " ++ colorToHex c)
        ]
        []


board : Svg Msg
board =
    rect
        [ x "0"
        , y "0"
        , width "320"
        , height "320"
        , fill "#dc6"
        ]
        []
