# Domain Docs

engineering skills がコードベースを探索するとき、このリポジトリの domain ドキュメントをどう消費すべきか。

## 探索の前に、これらを読む

- リポジトリルートの **`CONTEXT.md`**、または
- リポジトリルートに **`CONTEXT-MAP.md`** があればそれ — context ごとに 1 つの `CONTEXT.md` を指している。トピックに関連するものを各々読む。
- **`docs/adr/`** — これから作業する領域に触れる ADR を読む。multi-context リポジトリでは `src/<context>/docs/adr/` も確認して、context スコープの決定を拾う。

これらのファイルが存在しない場合は、**黙って進む**。欠如をフラグするな。先回りして作成を提案するな。`/domain-modeling` skill（`/grill-with-docs` と `/improve-codebase-architecture` から到達する）が、用語や決定が実際に固まったときに遅延作成する。

## ファイル構造

Single-context リポジトリ（ほとんどのリポジトリ）:

```
/
├── CONTEXT.md
├── docs/adr/
│   ├── 0001-event-sourced-orders.md
│   └── 0002-postgres-for-write-model.md
└── src/
```

Multi-context リポジトリ（ルートに `CONTEXT-MAP.md` が存在する）:

```
/
├── CONTEXT-MAP.md
├── docs/adr/                          ← システム横断の決定
└── src/
    ├── ordering/
    │   ├── CONTEXT.md
    │   └── docs/adr/                  ← context 固有の決定
    └── billing/
        ├── CONTEXT.md
        └── docs/adr/
```

## 用語集の語彙を使う

出力が domain 概念に名前を付けるとき（issue タイトル、リファクタ提案、仮説、テスト名）、`CONTEXT.md` で定義された通りの用語を使う。用語集が明示的に避けている同義語に流れるな。

必要な概念が用語集にまだ無いなら、それは合図だ — プロジェクトが使っていない言語を発明している（再考する）か、本物のギャップがある（`/domain-modeling` 向けにメモする）かのどちらかだ。

## ADR との衝突をフラグする

出力が既存の ADR と矛盾するなら、黙って上書きせず明示的に表面化する:

> _ADR-0007（event-sourced orders）に矛盾する — だが再オープンに値する。なぜなら…_
