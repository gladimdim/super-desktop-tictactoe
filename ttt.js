.pragma library

// Tic-tac-toe rules and the computer player, as plain functions.
// A board is an array of 9 strings: "", "X" or "O", row by row.

var LINES = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8],   // rows
    [0, 3, 6], [1, 4, 7], [2, 5, 8],   // columns
    [0, 4, 8], [2, 4, 6]               // diagonals
]

function emptyBoard() { return ["", "", "", "", "", "", "", "", ""] }

// A copy of the saved board, or an empty one when nothing valid is saved.
function board(values) {
    var b = values && values.board
    if (!b || b.length !== 9) return emptyBoard()
    var out = []
    for (var i = 0; i < 9; i++) out.push(b[i] === "X" || b[i] === "O" ? b[i] : "")
    return out
}

// {mark: "X"|"O", line: [a, b, c]} when someone has three in a row, else null.
function winner(b) {
    for (var i = 0; i < LINES.length; i++) {
        var l = LINES[i]
        if (b[l[0]] && b[l[0]] === b[l[1]] && b[l[0]] === b[l[2]]) return { mark: b[l[0]], line: l }
    }
    return null
}

function full(b) {
    for (var i = 0; i < 9; i++) if (!b[i]) return false
    return true
}

// "X" or "O" to move; `first` ("X" or "O") started this game.
function turn(b, first) {
    var f = first === "O" ? "O" : "X", s = f === "X" ? "O" : "X"
    var nf = 0, ns = 0
    for (var i = 0; i < 9; i++) { if (b[i] === f) nf++; else if (b[i] === s) ns++ }
    return nf === ns ? f : s
}

// The square that completes a line of `mark`, or -1.
function finishing(b, mark) {
    for (var i = 0; i < LINES.length; i++) {
        var l = LINES[i], mine = 0, free = -1
        for (var j = 0; j < 3; j++) {
            if (b[l[j]] === mark) mine++
            else if (!b[l[j]]) free = l[j]
        }
        if (mine === 2 && free >= 0) return free
    }
    return -1
}

function pick(list) { return list[Math.floor(Math.random() * list.length)] }

// The computer's move for `mark`: win, else block, else the centre, else a
// free corner, else any square. Good, but a fork beats it.
function cpuMove(b, mark) {
    var other = mark === "X" ? "O" : "X"
    var m = finishing(b, mark)
    if (m >= 0) return m
    m = finishing(b, other)
    if (m >= 0) return m
    if (!b[4]) return 4
    var corners = [0, 2, 6, 8].filter(function(i) { return !b[i] })
    if (corners.length) return pick(corners)
    var free = []
    for (var i = 0; i < 9; i++) if (!b[i]) free.push(i)
    return free.length ? pick(free) : -1
}

// ── Colors that stay readable in every Omarchy theme ──────────────────────

function rgb(color) {
    var s = String(color)
    if (s.length === 9) s = "#" + s.slice(3)   // #aarrggbb
    var m = /^#?([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})$/i.exec(s)
    return m ? [parseInt(m[1], 16), parseInt(m[2], 16), parseInt(m[3], 16)] : [128, 128, 128]
}

function luminance(color) {
    var c = rgb(color).map(function(v) {
        v /= 255
        return v <= 0.03928 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4)
    })
    return 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2]
}

function contrast(a, b) {
    var la = luminance(a), lb = luminance(b)
    return (Math.max(la, lb) + 0.05) / (Math.min(la, lb) + 0.05)
}

// How far apart two colors look, 0..441 (distance in RGB).
function distance(a, b) {
    var x = rgb(a), y = rgb(b)
    return Math.sqrt(Math.pow(x[0] - y[0], 2) + Math.pow(x[1] - y[1], 2) + Math.pow(x[2] - y[2], 2))
}

// The first of the theme's colors `names` that reads on its background and
// is easy to tell from `avoid`, else the foreground.
function readable(theme, names, avoid) {
    for (var i = 0; i < names.length; i++) {
        var c = theme[names[i]]
        if (c && contrast(c, theme.background) >= 3 && (!avoid || distance(c, avoid) >= 120)) return c
    }
    return theme.foreground
}
