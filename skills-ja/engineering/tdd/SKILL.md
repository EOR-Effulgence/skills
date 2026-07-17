---
name: tdd
description: テスト駆動開発。機能追加やバグ修正を test-first で進めたいとき、"red-green-refactor" に言及したとき、integration test が欲しいときに使う。Test-driven development. Use when the user wants to build features or fix bugs test-first, mentions "red-green-refactor", or wants integration tests. 日本語トリガー例 / "TDD で作って" "テストから書いて" "red-green-refactor で" / English / "build this test-first" "red-green-refactor" "integration tests"
---

# Test-Driven Development

TDD は red → green のループだ。このスキルは、そのループが「残す価値のあるテスト」を生み出すためのリファレンスである。良いテストとは何か、テストをどこに置くか、アンチパターン、ループのルール。すべてのセクションが毎サイクルで効く——ループの後ではなく、ループの前と最中に参照しろ。

コードベースを探索するときは `CONTEXT.md`（存在すれば）を読み、テスト名と interface の語彙をプロジェクトのドメイン言語に合わせろ。触れる領域の ADR も尊重しろ。

## 良いテストとは何か

テストは実装の詳細ではなく、public interface を通じて振る舞いを検証する。コードは丸ごと変わってよいが、テストは変わるべきではない。良いテストは仕様書のように読める——「user can checkout with valid cart」は、どんな能力が存在するかを正確に伝える——そして内部構造を気にしないので refactor を生き延びる。

例は [tests.md](tests.md)、mocking のガイドラインは [mocking.md](mocking.md) を見ろ。

## Seam — テストをどこに置くか

**seam** とは、テスト対象とする public な境界だ。内部に手を突っ込まずに振る舞いを観測できる interface である。テストは seam に置く。内部に対しては決して置かない。

**事前に合意した seam でのみテストしろ。** どんなテストを書く前にも、テスト対象の seam を書き出し、ユーザーと確認しろ。確認されていない seam でテストを書いてはならない。すべてをテストすることはできない——seam を前もって合意することが、テストの労力をあらゆるエッジケースではなくクリティカルパスと複雑なロジックに集中させる方法だ。

こう問え。「public interface は何か、どの seam をテストすべきか?」

## アンチパターン

- **実装結合型（Implementation-coupled）** — 内部の協調オブジェクトを mock する、private メソッドをテストする、サイドチャネル経由で検証する（interface を使わずデータベースを直接クエリする）。見分け方: 振る舞いは変わっていないのに refactor するとテストが壊れる。
- **同語反復型（Tautological）** — アサーションが、コードと同じやり方で期待値を再計算している（`expect(add(a, b)).toBe(a + b)`、手で同じ手順から導いた snapshot、自分自身と等しいと主張する定数）。そのため構造上必ずパスし、コードと食い違うことが決してない。期待値は独立した source of truth から来なければならない——既知の正しいリテラル、手計算した実例、仕様書だ。
- **水平スライス型（Horizontal slicing）** — 全テストを先に書き、それから全実装を書く。まとめて書いたテストは_想像上の_振る舞いを検証する: ユーザー向けの振る舞いではなく物事の_形_をテストしてしまい、テストは実際の変更に鈍感になり、実装を理解する前にテスト構造にコミットしてしまう。代わりに **vertical slice** で作業しろ——1 テスト → 1 実装 → 繰り返し、各テストは前サイクルの学びに応答する **tracer bullet** だ。

## ループのルール

- **green の前に red。** まず失敗するテストを書き、それをパスさせるだけの最小限のコードだけを書く。将来のテストを先取りしたり、投機的な機能を足したりするな。
- **一度に 1 スライス。** 1 サイクルにつき 1 seam、1 テスト、1 つの最小実装。
- **refactoring はループの一部ではない。** それは review ステージ（`code-review` スキルを見ろ）に属し、red → green の実装サイクルには属さない。
