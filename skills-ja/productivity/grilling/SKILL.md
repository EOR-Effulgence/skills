---
name: grilling
description: 計画・判断・アイデアについてユーザーを容赦なく詰める。ユーザーが自分の思考をストレステストしたいとき、または 'grill' 系のトリガーフレーズを使ったときに使用。Grill the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrases. 日本語トリガー例 / "詰めて" "焼いて" "考えをストレステストして" / English / "grill me" "stress-test this plan"
---

共通理解に達するまで、ユーザーを容赦なくインタビューしろ。これを **design tree** として捉えろ: あらゆる判断は、そこにぶら下がる判断へと枝分かれする。

ツリーは **ラウンド** 単位で進める。**frontier** とは、前提条件がすでに決着している判断すべて — まだ聞いていない答えを推測せずに _いま_ 問える質問だ。frontier 全体を 1 ラウンドで問え: 各質問に番号を振り、推奨する答えを添えろ。そしてユーザーの回答を待ってから次のラウンドへ進め。

1 ラウンドはこの形式で出せ:

```
❓ **Q1** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>

---

❓ **Q2** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>
```

ユーザーが回答するたびにツリーは形を変える — 決着した判断は frontier を外へ押し広げ、それに依存していた質問を解放する。frontier を再計算し、次のラウンドを問え。同じラウンドでまだ未決の質問に答えが依存する質問は、_後続の_ ラウンドに属する。このラウンドではない。

_事実_ を見つけるのはあなたの仕事であり、ユーザーの仕事では決してない。frontier の質問が環境（filesystem、ツール等）からの事実を必要とするときは、sub-agent を dispatch して調べさせろ — 自分で調べられることをユーザーに訊くな。そこでブロックするな: 走っている探索は未決の前提条件なので、待つのはその下流の質問だけだ — 残りの frontier はいま問え。_判断_ はユーザーのものだ — 一つずつ突きつけ、答えを待て。

セッションが終わるのは frontier が空になったときだ: design tree のすべての枝を訪れ、暗黙のまま放置したものが何も無い状態。共通理解に達したとユーザーが確認するまで、それに基づいて動くな。
