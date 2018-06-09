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

- Connected - Two stones are connected if they are the same color and adjacent (not diagonal) to each other.
- Chain - A set of one or more stones that are all connected to each other.
- Liberties - Empty intersections surrounding a chain. If there are none, the chain is "captured" and removed from the board.
- Territory - A chain of empty intersections. A territory is owned by black (for instance) if it is completely surrounded by black stones or the edge of the board.

## Implemented Features

- Stone Placement - Can place stones on any empty intersection (color alternates between black and white).
- Capture - Any chains adjacent to the placed stone are removed if they no longer have any liberties.
- Suicide Prevention - If placing a stone will immediately remove it from the board (after any captures), the move is blocked.
- Territory Calculations - Territories are recalculated each turn and colored according to their respective owner.
- End of Game Scoring - Once both players have passed, the game ends and the player with more territory wins.

## Planned Features

- Eye calculation - An empty point surrounded by one player's stones.
- Life calculation - A chain is alive if it has 2 or more eyes.
- Rule of Ko - Prevents the repetition of a position in which a single stone is captured, then immediately taken back.
- Recolor or highlight the chain that is currently being hovered over.
- Recolor or highlight any chains which are alive.
- Seki - Prevents stones from being played in a "mutual life" area; Suicide calculation may need to be rewritten for this.
- Superko - Repeating any previous board state is disallowed.
