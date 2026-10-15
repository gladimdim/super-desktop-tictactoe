import QtQuick

// An X or an O drawn with plain shapes (no font needed); it pops in when set.
Item {
    id: mark
    property string kind: ""            // "", "X" or "O"
    property color color: "white"       // set by the board. sd-lint: ignore theme-colors
    readonly property real side: Math.min(width, height) * 0.56
    readonly property real stroke: Math.max(3, side * 0.17)

    onKindChanged: if (kind) pop.restart()

    Item {
        id: shape
        anchors.centerIn: parent
        width: mark.side; height: mark.side

        Repeater {
            model: mark.kind === "X" ? [45, -45] : []
            delegate: Rectangle {
                required property var modelData
                anchors.centerIn: parent
                width: mark.side * 1.25; height: mark.stroke
                radius: height / 2
                rotation: modelData
                color: mark.color
            }
        }
        Rectangle {
            visible: mark.kind === "O"
            anchors.fill: parent
            radius: width / 2
            color: "transparent"
            border.width: mark.stroke
            border.color: mark.color
        }
    }

    NumberAnimation {
        id: pop
        target: shape; property: "scale"
        from: 0.3; to: 1; duration: 180; easing.type: Easing.OutBack
    }
}
