# coingames — MVP Design

## 1. Vision & Target
- **Audience**: 小学生低〜中学年を想定した 1 人用 Web メダルゲーム。
- **Motivation**: ゲーム内でメダル 10,000 枚を貯めるとトークン 1 枚に交換でき、現実世界でパパからお小遣いがもらえるご褒美ループを構築。
- **Tone**: カラフルで元気、SEGA ビンゴシアターのワクワク感を 2D で再構成。

## 2. MVP Gameplay Pillars
1. **シンプルなビンゴ抽選**: メダルをベット→数字抽選→ライン成立で配当。操作は 1 タップのみ。
2. **カジュアルな演出**: 子どもが好きなポップな UI、跳ねるアニメーション、短いジングル音。
3. **成長の見える化**: 現在メダル枚数と 10,000 枚までの進捗ゲージ、トークン保有数を常時表示。

## 3. Core Loop
```
メダル所持を確認 → ベット額選択 (10 / 50 / 100) → 抽選演出 → 結果表示 → メダル増減 → 目標進捗更新
```
- 所持メダルが 0 になったらデイリーボーナス(例: 500 枚) で再開できる救済を用意。
- 10,000 枚に達すると 1 トークンを即時発行し、所持メダルは 0 にリセット。

## 4. Detailed Flow (Single Round)
| Phase | UI/UX | Audio | Logic |
| --- | --- | --- | --- |
| **Bet** | カラフルなベットボタン 3 種、残メダル/進捗ゲージを上部に固定 | 軽快なクリック音 | ベット額が所持メダル以下なら消費 |
| **Draw** | 5×5 ビンゴカード中央に大きなスクリーン、数字が 7 個まで抽選される（固定長） | 1 数字ごとにチャイム、最後はドラムロール | 1~75 から重複なしで抽選 |
| **Result** | 完了後、成立ライン数をカラーパルスで表示 | ライン数に応じたジングル (通常/スーパーボーナス) | 配当倍率: 0 Line=0x, 1 Line=2x, 2 Lines=5x, 3 Lines=15x, Bingo=50x |
| **Reward** | メダル加算アニメーション、次のラウンド誘導 CTA | コイン獲得音 | メダル残高/進捗更新、トークン交換チェック |

## 5. Economy & Progression
- **ベット制限**: 最大 100 メダルで大型当たりのドキドキを作りつつ、所持メダルが目標値から大きく減らないようバランス。
- **救済策**: デイリーボーナス + ログインスタンプで最大 1,000 メダル/日。
- **トークン交換**: `if medals >= 10000 → tokens += 1 → medals -= 10000`。交換演出は特別ポップアップ + 写真撮影ボタン（記念用）。

## 6. Presentation Guidelines
- **ビジュアル**: フラット 2D、パステル＋ネオンアクセント。背景はシアターステージ風。
- **キャラクター**: 司会キャラ 1 体（例: コインの妖精）を配置し、引率役としてコメントを出す。
- **サウンド**: 効果音は 8bit とポップスの間。BGM は 1〜2 曲をループで実装。
- **レスポンシブ**: iPad/スマホ縦持ち最適化。画面上部に情報、中央に抽選、下部に操作。

## 7. Tech MVP
- **Frontend**: Vite + React + TypeScript。Zustand で UI 状態を管理しつつ、Amplify Hosting から配信。
- **Backend**: Nest.js を Lambda ランタイム (Node.js 18) 上で稼働させ、API Gateway (HTTP API) から呼び出し。メダル/トークン/抽選履歴の状態管理は DynamoDB を完全ソースオブトゥルースとし、低遅延読み書きに備える。
- **IaC**: すべての AWS リソース (API Gateway / Lambda / DynamoDB / IAM / Amplify Hosting 等) を Terraform (HCL) で定義し、コンソール操作は極力 Terraform からの反映に限定。
- **Randomness**: フロントの試遊段階では Math.random。報酬管理をサーバー側で厳密化するときは Lambda 内で抽選を実施し、結果のみ返却。
- **Asset 管理**: Lottie/Canvas は使わず、CSS アニメーションと軽量 PNG/SVG で演出。
- **Persistence**: DynamoDB がメダル/トークン/ログイン日の永続化を担い、フロントでは localStorage をキャッシュとして利用（オフライン時にフェイルソフト）。Cognito 追加時も Terraform で紐付ける。

## 8. Next Steps
1. 画面遷移ワイヤー (Home / Game / Result / Exchange) を Figma で確定。
2. React コンポーネント構造とゲーム状態管理を設計。
3. Terraform で Amplify Hosting / API Gateway / Lambda / DynamoDB の最小構成を記述し、`terraform apply` ベースの環境を整備。
4. 抽選ロジックとアニメーションのプロトタイプ実装。
5. サウンド/アセット差し込み、軽いプレイテストでテンポ調整。

この内容をベースに実装に着手できるよう、追加要望や調整ポイントがあれば教えてください。

## 9. Terraform Module Design

### 9.1 State & Environment Strategy
- `infra/bootstrap/` でリモートステート用 S3 バケット + DynamoDB ロックテーブルを作成し、作成後に `infra/backend.tf` の `backend "s3"` を `terraform init -reconfigure` で紐付ける。以降は `infra/` 側のみで OK。
- 環境（`dev`, `stg`, `prod`）は Terraform Workspace ではなく `environments/<env>.tfvars` を切り替えて管理。CI/CD も `terraform apply -var-file=environments/dev.tfvars` のように明示する。
- Amplify Hosting のビルドアカウント/ドメイン設定だけは最初に 1 度 `terraform apply` してから、以降も Terraform 管理とする。

### 9.2 Module Breakdown
| Module | Path | 主要リソース | 役割 |
| --- | --- | --- | --- |
| `amplify_hosting` | `modules/amplify_hosting` | `aws_amplify_app`, `aws_amplify_branch` | React アプリのビルド & 配信設定。環境変数やサービスロールも注入可能。 |
| `api_gateway` | `modules/api_gateway` | `aws_apigatewayv2_api`, `aws_apigatewayv2_stage`, `aws_apigatewayv2_integration` | HTTP API を定義し、Lambda との統合 URL・CORS 設定をカプセル化。 |
| `lambda_nest` | `modules/lambda_nest` | `aws_lambda_function` | Nest.js バンドルを Lambda にデプロイし、環境変数・VPC 設定・レイヤーをまとめて制御。 |
| `dynamodb_state` | `modules/dynamodb_state` | `aws_dynamodb_table` | メダル/トークン/抽選履歴テーブルを Terraform で宣言。GSIs（例: `user_id + created_at`）もこのモジュール内で管理。 |
| `iam_shared` | `modules/iam_shared` | `aws_iam_role`, `aws_iam_policy` | Amplify ビルド、Lambda 実行、API Gateway ログなど共通ポリシーをまとめる。 |
| `observability` (任意) | `modules/observability` | `aws_cloudwatch_dashboard`, `aws_logs_metric_filter` | CloudWatch ダッシュボードやエラーメトリクスを IaC 化。MVP では後回し可。 |

ルート構成サンプル:
```
infra/
├── bootstrap/
│   ├── main.tf
│   └── environments/
│       └── dev.tfvars
├── main.tf              # モジュール呼び出し
├── variables.tf
├── backend.tf           # S3 backend 定義
├── providers.tf
├── environments/
│   └── dev.tfvars
└── modules/
    ├── amplify_hosting/
    ├── api_gateway/
    ├── lambda_nest/
    ├── dynamodb_state/
    ├── iam_shared/
    └── observability/
```

### 9.3 Data Flow & Deployment Order
1. `dynamodb_state` でテーブルを作成（`PK=user_id`, `SK=item_type#timestamp` 等）。
2. `iam_shared` で Lambda/Amplify 用ロールを配備。
3. `lambda_nest` がビルドアーティファクト（`dist/main.zip`）を S3 へアップロードし Lambda を作成。
4. `api_gateway` が Lambda を統合し、Stage エンドポイントを出力。
5. `amplify_hosting` が API エンドポイントや Cognito 情報を環境変数として受け取り、React ビルドへ注入。

一連の apply は `infra/` 直下で `terraform init` → `terraform plan -var-file=environments/dev.tfvars` → `terraform apply -var-file=environments/dev.tfvars` の順で実行する。

### 9.4 Module Toggles & Usage
- それぞれのモジュールは `enable_lambda`, `enable_api_gateway`, `enable_amplify_hosting` でオン/オフを切り替えられる。デフォルトは `false` なので既存環境に影響せずに IaC を先に整備できる。
- Lambda を有効化する際は `lambda_package_path` に `zip` 化した Nest.js バンドル (例: `../backend/dist/main.zip`) を指定する。アーティファクトが存在しないと plan が失敗するため CI ではビルド→zip→Terraform の順序で実行する。
- API Gateway を有効化する場合は Lambda も同時にオンにし、`api_gateway_allowed_origins` でフロントのドメインを指定する。
- Amplify Hosting は GitHub 連携を行う場合 `amplify_repository` と `amplify_access_token` を与え、サービスロールとして `module.iam_shared.amplify_role_arn` を渡す。ローカルホストでの動作確認なら環境変数だけ先に注入しておき、手動アップロードでも対応可能。

## 10. Backend Lambda (Nest.js placeholder→TypeScript実装)
- `backend/` ディレクトリに TypeScript Lambda を追加。`src/handler.ts` が API Gateway (HTTP API) からのリクエストを受け、`dynamodb_state` テーブルでユーザー状態を管理。
- ゲーム処理: `bet` アクションでメダル消費→乱数でライン数/倍率→メダル加算→10,000 枚到達でトークン化。`status` アクションで所持メダル/トークンを返却。
- Additional actions:
  - `bonus`: 1 日 1 回、500 メダルのデイリーボーナスを付与 (同日二重受取を防止)。
  - `exchange`: 現在のメダルから 10,000 枚単位で手動交換し、即トークン獲得できるようにして目標達成を後押し。
- ビルド & デプロイ手順:
  1. `cd backend`
  2. `npm install` (初回のみ)
  3. `npm run package` で `dist/main.js` と `dist/main.zip` を生成
  4. `cd ../infra && AWS_PROFILE=coingames_admin terraform apply -var-file=environments/dev.tfvars`
- API 呼び出しは POST JSON (`{ "action": "bet", "userId": "kid01", "betAmount": 50 }`) or (`{ "action": "status", "userId": "kid01" }`) を `https://<api-id>.execute-api.ap-northeast-1.amazonaws.com/` へ。

## 11. Frontend (Vite + React)
- `frontend/` に Vite × React × TypeScript をセットアップ。API クライアント (`src/lib/api.ts`) が Lambda を呼び出し、`src/App.tsx` で UI/UX を構築。
- UI 構成:
  - ヘッダー: プレイヤーID切替・タイトル
  - ステータスカード: メダル/トークン表示＋10,000 までのゲージ
  - 行動ボタン: ベット (10/50/100)、デイリーボーナス、トークン交換
  - ログカード: 直近のベット結果(番号・ライン数・倍率)とメッセージ表示
- API エンドポイントは `VITE_API_BASE_URL` を参照 (Amplify 環境変数で注入)。ローカルで試す場合は `.env.local` に設定。
- 開発フロー:
  1. `cd frontend`
  2. `npm install` (初回のみ)
  3. `npm run dev` (開発サーバー)
  4. `npm run build` → `dist/` を Amplify が配信

## 12. GitHub & Amplify Hosting 連携
リポジトリ未作成の場合は以下の順で進める:
1. **Git 初期化 & コミット**
   ```bash
   git init
   git add .
   git commit -m "Initial coingames stack"
   ```
   `.gitignore` には `node_modules`, `dist`, `.terraform/` などを含め済み。
2. **GitHub でリポジトリ作成**
   - https://github.com/new で `coingames` 等を作成
   - リモートを追加して push
     ```bash
     git remote add origin git@github.com:USERNAME/coingames.git
     git push -u origin main
     ```
3. **Amplify 連携を Terraform に反映**
   - `infra/environments/dev.tfvars` の
     ```
     amplify_repository = "https://github.com/USERNAME/coingames"
     amplify_access_token = "ghp_xxx" # GitHub Personal Access Token (repo scope)
     ```
     を設定し、`terraform apply -var-file=environments/dev.tfvars` を実行。
   - Amplify 側で GitHub 接続が有効になり、`main` ブランチに push すると自動でビルド&デプロイ。
4. **CI (GitHub Actions)**
   - `.github/workflows/frontend.yml` が `frontend/` 変更時に `npm ci && npm run build` を実施。Amplify による本番デプロイ前の健全性チェックとして機能する。
