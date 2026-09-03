import QtQuick

Item {
  id: root

  property bool active: false
  property color foreground: "white"
  property color accent: "#7dd3fc"
  property real phase: 0

  opacity: active ? 1 : 0.58

  Behavior on opacity {
    NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
  }

  Timer {
    interval: 33
    repeat: true
    running: root.active && root.visible
    onTriggered: {
      root.phase += 0.105
      waveCanvas.requestPaint()
    }
  }

  onWidthChanged: waveCanvas.requestPaint()
  onHeightChanged: waveCanvas.requestPaint()
  onForegroundChanged: waveCanvas.requestPaint()
  onAccentChanged: waveCanvas.requestPaint()
  onActiveChanged: waveCanvas.requestPaint()

  Canvas {
    id: waveCanvas
    anchors.fill: parent
    antialiasing: true

    onPaint: {
      var ctx = getContext("2d")
      var w = width
      var h = height
      var middle = h / 2
      ctx.clearRect(0, 0, w, h)
      if (w <= 0 || h <= 0) return

      var layers = 5
      var step = 2
      for (var layer = layers - 1; layer >= 0; layer--) {
        var spread = (layer + 1) / layers
        var amplitude = h * (0.075 + spread * 0.19)
        var frequency = 2.0 + layer * 0.44
        var speed = 0.62 + layer * 0.11

        ctx.beginPath()
        for (var x = 0; x <= w + step; x += step) {
          var progress = x / w
          var envelope = Math.pow(Math.max(0, Math.sin(progress * Math.PI)), 0.58)
          var primary = Math.sin(progress * Math.PI * frequency + root.phase * speed)
          var shimmer = Math.sin(progress * Math.PI * (frequency * 2.17) - root.phase * 0.43) * 0.23
          var y = middle + (primary + shimmer) * amplitude * envelope
          if (x === 0) ctx.moveTo(x, y)
          else ctx.lineTo(x, y)
        }

        ctx.globalAlpha = root.active
          ? 0.12 + spread * 0.14
          : 0.09
        ctx.strokeStyle = layer === 0 ? root.accent : root.foreground
        ctx.lineWidth = 1.0 + spread * 1.2
        ctx.lineCap = "round"
        ctx.stroke()
      }

      ctx.globalAlpha = root.active ? 0.9 : 0.38
      ctx.strokeStyle = root.accent
      ctx.lineWidth = 2.2
      ctx.beginPath()
      for (var cx = 0; cx <= w + step; cx += step) {
        var cp = cx / w
        var ce = Math.pow(Math.max(0, Math.sin(cp * Math.PI)), 0.72)
        var cy = middle + Math.sin(cp * Math.PI * 2.6 + root.phase) * h * 0.16 * ce
        if (cx === 0) ctx.moveTo(cx, cy)
        else ctx.lineTo(cx, cy)
      }
      ctx.stroke()
      ctx.globalAlpha = 1
    }
  }
}
