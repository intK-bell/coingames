import type {
  APIGatewayProxyEventV2,
  APIGatewayProxyResultV2,
} from "aws-lambda";
import { getOrCreatePlayerState, savePlayerState } from "./storage";
import { GameRequest, GameResponse } from "./types";
import { simulateBet } from "./gameLogic";

const ALLOWED_BETS = new Set([10, 50, 100]);
const DAILY_BONUS = 500;

function response(
  statusCode: number,
  body: Record<string, unknown>,
): APIGatewayProxyResultV2 {
  return {
    statusCode,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
    },
    body: JSON.stringify(body),
  };
}

function parseBody(event: APIGatewayProxyEventV2): GameRequest {
  if (!event.body) {
    throw new Error("Request body is required");
  }

  const parsed = JSON.parse(event.body);
  if (typeof parsed?.action !== "string" || typeof parsed?.userId !== "string") {
    throw new Error("action and userId are required");
  }

  if (parsed.action === "bet") {
    if (typeof parsed.betAmount !== "number") {
      throw new Error("betAmount must be a number");
    }
    return {
      action: "bet",
      userId: parsed.userId,
      betAmount: parsed.betAmount,
    };
  }

  if (parsed.action === "bonus") {
    return {
      action: "bonus",
      userId: parsed.userId,
    };
  }

  if (parsed.action === "exchange") {
    return {
      action: "exchange",
      userId: parsed.userId,
    };
  }

  return {
    action: "status",
    userId: parsed.userId,
  };
}

function todayKey(): string {
  return new Date().toISOString().slice(0, 10);
}

export const handler = async (
  event: APIGatewayProxyEventV2,
): Promise<APIGatewayProxyResultV2> => {
  try {
    const request = parseBody(event);
    const currentState = await getOrCreatePlayerState(request.userId);

    if (request.action === "status") {
      const body: GameResponse = {
        userId: currentState.userId,
        medals: currentState.medals,
        tokens: currentState.tokens,
      };
      return response(200, body);
    }

    if (request.action === "bonus") {
      const today = todayKey();
      if (currentState.lastBonusDate === today) {
        return response(200, {
          userId: currentState.userId,
          medals: currentState.medals,
          tokens: currentState.tokens,
          bonusGranted: 0,
          message: "Daily bonus already claimed",
        });
      }

      const updated = await savePlayerState({
        ...currentState,
        medals: currentState.medals + DAILY_BONUS,
        lastBonusDate: today,
      });

      const body: GameResponse = {
        userId: updated.userId,
        medals: updated.medals,
        tokens: updated.tokens,
        bonusGranted: DAILY_BONUS,
        message: "Daily bonus granted",
      };
      return response(200, body);
    }

    if (request.action === "exchange") {
      if (currentState.medals < 10000) {
        return response(400, {
          message: "Need at least 10,000 medals to exchange",
        });
      }
      const tokensGained = Math.floor(currentState.medals / 10000);
      const remainder = currentState.medals % 10000;
      const updated = await savePlayerState({
        ...currentState,
        medals: remainder,
        tokens: currentState.tokens + tokensGained,
      });
      const body: GameResponse = {
        userId: updated.userId,
        medals: updated.medals,
        tokens: updated.tokens,
        message: `Exchanged for ${tokensGained} token(s)!`,
      };
      return response(200, body);
    }

    if (!ALLOWED_BETS.has(request.betAmount)) {
      return response(400, { message: "Invalid bet amount" });
    }

    if (request.betAmount > currentState.medals) {
      return response(400, { message: "Not enough medals" });
    }

    const { updated, outcome } = simulateBet(
      currentState,
      request.betAmount,
    );
    const saved = await savePlayerState(updated);

    const body: GameResponse = {
      userId: saved.userId,
      medals: saved.medals,
      tokens: saved.tokens,
      lastOutcome: outcome,
    };

    return response(200, body);
  } catch (error) {
    console.error("Handler error", error);
    return response(500, {
      message: (error as Error).message ?? "Internal Server Error",
    });
  }
};
