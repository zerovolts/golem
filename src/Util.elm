module Util exposing (..)


getAllGridCombinations : List a -> List b -> List ( a, b )
getAllGridCombinations xValues yValues =
    List.concat (List.map (\x -> List.map (\y -> ( x, y )) yValues) xValues)


getAllCombinations : List a -> List ( a, a )
getAllCombinations list =
    getAllGridCombinations list list
