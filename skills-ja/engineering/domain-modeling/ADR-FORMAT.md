# ADR フォーマット

ADR は `docs/adr/` に置き、連番を使う: `0001-slug.md`、`0002-slug.md` など。

`docs/adr/` ディレクトリは lazy に作れ ── 最初の ADR が必要になったときにだけ。

## テンプレート

```md
# {Short title of the decision}

{1-3 sentences: what's the context, what did we decide, and why.}
```

これだけだ。ADR は一段落で構わない。価値は、決定が下された *こと* とその *理由* を記録することにある ── セクションを埋めることにではない。

## 任意セクション

これらは本物の価値を加えるときにだけ含めろ。ほとんどの ADR には不要だ。

- **Status** frontmatter (`proposed | accepted | deprecated | superseded by ADR-NNNN`) ── 決定が見直されるときに有用
- **Considered Options** ── 却下した選択肢を覚えておく価値があるときにだけ
- **Consequences** ── 自明でない下流への影響を明示する必要があるときにだけ

## 採番

`docs/adr/` を走査して既存の最大番号を見つけ、1 を足せ。

## いつ ADR を提案するか

以下の 3 つがすべて真でなければならない:

1. **元に戻しにくい** ── 後で考えを変えるコストが無視できない
2. **文脈なしでは意外** ── 将来の読者がコードを見て「なぜ一体こんなやり方をしたのか?」と疑問に思う
3. **本物のトレードオフの結果** ── 真の選択肢があり、特定の理由で一つを選んだ

決定が簡単に元に戻せるなら、スキップしろ ── どうせ元に戻すのだから。意外でないなら、誰も理由を疑問に思わない。真の選択肢がなかったなら、「当たり前のことをやった」以上に記録すべきものはない。

### 何が該当するか

- **アーキテクチャの形。** 「monorepo を使う。」「write model は event-sourced、read model は Postgres に projection される。」
- **context 間の統合パターン。** 「Ordering と Billing は同期的な HTTP ではなく domain event で通信する。」
- **lock-in を伴う技術選定。** データベース、message bus、auth provider、デプロイ先。すべての library ではなく ── 差し替えに四半期かかるものだけ。
- **境界とスコープの決定。** 「Customer データは Customer context が所有し、他の context は ID でのみ参照する。」明示的な no は yes と同じくらい価値がある。
- **自明な道からの意図的な逸脱。** 「X という理由で ORM ではなく手書き SQL を使う。」まっとうな読者なら逆を仮定するあらゆるもの。これらは、意図的だったものを次のエンジニアが「修正」するのを止める。
- **コードに現れない制約。** 「compliance 要件のため AWS は使えない。」「partner API の契約により応答時間は 200ms 未満でなければならない。」
- **却下した選択肢のうち、却下が自明でないもの。** GraphQL を検討して微妙な理由で REST を選んだなら、記録しろ ── さもないと半年後に誰かがまた GraphQL を提案する。
