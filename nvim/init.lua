-- Neovim 基本設定
-- ミニマル構成: 後から拡張可能

-- エンコーディング
vim.scriptencoding = 'utf-8'
vim.opt.encoding = 'utf-8'
vim.opt.fileencoding = 'utf-8'

-- 基本設定
vim.opt.backup = false   -- バックアップファイル(file~)を作らない。gitで履歴管理しているので不要
vim.opt.swapfile = false -- スワップファイル(.swp)を作らない。作業ディレクトリが汚れるのを防ぐ
vim.opt.autoread = true  -- 外部でファイルが変更されたら自動的に再読み込みし、編集中の内容と整合を取る
vim.opt.hidden = true    -- 未保存のバッファを切り替え可能にし、複数ファイルの行き来をスムーズにする
vim.opt.showcmd = true   -- 入力途中のコマンド(d, 5, ci等)をステータスラインに表示し、打ち間違いに気づきやすくする
-- yankを直接OSのクリップボードに乗せ、ターミナル外のアプリとのコピペに余分な操作を不要にする
vim.opt.clipboard = 'unnamedplus'

-- 見た目
vim.opt.number = true
-- 5jなどの距離指定移動を一目で組み立てやすくするため、行番号を相対表示にする
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.cursorcolumn = true
-- 行末の1文字先までカーソルを置けるようにし、行末への挿入や $ 移動を直感的に扱えるようにする
vim.opt.virtualedit = 'onemore'
vim.opt.smartindent = true
vim.opt.showmatch = true
vim.opt.laststatus = 2
vim.opt.wildmode = 'list:longest'
-- 24bitカラーを使い、カラースキームの微妙な色差を正確に表示する。対応していないターミナルでは無効化が必要
vim.opt.termguicolors = true
-- GitサインやLSP診断マーカーが付いたり消えたりするたびにテキスト領域がガタつくのを防ぐため常に表示
vim.opt.signcolumn = 'yes'

-- beep音を完全に無効化
vim.opt.errorbells = false
vim.opt.visualbell = false

-- タブ/インデント
vim.opt.list = true
-- 不可視文字を最低限の主張で可視化し、意図しないタブや末尾空白に気づけるようにする
vim.opt.listchars = { tab = '▸-', trail = '·', extends = '»', precedes = '«' }
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2

-- 検索
-- 小文字のみの検索は大文字小文字を無視し、大文字を含む検索は完全一致になる組み合わせ
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.wrapscan = true
vim.opt.hlsearch = true

-- 折り返し表示
vim.opt.wrap = true
vim.opt.linebreak = true -- 単語単位で折り返す

-- スクロール
-- 画面端ギリギリではコードの前後文脈が見えないため、上下8行の余白を常に確保する
-- 中央固定(999)は視点が動かず疲れるので不採用
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

-- 折り返された長い行(Markdown等)を1段ずつ降りられるようにする
-- 論理行ジャンプが要るときは大文字Gや行番号指定で行う
vim.keymap.set('n', 'j', 'gj', { noremap = true, silent = true })
vim.keymap.set('n', 'k', 'gk', { noremap = true, silent = true })

-- ESC連打でハイライト解除
vim.keymap.set('n', '<Esc><Esc>', ':nohlsearch<CR>', { noremap = true, silent = true })

-- 左右どちらの親指でも打てるSpaceをLeaderにし、リーダーキーの打鍵負荷を最小化する
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- 便利なキーマップ
vim.keymap.set('n', '<leader>w', ':w<CR>', { noremap = true, silent = true, desc = '保存' })
vim.keymap.set('n', '<leader>q', ':q<CR>', { noremap = true, silent = true, desc = '終了' })
vim.keymap.set('n', '<leader>e', ':Ex<CR>', { noremap = true, silent = true, desc = 'ファイラー' })

-- ウィンドウ移動
vim.keymap.set('n', '<C-h>', '<C-w>h', { noremap = true, silent = true })
vim.keymap.set('n', '<C-j>', '<C-w>j', { noremap = true, silent = true })
vim.keymap.set('n', '<C-k>', '<C-w>k', { noremap = true, silent = true })
vim.keymap.set('n', '<C-l>', '<C-w>l', { noremap = true, silent = true })

-- バッファ移動
vim.keymap.set('n', '<Tab>', ':bnext<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<S-Tab>', ':bprevious<CR>', { noremap = true, silent = true })

-- 選択範囲のインデント後も選択を維持
vim.keymap.set('v', '<', '<gv', { noremap = true, silent = true })
vim.keymap.set('v', '>', '>gv', { noremap = true, silent = true })

-- 選択範囲を1行単位で上下に動かし、移動後 gv=gv で再選択+再インデントまで一括で行う
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { noremap = true, silent = true })

-- カラースキーム（組み込み）
vim.cmd('colorscheme habamax')
vim.cmd('syntax on')

-- ファイルタイプ検出
vim.cmd('filetype plugin indent on')

-- C#コミュニティの慣例(MSスタイル)に合わせて4スペース。プロジェクトに .editorconfig があればそちらが優先される
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'cs',
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
  end
})

-- Markdown用の設定
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  callback = function()
    vim.opt_local.conceallevel = 0    -- 強調記号をそのまま表示
    vim.opt_local.spell = true        -- スペルチェック
    vim.opt_local.spelllang = 'en,cjk' -- 日本語はスペルチェック対象外
  end
})

-- 未インストール時に自動でcloneし、dotfilesをcloneするだけで環境が再現できるようにする
-- stableに固定して破壊的変更を避け、blob:noneでblobを遅延取得することで初回cloneを軽くする
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- プラグイン設定
require("lazy").setup({
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "ファイル検索" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "テキスト検索" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "バッファ一覧" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "最近開いたファイル" },
    },
    config = function(_, opts)
      local telescope = require('telescope')
      telescope.setup(opts)

      -- defaults.wrap_results は results 側にしか効かないため、
      -- preview側は TelescopePreviewerLoaded で個別に wrap を有効化する
      vim.api.nvim_create_autocmd('User', {
        pattern = 'TelescopePreviewerLoaded',
        callback = function()
          vim.wo.wrap = true
        end,
      })
    end,
    opts = {
      defaults = {
        wrap_results = true,
        layout_strategy = 'horizontal',
        layout_config = {
          width = 0.95,
          height = 0.95,
          preview_width = 0.5,
        },
      },
    },
  },

-- ファイルツリー: サイドバーでディレクトリ構造を表示
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "ファイルツリー" },
    },
    opts = {
      filesystem = {
        follow_current_file = { enabled = true },
        filtered_items = { visible = true },
      },
      window = { width = 30 },
    },
  },

  -- Markdown: ブラウザでリアルタイムプレビュー
  {
    "iamcco/markdown-preview.nvim",
    ft = { "markdown" },
    -- yarn未インストール環境でも動くよう npx 経由で起動し、frozen-lockfile で再現性を担保する
    build = "cd app && npx --yes yarn install --frozen-lockfile",
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdownプレビュー" },
    },
  },

  -- フォーマッタ: 保存時に自動整形
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    keys = {
      { "<leader>mf", function() require("conform").format({ async = true }) end, desc = "フォーマット" },
    },
    opts = {
      formatters_by_ft = {
        markdown = { "prettier" },
      },
      -- conformで対応するformatterが見つからないときだけLSPフォーマッタに委ねる。prettier等を優先する方針
      format_on_save = {
        timeout_ms = 3000,
        lsp_format = "fallback",
      },
    },
  },

  -- Treesitter: markdownのシンタックスハイライトに必要
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      -- 普段触る言語だけを明示しビルド時間を抑える
      -- auto_install は初回バッファ open が重くなるので不採用
      require("nvim-treesitter").install({ "markdown", "markdown_inline", "c_sharp" })
    end,
  },

  -- Git差分表示: 行の左端にgitの変更状態を色で表示
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add          = { text = '▎' },
        change       = { text = '▎' },
        delete       = { text = '▁' },
        topdelete    = { text = '▔' },
        changedelete = { text = '▎' },
      },
    },
  },

  -- LSP設定（nvim 0.11+ の vim.lsp.config を使用）
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- dotnet SDKのパス解決や起動引数差異を吸収するためwrapper経由
      -- 公式pkg版のdotnetを確実に指すため DOTNET_ROOT を明示する
      vim.lsp.config('omnisharp', {
        cmd = { vim.fn.expand("~/.local/share/omnisharp/omnisharp-wrapper.sh"), "--languageserver", "--hostPID", tostring(vim.fn.getpid()), "--loglevel", "Error" },
        cmd_env = {
          DOTNET_ROOT = "/usr/local/share/dotnet",
        },
      })
      vim.lsp.enable('omnisharp')

      -- LSPアタッチ時のキーマップ設定
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local opts = { noremap = true, silent = true, buffer = args.buf }
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
          vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
        end,
      })
    end,
  },

  -- スニペットエンジン
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    -- jsregexp は JavaScript 正規表現を Lua から使う C 拡張
    -- これがないと正規表現変換系スニペットが動かない
    build = "make install_jsregexp",
    config = function()
      local ls = require("luasnip")

      -- C#用XMLドキュメントスニペット
      local s = ls.snippet
      local t = ls.text_node
      local i = ls.insert_node

      ls.add_snippets("cs", {
        -- /// トリガー: <summary>のみ
        s("///", {
          t("/// <summary>"),
          t({ "", "/// " }), i(1, "説明"),
          t({ "", "/// </summary>" }),
        }),

        -- ///p トリガー: <summary> + <param> + <returns>（メソッド用）
        s("///p", {
          t("/// <summary>"),
          t({ "", "/// " }), i(1, "説明"),
          t({ "", "/// </summary>" }),
          t({ "", "/// <param name=\"" }), i(2, "paramName"), t("\">"), i(3, "パラメータの説明"), t("</param>"),
          t({ "", "/// <returns>" }), i(4, "戻り値の説明"), t("</returns>"),
        }),

        -- ///pp トリガー: <summary> + 複数<param>（引数2つのメソッド用）
        s("///pp", {
          t("/// <summary>"),
          t({ "", "/// " }), i(1, "説明"),
          t({ "", "/// </summary>" }),
          t({ "", "/// <param name=\"" }), i(2, "param1"), t("\">"), i(3, "パラメータ1の説明"), t("</param>"),
          t({ "", "/// <param name=\"" }), i(4, "param2"), t("\">"), i(5, "パラメータ2の説明"), t("</param>"),
          t({ "", "/// <returns>" }), i(6, "戻り値の説明"), t("</returns>"),
        }),
      })

      -- Tab/S-Tabでスニペットのプレースホルダ間を移動
      vim.keymap.set({ "i", "s" }, "<Tab>", function()
        if ls.expand_or_jumpable() then
          ls.expand_or_jump()
        else
          -- デフォルトのTab動作にフォールバック
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
        end
      end, { silent = true, desc = "LuaSnip: 展開/次へジャンプ" })

      vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
        if ls.jumpable(-1) then
          ls.jump(-1)
        end
      end, { silent = true, desc = "LuaSnip: 前へジャンプ" })
    end,
  },

  -- 補完エンジン + ソース
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",   -- LSP補完ソース
      "hrsh7th/cmp-buffer",     -- バッファ内の単語補完
      "hrsh7th/cmp-path",       -- ファイルパス補完
      "saadparwaiz1/cmp_luasnip", -- LuaSnipソース
      "L3MON4D3/LuaSnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },

        -- 第一グループ(LSP/snippet)に候補があれば第二グループ(buffer/path)を抑制し、補完ノイズを減らす
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
          { name = "path" },
        }),

        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          -- ハイライトされた候補だけを採用する
          -- 何も選んでいない状態で Enter を押しても改行になり、誤確定を防ぐ
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
        }),

        -- 補完ウィンドウの見た目
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
      })
    end,
  },
})
