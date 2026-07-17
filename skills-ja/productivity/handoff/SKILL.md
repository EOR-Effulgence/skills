---
name: handoff
description: 現在の会話を、別のエージェントが引き継げる handoff ドキュメントに圧縮する。Compact the current conversation into a handoff document for another agent to pick up. 日本語トリガー例 / "次セッションへ作業を渡す" "ハンドオフを書いて" / English / "hand this off" "create a handoff"
argument-hint: "次セッションは何に使うのか？"
disable-model-invocation: true
---

新しいエージェントが作業を継続できるよう、現在の会話を要約した handoff ドキュメントを書く。保存先は **ユーザー OS の temporary ディレクトリ** — 現在のワークスペースには保存しない。

ドキュメントには「suggested skills」セクションを含め、エージェントが起動すべきスキルを提案する。

他のアーティファクト（spec・計画・ADR・issue・コミット・diff）にすでに記録されている内容は重複させない。代わりにパスや URL で参照する。

機密情報（API キー、パスワード、個人を特定できる情報）は伏せる。

ユーザーが引数を渡してきた場合、それは次セッションが焦点を当てる対象の説明として扱い、ドキュメントをそれに合わせて整える。
