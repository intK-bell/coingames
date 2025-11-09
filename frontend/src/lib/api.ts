export type GameAction = "status" | "bet" | "bonus" | "exchange";

export interface GameRequestBase {
  userId: string;
  action: GameAction;
}

export interface BetRequest extends GameRequestBase {
  action: "bet";
  betAmount: number;
}

export type GameRequest = GameRequestBase | BetRequest;

export interface BetOutcome {
  betAmount: number;
  drawnNumbers: number[];
  lines: number;
  multiplier: number;
  payout: number;
}

export interface GameResponse {
  userId: string;
  medals: number;
  tokens: number;
  lastOutcome?: BetOutcome;
  message?: string;
  bonusGranted?: number;
}

const API_BASE_URL =
  import.meta.env.VITE_API_BASE_URL ??
  "https://example.execute-api.ap-northeast-1.amazonaws.com/";

export async function callGameApi(payload: GameRequest): Promise<GameResponse> {
  const res = await fetch(API_BASE_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(payload),
  });

  if (!res.ok) {
    const message = await res.text();
    throw new Error(message || "API error");
  }

  return (await res.json()) as GameResponse;
}
