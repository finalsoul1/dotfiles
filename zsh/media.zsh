# media.zsh — 영상 → GIF 변환 헬퍼

# 영상 → 최적화 GIF (팔레트 생성/적용). 사용: vid2gif <video> [width=400] [fps=12]
#   예) vid2gif 화면기록.mov 300 10
vid2gif() {
  emulate -L zsh
  local in="$1" w="${2:-400}" fps="${3:-12}"
  if [[ -z "$in" || ! -f "$in" ]]; then
    echo "usage: vid2gif <video> [width=400] [fps=12]" >&2
    return 1
  fi
  if ! command -v ffmpeg >/dev/null; then
    echo "ffmpeg 없음 → brew install ffmpeg" >&2
    return 1
  fi
  local out="${in:r}.gif"
  ffmpeg -y -i "$in" \
    -vf "fps=${fps},scale=${w}:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
    -loop 0 "$out" \
    && echo "→ $out ($(du -h "$out" | cut -f1))"
}
