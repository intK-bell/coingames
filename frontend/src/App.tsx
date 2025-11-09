import { useCallback, useEffect, useMemo, useState } from "react";
import "./App.css";
import { callGameApi } from "./lib/api";
import type { GameResponse, GameRequest } from "./lib/api";

const BET_OPTIONS = [10, 50, 100];
const PROGRESS_GOAL = 10000;
const STORAGE_KEY = "coingames_user";

function App() {
  const [userId, setUserId] = useState<string>(() => {
    return localStorage.getItem(STORAGE_KEY) || "kid01";
  });
  const [inputUserId, setInputUserId] = useState(userId);
  const [status, setStatus] = useState<GameResponse | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [message, setMessage] = useState<string | null>(null);

  const fetchStatus = useCallback(
    async (targetUserId: string) => {
      setLoading(true);
      setError(null);
      setMessage(null);
      try {
        const response = await callGameApi({
          action: "status",
          userId: targetUserId,
        });
        setStatus(response);
      } catch (err) {
        setError((err as Error).message);
      } finally {
        setLoading(false);
      }
    },
    [],
  );

  useEffect(() => {
    localStorage.setItem(STORAGE_KEY, userId);
    fetchStatus(userId);
  }, [userId, fetchStatus]);

  const handleAction = useCallback(
    async (action: "bonus" | "exchange" | "bet", betAmount?: number) => {
      if (loading) return;
      setLoading(true);
      setError(null);
      setMessage(null);
      try {
        const payload: GameRequest =
          action === "bet"
            ? { action, userId, betAmount: betAmount ?? 0 }
            : { action, userId };

        const response = await callGameApi(payload);
        setStatus(response);
        if (response.message) {
          setMessage(response.message);
        } else if (action === "bonus" && response.bonusGranted) {
          setMessage(`+${response.bonusGranted} medals!`);
        } else {
          setMessage("Action completed!");
        }
      } catch (err) {
        setError((err as Error).message);
      } finally {
        setLoading(false);
      }
    },
    [loading, userId],
  );

  const progress = useMemo(() => {
    if (!status) return 0;
    return Math.min(100, Math.round((status.medals / PROGRESS_GOAL) * 100));
  }, [status]);

  return (
    <div className="app-shell">
      <header className="app-header">
        <div>
          <p className="eyebrow">coingames</p>
          <h1>メダルを集めてトークンゲット！</h1>
        </div>
        <div className="user-switcher">
          <label htmlFor="userId">プレイヤーID</label>
          <div className="user-input-row">
            <input
              id="userId"
              value={inputUserId}
              onChange={(e) => setInputUserId(e.target.value)}
              placeholder="kid01"
            />
            <button
              type="button"
              onClick={() => {
                const trimmed = inputUserId.trim();
                if (trimmed) setUserId(trimmed);
              }}
            >
              切り替え
            </button>
          </div>
        </div>
      </header>

      <main className="dashboard">
        <section className="status-panel">
          <div className="stat">
            <p>メダル</p>
            <strong>{status?.medals ?? "---"}</strong>
          </div>
          <div className="stat">
            <p>トークン</p>
            <strong>{status?.tokens ?? "---"}</strong>
          </div>
          <div className="progress">
            <p>10,000メダルまであと</p>
            <div className="progress-bar">
              <span style={{ width: `${progress}%` }} />
            </div>
            <small>{progress}%</small>
          </div>
        </section>

        <section className="actions-panel">
          <h2>ベットする</h2>
          <div className="bet-buttons">
            {BET_OPTIONS.map((bet) => (
              <button
                key={bet}
                disabled={
                  loading || (status ? status.medals < bet : true)
                }
                onClick={() => handleAction("bet", bet)}
              >
                {bet} メダル
              </button>
            ))}
          </div>
          <div className="secondary-actions">
            <button disabled={loading} onClick={() => handleAction("bonus")}>
              デイリーボーナス
            </button>
            <button
              disabled={loading || (status ? status.medals < PROGRESS_GOAL : true)}
              onClick={() => handleAction("exchange")}
            >
              トークン交換
            </button>
          </div>
        </section>

        <section className="summary-panel">
          <h2>ゲームログ</h2>
          {loading && <p>読み込み中...</p>}
          {error && <p className="error">{error}</p>}
          {message && <p className="message">{message}</p>}
          {status?.lastOutcome ? (
            <div className="outcome-card">
              <p>
                ベット: <strong>{status.lastOutcome.betAmount}</strong> メダル
              </p>
              <p>
                ライン: <strong>{status.lastOutcome.lines}</strong> / 倍率{" "}
                {status.lastOutcome.multiplier}x
              </p>
              <p>リワード: +{status.lastOutcome.payout} メダル</p>
              <p className="numbers">
                抽選番号: {status.lastOutcome.drawnNumbers.join(", ")}
              </p>
            </div>
          ) : (
            <p>まだプレイしていません。ベットしてみよう！</p>
          )}
        </section>
      </main>
    </div>
  );
}

export default App;
