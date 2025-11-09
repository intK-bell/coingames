export type GamePhase = "bet" | "draw" | "result";

export interface PlayerState {
  userId: string;
  medals: number;
  tokens: number;
  updatedAt: string;
  lastBonusDate?: string;
}

export interface BetRequest {
  action: "bet";
  userId: string;
  betAmount: number;
}

export interface StatusRequest {
  action: "status";
  userId: string;
}

export interface BonusRequest {
  action: "bonus";
  userId: string;
}

export interface ExchangeRequest {
  action: "exchange";
  userId: string;
}

export type GameRequest =
  | BetRequest
  | StatusRequest
  | BonusRequest
  | ExchangeRequest;

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
