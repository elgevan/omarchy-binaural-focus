import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root

  property var shell: null
  property var manifest: null
  property bool playing: false
  property bool expectedStop: false
  property int elapsedSeconds: 0
  property double startedAtMs: 0
  property string lastError: ""
  property string stderrText: ""

  readonly property string sourceDir: manifest && manifest.__sourceDir
    ? String(manifest.__sourceDir)
    : ""
  readonly property string audioPath: sourceDir !== ""
    ? sourceDir + "/assets/binaural-focus-40hz.opus"
    : ""

  function play() {
    if (player.running) return true
    if (audioPath === "") {
      lastError = "The offline audio asset could not be found."
      return false
    }

    lastError = ""
    stderrText = ""
    expectedStop = false
    elapsedSeconds = 0
    startedAtMs = Date.now()
    player.command = [
      "mpv",
      "--no-config",
      "--no-video",
      "--audio-display=no",
      "--gapless-audio=yes",
      "--loop-file=inf",
      "--really-quiet",
      "--volume=50",
      audioPath
    ]
    playing = true
    player.running = true
    return true
  }

  function stop() {
    if (!player.running) {
      playing = false
      return
    }
    expectedStop = true
    playing = false
    player.running = false
  }

  function toggle() {
    if (player.running) stop()
    else play()
  }

  IpcHandler {
    target: "io.github.elgevan.binaural-focus"

    function play(): string {
      return root.play() ? "ok" : root.lastError
    }

    function stop(): string {
      root.stop()
      return "ok"
    }

    function toggle(): string {
      root.toggle()
      return root.playing ? "playing" : "stopped"
    }

    function status(): string {
      return JSON.stringify({
        playing: root.playing,
        elapsedSeconds: root.elapsedSeconds,
        error: root.lastError
      })
    }
  }

  Process {
    id: player
    running: false
    command: []

    stderr: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.stderrText = String(text || "").trim()
    }

    onExited: function(exitCode) {
      root.playing = false
      if (!root.expectedStop && exitCode !== 0) {
        root.lastError = root.stderrText !== ""
          ? root.stderrText
          : "Audio playback stopped unexpectedly."
      }
      root.expectedStop = false
    }
  }

  Timer {
    interval: 1000
    repeat: true
    running: root.playing
    onTriggered: root.elapsedSeconds = Math.max(0, Math.floor((Date.now() - root.startedAtMs) / 1000))
  }

  Component.onDestruction: root.stop()
}
