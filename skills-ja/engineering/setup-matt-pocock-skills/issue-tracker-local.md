# Issue tracker: Local Markdown

このリポジトリの issue と spec（spec を PRD として知っているかもしれない）は `.scratch/` 配下の markdown ファイルとして存在する。

## 規約

- 機能ごとに 1 ディレクトリ: `.scratch/<feature-slug>/`
- spec は `.scratch/<feature-slug>/spec.md`
- 実装 issue はチケットごとに 1 ファイルで `.scratch/<feature-slug>/issues/<NN>-<slug>.md`、`01` から番号付け — 決して単一のまとめチケットファイルにしない
- triage 状態は各 issue ファイル先頭付近の `Status:` 行に記録する（役割文字列は `triage-labels.md` 参照）
- コメントと会話履歴は `## Comments` 見出しの下、ファイル末尾に追記する

## スキルが「issue tracker に publish せよ」と言ったら

`.scratch/<feature-slug>/` 配下に新ファイルを作る（必要ならディレクトリも作る）。

## スキルが「関連チケットを fetch せよ」と言ったら

参照されているパスのファイルを読む。ユーザーは通常パスか issue 番号を直接渡してくる。

## Wayfinding 操作

`/wayfinder` が使う。**map** は 1 つのファイルで、チケットごとに 1 つの **child** ファイルを持つ。

- **Map**: `.scratch/<effort>/map.md` — Notes / Decisions-so-far / Fog の body。
- **Child ticket**: `.scratch/<effort>/issues/NN-<slug>.md`、`01` から番号付け、body に問いを持つ。`Type:` 行がチケット種別（`research`/`prototype`/`grilling`/`task`）を記録し、`Status:` 行が `claimed`/`resolved` を記録する。
- **Blocking**: 先頭付近の `Blocked by: NN, NN` 行。列挙されたすべてのファイルが `resolved` になればチケットは unblock される。
- **Frontier**: `.scratch/<effort>/issues/` をスキャンし、open で unblock 済みかつ unclaimed のファイルを探す。番号で最初のものが勝つ。
- **Claim**: 作業の前に `Status: claimed` を設定して保存する。
- **Resolve**: `## Answer` 見出しの下に答えを追記し、`Status: resolved` を設定し、次に map の `map.md` の Decisions-so-far に context ポインタ（gist + リンク）を追記する。
