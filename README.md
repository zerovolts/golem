# Golem

This project is an implementation of the [Go board game](<https://en.wikipedia.org/wiki/Go_(game)>) using the [Elm programming language](http://elm-lang.org/).

## Usage

```console
λ git clone https://github.com/zerovolts/golem.git
λ cd golem
λ elm-reactor
```

Then navigate to `localhost:8000`

## Definitions

* Connected - Two stones are connected if they are the same color and adjacent (not diagonal) to each other.
* Chain - A set of one or more stones that are all connected to each other.
* Liberties - Empty intersections surrounding a chain. If there are none, the chain is "captured" and removed from the board.
* Territory - A chain of empty intersections. A territory is owned by black (for instance) if it is completely surrounded by black stones or the edge of the board.

## Implemented Features

* Stone Placement - Can place stones on any empty intersection (color alternates between black and white).
* Capture - Any chains adjacent to the placed stone are removed if they no longer have any liberties.
* Suicide Prevention - If placing a stone will immediately remove it from the board (after any captures), the move is blocked.
* Territory Calculations - Territories are recalculated each turn and colored according to their respective owner.
* End of Game Scoring - Once both players have passed, the game ends and the player with more territory wins.
