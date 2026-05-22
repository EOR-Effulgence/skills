#!/usr/bin/env bash
# Human-in-the-loop 再現ループ。
# このファイルをコピーし、下のステップを編集して実行する。
# エージェントがスクリプトを実行し、ユーザーは自分のターミナルでプロンプトに従う。
#
# 使い方:
#   bash hitl-loop.template.sh
#
# ヘルパー 2 つ:
#   step "<instruction>"          → 指示を表示し、Enter を待つ
#   capture VAR "<question>"      → 質問を表示し、応答を VAR に読み込む
#
# 最後に、キャプチャされた値が KEY=VALUE で表示され、エージェントがパースする。

set -euo pipefail

step() {
  printf '\n>>> %s\n' "$1"
  read -r -p "    [Enter when done] " _
}

capture() {
  local var="$1" question="$2" answer
  printf '\n>>> %s\n' "$question"
  read -r -p "    > " answer
  printf -v "$var" '%s' "$answer"
}

# --- edit below ---------------------------------------------------------

step "Open the app at http://localhost:3000 and sign in."

capture ERRORED "Click the 'Export' button. Did it throw an error? (y/n)"

capture ERROR_MSG "Paste the error message (or 'none'):"

# --- edit above ---------------------------------------------------------

printf '\n--- Captured ---\n'
printf 'ERRORED=%s\n' "$ERRORED"
printf 'ERROR_MSG=%s\n' "$ERROR_MSG"
