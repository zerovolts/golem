module View exposing (..)

import Game exposing (territoryCount)
import Html exposing (..)
import Html.Attributes
import Html.Events exposing (onClick)
import Model exposing (Board, Game, GameOptions, GameStatus(..), GameType(..), Model, Page(..), Stone(..))
import Msg exposing (Msg(..))
import Svg.Attributes exposing (..)
import View.Board exposing (drawBoard)
import View.Util exposing (stylesheet)


view : Model -> Html Msg
view model =
    case model.page of
        MainMenu ->
            viewMainMenu model.gameOptions

        GameScreen ->
            viewGameScreen model.game


viewMainMenu : GameOptions -> Html Msg
viewMainMenu gameOptions =
    div
        [ class "horizontal-container" ]
        [ div [ class "vertical-container" ]
            [ stylesheet "main"
            , Html.h1 [] [ Html.text "Golem" ]
            , div []
                [ radio "game-type"
                    (toString gameOptions.gameType)
                    [ ( "Local", ChangeGameType Local )
                    , ( "Computer", ChangeGameType Computer )
                    , ( "Online", ChangeGameType Online )
                    ]
                , radio "preferred-color"
                    (toString gameOptions.preferredColor)
                    [ ( "Black", ChangeColor Black )
                    , ( "White", ChangeColor White )
                    ]
                , Html.button [ onClick StartGame ] [ Html.text "Start Game!" ]
                ]
            , div [ Html.Attributes.style [ ( "height", "4rem" ) ] ] []
            ]
        ]


radio : String -> String -> List ( String, Msg ) -> Html Msg
radio name selected textMsgPairs =
    Html.fieldset [ Html.Attributes.class "radio-horizontal" ]
        (List.map
            (\( text, msg ) ->
                [ Html.input
                    [ Html.Attributes.name name
                    , Html.Attributes.checked (selected == text)
                    , Html.Attributes.id text
                    , Html.Attributes.type_ "radio"
                    , Html.Events.onClick msg
                    ]
                    []
                , Html.label
                    [ Html.Attributes.for text ]
                    [ Html.text text ]
                ]
            )
            textMsgPairs
            |> List.concat
        )


viewGameScreen : Game -> Html Msg
viewGameScreen game =
    div [ class "container" ]
        [ sideBar game
        , div
            [ class "horizontal-container" ]
            [ div [ class "vertical-container" ]
                [ stylesheet "main"
                , drawBoard game.board game.territories
                ]
            ]
        ]


sideBar : Game -> Html Msg
sideBar game =
    let
        blackTerritory =
            territoryCount Black game.territories

        whiteTerritory =
            territoryCount White game.territories
    in
    div
        [ class "side-bar" ]
        [ div []
            [ h2 [] [ Html.text "囲碁：Golem" ]
            , hr [] []
            , kvPair "Turn Counter" (toString game.turnCount)
            , kvPair "Turn" (toString game.turn)
            , kvPair "Black Territory" (toString blackTerritory)
            , kvPair "White Territory" (toString whiteTerritory)
            ]
        , case game.gameStatus of
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
