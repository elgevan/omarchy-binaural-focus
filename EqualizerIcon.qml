import QtQuick

Item {
  id: root

  property bool active: false
  property color foreground: "white"
  property color accent: "#7dd3fc"
  property real phase: 0

  readonly property var idleHeights: [0.28, 0.48, 0.72, 0.94, 0.72, 0.48, 0.28]

  NumberAnimation on phase {
    from: 0
    to: Math.PI * 2
    duration: 7200
    loops: Animation.Infinite
    running: root.active && root.visible
    easing.type: Easing.Linear
  }

  onActiveChanged: if (!active) phase = 0

  Row {
    anchors.centerIn: parent
    spacing: Math.max(1, root.width * 0.045)

    Repeater {
      model: 7

      Rectangle {
        required property int index

        readonly property real animatedLevel: 0.32
          + ((Math.sin(root.phase + index * 0.72) + 1) / 2) * 0.48

        anchors.verticalCenter: parent.verticalCenter
        width: Math.max(1.5, root.width * 0.085)
        height: Math.max(width, root.height * (root.active ? animatedLevel : root.idleHeights[index]))
        radius: width / 2
        color: root.active ? root.accent : root.foreground
        opacity: root.active ? 1 : (0.62 + (3 - Math.abs(3 - index)) * 0.08)

        Behavior on height {
          enabled: !root.active
          NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
        }

        Behavior on color {
          ColorAnimation { duration: 160 }
        }
      }
    }
  }
}
