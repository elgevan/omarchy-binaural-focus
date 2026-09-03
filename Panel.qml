import QtQuick
import qs.Commons
import qs.Ui

Panel {
  id: root
  moduleName: "io.github.elgevan.binaural-focus"
  manageIpc: false

  property var anchorItem: null
  property var hostWidget: null
  property var service: null

  readonly property var barIdentity: hostWidget || root
  readonly property bool playing: service ? service.playing === true : false
  readonly property color foreground: bar ? bar.foreground : Color.foreground
  readonly property color accent: Color.accent
  readonly property color urgent: bar ? bar.urgent : Color.urgent
  readonly property color dim: Qt.darker(foreground, 1.45)
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family
  readonly property string elapsedLabel: formatElapsed(service ? service.elapsedSeconds : 0)

  function formatElapsed(rawSeconds) {
    var total = Math.max(0, Number(rawSeconds) || 0)
    var hours = Math.floor(total / 3600)
    var minutes = Math.floor((total % 3600) / 60)
    var seconds = Math.floor(total % 60)
    function two(value) { return value < 10 ? "0" + value : String(value) }
    return hours > 0
      ? hours + ":" + two(minutes) + ":" + two(seconds)
      : two(minutes) + ":" + two(seconds)
  }

  function open() { root.controller.show() }
  function close() { root.controller.hide() }
  function toggle() { root.opened ? root.close() : root.open() }
  function togglePlayback() { if (root.service) root.service.toggle() }

  function switchPanel(direction) {
    if (root.bar && typeof root.bar.switchPanelFrom === "function")
      return root.bar.switchPanelFrom(root.barIdentity, direction)
    return false
  }

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.barIdentity
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(430))
    contentHeight: panel.fittedContentHeight(contentColumn.implicitHeight, Style.space(600))

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onActivateRequested: root.togglePlayback()
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onTextKey: function(text) {
        if (text === "p" || text === "P") root.togglePlayback()
      }

      Column {
        id: contentColumn
        width: parent.width
        spacing: Style.space(12)

        Row {
          width: parent.width
          spacing: Style.space(10)

          Column {
            width: parent.width - statusPill.width - parent.spacing
            spacing: Style.space(2)

            Text {
              width: parent.width
              text: "BINAURAL FOCUS"
              color: root.foreground
              font.family: root.fontFamily
              font.pixelSize: Style.font.title
              font.bold: true
              font.letterSpacing: 1.4
            }

            Text {
              width: parent.width
              text: "FOCUS  ·  CONCENTRATION"
              color: root.dim
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
              font.bold: true
              font.letterSpacing: 0.8
            }
          }

          BorderSurface {
            id: statusPill
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: statusText.implicitWidth + Style.space(14)
            implicitHeight: statusText.implicitHeight + Style.space(7)
            radius: height / 2
            color: root.playing
              ? Style.selectedFillFor(root.accent, root.accent)
              : Style.normalFillFor(root.foreground, root.accent)
            borderSpec: Border.controlSpec(root.playing ? "selected" : "normal", root.playing ? root.accent : root.foreground, root.accent)

            Text {
              id: statusText
              anchors.centerIn: parent
              text: root.playing ? "LIVE  " + root.elapsedLabel : "READY"
              color: root.playing ? root.accent : root.dim
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
              font.bold: true
              font.letterSpacing: 0.8
            }
          }
        }

        BorderSurface {
          id: visualStage
          width: parent.width
          height: Style.space(240)
          radius: Style.cornerRadius * 1.6
          color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, root.playing ? 0.055 : 0.025)
          borderSpec: Border.controlSpec(root.playing ? "selected" : "normal", root.playing ? root.accent : root.foreground, root.accent)
          clip: true

          Repeater {
            model: 3

            Rectangle {
              required property int index
              anchors.centerIn: parent
              width: Style.space(76) + index * Style.space(34)
              height: width
              radius: width / 2
              color: "transparent"
              border.width: Math.max(1, Style.spaceReal(1))
              border.color: root.accent
              opacity: root.playing ? 0.20 - index * 0.045 : 0.08
              scale: 1

              SequentialAnimation on scale {
                running: root.playing && root.opened
                loops: Animation.Infinite
                PauseAnimation { duration: index * 240 }
                NumberAnimation { from: 0.82; to: 1.18; duration: 1250; easing.type: Easing.OutCubic }
                NumberAnimation { from: 1.18; to: 0.82; duration: 1250; easing.type: Easing.InOutSine }
              }
            }
          }

          WaveField {
            anchors.fill: parent
            anchors.margins: Style.space(12)
            active: root.playing && root.opened
            foreground: root.foreground
            accent: root.accent
          }

          Rectangle {
            anchors.centerIn: parent
            width: Style.space(78)
            height: width
            radius: width / 2
            color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, root.playing ? 0.92 : 0.16)
            border.width: Math.max(1, Style.spaceReal(1))
            border.color: root.playing ? root.accent : root.dim

            Behavior on color { ColorAnimation { duration: 220 } }

            Column {
              anchors.centerIn: parent
              spacing: -Style.space(2)

              Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "40"
                color: root.playing ? Color.background : root.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.display
                font.bold: true
              }

              Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "HZ"
                color: root.playing ? Color.background : root.dim
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
                font.bold: true
                font.letterSpacing: 1.5
              }
            }
          }
        }

        BorderSurface {
          anchors.horizontalCenter: parent.horizontalCenter
          implicitWidth: actionLabel.implicitWidth + Style.space(42)
          implicitHeight: actionLabel.implicitHeight + Style.space(18)
          radius: height / 2
          color: actionMouse.containsMouse
            ? Style.hoverFillFor(root.playing ? root.urgent : root.accent, root.accent)
            : Style.selectedFillFor(root.playing ? root.urgent : root.accent, root.accent)
          borderSpec: Border.controlSpec("selected", root.playing ? root.urgent : root.accent, root.accent)

          Text {
            id: actionLabel
            anchors.centerIn: parent
            text: root.playing ? "■  STOP FOCUS" : "▶  START FOCUS"
            color: root.playing ? root.urgent : root.accent
            font.family: root.fontFamily
            font.pixelSize: Style.font.body
            font.bold: true
            font.letterSpacing: 0.9
          }

          MouseArea {
            id: actionMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.togglePlayback()
          }
        }

        Text {
          visible: root.service && root.service.lastError !== ""
          width: parent.width
          horizontalAlignment: Text.AlignHCenter
          text: root.service ? root.service.lastError : ""
          color: root.urgent
          font.family: root.fontFamily
          font.pixelSize: Style.font.bodySmall
          wrapMode: Text.WordWrap
        }
      }
    }
  }
}
