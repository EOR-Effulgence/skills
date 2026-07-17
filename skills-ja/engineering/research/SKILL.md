---
name: research
description: 信頼性の高い一次情報源に対して問いを調査し、その結果を repo 内の Markdown ファイルとして記録する。Investigate a question against high-trust primary sources and capture the findings as a Markdown file in the repo. 日本語トリガー例 / "このトピックを調査して" "docs や API の事実を集めて" "調査を background agent に任せて" / English / "research this topic" "gather docs/API facts" "delegate the reading to a background agent"
---

**background agent** を立ち上げて調査させ、それが読んでいる間も自分は作業を続けろ。

その agent の仕事:

1. **一次情報源** — 公式 docs、ソースコード、仕様、first-party API — に対して問いを調査する。それらの二次的な解説記事ではない。すべての主張を、それを所有する情報源まで遡って辿れ。
2. 調査結果を単一の Markdown ファイルに書き出し、各主張の情報源を引用する。
3. repo が既にこの種のノートを置いている場所に保存する。既存の慣習に合わせろ。慣習が無ければ適切な場所に置き、どこに置いたかを述べろ。
