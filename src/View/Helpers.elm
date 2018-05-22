module View.Helpers exposing (..)

import Html exposing (Html)
import Html.Attributes exposing (href, rel)
import Msg exposing (Msg)


stylesheet : String -> Html Msg
stylesheet name =
    Html.node "link"
        [ rel "stylesheet", href ("./styles/" ++ name ++ ".css") ]
        []
