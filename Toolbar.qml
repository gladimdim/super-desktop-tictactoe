import QtQuick

// The game is a card: SUPER DESKTOP remembers whether it was open when it
// last ran and starts with it open or closed, where it was. This item only
// opens it the very first time the plugin loads (sd.values.shown is not yet
// set); after that a click on # opens or closes it, and nothing else does.
// To turn it off completely, use Settings → Plugins.
Rectangle {
    id: root
    radius: height / 2
    color: area.containsMouse ? sd.theme.accent : Qt.alpha(sd.theme.surface, 0.9)

    function report(what, err) {
        if (err && err.code !== "not_connected") sd.log(what + " failed: " + err.message)
    }

    function toggleGame() {
        sd.call("card.toggle", { surface: "game" }, function(result, err) { report("card.toggle", err) })
    }

    // The first time only: show the game once, then leave it to the user
    // (and to SUPER DESKTOP, which restores an open card after a restart).
    Component.onCompleted: {
        if (sd.values.shown === true) return
        sd.call("card.open", { surface: "game" }, function(result, err) {
            report("card.open", err)
            if (!err) sd.setValue("shown", true)
        })
    }

    // A small # board icon.
    Item {
        id: icon
        readonly property real side: Math.round(Math.min(root.width, root.height) * 0.46)
        readonly property real line: Math.max(1.5, side * 0.11)
        readonly property color ink: area.containsMouse ? sd.theme.background : sd.theme.foreground
        anchors.centerIn: parent
        width: side; height: side

        Repeater {
            model: [1, 2]
            delegate: Rectangle {
                required property int modelData
                x: icon.side * modelData / 3 - icon.line / 2
                width: icon.line; height: icon.side
                radius: width / 2
                color: icon.ink
            }
        }
        Repeater {
            model: [1, 2]
            delegate: Rectangle {
                required property int modelData
                y: icon.side * modelData / 3 - icon.line / 2
                width: icon.side; height: icon.line
                radius: height / 2
                color: icon.ink
            }
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggleGame()
    }
}
