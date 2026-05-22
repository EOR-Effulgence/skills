---
name: to-prd
description: 現在の会話コンテキストを PRD に変換し、プロジェクトの issue tracker に公開する。現在のコンテキストから PRD を作成したいときに使用。
---

このスキルは現在の会話コンテキストとコードベース理解を取り、PRD を生成する。ユーザーへインタビューしてはいけない — すでに知っていることを統合するだけだ。

issue tracker と triage ラベルの語彙は事前に提示されているはずだ — もし無ければ `/setup-matt-pocock-skills` を走らせる。

## Process

1. まだ探索していなければ、コードベースの現状を理解するためリポジトリを探索する。PRD 全体を通してプロジェクトの**ドメイン用語集**の語彙を使い、触る領域の ADR を尊重する。

2. 実装に必要な構築・改修対象の主要 Module をスケッチする。**深い Module（deep modules）**を切り出し、単独でテストできる機会を能動的に探す。

   深い Module とは（浅い Module の対義語）、多くの機能を、めったに変わらないシンプルかつテスト可能なインターフェースの裏に隠した Module のこと。

   Module 群がユーザーの期待と一致するか確認する。どの Module にテストを書きたいか確認する。

3. 下記テンプレートで PRD を書き、プロジェクトの issue tracker に公開する。`ready-for-agent` の triage ラベルを付ける — 追加 triage は不要。

<prd-template>

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

- 構築・改修する Module
- 改修するそれら Module のインターフェース
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
- どの Module をテストするか
- テストの先行事例（コードベース内の類似テストタイプ）

## Out of Scope

この PRD のスコープ外となる事項の記述。

## Further Notes

機能に関するその他の注記。

</prd-template>
