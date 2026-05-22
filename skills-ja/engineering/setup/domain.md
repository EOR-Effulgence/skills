# Domain Docs

エンジニアリング系スキルがコードベースを探索するとき、このリポジトリのドメインドキュメントをどう消費するか。

## 探索の前に、これらを読む

- リポジトリルートの **`CONTEXT.md`**、または
- リポジトリルートの **`CONTEXT-MAP.md`** があれば — context ごとの `CONTEXT.md` を指している。トピックに関連するものを各々読む。
- **`docs/adr/`** — これから触る領域に関係する ADR を読む。multi-context リポジトリでは `src/<context>/docs/adr/` も確認して、context スコープの決定を拾う。

これらのファイルが存在しない場合は、**黙って進む**。欠如をフラグしない、先回りで作成を提案しない。プロデューサ側のスキル（`/grill-with-docs`）が、用語や決定が実際に固まったときに遅延作成する。

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

Multi-context リポジトリ（ルートに `CONTEXT-MAP.md` がある）:

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

出力がドメイン概念に名前を付けるとき（issue タイトル、リファクタ提案、仮説、テスト名）、`CONTEXT.md` で定義された通りの用語を使う。用語集が明示的に避けている同義語に流れない。

必要な概念が用語集にまだないなら、それは合図 — プロジェクトが使っていない言語を発明している（再考する）か、本物のギャップがある（`/grill-with-docs` 向けにメモする）。

## ADR との衝突をフラグする

出力が既存 ADR と矛盾するなら、黙って上書きせず明示的に表面化する:

> _ADR-0007（event-sourced orders）に矛盾するが、再オープンに値する。なぜなら…_
