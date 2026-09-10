# dotfiles

zsh / tmux / Neovim / VSCode の設定ファイル一式。

| ファイル | 用途 |
|---|---|
| `.zshrc` | Mac用メイン (peco, brew前提) |
| `.zshrc.base` | クロスプラットフォーム共通 (fzf) |
| `.zshrc.ubuntu` | Ubuntu/WSL用メイン (`.zshrc.base` をsource) |
| `.tmux.conf.ubuntu` | tmux設定 (Ubuntu/WSL) |
| `config.fish` | Fish shell設定 |
| `nvim/init.lua` | Neovim設定 (シングルファイル) |
| `PowerShell/profile.ps1` | Windows PowerShell 5.1 用プロファイル (WSL併用時) |
| `VSCode/` | VSCode設定 |

- tmux のチートシート → [cheat-sheet-tmux.md](cheat-sheet-tmux.md)
- 導入は `install.sh` （`~/.config/nvim` → `dotfiles/nvim/` などの symlink を作成）

## PowerShell プロファイル (WSL)

`/mnt/c` 上に WSL から張った symlink は Windows 側から辿れない (`IOException`) ため、
ここだけ symlink ではなく**スタブ方式**にしている。

- 実体は `PowerShell/profile.ps1`。**編集するのはこちら**
- `install.sh ubuntu` が Windows 側の
  `%USERPROFILE%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1` に
  スタブを書き込む。スタブは `\\wsl.localhost\<distro>\...` 経由で実体を読み込むだけ
- 実体を編集すれば、次に PowerShell を起動した時点で反映される（同期作業は不要）

補足:

- UNC パス上のスクリプトは「リモート」扱いになり、`ExecutionPolicy = RemoteSigned` では
  dot-source が `PSSecurityException` で弾かれる。そのためスタブは中身を読んで
  `[scriptblock]::Create()` で実行している。実行ポリシーは変更していない
- PowerShell 5.1 は BOM が無いと日本語を CP932 として読むので、両ファイルとも
  **UTF-8 BOM 付き**で保存すること
- `zoxide` / `fzf` は Windows 側に未インストールのため、該当キーバインドは現状無効
  （プロファイル側で `Get-Command` によりガード済み）

---

# Neovim チートシート

この設定 (`nvim/init.lua`) 前提。**Leader キーは `Space`**。
以下 `<leader>` と書いてあるところは Space を押してから続けて打つ。

## 迷ったとき / 抜けたいとき

| やりたいこと | キー |
|---|---|
| とりあえず今の状態から抜ける | `Esc`（効かないときは `Ctrl-c`） |
| 検索のハイライトを消す | `Esc` `Esc`（Esc 2連打） |
| 直前の操作を取り消す | `u` |
| 取り消しを取り消す | `Ctrl-r` |
| 保存 | `<leader>w` |
| 終了 | `<leader>q` |
| 保存せず強制終了 | `:q!` → Enter |
| 全部保存して終了 | `:wqa` → Enter |
| Telescope / 補完ウィンドウを閉じる | `Esc`（補完は `Ctrl-e`） |
| ファイルツリーを閉じる | `<leader>e`（トグル） |
| キー割り当てを調べる | `:map` / `:verbose map <キー>` |
| 今どのモードか分からない | 画面左下の表示を見る（`-- INSERT --` 等） |
| プラグインの状態を見る | `:Lazy` |
| LSP の状態を見る | `:LspInfo` / `:checkhealth` |

## 検索・移動 (Telescope)

| キー | 機能 |
|---|---|
| `<leader>ff` | ファイル検索 (find_files) |
| `<leader>fg` | テキスト全文検索 (live grep) |
| `<leader>fb` | バッファ一覧 |
| `<leader>fr` | 最近開いたファイル |

Telescope 内では `Ctrl-n`/`Ctrl-p` で候補移動、`Enter` で開く、`Esc` で閉じる。

## ファイルツリー (Neo-tree)

| キー | 機能 |
|---|---|
| `<leader>e` | ファイルツリーの開閉 |

ツリー内: `Enter` 開く / `a` 新規作成 / `d` 削除 / `r` リネーム / `?` ヘルプ

## ウィンドウ・バッファ

| キー | 機能 |
|---|---|
| `Ctrl-h/j/k/l` | 左/下/上/右のウィンドウへ移動 |
| `Tab` | 次のバッファ |
| `Shift-Tab` | 前のバッファ |
| `:vs` / `:sp` | 縦/横に分割 |
| `:bd` | バッファを閉じる |

## 編集

| キー | モード | 機能 |
|---|---|---|
| `j` / `k` | ノーマル | 表示行単位で上下移動（折り返し行を1段ずつ） |
| `G` / `<行番号>G` | ノーマル | 論理行でジャンプ |
| `<` / `>` | ビジュアル | インデント解除/追加（選択は維持される） |
| `J` / `K` | ビジュアル | 選択行を下/上へ移動（再インデント付き） |

ヤンク (`y`) は OS のクリップボードに直結しているので、そのまま他アプリに貼れる。

## LSP (C# / OmniSharp)

| キー | 機能 |
|---|---|
| `gd` | 定義へジャンプ |
| `gr` | 参照一覧 |
| `K` | ホバー（型・ドキュメント表示） |
| `<leader>rn` | リネーム |
| `<leader>ca` | コードアクション |

`Ctrl-o` で元の位置に戻れる。

## 補完 (nvim-cmp)

| キー | 機能 |
|---|---|
| `Ctrl-Space` | 補完を手動で開く |
| `Ctrl-n` / `Ctrl-p` | 候補を選ぶ |
| `Enter` | 選択中の候補を確定（未選択なら普通に改行） |
| `Ctrl-b` / `Ctrl-f` | ドキュメントをスクロール |
| `Ctrl-e` | 補完を閉じる |

## スニペット (LuaSnip / C#)

インサートモードでトリガーを打って `Tab` で展開。

| トリガー | 展開されるもの |
|---|---|
| `///` | `<summary>` のみ |
| `///p` | `<summary>` + `<param>` + `<returns>` |
| `///pp` | `<summary>` + `<param>` 2つ + `<returns>` |

`Tab` で次のプレースホルダ、`Shift-Tab` で前へ。

## Markdown

| キー | 機能 |
|---|---|
| `<leader>mp` | ブラウザでプレビュー（トグル） |
| `<leader>mf` | 手動フォーマット (prettier) |

保存時に conform.nvim が自動フォーマットする。Markdown ではスペルチェックが有効
(`en,cjk` なので日本語は対象外)。スペル候補は `z=`、単語登録は `zg`。

## Git 差分 (gitsigns)

行の左端に変更マーカーが出る（`▎` 追加/変更、`▁` 削除）。
