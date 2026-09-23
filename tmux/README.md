# tmux/

`~/.config/tmux`の実体になるディレクトリ。
tmuxの設定ファイル本体ではなく、設定ファイルから`#()`や`run-shell`で呼び出す補助スクリプトを置く。
[`install.sh`](../install.sh)の「update tmux config」でYを選ぶと、`~/.config/tmux`がこのディレクトリへのsymlinkになる。

## ファイル

| ファイル | 呼び出し元 | 役割 |
|---|---|---|
| [`pane-last-session.sh`](pane-last-session.sh) | [`.tmux.conf.mac`](../.tmux.conf.mac)の`@pane_beacon_title_fallback` | タイトルがホスト名のままのペインで、そのペインで最後に動いていたClaude Codeセッションの要約を`~/.claude/sessions.db`から引き、`prev:`を付けて返す。記録がなければ`pane_current_command`を返す |

## tmux設定の全体像

| 置き場 | 内容 |
|---|---|
| [`.tmux.conf.mac`](../.tmux.conf.mac) | macOS用の設定本体。prefix(`C-t`)、vi風のコピー操作と`pbcopy`連携、ペイン移動とリサイズ、2行ステータス、TPMのプラグイン一覧 |
| [`.tmux.conf.ubuntu`](../.tmux.conf.ubuntu) | Ubuntu(WSL)用の設定本体。`clip.exe`連携と、TPM経由のtmux-pane-beacon |
| [tmux-pane-beacon](https://github.com/ryuchan00/tmux-pane-beacon) | ペインごとの固有色と、枠線上部の「[番号] タイトル」またはアラート表示を担うTPMプラグイン。このリポジトリから切り出して公開済みで、TPMが`~/.tmux/plugins/`へ取得する。オプションとアラートの使い方は同リポジトリのREADME |
| `tmux/`(このディレクトリ) | 上の設定から呼ぶ補助スクリプト |
| [`cheat-sheet-tmux.md`](../cheat-sheet-tmux.md) | 操作のチートシート |

## Claude Codeとの連携

Claude CodeはOSCシーケンスでセッション要約をターミナルタイトルに出し続ける。
tmuxは`allow-set-title`がon(既定)のとき、これを各ペインの`pane_title`に取り込む。
tmux-pane-beaconはこの`pane_title`を枠線に表示するため、ペインごとの作業内容が一目で分かる。
Claude Codeが終了してタイトルがホスト名に戻ったペインでは、`pane-last-session.sh`がsqliteの記録から直前の要約を補う。

sqliteへの記録と、処理完了や入力待ちのアラートは`~/.claude/hooks/`側のhookが担う(このリポジトリの管理外)。

| hook | 役割 |
|---|---|
| `record-session.sh` | セッション要約(`pane_title`)、session_id、`tmux_pane`、tmuxサーバーのPIDを`~/.claude/sessions.db`に記録する |
| `notify-stop.sh`と`notify-waiting.sh` | `~/.tmux/plugins/tmux-pane-beacon/scripts/alert.sh`を呼び、画面に見えていないペインの枠とウィンドウタブにアラートを付ける |

`pane-last-session.sh`がサーバーPIDで絞り込むのは、tmuxサーバーを再起動するとペインIDが再利用され、別セッションの記録を拾うためである。

## 新しいマシンでの導入

```bash
# 1. 設定ファイルと補助スクリプトをsymlinkする(対話でYを選ぶ)。Ubuntuでは引数をubuntuにする
./install.sh mac

# 2. TPMを入れる
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# 3. tmuxを起動し、prefix + I (C-t I) でプラグインを入れる
#    tmux-pane-beacon もここでGitHubから取得される
```

`pane-last-session.sh`は`sqlite3`コマンドと`~/.claude/sessions.db`を前提とする。
どちらも無い環境ではコマンド名を返すだけで、エラーにはならない。

### Ubuntu(WSL)で追加で確認すること

- tmux 3.0以降が必要である。プラグインがペイン単位オプション(`set-option -p`)とhookの配列指定を使うため、`tmux -V`で確認する。動作確認はmacOSのtmux 3.7bでのみ行っている。
- `apt install sqlite3 jq`で`pane-last-session.sh`と`record-session.sh`の依存が揃う。
- `~/.claude/hooks/`の`notify-stop.sh`と`notify-waiting.sh`は`osascript`と`afplay`で通知と音を出すため、WSLではその部分を置き換えるか削る。`alert.sh`の呼び出しはそのまま動く。
- 枠線の`━━`やアラート記号の幅が崩れるときは、`@pane_beacon_alert_icon`を`!`などに変える。
- `apt install bats shellcheck`のあと、`~/.tmux/plugins/tmux-pane-beacon`で`make test`と`make lint`を実行すると、そのtmuxで動くかを確認できる。
