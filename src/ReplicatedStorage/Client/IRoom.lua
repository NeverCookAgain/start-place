--!strict

export type RoomPlayer = {
  userID: number;
  characterName: string;
  isReady: boolean;
}

export type RoomProperties = {
  id: string;
  players: {RoomPlayer};
}

export type IRoom = RoomProperties;

return {};