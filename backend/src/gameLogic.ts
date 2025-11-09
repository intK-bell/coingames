import { BetOutcome, PlayerState } from "./types";

const DRAW_COUNT = 7;
const MIN_NUMBER = 1;
const MAX_NUMBER = 75;
const MULTIPLIERS: Record<number, number> = {
  0: 0,
  1: 2,
  2: 5,
  3: 15,
  4: 25,
  5: 35,
  6: 45,
  7: 50,
};

function randomInts(count: number, min: number, max: number): number[] {
  const available = Array.from({ length: max - min + 1 }, (_, idx) => idx + min);
  const results: number[] = [];
  for (let i = 0; i < count && available.length > 0; i += 1) {
    const idx = Math.floor(Math.random() * available.length);
    results.push(available[idx]);
    available.splice(idx, 1);
  }
  return results;
}

function rollLines(): number {
  const roll = Math.random();
  if (roll > 0.995) return 7; // jackpot
  if (roll > 0.98) return 5;
  if (roll > 0.95) return 3;
  if (roll > 0.85) return 2;
  if (roll > 0.65) return 1;
  return 0;
}

export function simulateBet(
  state: PlayerState,
  betAmount: number,
): { updated: PlayerState; outcome: BetOutcome } {
  const drawnNumbers = randomInts(DRAW_COUNT, MIN_NUMBER, MAX_NUMBER);
  const lines = rollLines();
  const multiplier = MULTIPLIERS[lines] ?? 0;
  const payout = Math.floor(betAmount * multiplier);

  let medals = state.medals - betAmount + payout;
  let tokens = state.tokens;

  if (medals >= 10000) {
    tokens += Math.floor(medals / 10000);
    medals = medals % 10000;
  }

  const updated: PlayerState = {
    ...state,
    medals,
    tokens,
  };

  const outcome: BetOutcome = {
    betAmount,
    drawnNumbers,
    lines,
    multiplier,
    payout,
  };

  return { updated, outcome };
}
