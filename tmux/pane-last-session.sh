#!/bin/bash
# pane-border-format の #() から呼ばれ、pane_title が未設定(ホスト名)のペイン向けに
# 「このペインで最後に動いていた Claude セッションの要約」を sqlite から引いて表示する。
# 引数はすべて tmux のフォーマット展開で渡されるため、tmux コマンドの呼び出しは不要:
#   $1: #{pane_id}  $2: #{pid}(tmuxサーバーPID)  $3: #{pane_current_command}
set -uo pipefail

DB="$HOME/.claude/sessions.db"
pane_id="${1:-}"
server_pid="${2:-}"
fallback_cmd="${3:-}"

print_fallback() {
  printf %s "$fallback_cmd"
  exit 0
}

[ -n "$pane_id" ] && [ -f "$DB" ] || print_fallback
# ペインIDはサーバー再起動で再利用されるため、現行サーバーPIDの記録に限定する
[[ "$server_pid" =~ ^[0-9]+$ ]] || print_fallback

esc() { printf %s "$1" | sed "s/'/''/g"; }

# PRAGMA busy_timeout は設定値を stdout に返して name に混入するため、.timeout を使う
name=$(sqlite3 "$DB" 2>/dev/null <<SQL
.timeout 1000
SELECT name FROM sessions
WHERE tmux_pane = '$(esc "$pane_id")'
  AND server_pid = $server_pid
  AND name IS NOT NULL
ORDER BY updated_at DESC
LIMIT 1;
SQL
)

[ -n "$name" ] || print_fallback
# 終了済みセッションの残像であることが分かるよう prev: を付ける
printf 'prev: %s' "$name"
