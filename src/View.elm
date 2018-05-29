module View exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick)
import Model exposing (Board, GameStatus(..), Model, Point, Stone(..))
import Msg exposing (Msg(..))
import Svg.Attributes exposing (..)
import View.Board exposing (drawBoard)
import View.Helpers exposing (stylesheet)


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ sideBar model
        , div
            [ class "horizontal-container" ]
            [ div [ class "vertical-container" ]
                [ stylesheet "main"
                , drawBoard model.board
                ]
            ]
        ]


sideBar : Model -> Html Msg
sideBar model =
    div
        [ class "side-bar" ]
        [ div []
            [ h2 [] [ Html.text "囲碁：Golem" ]
            , hr [] []
            , kvPair "Turn Counter" (toString model.turnNumber)
            , kvPair "Turn" (toString model.turn)
            ]
        , case model.gameStatus of
            Over ->
                div [] [ Html.text "Game Over!" ]

            _ ->
                Html.button [ onClick Pass ] [ Html.text "Pass" ]
        ]


kvPair : String -> String -> Html Msg
kvPair key value =
    div []
        [ Html.span [ class "dark-text" ] [ Html.text (key ++ ": ") ]
        , Html.text value
        ]
