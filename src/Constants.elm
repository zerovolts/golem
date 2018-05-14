module Constants exposing (..)


stoneRadius : Int
stoneRadius =
    12


stonePadding : Int
stonePadding =
    2


stoneSize : Int
stoneSize =
    (stoneRadius * 2) + (stonePadding * 2)


boardPadding : Int
boardPadding =
    stoneSize + stoneRadius + stonePadding
