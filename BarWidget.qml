import QtQuick
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "io.github.elgevan.binaural-focus"

  readonly property var focusService: bar && bar.shell
    ? bar.shell.serviceFor(moduleName)
    : null
  readonly property bool playing: focusService ? focusService.playing === true : false
  readonly property bool opened: panelLoader.item ? panelLoader.item.opened === true : false
  readonly property bool popoutSwitchClosing: panelLoader.item
    ? panelLoader.item.popoutSwitchClosing === true
    : false
  readonly property real openPanelIndicatorWidth: button.opticalSize

  function injectPanel() {
    var target = panelLoader.item
    if (!target) return
    target.bar = root.bar
    target.settings = root.settings
    target.anchorItem = button
    target.hostWidget = root
    target.service = root.focusService
  }

  function open() { if (panelLoader.item) panelLoader.item.open() }
  function close() { if (panelLoader.item) panelLoader.item.close() }
  function togglePanel() { if (panelLoader.item) panelLoader.item.toggle() }
  function closeForPopoutSwitch() { if (panelLoader.item) panelLoader.item.closeForPopoutSwitch() }

  function togglePlayback() {
    if (!focusService) return
    if (focusService.playing) {
      focusService.stop()
      close()
    } else {
      focusService.play()
      open()
    }
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  onBarChanged: injectPanel()
  onSettingsChanged: injectPanel()
  onFocusServiceChanged: injectPanel()

  Loader {
    id: panelLoader
    active: true
    source: Qt.resolvedUrl("Panel.qml")
    visible: false
    onLoaded: {
      root.injectPanel()
      Qt.callLater(root.injectPanel)
    }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    slotSize: Style.bar.statusSlot
    opticalSize: Style.bar.iconCanvas
    active: root.playing
    tooltipText: root.playing
      ? "40 Hz focus is playing · click to stop · right-click for controls"
      : "40 Hz binaural focus · click to play"

    iconComponent: Component {
      EqualizerIcon {
        active: root.playing
        foreground: button.foreground
        accent: button.activeColor
      }
    }

    onPressed: function(buttonCode) {
      if (buttonCode === Qt.RightButton) root.togglePanel()
      else if (buttonCode === Qt.MiddleButton) {
        if (root.focusService) root.focusService.stop()
      } else root.togglePlayback()
    }
  }
}
