#!/usr/bin/env bash
# resize-headshots.sh — generate web-ready square headshots at 320/640/960px
# Usage:
#   ./resize-headshots.sh [source.jpg] [outdir] [basename] [--bw]
# Defaults:
#   source  = founder-source.jpg
#   outdir  = .
#   basename= founder
set -euo pipefail

command -v convert >/dev/null || { echo "ImageMagick 'convert' is required."; exit 1; }

src="${1:-founder-source.jpg}"
outdir="${2:-.}"
base="${3:-founder}"
bw="${4:-}"

mkdir -p "$outdir"

sizes=(320 640 960)

mkjpg() {
  local size="$1" name="$2"
  local target="${outdir}/${name}-${size}.jpg"
  echo "→ ${target}"

  # Steps:
  # - auto-orient (EXIF), sRGB, strip metadata
  # - resize to fill square (^), center crop (extent), keep face near center
  # - gentle sharpen, quality ~82, progressive JPEG
  convert "$src" \
    -auto-orient -strip -colorspace sRGB \
    -resize "${size}x${size}^" -gravity center -extent "${size}x${size}" \
    -unsharp 0x0.75+0.75+0.008 -quality 82 -interlace JPEG \
    "$target"
}

mkbw() {
  local size="$1" name="$2"
  local target="${outdir}/${name}-bw-${size}.jpg"
  echo "→ ${target}"
  convert "$src" \
    -auto-orient -strip -colorspace sRGB \
    -resize "${size}x${size}^" -gravity center -extent "${size}x${size}" \
    -colorspace Gray -contrast-stretch 0x0.5% \
    -unsharp 0x0.75+0.75+0.008 -quality 82 -interlace JPEG \
    "$target"
}

for s in "${sizes[@]}"; do
  mkjpg "$s" "$base"
  [[ "$bw" == "--bw" ]] && mkbw "$s" "$base"
done

cat <<EOF

Done.
Generated:
  ${outdir}/${base}-{320,640,960}.jpg$( [[ "$bw" == "--bw" ]] && printf "\n  ${outdir}/${base}-bw-{320,640,960}.jpg")
Tips:
- Start from a large, square-ish source cropped around face/shoulders.
- Tweak centering by editing '-gravity center' to 'north'/'south' if needed.
- If you want AVIF/WebP too, run: magick input -resize ... output.avif|webp
EOF
