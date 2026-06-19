#!/usr/bin/env bash
# tmux ペインに固有色 @pc を割り当て、アクティブなら枠線にも即反映する。
#   引数あり: そのペイン1つだけ割り当てる(新規ペイン用、フックから呼ぶ)
#   引数なし: 全ペインに通し番号で割り当て直す(初回適用 / source-file 時)
#
# 枠線は隣接ペインで共有されるため、同時に色を出せるのはアクティブペインのみ。
# 非アクティブの識別は pane-border-format(縁の上辺の色帯)が担う。
set -euo pipefail

# 背景が暗い端末で見分けやすい256色パレットから30色を選定。
# 隣り合うペインで似た色にならないよう、色相を大きく飛ばして並べてある。
colors=(
  196 46  21  226 201 51  208 118 27  199
  214 82  39  220 165 50  202 154 33  129
  190 48  57  93  197 45  213 159 87  228
)
n=${#colors[@]}

assign() {
  local pane="$1" idx color
  idx="$(tmux show-options -gqv @pc_next)"
  [ -n "$idx" ] || idx=0
  color="colour${colors[$(( idx % n ))]}"
  tmux set-option -p -t "$pane" @pc "$color"
  tmux set-option -g @pc_next "$(( idx + 1 ))"
  # 割り当て先がアクティブなら、枠線をその色へ即時反映する
  if [ "$(tmux display-message -p -t "$pane" '#{pane_active}')" = "1" ]; then
    tmux set-window-option -t "$pane" pane-active-border-style "fg=${color},bg=terminal"
  fi
}

if [ "$#" -ge 1 ]; then
  assign "$1"
else
  tmux set-option -g @pc_next 0
  while IFS= read -r pane; do
    assign "$pane"
  done < <(tmux list-panes -a -F '#{pane_id}')
fi
