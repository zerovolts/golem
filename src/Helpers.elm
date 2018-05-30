module Helpers exposing (..)


getAllCombinations : List a -> List ( a, a )
getAllCombinations list =
    List.concat (List.map (\x -> List.map (\y -> ( x, y )) list) list)
