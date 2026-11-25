#!/usr/bin/env bash
# janitor: delete stale temp files by age, and warn before disks fill up.
#
#   janitor clean [--dry-run]   hourly: age-based deletes, then threshold warnings
#   janitor report              weekly: worktrees, containers and open servers to review
#
# Rules ("untouched" = newest mtime of the entry and everything under it):
#   - General temp ($HOME/.tmp/general) and your own top-level entries in /tmp:
#     deleted after JANITOR_GENERAL_DAYS (2) days untouched.
#   - Claude Code session scratch (<claude dir>/<project>/<session uuid>):
#     deleted after JANITOR_SCRATCH_DAYS (7) days untouched.
#   - Never deleted: anything a process has open or uses as its working directory,
#     sockets and folders that hold one, known daemon folders in /tmp, files owned
#     by other users. Worktrees, containers and servers are only reported.
set -euo pipefail

GENERAL_DAYS="${JANITOR_GENERAL_DAYS:-2}"
SCRATCH_DAYS="${JANITOR_SCRATCH_DAYS:-7}"
DISK_PCT="${JANITOR_DISK_PCT:-80}"
TMP_PCT="${JANITOR_TMP_PCT:-70}"
TMP_ROOT="${JANITOR_TMP_ROOT:-/tmp}"
GENERAL_DIR="${JANITOR_GENERAL_DIR:-$HOME/.tmp/general}"
CLAUDE_DIRS="${JANITOR_CLAUDE_DIRS:-$HOME/.tmp/claude/claude-$(id -u) /tmp/claude-$(id -u)}"
CODE_DIR="${JANITOR_CODE_DIR:-$HOME/CODE}"
STATE_DIR="${JANITOR_STATE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/janitor}"
FIND=/usr/bin/find
UUID_RE='^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'

DRY_RUN=0
NOW="$(date +%s)"
INUSE_FILE=""
UNDELETABLE=()

log() { printf 'janitor level=%s %s\n' "$1" "$2"; }

# Newest mtime (epoch seconds) of PATH and everything under it.
newest_mtime() {
  { "$FIND" "$1" -printf '%T@\n' 2>/dev/null || true; } \
    | awk '{ v = int($1); if (v > m) m = v } END { if (NR) print m }'
}

# True if PATH is a socket or holds one anywhere below it.
holds_socket() {
  [ -S "$1" ] && return 0
  [ -d "$1" ] && [ -n "$("$FIND" "$1" -type s -print -quit 2>/dev/null)" ]
}

# Paths that processes have open or use as their working directory.
collect_in_use() {
  INUSE_FILE="$STATE_DIR/in-use.$$"
  local p
  for p in /proc/[0-9]*; do
    readlink "$p/cwd" 2>/dev/null || true
    "$FIND" "$p/fd" -mindepth 1 -maxdepth 1 -printf '%l\n' 2>/dev/null || true
  done | sed 's/ (deleted)$//' | grep '^/' | sort -u > "$INUSE_FILE" || true
}

in_use() {
  awk -v p="$1" 'index($0, p "/") == 1 || $0 == p { found = 1; exit } END { exit !found }' "$INUSE_FILE"
}

# delete_if_stale RULE PATH MAX_DAYS
delete_if_stale() {
  local rule="$1" path="$2" days="$3" newest age_days
  [ -e "$path" ] || [ -L "$path" ] || return 0
  newest="$(newest_mtime "$path")"
  [ -n "$newest" ] || return 0
  age_days=$(( (NOW - newest) / 86400 ))
  [ "$age_days" -ge "$days" ] || return 0
  if holds_socket "$path"; then
    log info "action=skip rule=$rule reason=socket path=$path"
    return 0
  fi
  if in_use "$path"; then
    log info "action=skip rule=$rule reason=in-use path=$path"
    return 0
  fi
  if [ "$DRY_RUN" -eq 1 ]; then
    log info "action=would-delete rule=$rule age_days=$age_days path=$path"
    return 0
  fi
  rm -rf -- "$path" 2>/dev/null || true
  if [ -e "$path" ] || [ -L "$path" ]; then
    log warning "action=delete-failed rule=$rule path=$path"
    UNDELETABLE+=("$path")
  else
    log info "action=delete rule=$rule age_days=$age_days path=$path"
  fi
}

# Folders in /tmp that belong to long-running programs or to the system.
tmp_root_excluded() {
  case "$1" in
    claude-* | tmux-* | codex-daemon-* | ssh-* | systemd-private-* | snap-private-tmp | \
      .X11-unix | .ICE-unix | .XIM-unix | .font-unix | .Test-unix) return 0 ;;
  esac
  return 1
}

clean_general() {
  local entry
  if [ -d "$GENERAL_DIR" ]; then
    while IFS= read -r -d '' entry; do
      delete_if_stale general "$entry" "$GENERAL_DAYS"
    done < <("$FIND" "$GENERAL_DIR" -mindepth 1 -maxdepth 1 -print0)
  fi
  if [ -d "$TMP_ROOT" ]; then
    while IFS= read -r -d '' entry; do
      tmp_root_excluded "$(basename "$entry")" && continue
      delete_if_stale general "$entry" "$GENERAL_DAYS"
    done < <("$FIND" "$TMP_ROOT" -mindepth 1 -maxdepth 1 -user "$(id -u)" -print0)
  fi
}

clean_scratch() {
  local dir session project
  for dir in $CLAUDE_DIRS; do
    [ -d "$dir" ] || continue
    while IFS= read -r -d '' session; do
      [[ "$(basename "$(dirname "$session")")" == -* ]] || continue
      [[ "$(basename "$session")" =~ $UUID_RE ]] || continue
      delete_if_stale scratch "$session" "$SCRATCH_DAYS"
    done < <("$FIND" "$dir" -mindepth 2 -maxdepth 2 -type d -print0)
    [ "$DRY_RUN" -eq 1 ] && continue
    # Project folders that the deletes above left empty.
    while IFS= read -r -d '' project; do
      [[ "$(basename "$project")" == -* ]] || continue
      if rmdir -- "$project" 2>/dev/null; then
        log info "action=delete rule=scratch-empty-project path=$project"
      fi
    done < <("$FIND" "$dir" -mindepth 1 -maxdepth 1 -type d -empty -print0)
  done
}

# usage_pct PATH FIELD (pcent or ipcent) -> number without the % sign
usage_pct() { { df --output="$2" "$1" 2>/dev/null || true; } | tail -1 | tr -dc '0-9'; }

write_warnings() {
  local lines=() path label limit space inodes
  for spec in "$HOME|disk|$DISK_PCT" "$TMP_ROOT|tmp|$TMP_PCT"; do
    IFS='|' read -r path label limit <<< "$spec"
    space="$(usage_pct "$path" pcent)"
    inodes="$(usage_pct "$path" ipcent)"
    if [ -n "$space" ] && [ "$space" -ge "$limit" ]; then
      lines+=("$label ($path) space at ${space}% (limit ${limit}%)")
    fi
    if [ -n "$inodes" ] && [ "$inodes" -ge "$limit" ]; then
      lines+=("$label ($path) inodes at ${inodes}% (limit ${limit}%)")
    fi
  done
  if [ "${#UNDELETABLE[@]}" -gt 0 ]; then
    lines+=("could not delete ${#UNDELETABLE[@]} stale path(s), probably owned by root: ${UNDELETABLE[*]}")
  fi
  if [ "${#lines[@]}" -eq 0 ]; then
    rm -f "$STATE_DIR/warnings"
    return
  fi
  printf '%s\n' "${lines[@]}" > "$STATE_DIR/warnings"
  local line
  for line in "${lines[@]}"; do log warning "warning=\"$line\""; done
}

# Lines from `ss -ltnpH` -> "address program pid=N", for sockets bound to all interfaces.
format_listeners() {
  awk '$4 ~ /^(\*|0\.0\.0\.0|\[::\]):/' \
    | sed -nE 's/^\S+\s+\S+\s+\S+\s+(\S+)\s.*users:\(\("([^"]*)",pid=([0-9]+).*/\1 \2 pid=\3/p'
}

report_worktrees() {
  local repo wt branch dirty local_only last
  echo "== Git worktrees (besides each main checkout) =="
  for repo in "$CODE_DIR"/*/; do
    [ -d "$repo.git" ] || continue
    git -C "$repo" worktree list --porcelain 2>/dev/null \
      | awk '/^worktree /{p=substr($0,10)} /^branch /{b=substr($0,19)} /^detached/{b="(detached)"} /^$/{if(p)print p"\t"b; p="";b=""} END{if(p)print p"\t"b}' \
      | tail -n +2 \
      | while IFS=$'\t' read -r wt branch; do
          if [ -d "$wt" ]; then
            dirty="$(git -C "$wt" status --porcelain 2>/dev/null | wc -l)"
            local_only="$(git -C "$wt" rev-list --count HEAD --not --remotes 2>/dev/null || echo '?')"
            last="$(git -C "$wt" log -1 --format=%cs 2>/dev/null)"
            printf '%s  %s  dirty=%s local-only=%s last-commit=%s\n' "$wt" "$branch" "$dirty" "$local_only" "$last"
          else
            printf '%s  %s  MISSING (run: git -C %s worktree prune)\n' "$wt" "$branch" "$repo"
          fi
        done || true
  done
}

report() {
  {
    echo "janitor report, $(date '+%Y-%m-%d %H:%M')"
    echo
    echo "== Usage =="
    df -h "$HOME" "$TMP_ROOT" 2>/dev/null || true
    df --output=target,ipcent "$HOME" "$TMP_ROOT" 2>/dev/null || true
    echo
    report_worktrees
    echo
    echo "== Docker containers =="
    if command -v docker >/dev/null 2>&1; then
      docker ps -a --format '{{.Names}}  {{.Status}}  {{.Image}}' 2>/dev/null || echo "(docker not reachable)"
    else
      echo "(docker not installed)"
    fi
    echo
    echo "== Servers listening on all interfaces =="
    { ss -ltnpH 2>/dev/null || true; } | format_listeners
    echo
    echo "== Largest temp entries =="
    local d
    for d in "$GENERAL_DIR" $CLAUDE_DIRS; do
      if [ -d "$d" ]; then
        { du -sh "$d"/* 2>/dev/null || true; } | sort -rh | head -5
      fi
    done
  } > "$STATE_DIR/report.txt"
  log info "action=report path=$STATE_DIR/report.txt"
}

main() {
  local mode="${1:-clean}"
  shift || true
  [ "${1:-}" = "--dry-run" ] && DRY_RUN=1
  if [ "$mode" = "format-listeners" ]; then
    format_listeners
    return
  fi
  mkdir -p "$STATE_DIR"
  exec 9> "$STATE_DIR/lock"
  if ! flock -n 9; then
    log info "action=skip reason=another-run-in-progress"
    exit 0
  fi
  case "$mode" in
    clean)
      collect_in_use
      clean_general
      clean_scratch
      rm -f "$INUSE_FILE"
      write_warnings
      ;;
    report) report ;;
    *)
      echo "usage: janitor clean [--dry-run] | janitor report" >&2
      exit 2
      ;;
  esac
}

main "$@"
