import QtQuick

// Puts the game panel on the desktop when the plugin loads (SUPER DESKTOP
// starting). Open panels stay open while SUPER DESKTOP is hidden; a panel
// closed with ✕ stays closed until this top-bar item is clicked.
// To turn it off completely, use Settings → Plugins.
Rectangle {
    id: root
    radius: height / 2
    color: area.containsMouse ? sd.theme.accent : Qt.alpha(sd.theme.surface, 0.9)

    function showPanel() {
        sd.call("panel.open", { surface: "game" }, function(result, err) {
            if (err && err.code !== "not_connected") sd.log("panel.open failed: " + err.message)
        })
    }

    Component.onCompleted: showPanel()

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
        onClicked: root.showPanel()
    }
}
