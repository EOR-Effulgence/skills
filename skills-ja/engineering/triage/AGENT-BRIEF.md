# エージェントブリーフの書き方

エージェントブリーフは、Issue が `ready-for-agent` に動いた時に投稿する構造化コメント。AFK エージェントが作業の拠り所にする**権威ある仕様書**だ。元の Issue 本文と議論はコンテキストにすぎず、エージェントブリーフこそが**契約**である。

## 原則

### 精度よりも耐久性

Issue は `ready-for-agent` のまま数日から数週間放置されることがある。その間にコードベースは変わる。ファイルがリネーム・移動・リファクタされても、ブリーフが有用なまま残るように書け。

- **やる**: インターフェース、型、ふるまいの契約を記述する
- **やる**: エージェントが探すべき・変更すべき具体的な型名、関数シグネチャ、設定形状を挙げる
- **やらない**: ファイルパスを参照する — 古くなる
- **やらない**: 行番号を参照する
- **やらない**: 現在の実装構造がそのまま残ると仮定する

### 手続きではなくふるまい

システムが**何を**すべきかを書け。**どう**実装するかは書かない。エージェントは新鮮な目でコードベースを探索し、自身で実装判断をする。

- **良い**: 「`SkillConfig` 型はオプショナルな `schedule` フィールド（型: `CronExpression`）を受け取れるようにする」
- **悪い**: 「src/types/skill.ts を開いて 42 行目に schedule フィールドを追加」
- **良い**: 「ユーザーが `/triage` を引数なしで実行したら、注意が必要な Issue のサマリが見える」
- **悪い**: 「main ハンドラ関数に switch 文を足す」

### 完全な受け入れ基準

エージェントは「いつ終わったか」を知る必要がある。すべてのエージェントブリーフは、具体的でテスト可能な受け入れ基準を持つ。各基準は独立に検証可能であること。

- **良い**: 「`gh issue list --label needs-triage` が初期分類済みの Issue を返す」
- **悪い**: 「トリアージが正しく動くこと」

### 明示的なスコープ境界

何がスコープ外かを明記する。これによりエージェントが過剰実装したり隣接機能を勝手に想定するのを防ぐ。

## テンプレート

```markdown
## Agent Brief

**Category:** bug / enhancement
**Summary:** やるべきことの 1 行説明

**Current behavior:**
今何が起きているか。bug の場合は壊れている挙動。
enhancement の場合は、機能が乗る現状。

**Desired behavior:**
エージェントの作業が完了したあと、何が起きるべきか。
エッジケースとエラー条件について具体的に書く。

**Key interfaces:**
- `TypeName` — 何をなぜ変えるか
- `functionName()` の戻り値の型 — 現在何を返すか / 何を返すべきか
- 設定形状 — 必要な新しい設定オプション

**Acceptance criteria:**
- [ ] 具体的・テスト可能な基準 1
- [ ] 具体的・テスト可能な基準 2
- [ ] 具体的・テスト可能な基準 3

**Out of scope:**
- この Issue では変更・対応すべきでないもの
- 関連しているように見えるが別物の隣接機能
```

## 例

### 良いエージェントブリーフ（bug）

```markdown
## Agent Brief

**Category:** bug
**Summary:** Skill description の切り詰めが単語の途中で切れて、壊れた出力になっている

**Current behavior:**
skill description が 1024 文字を超えると、単語境界を無視して
ぴったり 1024 文字で切り詰められる。その結果、説明が単語の途中で
終わってしまう（例: "Use when the user wants to confi"）。

**Desired behavior:**
切り詰めは 1024 文字以下の最後の単語境界で行い、切り詰めを示す
"..." を末尾に付与する。

**Key interfaces:**
- `SkillMetadata` 型の `description` フィールド — 型自体の変更は不要だが、
  これを埋めるバリデーション / 処理ロジックが単語境界を尊重する必要がある
- SKILL.md の frontmatter を読んで description を抽出する関数

**Acceptance criteria:**
- [ ] 1024 文字未満の description は変更されない
- [ ] 1024 文字超の description は、1024 文字以下の最後の単語境界で
      切り詰められる
- [ ] 切り詰められた description は "..." で終わる
- [ ] "..." を含めた合計長は 1024 文字を超えない

**Out of scope:**
- 1024 文字制限そのものの変更
- 複数行 description のサポート
```

### 良いエージェントブリーフ（enhancement）

```markdown
## Agent Brief

**Category:** enhancement
**Summary:** 却下した機能要望を追跡する `.out-of-scope/` ディレクトリ対応を追加

**Current behavior:**
機能要望が却下されると、Issue は `wontfix` ラベルとコメント付きで
クローズされる。判断とその理由を残す永続的な記録は存在しない。
将来似た要望が来たら、メンテナは過去の議論を思い出すか検索する
ことになる。

**Desired behavior:**
却下された機能要望は `.out-of-scope/<concept>.md` に文書化される。
ファイルは判断・理由、その機能を要求したすべての Issue へのリンクを
含む。新規 Issue のトリアージ時、これらのファイルがマッチ確認に
使われる。

**Key interfaces:**
- `.out-of-scope/` 配下の markdown ファイル形式 — 各ファイルは
  `# Concept Name` 見出し、`**Decision:**` 行、`**Reason:**` 行、
  Issue リンクを含む `**Prior requests:**` リストを持つ
- トリアージワークフローは早い段階で全 `.out-of-scope/*.md` を読み、
  概念類似度で新規 Issue と突き合わせる

**Acceptance criteria:**
- [ ] enhancement を wontfix としてクローズすると、`.out-of-scope/` に
      ファイルが作成または更新される
- [ ] ファイルは判断・理由・クローズした Issue へのリンクを含む
- [ ] 一致する `.out-of-scope/` ファイルがすでにあれば、重複作成ではなく
      "Prior requests" リストに追記される
- [ ] トリアージ時、既存の `.out-of-scope/` ファイルがチェックされ、
      新規 Issue が過去の却下とマッチしたら表面化される

**Out of scope:**
- マッチングの自動化（人間が確認する）
- 過去に却下された機能の再オープン
- バグ報告（`.out-of-scope/` 行きは enhancement 却下のみ）
```

### 悪いエージェントブリーフ

```markdown
## Agent Brief

**Summary:** triage のバグを直して

**What to do:**
triage のあれが壊れてる。メインのファイルを見て直して。
150 行目あたりの関数に問題がある。

**Files to change:**
- src/triage/handler.ts (line 150)
- src/types.ts (line 42)
```

これがダメな理由:
- カテゴリなし
- 曖昧な説明（「triage のあれが壊れてる」）
- 古くなるファイルパスと行番号を参照
- 受け入れ基準なし
- スコープ境界なし
- 現状とあるべき挙動の説明なし
