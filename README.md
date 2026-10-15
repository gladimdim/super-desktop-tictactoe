# TicTacToe for SUPER DESKTOP

A simple tic-tac-toe game on a card on the
[SUPER DESKTOP](https://github.com/gladimdim/super-desktop) desktop: a big
board and the score beside it. Play the computer or a friend.

| Your turn | The computer wins | Two players, a draw |
| --- | --- | --- |
| ![A game in progress](docs/game.png) | ![The computer's winning line highlighted](docs/win.png) | ![A full board in two-player mode](docs/duo.png) |

## Use it

- **Click a square** to play. Against the computer you are X; in
  **2 Players** mode X and O take turns at one mouse. The other player starts
  the next game.
- **The score** (you, draws, computer) is on the right; the player to move is
  outlined. Each mode keeps its own score; **Reset** clears it.
- **New game**, or a click on a finished board, starts the next game.
- The computer wins when it can, blocks you when it must, and likes the centre
  and corners. A fork beats it.

The game is a card like the notes and terminals: drag it, resize it, let
Arrange place it. It opens by itself the first time the plugin loads. After
that SUPER DESKTOP remembers it: start SUPER DESKTOP again and the game is
there, where you left it, if it was open; closed with ✕, it stays closed.
The small **#** in the top bar opens and closes it. To turn it off
completely, use Settings → Plugins. The game in progress and the score
survive closing the card and restarting SUPER DESKTOP. Colors come from your
Omarchy theme.

## Install

Needs SUPER DESKTOP 1.6.0 or newer.

```sh
super-desktop plugin install https://github.com/gladimdim/super-desktop-tictactoe
super-desktop plugin approve tictactoe
```

Or approve it in Settings → Plugins, where **Ask AI to review** reads it first.

Already installed? `super-desktop plugin update tictactoe`.

## What it does on your PC

- Saves the board, the mode, the score and whether it has shown itself once
  in SUPER DESKTOP's plugin values
  (`~/.local/state/super-desktop/plugins/tictactoe.data.json`).
- Asks SUPER DESKTOP to open or close its own card (`card.open`,
  `card.toggle`). SUPER DESKTOP keeps the card's place and whether it is open
  (`tictactoe.cards.json` next to the values).
- Nothing else: no network, no other files, no programs.

## Change it

It is plain QML: edit a file and SUPER DESKTOP reloads it. `AGENTS.md`
describes how it works for an AI agent; `super-desktop plugin check tictactoe`
and `super-desktop plugin snapshot tictactoe --surface game` check your edits.

## Versions

- **1.1.0**: the game is a card, so SUPER DESKTOP starts with it open or
  closed as you left it. It opens by itself only the first time; # opens and
  closes it.
- **1.0.1**: a closed game stayed closed until # was clicked.
- **1.0.0**: first version.

## License

MIT
