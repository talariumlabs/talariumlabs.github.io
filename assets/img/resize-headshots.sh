#!/usr/bin/env bash
# p2-resize.sh: make power-of-two downsized copies of image-N.png
set -euo pipefail

src=${1:-image-1024.png}     # input file, defaults to image-1024.png
min=${2:-16}                 # smallest size to generate (default 16)

command -v convert >/dev/null \
  || { echo "ImageMagick 'convert' is required."; exit 1; }

bn="$(basename "$src")"
ext="${bn##*.}"              # png
stem="${bn%.*}"              # image-1024
start="${stem##*-}"          # 1024
[[ "$start" =~ ^[0-9]+$ ]] || { echo "Filename must end with -<number>."; exit 1; }

size=$start
base="${stem%-${start}}"     # image

while (( size >= min )); do
  out="${base}-${size}.${ext}"
  echo "→ ${out}"
  convert "$src" -resize "${size}x${size}" "$out"
  size=$(( size / 2 ))
done
