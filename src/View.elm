module View exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick)
import Model exposing (Board, Model, Point, Stone(..))
import Msg exposing (Msg(..))
import Svg.Attributes exposing (..)
import View.Board exposing (drawBoard)
import View.Helpers exposing (stylesheet)


view : Model -> Html Msg
view model =
    div
        [ class "horizontal-container" ]
        [ div [ class "vertical-container" ]
            [ stylesheet "main"
            , drawBoard model.board
            , div [] [ Html.text ("Turn Number: " ++ toString model.turnNumber) ]
            , div [] [ Html.text ("Turn: " ++ toString model.turn) ]
            , case model.gameOver of
                True ->
                    div [] [ Html.text "Game Over!" ]

                False ->
                    Html.button [ onClick Pass, width "6rem" ] [ Html.text "Pass" ]
            ]
        ]
