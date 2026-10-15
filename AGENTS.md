# SUPER DESKTOP plugin: TicTacToe

This folder is a SUPER DESKTOP plugin (QML). SUPER DESKTOP reloads it on
screen every time a file here is saved.

Before changing anything, read `.claude/skills/super-desktop-plugin/SKILL.md`
and follow its loop:

1. edit the QML or plugin.json;
2. `super-desktop plugin check tictactoe --json` and fix every error and warning;
3. `super-desktop plugin snapshot tictactoe --out /tmp/tictactoe.png --json` (add
   `--surface <id>` for each surface), then open the PNG and look at it;
4. click through it like a user: `snapshot ... --do 'click "OK"; type hi;
   expect "hi"'` for every button and form;
5. `super-desktop plugin logs tictactoe` for runtime errors.

Keep the plugin id `tictactoe` (it must equal the folder name). You may change
the slots, add surfaces and files, and rewrite the starting QML entirely.

## What it does

A tic-tac-toe game on a card (`Game.qml`, surface `game`, slot `card`) on the
SUPER DESKTOP desktop. A card, not a panel, on purpose: SUPER DESKTOP saves
a card's place and whether it is open, and reopens it after a restart only if
it was open, so the game comes back exactly as the user left it. A panel
cannot do that (a plugin never learns that its panel was closed with ✕).

The top-bar item (`Toolbar.qml`, surface `button`, a small # icon) calls
`card.open` once in `Component.onCompleted` the very first time the plugin
loads, when `sd.values.shown` is not yet `true`, and sets `shown` once the
call succeeds. After that it never opens the card by itself: a click on #
calls `card.toggle`, and SUPER DESKTOP restores an open card at start. Do
not open the card from `sd.visibleChanged`, a timer or a change of values,
and do not drop the `shown` check: it is what lets a closed game stay
closed across restarts.

The board is on the left, as large as the card allows; a column on its right
holds the mode switch (vs CPU / 2 Players), the score (one row each for X,
draws and O, the player to move outlined), the status and New game / Reset.
`Mark.qml` draws X and O with plain shapes.

Everything is in `sd.values`: `board` (9 of `""`, `"X"`, `"O"`), `first` (who
started this game; it alternates), `mode` (`"cpu"` or `"duo"`), `score`
(`{cpu: {X, O, draw}, duo: {...}}`) and `shown` (the card was opened once).
Only the game writes the first four; only the toolbar item writes `shown`.
`ttt.js` holds the rules (`winner`, `turn`, `full`), the computer player
(`cpuMove`: win, block, centre, corner) and the theme color checks. In `cpu`
mode the player is X and the computer O, moving 450 ms after the player.

Needs SUPER DESKTOP 1.6.0 or newer (the `card` slot).
