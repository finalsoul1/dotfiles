# Zsh completion system
autoload -Uz compinit
(( $+functions[compdef] )) || compinit

# Use zoxide for cd while keeping z/zi compatibility commands.
eval "$(zoxide init zsh --cmd cd)"

function z() {
  cd "$@"
}

function zi() {
  cdi "$@"
}

# Try exact, case-insensitive, and substring completion in that order.
zstyle ':completion:*' matcher-list \
  '' \
  'm:{a-zA-Z}={A-Za-z}' \
  'l:|=* r:|=*'

# Add live directory matches from the shared projects root.
typeset -g ZOXIDE_PROJECT_COMPLETION_ROOT="${ZOXIDE_PROJECT_COMPLETION_ROOT:-$HOME/Desktop/Projects}"

function __zoxide_z_complete_with_projects() {
  local completion_status=1

  # Prefer normal path completion when the current directory has matches.
  _directories && return 0
  __zoxide_z_complete && completion_status=0

  [[ "${#words[@]}" -eq 2 && -n "${words[2]}" ]] || return "$completion_status"
  [[ -d "$ZOXIDE_PROJECT_COMPLETION_ROOT" ]] || return "$completion_status"

  local query="${words[2]:l}"
  local directory
  local -a matches

  while IFS= read -r directory; do
    [[ "${directory:t:l}" == *"$query"* ]] && matches+=("$directory")
  done < <(
    /usr/bin/find "$ZOXIDE_PROJECT_COMPLETION_ROOT" -maxdepth 4 \
      \( -name .git -o -name node_modules -o -name .next \
         -o -name .dart_tool -o -name Pods -o -name build \
         -o -name dist -o -name .fvm \) -prune \
      -o -type d -print 2>/dev/null
  )

  if (( ${#matches[@]} )); then
    compadd -U -f -- "${matches[@]}"
    return 0
  fi

  return "$completion_status"
}
compdef __zoxide_z_complete_with_projects cd z

# Fuzzy completion and key bindings
source <(fzf --zsh)
