---
name: to-questionnaire
description: 自分だけでは答えきれない判断を、他の誰かに記入してもらう questionnaire に変換する。Turn a decision you can't fully answer into a questionnaire for someone else to fill in. 日本語トリガー例 / "質問票を作って" "ヒアリングシートにして" "相手に聞くことをまとめて" / English / "make a questionnaire" "turn this into questions for them"
disable-model-invocation: true
---

ユーザーが一人では答えられないものを **questionnaire** に変える。相手 1 人に渡して非同期で記入してもらう、あるいはミーティングで一緒に埋める Markdown 文書だ。相手はユーザーに欠けている知識を持っている。questionnaire はそれを引き出す。

**主題ではなく、送付を詰めろ。** ユーザーに対しては _送付_ についてだけ interview する。それは常に答えられるからだ: 誰に送るのか、何を返してほしいのか。文書内の質問は、そのうえで **相手が知っていることとユーザーが必要としていることの隔たり** を狙う。

1. **誰に送るのか?** 相手の役割、専門性、ユーザーとの関係を 1 往復で訊く。これで questionnaire のトーンと、どれだけ context を持たせる必要があるかが決まる。相手が誰か、そしてユーザーが知らない何をその人が知っているかが分かった時点で完了。

2. **何を返してほしいのか?** ユーザーが一人では解決できず、この人から得る必要がある具体的な判断や事実を 1 往復で訊く。ユーザーが最終的にできるようになる / 決められるようになるべきことの具体的なリストが揃った時点で完了。

3. **questionnaire を書く。** step 1〜2 で見えた隔たりを狙う質問を、下記の Document structure に従って起草する。カレントディレクトリの `to-questionnaire-<slug>.md`（slug はトピックから）に書き出し、パスを報告する。ファイルが存在し、step 2 でユーザーが挙げたすべての項目が質問でカバーされた時点で完了。

## Document structure

文書は **discovery questionnaire** として枠付けろ: ユーザーには context が無く、相手がそれを握っている。質問は重要な順に並べる（非同期ということは 1 回しか機会が無いかもしれない）。そして数個を超えたら `##` 見出しでテーマ別にまとめる。下のテンプレートを使って書け。

<questionnaire-template>

# <Questionnaire title>

**Purpose:** why this questionnaire exists and the decision riding on it.

**From:** <the user> / **To:** <the recipient> / **How your answers will be used:** <where they go>

## Context

One paragraph orienting a recipient who wasn't in the user's head. Enough to answer well, not a page.

## How to answer

Deadline and rough effort. Partial answers and "I don't know" are useful: flag anything you're unsure of rather than skipping it.

## <Theme heading>

One `##` section per theme. Under each, its questions, most-important-first. Every question is one idea, never compound, with an answer stub directly beneath, and a one-line _why this matters_ only where the question could be misread or invite a throwaway answer.

<question-example>
### What load is the system expected to handle at launch?

_Why this matters: it decides whether we provision for burst traffic now or defer it._

>
</question-example>

## Anything else?

A closing catch-all: anything we didn't ask that we should know?

</questionnaire-template>

テンプレートの見出し・ラベルは、questionnaire を書く言語に合わせて訳せ（日本語の相手に送るなら日本語で書く）。構造そのものは変えるな。
