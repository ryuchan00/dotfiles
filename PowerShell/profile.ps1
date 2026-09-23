# =============================================================
#  PowerShell プロファイル
#  WSL の zsh (fzf / anyframe / cdr) のキーバインドを fzf + zoxide で再現する
# =============================================================

# ---------- PATH ----------
$env:PATH += ";C:\Users\leo02\.local\bin"

# Chocolatey のタブ補完
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}

# ---------- 履歴 ----------
$MaximumHistoryCount = 10000                      # Get-History 用
Set-PSReadLineOption -MaximumHistoryCount 10000   # 永続履歴 (既定 4096)
Set-PSReadLineOption -HistoryNoDuplicates         # zsh の HIST_IGNORE_ALL_DUPS 相当
Set-PSReadLineOption -HistorySaveStyle SaveIncrementally

# 入力中に履歴から候補を薄く表示する (zsh-autosuggestions 相当)。PSReadLine 2.2 以降が必要。
# 出力がリダイレクトされている環境 (スクリプトからの読み込みなど) では有効化できないので握りつぶす
if ((Get-Module PSReadLine).Version -ge [version]'2.2.0') {
    try {
        Set-PSReadLineOption -PredictionSource History -ErrorAction Stop
        Set-PSReadLineOption -PredictionViewStyle ListView -ErrorAction Stop
    } catch {
        # 仮想ターミナル非対応 / 出力リダイレクト時。対話セッションでは有効になる
    }
}

# 上下キーで「入力済みの文字列に前方一致する履歴」だけを辿る
Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# ---------- zoxide (cd した場所を記録し、あいまい検索で戻る) ----------
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# =============================================================
#  fzf ベースのキーバインド (WSL の zsh 側と同じ操作を割り当てる)
# =============================================================

# 入力行を選択結果で置き換える。実行はせずカーソルを末尾に置くだけ (zsh の fzf-select-history と同じ挙動)
function Set-FzfLine([string]$text) {
    if (-not $text) { return }
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($text)
}

# --- Ctrl+L : 最近使ったディレクトリへ移動 (zsh の fzf-cdr 相当) ---
# 既定の Ctrl+L (画面クリア) は Ctrl+Shift+L に退避する。cls / clear も従来どおり使える
Set-PSReadLineKeyHandler -Chord 'Ctrl+Shift+l' -Function ClearScreen
Set-PSReadLineKeyHandler -Chord 'Ctrl+l' -BriefDescription 'FuzzyRecentDirectory' -LongDescription '最近使ったディレクトリを fzf で選んで移動' -ScriptBlock {
    $dir = zoxide query --interactive
    if ($LASTEXITCODE -eq 0 -and $dir) {
        Set-Location $dir
        [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
    }
}

# --- Ctrl+R : 履歴のあいまい検索 (zsh の fzf-select-history 相当) ---
Set-PSReadLineKeyHandler -Chord 'Ctrl+r' -BriefDescription 'FuzzyHistory' -LongDescription '履歴を fzf で検索して入力行に挿入' -ScriptBlock {
    $path = (Get-PSReadLineOption).HistorySavePath
    if (-not (Test-Path $path)) { return }
    $lines = @(Get-Content $path -ErrorAction SilentlyContinue)
    [array]::Reverse($lines)                       # 新しい順に並べる
    $sel = $lines | Select-Object -Unique | fzf --height 60% --reverse --prompt 'history> '
    Set-FzfLine $sel
}

# --- Ctrl+K : プロセスを選んで kill コマンドを組み立てる (zsh の fzf-kill 相当) ---
# 安全のため即実行はせず、Stop-Process コマンドを入力行に置くだけにしている。確認して Enter
Set-PSReadLineKeyHandler -Chord 'Ctrl+k' -BriefDescription 'FuzzyKillProcess' -LongDescription 'プロセスを fzf で選び Stop-Process を入力行に挿入' -ScriptBlock {
    $sel = Get-Process |
        Sort-Object -Property WS -Descending |
        ForEach-Object { '{0,-8} {1,-32} {2,8:N0} MB' -f $_.Id, $_.ProcessName, ($_.WS / 1MB) } |
        fzf --multi --height 60% --reverse --prompt 'kill> '
    if (-not $sel) { return }
    $ids = @($sel) | ForEach-Object { ($_ -split '\s+')[0] }
    Set-FzfLine ('Stop-Process -Id ' + ($ids -join ',') + ' -Force')
}

# --- Ctrl+N : git ブランチを選んで切り替えコマンドを組み立てる ---
Set-PSReadLineKeyHandler -Chord 'Ctrl+n' -BriefDescription 'FuzzyGitSwitch' -LongDescription 'git ブランチを fzf で選び git switch を入力行に挿入' -ScriptBlock {
    $branches = git branch --all --format='%(refname:short)' 2>$null
    if (-not $branches) { return }
    $sel = $branches | fzf --height 60% --reverse --prompt 'branch> '
    if ($sel) { Set-FzfLine ('git switch ' + ($sel -replace '^origin/', '')) }
}

# --- Ctrl+] : git ブランチ名だけをカーソル位置に挿入 ---
# 既定の Ctrl+] (GotoBrace: 対応する括弧へ移動) を上書きしている
Set-PSReadLineKeyHandler -Chord 'Ctrl+]' -BriefDescription 'InsertGitBranch' -LongDescription 'git ブランチ名を fzf で選んでカーソル位置に挿入' -ScriptBlock {
    $branches = git branch --format='%(refname:short)' 2>$null
    if (-not $branches) { return }
    $sel = $branches | fzf --height 60% --reverse --prompt 'branch> '
    if ($sel) { [Microsoft.PowerShell.PSConsoleReadLine]::Insert($sel) }
}
