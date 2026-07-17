---
name: to-spec
description: 現在の会話を spec に変換し、プロジェクトの issue tracker に公開する — インタビューはせず、すでに議論した内容を統合するだけ。Turn the current conversation into a spec and publish it to the project issue tracker — no interview, just synthesis of what you've already discussed. 日本語トリガー例 / "spec を作って" "この会話から spec 化して" / English / "create a spec from this conversation"
disable-model-invocation: true
---

このスキルは現在の会話コンテキストとコードベース理解を取り、spec（この文書は PRD として知っているかもしれない）を生成する。ユーザーへインタビューしてはいけない — すでに知っていることを統合するだけだ。

issue tracker と triage ラベルの語彙は事前に提示されているはずだ — もし無ければ `/setup-matt-pocock-skills` を走らせる。

## Process

1. まだ探索していなければ、コードベースの現状を理解するためリポジトリを探索する。spec 全体を通してプロジェクトの domain glossary の語彙を使い、触る領域の ADR を尊重する。

2. その機能をテストする seam をスケッチする。新しい seam より既存の seam を優先する。可能な限り高い位置の seam を使う。新しい seam が必要なら、できる限り高い地点で提案する。コードベース全体で seam の数は少ないほどよい — 理想は 1 つだ。

これらの seam がユーザーの期待と一致するか確認する。

3. 下記テンプレートで spec を書き、プロジェクトの issue tracker に公開する。`ready-for-agent` の triage ラベルを付ける — 追加 triage は不要。

<spec-template>

## Problem Statement

ユーザーが直面している問題を、ユーザー視点で記述する。

## Solution

その問題の解決策を、ユーザー視点で記述する。

## User Stories

長い番号付きリストのユーザーストーリー。各ユーザーストーリーは以下の形式:

1. As an <actor>, I want a <feature>, so that <benefit>

<user-story-example>
1. As a mobile bank customer, I want to see balance on my accounts, so that I can make better informed decisions about my spending
</user-story-example>

このユーザーストーリーのリストは極めて網羅的にし、機能のあらゆる側面をカバーする。

## Implementation Decisions

行った実装判断のリスト。以下を含めてよい:

- 構築・改修する module
- 改修するそれら module のインターフェース
- 開発者からの技術的な明確化
- アーキテクチャ判断
- スキーマ変更
- API contract
- 特定のインタラクション

具体的なファイルパスやコードスニペットは含めない。すぐ古びる可能性がある。

例外: プロトタイプが、散文より正確に意思決定をエンコードするスニペット（state machine、reducer、schema、type shape）を生んだ場合、それを該当の判断にインラインで貼り、プロトタイプ由来であることを簡潔に明記する。意思決定の核となる部分だけに刈り込む — 動くデモではなく、重要な要点だけ。

## Testing Decisions

行ったテスト判断のリスト。以下を含める:

- 良いテストとは何か（外部のふるまいだけをテストし、実装の詳細はテストしない）の説明
- どの module をテストするか
- テストの先行事例（コードベース内の類似テストタイプ）

## Out of Scope

この spec のスコープ外となる事項の記述。

## Further Notes

機能に関するその他の注記。

</spec-template>
