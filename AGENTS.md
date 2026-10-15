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

A tic-tac-toe game in a panel (`Panel.qml`, surface `game`) that is always
shown on the SUPER DESKTOP desktop. Panels only run while open, so the
top-bar item (`Toolbar.qml`, surface `button`, a small # icon) calls
`panel.open` when it loads, every time the overlay is shown
(`sd.visibleChanged`) and on a click. There is no way to close it for good
except turning the plugin off in Settings → Plugins; keep it that way.

The board is on the left, as large as the panel allows; a column on its right
holds the mode switch (vs CPU / 2 Players), the score (one row each for X,
draws and O, the player to move outlined), the status and New game / Reset.
`Mark.qml` draws X and O with plain shapes.

Everything is in `sd.values`: `board` (9 of `""`, `"X"`, `"O"`), `first` (who
started this game; it alternates), `mode` (`"cpu"` or `"duo"`) and `score`
(`{cpu: {X, O, draw}, duo: {...}}`). Only the panel writes them. `ttt.js` holds
the rules (`winner`, `turn`, `full`), the computer player (`cpuMove`: win,
block, centre, corner) and the theme color checks. In `cpu` mode the player
is X and the computer O, moving 450 ms after the player.

Needs SUPER DESKTOP 1.6.0 or newer.
