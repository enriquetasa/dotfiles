#!/usr/bin/env bash
# Tests for janitor.sh. Each test builds a fake tree and points the janitor at it,
# so nothing outside the test folder is touched. Run: ./janitor/test_janitor.sh
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JANITOR="$HERE/janitor.sh"
FAILURES=0
BG_PIDS=()

ok() { printf '  ok   %s\n' "$1"; }
fail() { printf '  FAIL %s\n' "$1"; FAILURES=$((FAILURES + 1)); }
assert_exists() { if [ -e "$1" ] || [ -L "$1" ]; then ok "$2"; else fail "$2 (missing: $1)"; fi; }
assert_gone() { if [ -e "$1" ] || [ -L "$1" ]; then fail "$2 (still there: $1)"; else ok "$2"; fi; }
assert_contains() { if grep -qF -- "$2" "$1" 2>/dev/null; then ok "$3"; else fail "$3 (no '$2' in $1)"; fi; }

# age PATH DAYS: set the mtime of PATH (and everything under it) to DAYS ago.
age() { /usr/bin/find "$1" -depth -exec touch -h -d "$2 days ago" {} +; }
make_socket() { python3 -c 'import socket, sys; socket.socket(socket.AF_UNIX).bind(sys.argv[1])' "$1"; }

setup() {
  ROOT="$(mktemp -d)"
  export JANITOR_TMP_ROOT="$ROOT/tmp"
  export JANITOR_GENERAL_DIR="$ROOT/home/.tmp/general"
  export JANITOR_CLAUDE_DIRS="$ROOT/home/.tmp/claude/claude-1000 $ROOT/tmp/claude-1000"
  export JANITOR_STATE_DIR="$ROOT/state"
  export JANITOR_CODE_DIR="$ROOT/code"
  export JANITOR_GENERAL_DAYS=2 JANITOR_SCRATCH_DAYS=7
  export JANITOR_DISK_PCT=101 JANITOR_TMP_PCT=101
  mkdir -p "$JANITOR_TMP_ROOT" "$JANITOR_GENERAL_DIR" "$ROOT/home/.tmp/claude/claude-1000" "$JANITOR_CODE_DIR"
}

teardown() {
  local pid
  for pid in "${BG_PIDS[@]:-}"; do [ -n "$pid" ] && kill "$pid" 2>/dev/null; done
  BG_PIDS=()
  chmod -R u+rwx "$ROOT" 2>/dev/null
  rm -rf "$ROOT"
}

run_janitor() { "$JANITOR" "$@" > "$ROOT/out.log" 2>&1; }

UUID_OLD=11111111-1111-1111-1111-111111111111
UUID_NEW=22222222-2222-2222-2222-222222222222
UUID_BUSY=33333333-3333-3333-3333-333333333333

test_general_rule() {
  echo "general temp: delete after 2 days untouched"
  setup
  local g="$JANITOR_GENERAL_DIR"
  echo x > "$g/old.txt"; age "$g/old.txt" 3
  echo x > "$g/new.txt"; age "$g/new.txt" 1
  mkdir -p "$g/tmpold/a"; echo x > "$g/tmpold/a/f"; age "$g/tmpold" 3
  mkdir -p "$g/tmpmixed/a"; echo x > "$g/tmpmixed/a/f"; age "$g/tmpmixed" 3; touch "$g/tmpmixed/a/f"
  run_janitor clean
  assert_gone "$g/old.txt" "old file deleted"
  assert_exists "$g/new.txt" "new file kept"
  assert_gone "$g/tmpold" "old folder deleted"
  assert_exists "$g/tmpmixed" "old folder with a recent file kept"
  assert_contains "$ROOT/out.log" "action=delete rule=general" "deletions are logged"
  teardown
}

test_tmp_root_rule() {
  echo "/tmp: delete own entries after 2 days, keep sockets and known daemons"
  setup
  local t="$JANITOR_TMP_ROOT"
  echo x > "$t/uv-abc.lock"; age "$t/uv-abc.lock" 3
  echo x > "$t/fresh.lock"
  mkdir -p "$t/daemon-dir"; make_socket "$t/daemon-dir/sock"; age "$t/daemon-dir" 30
  make_socket "$t/bare.sock"; touch -h -d '30 days ago' "$t/bare.sock"
  mkdir -p "$t/tmux-1000"; age "$t/tmux-1000" 30
  mkdir -p "$t/claude-1000/-home-x/$UUID_NEW"; age "$t/claude-1000" 3
  run_janitor clean
  assert_gone "$t/uv-abc.lock" "old lock file deleted"
  assert_exists "$t/fresh.lock" "fresh file kept"
  assert_exists "$t/daemon-dir/sock" "folder holding a socket kept"
  assert_exists "$t/bare.sock" "socket kept"
  assert_exists "$t/tmux-1000" "tmux folder kept"
  assert_exists "$t/claude-1000/-home-x/$UUID_NEW" "Claude scratch not under the 2-day rule"
  teardown
}

test_scratch_rule() {
  echo "Claude scratchpads: delete sessions after 7 days untouched, never while in use"
  setup
  local c="$ROOT/home/.tmp/claude/claude-1000" legacy="$JANITOR_TMP_ROOT/claude-1000"
  mkdir -p "$c/-home-a/$UUID_OLD/scratchpad" "$c/-home-a/$UUID_NEW/scratchpad" "$c/-home-a/$UUID_BUSY/scratchpad"
  echo x > "$c/-home-a/$UUID_OLD/scratchpad/f"; age "$c/-home-a/$UUID_OLD" 8
  echo x > "$c/-home-a/$UUID_NEW/scratchpad/f"; age "$c/-home-a/$UUID_NEW" 6
  echo x > "$c/-home-a/$UUID_BUSY/scratchpad/f"; age "$c/-home-a/$UUID_BUSY" 8
  (cd "$c/-home-a/$UUID_BUSY/scratchpad" && exec sleep 60) & BG_PIDS+=($!)
  mkdir -p "$c/-home-b/$UUID_OLD"; age "$c/-home-b" 8
  mkdir -p "$c/-home-a/not-a-session"; age "$c/-home-a/not-a-session" 30
  mkdir -p "$c/bundled-skills"; age "$c/bundled-skills" 30
  mkdir -p "$legacy/-home-c/$UUID_OLD"; echo x > "$legacy/-home-c/$UUID_OLD/f"; age "$legacy/-home-c" 8
  sleep 0.2
  run_janitor clean
  assert_gone "$c/-home-a/$UUID_OLD" "8-day-old session deleted"
  assert_exists "$c/-home-a/$UUID_NEW" "6-day-old session kept"
  assert_exists "$c/-home-a/$UUID_BUSY" "old session in use kept"
  assert_gone "$c/-home-b" "project folder left empty is removed"
  assert_exists "$c/-home-a/not-a-session" "non-session folder kept"
  assert_exists "$c/bundled-skills" "Claude internals kept"
  assert_gone "$legacy/-home-c/$UUID_OLD" "legacy /tmp scratch session deleted"
  teardown
}

test_dry_run() {
  echo "--dry-run deletes nothing"
  setup
  echo x > "$JANITOR_GENERAL_DIR/old.txt"; age "$JANITOR_GENERAL_DIR/old.txt" 3
  run_janitor clean --dry-run
  assert_exists "$JANITOR_GENERAL_DIR/old.txt" "old file kept in dry run"
  assert_contains "$ROOT/out.log" "action=would-delete" "dry run says what it would delete"
  teardown
}

test_undeletable_is_reported() {
  echo "paths it cannot delete become a warning"
  setup
  local g="$JANITOR_GENERAL_DIR"
  mkdir -p "$g/locked"; echo x > "$g/locked/f"; age "$g/locked" 3; chmod 500 "$g/locked"
  run_janitor clean
  assert_exists "$g/locked/f" "locked file still there"
  assert_contains "$JANITOR_STATE_DIR/warnings" "could not delete" "warning written"
  teardown
}

test_thresholds() {
  echo "warnings when usage passes the thresholds"
  setup
  JANITOR_DISK_PCT=0 JANITOR_TMP_PCT=0 run_janitor clean
  assert_contains "$JANITOR_STATE_DIR/warnings" "inodes" "inode warning written"
  assert_contains "$JANITOR_STATE_DIR/warnings" "space" "space warning written"
  run_janitor clean
  assert_gone "$JANITOR_STATE_DIR/warnings" "warnings cleared when usage is fine"
  teardown
}

test_report() {
  echo "weekly report lists worktrees"
  setup
  local repo="$JANITOR_CODE_DIR/demo"
  git init -q -b main "$repo"
  git -C "$repo" -c user.email=t@example.com -c user.name=t commit -q --allow-empty -m init
  git -C "$repo" worktree add -q "$ROOT/wt-demo" -b feature
  run_janitor report
  assert_contains "$JANITOR_STATE_DIR/report.txt" "$ROOT/wt-demo" "worktree listed"
  assert_contains "$JANITOR_STATE_DIR/report.txt" "== Docker containers ==" "docker section present"
  assert_contains "$JANITOR_STATE_DIR/report.txt" "== Servers listening on all interfaces ==" "servers section present"
  teardown
}

test_listener_format() {
  echo "report shows each open server as address, program and pid"
  local line out
  line='LISTEN 0      511                *:3123            *:*    users:(("next-server (v1",pid=1640795,fd=21))'
  out="$(printf '%s\n' "$line" | "$JANITOR" format-listeners)"
  if [ "$out" = '*:3123 next-server (v1 pid=1640795' ]; then ok "listener formatted"; else fail "listener formatted (got: $out)"; fi
}

for t in test_general_rule test_tmp_root_rule test_scratch_rule test_dry_run \
         test_undeletable_is_reported test_thresholds test_report test_listener_format; do
  "$t"
done
echo
if [ "$FAILURES" -eq 0 ]; then echo "all tests passed"; else echo "$FAILURES failure(s)"; exit 1; fi
