import {
  DynamoDBClient,
  DynamoDBClientConfig,
} from "@aws-sdk/client-dynamodb";
import {
  DynamoDBDocumentClient,
  GetCommand,
  PutCommand,
  UpdateCommand,
} from "@aws-sdk/lib-dynamodb";
import { PlayerState } from "./types";

const TABLE_NAME = process.env.DYNAMODB_TABLE ?? "";

if (!TABLE_NAME) {
  throw new Error("DYNAMODB_TABLE environment variable is required");
}

const clientConfig: DynamoDBClientConfig = {};
const dynamo = DynamoDBDocumentClient.from(new DynamoDBClient(clientConfig), {
  marshallOptions: {
    convertClassInstanceToMap: true,
    removeUndefinedValues: true,
  },
});

const STATE_SORT_KEY = "STATE";
const INITIAL_MEDALS = 1000;

export async function getOrCreatePlayerState(
  userId: string,
): Promise<PlayerState> {
  const result = await dynamo.send(
    new GetCommand({
      TableName: TABLE_NAME,
      Key: {
        user_id: userId,
        entity_type_ts: STATE_SORT_KEY,
      },
    }),
  );

  if (result.Item) {
    return result.Item as PlayerState;
  }

  const newState: PlayerState = {
    userId,
    medals: INITIAL_MEDALS,
    tokens: 0,
    updatedAt: new Date().toISOString(),
    lastBonusDate: undefined,
  };

  await dynamo.send(
    new PutCommand({
      TableName: TABLE_NAME,
      Item: {
        user_id: userId,
        entity_type_ts: STATE_SORT_KEY,
        ...newState,
      },
    }),
  );

  return newState;
}

export async function savePlayerState(state: PlayerState): Promise<PlayerState> {
  const updated: PlayerState = {
    ...state,
    updatedAt: new Date().toISOString(),
  };

  await dynamo.send(
    new UpdateCommand({
      TableName: TABLE_NAME,
      Key: {
        user_id: state.userId,
        entity_type_ts: STATE_SORT_KEY,
      },
      UpdateExpression:
        "SET medals = :medals, tokens = :tokens, updatedAt = :updatedAt, lastBonusDate = :lastBonusDate",
      ExpressionAttributeValues: {
        ":medals": updated.medals,
        ":tokens": updated.tokens,
        ":updatedAt": updated.updatedAt,
        ":lastBonusDate": updated.lastBonusDate ?? null,
      },
    }),
  );

  return updated;
}
