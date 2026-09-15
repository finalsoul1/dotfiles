# clipboard.zsh — 표를 리치텍스트로 클립보드에 올리는 헬퍼
# 배경: Slack·노션·메일은 마크다운 표를 렌더링하지 않는다. macOS 클립보드에 HTML flavor를
#       실으면 붙여넣기 한 번으로 표가 들어간다.
#       단 HTML flavor만 넣으면 plain text가 비어 대부분의 앱이 페이스트보드를 통째로
#       무시한다. 반드시 HTML + string 두 flavor를 레코드로 함께 넣어야 한다.

# 마크다운 표 또는 TSV → 클립보드(HTML+TSV). 사용: tbl2clip [file]  /  ... | tbl2clip
#   예) tbl2clip routes.md
#   예) pbpaste | tbl2clip
tbl2clip() {
  emulate -L zsh
  local src
  if [[ -n "$1" ]]; then
    if [[ ! -f "$1" ]]; then
      echo "파일 없음: $1" >&2
      return 1
    fi
    src="$(cat "$1")"
  elif [[ ! -t 0 ]]; then
    src="$(cat)"
  else
    echo "usage: tbl2clip [file]   또는   <표 출력> | tbl2clip" >&2
    echo "  입력은 마크다운 표(| a | b |) 또는 탭 구분 TSV" >&2
    return 1
  fi

  if [[ -z "${src//[[:space:]]/}" ]]; then
    echo "입력이 비어 있음" >&2
    return 1
  fi

  TBL2CLIP_SRC="$src" python3 -c '
import os, re, subprocess, html as H

src = os.environ["TBL2CLIP_SRC"]
rows = []
for raw in src.splitlines():
    line = raw.strip()
    if not line:
        continue
    if line.startswith("|"):
        # 마크다운 구분선(|---|---|)은 건너뛴다
        if re.fullmatch(r"\|[\s:\-|]+\|?", line):
            continue
        cells = [c.strip() for c in line.strip("|").split("|")]
    elif "\t" in raw:
        cells = [c.strip() for c in raw.split("\t")]
    else:
        continue
    rows.append(cells)

if not rows:
    raise SystemExit("표를 못 찾음 - 마크다운 표(| a | b |) 또는 TSV 를 넣어라")

def cell(text):
    # `code` 는 <code>, **bold** 는 <strong> 으로만 바꾼다
    out = H.escape(text)
    out = re.sub(r"\*\*(.+?)\*\*", r"<strong>\1</strong>", out)
    out = re.sub(r"`(.+?)`", r"<code>\1</code>", out)
    return out

head, body = rows[0], rows[1:]
parts = ["<table style=\"border-collapse:collapse\">"]
parts.append("<tr>" + "".join(
    f"<th style=\"border:1px solid #ccc;padding:6px 14px;text-align:left\">{cell(c)}</th>"
    for c in head) + "</tr>")
for r in body:
    parts.append("<tr>" + "".join(
        f"<td style=\"border:1px solid #ccc;padding:6px 14px\">{cell(c)}</td>"
        for c in r) + "</tr>")
parts.append("</table>")
markup = "".join(parts)

plain = "\n".join("\t".join(r) for r in rows)
esc = plain.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n")
hexed = markup.encode("utf-8").hex()
script = "set the clipboard to {«class HTML»:«data HTML" + hexed + "», string:\"" + esc + "\"}"
subprocess.run(["osascript", "-e", script], check=True)

# 검증 - plain flavor 가 비면 붙여넣기가 안 먹는다
back = subprocess.run(["pbpaste"], capture_output=True, text=True).stdout
if not back.strip():
    raise SystemExit("클립보드 plain flavor 가 비었다 - 붙여넣기가 안 먹는다")
print(f"→ 클립보드에 표 {len(rows)}행 x {len(head)}열 (Slack 입력창에 그대로 붙여넣기)")
' || return 1
}
