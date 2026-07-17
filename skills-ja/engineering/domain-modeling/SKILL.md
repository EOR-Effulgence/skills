---
name: domain-modeling
description: プロジェクトの domain model を構築し研ぎ澄ます。ユーザーが domain の用語や Ubiquitous Language を確定したいとき、architectural decision を記録したいとき、または別のスキルが domain model を保守する必要があるときに使用。Build and sharpen a project's domain model. Use when the user wants to pin down domain terminology or a ubiquitous language, record an architectural decision, or when another skill needs to maintain the domain model. 日本語トリガー例 / "ドメインモデルを固めたい" "用語を統一したい" "ADR を書きたい" / English / "pin down the ubiquitous language" "record an architectural decision"
---

# Domain Modeling

設計を進めながら、プロジェクトの domain model を能動的に構築し研ぎ澄ませ。これは *能動的* な規律だ ── 用語に挑み、エッジケースのシナリオを考案し、用語集と決定事項が固まった瞬間に書き留める。(語彙のために `CONTEXT.md` を *読むだけ* なら、このスキルではない ── それはどのスキルでもできる一行の習慣にすぎない。このスキルは、モデルを消費するだけでなく、モデルを *変える* ときのためのものだ。)

## ファイル構成

ほとんどの repo は単一の context を持つ:

```
/
├── CONTEXT.md
├── docs/
│   └── adr/
│       ├── 0001-event-sourced-orders.md
│       └── 0002-postgres-for-write-model.md
└── src/
```

root に `CONTEXT-MAP.md` が存在するなら、その repo は複数の context を持つ。map は各 context がどこにあるかを指し示す:

```
/
├── CONTEXT-MAP.md
├── docs/
│   └── adr/                          ← system-wide decisions
├── src/
│   ├── ordering/
│   │   ├── CONTEXT.md
│   │   └── docs/adr/                 ← context-specific decisions
│   └── billing/
│       ├── CONTEXT.md
│       └── docs/adr/
```

ファイルは lazy に作れ ── 書くべきものができたときにだけ作る。`CONTEXT.md` が存在しないなら、最初の用語が解決したときに作る。`docs/adr/` が存在しないなら、最初の ADR が必要になったときに作る。

## セッション中

### 用語集に照らして挑む

ユーザーが `CONTEXT.md` の既存の言語と衝突する用語を使ったら、その場で指摘しろ。「あなたの用語集は 'cancellation' を X と定義しているが、あなたは Y を意味しているように見える ── どちらだ?」

### 曖昧な言語を研ぎ澄ます

ユーザーが漠然とした、あるいは多義的な用語を使ったら、正確な canonical な用語を提案しろ。「あなたは 'account' と言っているが ── それは Customer のことか User のことか? それらは別物だ。」

### 具体的なシナリオで議論する

domain の関係が議論されているとき、具体的なシナリオでストレステストしろ。エッジケースを探るシナリオを考案し、概念どうしの境界についてユーザーに正確さを強いろ。

### コードと相互参照する

ユーザーが何かの動作を述べたら、コードがそれに同意するか確認しろ。矛盾を見つけたら表に出せ。「あなたのコードは Order 全体を cancel しているが、あなたはたった今、部分的な cancellation が可能だと言った ── どちらが正しい?」

### CONTEXT.md をその場で更新する

用語が解決したら、その場で `CONTEXT.md` を更新しろ。これらをまとめて後回しにするな ── 起きたそばから捕まえろ。フォーマットは [CONTEXT-FORMAT.md](./CONTEXT-FORMAT.md) を使え。

`CONTEXT.md` は実装の詳細を完全に排除すべきだ。`CONTEXT.md` を spec、scratch pad、あるいは実装上の決定の置き場として扱うな。それは用語集であり、それ以外の何物でもない。

### ADR は控えめに提案する

以下の 3 つがすべて真であるときにだけ、ADR の作成を提案しろ:

1. **元に戻しにくい** ── 後で考えを変えるコストが無視できない
2. **文脈なしでは意外** ── 将来の読者が「なぜこうしたのか?」と疑問に思う
3. **本物のトレードオフの結果** ── 真の選択肢があり、特定の理由で一つを選んだ

3 つのどれかが欠けているなら、ADR はスキップしろ。フォーマットは [ADR-FORMAT.md](./ADR-FORMAT.md) を使え。
