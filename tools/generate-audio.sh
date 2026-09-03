#!/usr/bin/env bash

set -euo pipefail

plugin_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
output_path=${1:-"$plugin_root/assets/binaural-focus-40hz.opus"}
duration_seconds=${DURATION_SECONDS:-300}

if [[ ! $duration_seconds =~ ^[1-9][0-9]*$ ]]; then
  echo "DURATION_SECONDS must be a positive whole number." >&2
  exit 1
fi

command -v ffmpeg >/dev/null || {
  echo "ffmpeg is required to regenerate the audio asset." >&2
  exit 1
}

mkdir -p -- "$(dirname -- "$output_path")"

ffmpeg \
  -hide_banner \
  -loglevel error \
  -f lavfi \
  -i "aevalsrc=exprs='0.8927*sin(2*PI*134*t)|0.8930*sin(2*PI*174*t)':s=48000:d=${duration_seconds}" \
  -c:a libopus \
  -b:a 48k \
  -vbr on \
  -compression_level 10 \
  -application audio \
  -metadata title="Binaural Focus — Original 40 Hz" \
  -metadata artist="Binaural Focus" \
  -metadata license="CC0-1.0" \
  -metadata comment="Generated from independent 134 Hz left and 174 Hz right sine waves; no source recording used." \
  -fflags +bitexact \
  -flags:a +bitexact \
  -serial_offset 40134 \
  -y \
  "$output_path"

echo "Generated $output_path"
