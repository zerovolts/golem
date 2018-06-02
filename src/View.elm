module View exposing (..)

import Game exposing (territoryCount)
import Html exposing (..)
import Html.Events exposing (onClick)
import Model exposing (Board, GameStatus(..), Model, Stone(..))
import Msg exposing (Msg(..))
import Svg.Attributes exposing (..)
import View.Board exposing (drawBoard)
import View.Util exposing (stylesheet)


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ sideBar model
        , div
            [ class "horizontal-container" ]
            [ div [ class "vertical-container" ]
                [ stylesheet "main"
                , drawBoard model.game.board model.game.territories
                ]
            ]
        ]


sideBar : Model -> Html Msg
sideBar model =
    let
        blackTerritory =
            territoryCount Black model.game.territories

        whiteTerritory =
            territoryCount White model.game.territories
    in
    div
        [ class "side-bar" ]
        [ div []
            [ h2 [] [ Html.text "囲碁：Golem" ]
            , hr [] []
            , kvPair "Turn Counter" (toString model.game.turnCount)
            , kvPair "Turn" (toString model.game.turn)
            , kvPair "Black Territory" (toString blackTerritory)
            , kvPair "White Territory" (toString whiteTerritory)
            ]
        , case model.game.gameStatus of
            Over ->
                div [] [ Html.text ("Game Over! " ++ winString blackTerritory whiteTerritory) ]

            _ ->
                div []
                    [ Html.button [ onClick ComputerMove ] [ Html.text "Computer" ]
                    , Html.button [ onClick Pass ] [ Html.text "Pass" ]
                    ]
        ]


winString : Int -> Int -> String
winString blackTerritory whiteTerritory =
    case compare blackTerritory whiteTerritory of
        LT ->
            "White Wins!"

        GT ->
            "Black Wins!"

        EQ ->
            "Tie game!"


kvPair : String -> String -> Html Msg
kvPair key value =
    div []
        [ Html.span [ class "dark-text" ] [ Html.text (key ++ ": ") ]
        , Html.text value
        ]
