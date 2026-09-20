# dotfiles

## ファイル構成

```
.zshrc          → Mac用メインファイル (peco使用, brew前提)
.zshrc.base     → クロスプラットフォーム共通設定 (fzf使用)
.zshrc.ubuntu   → Ubuntu/WSL用メインファイル (.zshrc.baseをsource)
.zshrc.mac      → Mac追加設定 (未使用/予備)
config.fish     → Fish shell設定
nvim/           → Neovim設定
VSCode/         → VSCode設定
```

## シンボリックリンク

| ファイル | リンク先 |
|---|---|
| `~/.zshrc` | `~/dotfiles/.zshrc.ubuntu` (WSL) |

## 設計思想

- **`.zshrc.base`**: Mac/Linux両対応の共通設定。fzfベース。OS依存コマンドは `command -v` で分岐
- **`.zshrc.ubuntu`**: WSL固有の設定。fzfのPATH設定・anyframe・starship・nvm等
- **`.zshrc`**: Mac専用。pecoベース・brewパス・oh-my-zsh

## 主なキーバインド (Ubuntu)

| キー | 機能 |
|---|---|
| `^r` | fzfでコマンド履歴検索 |
| `^g` | fzfでghqリポジトリに移動 |
| `^l` | fzfでcdr (最近のディレクトリ) |
| `^k` | fzfでプロセスkill |
| `^n` | fzfでgitブランチ切り替え |

## Neovim設定

`nvim/init.lua` に全設定をまとめたシングルファイル構成。

| プラグイン | 用途 |
|---|---|
| lazy.nvim | プラグインマネージャ |
| Telescope | ファイル/テキスト検索 (`<leader>ff/fg/fb/fr`) |
| Neo-tree | ファイルツリー (`<leader>e`) |
| nvim-cmp + LuaSnip | 補完・スニペット |
| nvim-lspconfig | LSP (OmniSharp for C#) |
| Treesitter | シンタックスハイライト |
| gitsigns | Git差分表示 |
| conform.nvim | 保存時自動フォーマット |

install.sh で `~/.config/nvim` → `dotfiles/nvim/` のsymlinkを作成。
nvim本体は `~/.local/bin/nvim` に配置 (`$HOME/.local/bin` はPATH済み)。

## 注意事項

- `tail -r` はmacOS専用。Linuxでは `tac` を使う → `.zshrc.base` では `command -v tac` で判定済み
- `~/.fzf.zsh` は `.zshrc.ubuntu` の先頭でsourceするとfzfのPATHが保証される
- anyframeは `~/.zsh/anyframe/` に手動インストールが必要
