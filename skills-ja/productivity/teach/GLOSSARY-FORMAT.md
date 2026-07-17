# GLOSSARY.md フォーマット

`GLOSSARY.md` は、この teaching ワークスペースの正典となる言語だ。すべての解説、練習、learning record はその用語法に従うべきだ。それを築くこと自体が学習の一部だ: 概念を引き締まった定義に圧縮できることは、ユーザーがそれを理解している証拠だ。

## 構造

```md
# {Topic} Glossary

{One or two sentence description of the topic this glossary covers.}

## Terms

**Hypertrophy**:
Muscle growth driven by mechanical tension and metabolic stress over repeated training sessions.
_Avoid_: Bulking, getting big

**Progressive overload**:
Systematically increasing the demand on a muscle over time — via load, volume, or intensity.
_Avoid_: Pushing harder, levelling up

**RPE (Rate of Perceived Exertion)**:
A 1–10 self-rating of how hard a set felt, where 10 is failure and 8 means two reps left in the tank.
_Avoid_: Effort score, intensity rating
```

## ルール

- **ユーザーが理解したときにだけ用語を追加する。** 用語集は圧縮された知識の記録であって、ユーザーが学ぶために読む辞書ではない。ユーザーが概念に触れたばかりなら、正しく使えるようになるまで待ってからここへ昇格させる。
- **意見を持て。** 同じ概念に複数の言葉が存在するときは、最良の一つを選び、残りは避けるべき別名として列挙する。これが言語の圧縮のされ方だ。
- **定義は引き締めて保つ。** 1〜2 文。用語が何を_する_かやどう_やる_かではなく、何で_ある_かを定義する。
- **定義の中で用語集自身の用語を使う。** ひとたび用語が用語集に入ったら、どこでもそれを優先する — 他の定義の中でも。これが、複雑な用語を後でつかみやすくする。
- **自然なクラスタが現れたらサブ見出しでグループ化する**（例: `## Anatomy`、`## Programming`）。用語がまとまっているならフラットな一覧で構わない。
- **曖昧さを明示的に旗立てする。** 用語が広い分野で緩く使われているなら、その解決を注記する: 「このワークスペースでは、'set' は常に working set を意味する — ウォームアップは別に記録する」。
- **理解が深まるにつれて改訂する。** 第 1 週にユーザーが書いた定義は、第 6 週には間違っているかもしれない。その場で更新し、古びたエントリを残すな。
