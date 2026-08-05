---
name: wizard
description: 人間にしか踏めない手順を案内する、対話的な bash wizard を生成する。インフラの払い出し、認証情報や CI secret の設定、不慣れなサードパーティのダッシュボードの操作、一度きりの migration や切り替えに使用。agent 自身が実行できる手順のためには invoke するな。Generate an interactive bash wizard that walks a human through steps only they can perform. 日本語トリガー例 / "セットアップ手順をウィザードにして" "この設定作業を案内するスクリプトを作って" / English / "make a wizard" "walk me through this setup"
---

# Wizard

**wizard** とは、手でやるのも面倒なら毎回 AI に説明し直すのも面倒な手作業の手順を、人間に一段ずつ案内する bash スクリプトだ。各 URL を開き、何をクリックして何をコピーするかを正確に告げ、値を取り込み、あるべき場所（`.env`、GitHub secrets）へ書き込み、各段階で確認を取り、あとどれだけ残っているかを示す。サードパーティサービスの設定、一度きりの migration、プロジェクトをある状態から別の状態へ移すこと、いずれにも使える。

心地よい UX は [template.sh](template.sh) で解決済みだ — 残り時間付きの進捗表示、確認ゲート、クロスプラットフォームな URL オープン（WSL 含む）、伏せ字での secret 入力、冪等な `.env` upsert、`gh secret`/`gh variable` への書き込み、締めのサマリー。**あなたの仕事は手順をスコープし、その stage を書き起こすことだけだ。** `STAGES` マーカーより上のライブラリはどの wizard でも同一であり、その一貫性こそが要点だ — 決して手で編集するな。

wizard はデフォルトで一過性のものだ — 1 回の実行のために作り、scratch か `scripts/` のパスに保存し、仕事が終われば消す。リポジトリに置くべき再現可能なセットアップ経路をユーザーが望むときにだけ commit しろ。

## Process

### 1. 手順をスコープする

人間が踏まなければならない手作業のステップと、その道中で取り込まれる値をすべて洗い出す。まずリポジトリを読め — 何も知らずに尋ねるな:

- セットアップの場合: `.env`、`.env.example`、`.env.*`、`README`、`docker-compose*`、フレームワークの config、`.github/workflows/*`（`secrets.*` / `vars.*` への参照は 1 つ残らず、wizard が生み出さなければならない値だ）。
- migration や移行の場合: 現在の状態、目標の状態、そのあいだにある不可逆な操作。

そのうえで、順序付けした stage のリストと各 stage が生む値をユーザーに見せ、確認を取れ — 追加・削除・並べ替えが入りうる。

**完了条件:** すべての stage が順番に命名されており、取り込む各値について (a) 人間がそれをどこで得るか、(b) どこへ書かれるか（`.env`、GitHub secret、両方、あるいはどこにも書かない — 純粋な操作だけの stage もある）、(c) secret か（伏せ字入力）public か、が分かっていること。

### 2. 各 stage の道筋を描く

stage ごとに、人間が辿る正確な経路を書け: どの URL を開き、そこで何をし、値がどこに表示され、どの変数を埋めるのか — 例:「Dashboard → Developers → API keys → Reveal test key → copy」。現在の UI や正確なコマンドを実際には知らない箇所では、そう明言してユーザーに尋ねるかドキュメントを確認しろ — 存在しないかもしれない手順を決して発明するな。

**完了条件:** すべての stage が、初見の人でも辿れる具体的な指示に落ちていること。

### 3. wizard を書く

`template.sh` を対象パスへコピーする。サンプルの stage を、依存順に並べた 1 ステップ 1 `stage` へ置き換える。ライブラリのヘルパー — `stage`、`say`/`step`、`open_url`、`ask`/`ask_secret`、`write_env`、`set_secret`/`set_var`、`pause`/`confirm` — を使い、`TOTAL_STAGES` と `TOTAL_MINUTES` に正直な見積もりを入れる（残り時間表示がこれで動く）。

template が定めた水準を保て: 値を尋ねる前に URL を開く、secret には `ask_secret` を使う、永続化する値はすべて `write_env`、CI が実際に必要とする値だけを `set_secret`、不可逆な操作の前には `confirm`。各 `stage` は画面をクリアし、現在のステップだけが見えるようにする — 人間に必要なものが流れて消えないよう、1 stage は 1 つの焦点の絞られたタスクに留めろ。マーカーより上のライブラリには手を触れるな。

### 4. 検証して引き渡す

- `bash -n <script>`。利用可能なら `shellcheck` も走らせる。
- `chmod +x <script>`。
- 自分で通しては実行するな — ブラウザを開き、人間の入力でブロックする。代わりに静的に辿れ: step 1 のすべての値が取り込まれ、step 1 が言った場所へ着地すること、そして `set_secret` の名前が CI の `secrets.*` 参照と正確に一致すること。
- ユーザーに実行方法を伝える。再現可能なセットアップ経路なら commit し、README からリンクして、次の人が AI に尋ねる代わりにスクリプトを走らせられるようにしろ。
