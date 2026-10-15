import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "ttt.js" as T

// The game, on a card. Everything is saved in sd.values (board, who started, mode,
// score), so a game survives the card closing and SUPER DESKTOP restarting.
Rectangle {
    id: game
    color: sd.theme.background

    readonly property string mode: sd.values.mode === "duo" ? "duo" : "cpu"
    readonly property string first: sd.values.first === "O" ? "O" : "X"
    readonly property var board: T.board(sd.values)
    readonly property var win: T.winner(board)
    readonly property bool over: win !== null || T.full(board)
    readonly property string current: T.turn(board, first)
    // In "cpu" mode the player is X and the computer is O.
    readonly property bool cpuToMove: mode === "cpu" && !over && current === "O"
    readonly property var score: {
        var s = sd.values.score && sd.values.score[mode]
        return { X: (s && s.X) || 0, O: (s && s.O) || 0, draw: (s && s.draw) || 0 }
    }

    readonly property color xColor: T.readable(sd.theme, ["accent", "blue", "cyan"])
    readonly property color oColor: T.readable(sd.theme, ["red", "orange", "magenta", "yellow", "green"], xColor)
    readonly property color softText: Qt.alpha(sd.theme.foreground, 0.7)

    function markColor(m) { return m === "X" ? xColor : oColor }
    function nameOf(m) { return mode === "cpu" ? (m === "X" ? "You" : "Computer") : m }

    readonly property string status: {
        if (win) return mode === "cpu" ? (win.mark === "X" ? "You win!" : "Computer wins") : win.mark + " wins!"
        if (over) return "Draw"
        if (mode === "cpu") return current === "X" ? "Your turn" : "Computer is thinking…"
        return current + " to move"
    }

    function play(i) {
        if (over || board[i]) return
        var b = board.slice()
        b[i] = current
        var w = T.winner(b)
        if (w || T.full(b)) {
            var all = Object.assign({}, sd.values.score || {})
            var s = Object.assign({}, score)
            s[w ? w.mark : "draw"] += 1
            all[mode] = s
            sd.setValue("score", all)
        }
        sd.setValue("board", b)
    }

    // The next game starts with the other mark.
    function newGame() {
        sd.setValue("first", first === "X" ? "O" : "X")
        sd.setValue("board", T.emptyBoard())
    }

    function setMode(m) {
        if (m === mode) return
        sd.setValue("mode", m)
        sd.setValue("first", "X")
        sd.setValue("board", T.emptyBoard())
    }

    function resetScore() {
        var all = Object.assign({}, sd.values.score || {})
        delete all[mode]
        sd.setValue("score", all)
    }

    Timer {
        interval: 450
        repeat: true
        running: game.cpuToMove
        onTriggered: game.play(T.cpuMove(game.board, "O"))
    }

    // The board and the side column, centred together as one group.
    RowLayout {
        id: row
        readonly property real sideWidth: 176
        readonly property real gap: 18
        anchors.fill: parent
        anchors.margins: 16
        spacing: 0

        Item { Layout.fillWidth: true }

        // The board: a square as big as the space allows.
        Item {
            readonly property real side: Math.max(90, Math.min(row.height, row.width - row.sideWidth - row.gap))
            Layout.preferredWidth: side
            Layout.preferredHeight: side
            Layout.alignment: Qt.AlignVCenter
            Layout.rightMargin: row.gap

            Grid {
                id: grid
                readonly property real side: parent.width
                anchors.fill: parent
                columns: 3
                spacing: Math.round(side * 0.025)

                Repeater {
                    model: 9
                    delegate: Rectangle {
                        id: cell
                        required property int index
                        readonly property string mark: game.board[index]
                        readonly property bool winning: game.win !== null && game.win.line.indexOf(index) >= 0
                        readonly property bool playable: !game.over && !mark && !game.cpuToMove
                        objectName: "cell" + index
                        width: (grid.side - grid.spacing * 2) / 3
                        height: width
                        radius: width * 0.12
                        color: winning ? Qt.alpha(game.markColor(game.win.mark), 0.22)
                             : area.containsMouse && playable ? Qt.alpha(sd.theme.foreground, 0.12)
                             : Qt.alpha(sd.theme.foreground, 0.06)
                        opacity: game.over && !winning && game.win !== null ? 0.55 : 1

                        Mark {
                            anchors.fill: parent
                            kind: cell.mark
                            color: game.markColor(cell.mark)
                        }
                        MouseArea {
                            id: area
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: cell.playable || game.over ? Qt.PointingHandCursor : Qt.ArrowCursor
                            // A click on a finished board starts the next game.
                            onClicked: {
                                if (game.over) game.newGame()
                                else if (cell.playable) game.play(cell.index)
                            }
                        }
                    }
                }
            }
        }

        // The side column: mode, the score (one row per player), status, buttons.
        ColumnLayout {
            Layout.preferredWidth: row.sideWidth
            Layout.fillWidth: false
            Layout.fillHeight: true
            spacing: 8

            // Mode: against the computer or two players at one mouse.
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 34
                radius: 9
                color: Qt.alpha(sd.theme.foreground, 0.06)

                Row {
                    anchors.fill: parent
                    anchors.margins: 3
                    Repeater {
                        model: [{ id: "cpu", label: "vs CPU" }, { id: "duo", label: "2 Players" }]
                        delegate: Rectangle {
                            required property var modelData
                            readonly property bool chosen: game.mode === modelData.id
                            width: parent.width / 2
                            height: parent.height
                            radius: 7
                            color: chosen ? sd.theme.accent
                                 : modeArea.containsMouse ? Qt.alpha(sd.theme.foreground, 0.08) : "transparent"
                            Text {
                                anchors.centerIn: parent
                                text: modelData.label
                                color: chosen ? sd.theme.background : sd.theme.foreground
                                font.family: sd.theme.fontFamily
                                font.pixelSize: 12
                                font.bold: chosen
                            }
                            MouseArea {
                                id: modeArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: game.setMode(modelData.id)
                            }
                        }
                    }
                }
            }

            // Score: X, draws, O, top to bottom. The player to move is outlined.
            Repeater {
                model: ["X", "draw", "O"]
                delegate: Rectangle {
                    required property string modelData
                    readonly property bool toMove: !game.over && game.current === modelData
                    readonly property bool won: game.win !== null && game.win.mark === modelData
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredHeight: 62
                    Layout.minimumHeight: 40
                    Layout.maximumHeight: 62
                    radius: 10
                    color: won ? Qt.alpha(game.markColor(modelData), 0.18) : Qt.alpha(sd.theme.foreground, 0.05)
                    border.width: toMove ? 2 : 0
                    border.color: game.markColor(modelData)

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 14
                        spacing: 10

                        Item {
                            Layout.preferredWidth: 30
                            Layout.preferredHeight: 30
                            Mark {
                                anchors.fill: parent
                                visible: modelData !== "draw"
                                kind: modelData === "draw" ? "" : modelData
                                color: game.markColor(modelData)
                            }
                            Text {
                                anchors.centerIn: parent
                                visible: modelData === "draw"
                                text: "="
                                color: game.softText
                                font.family: sd.theme.fontFamily
                                font.pixelSize: 22
                                font.bold: true
                            }
                        }
                        Text {
                            Layout.fillWidth: true
                            text: modelData === "draw" ? "Draws" : game.nameOf(modelData)
                            color: modelData === "draw" ? game.softText : game.markColor(modelData)
                            elide: Text.ElideRight
                            font.family: sd.theme.fontFamily
                            font.pixelSize: 13
                        }
                        Text {
                            text: game.score[modelData]
                            color: sd.theme.foreground
                            font.family: sd.theme.fontFamily
                            font.pixelSize: 24
                            font.bold: true
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }

            Text {
                Layout.fillWidth: true
                Layout.preferredHeight: 42
                Layout.minimumHeight: 20
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
                text: game.status
                color: game.win ? game.markColor(game.win.mark) : sd.theme.foreground
                font.family: sd.theme.fontFamily
                font.pixelSize: 16
                font.bold: game.over
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 6
                Button {
                    Layout.fillWidth: true
                    text: "New game"
                    highlighted: game.over
                    font.family: sd.theme.fontFamily
                    onClicked: game.newGame()
                }
                Button {
                    Layout.preferredWidth: 62
                    text: "Reset"
                    flat: true
                    font.family: sd.theme.fontFamily
                    onClicked: game.resetScore()
                }
            }
        }

        Item { Layout.fillWidth: true }
    }
}
