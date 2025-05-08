--!strict

export type RoomPlayer = {
  userID: number;
  characterName: string;
  isReady: boolean;
}

export type RoomProperties = {
  id: string;
  players: {RoomPlayer};
  serverAccessCode: string?;
  privateServerID: number?;
  isComplete: boolean;
}

export type RoomMethods = {
  addPlayer: (self: IRoom, playerID: RoomPlayer) -> ();
  removePlayer: (self: IRoom, playerID: number) -> ();
  toString: (self: IRoom) -> string;
  save: (self: IRoom) -> IRoom;
  watch: (self: IRoom) -> RBXScriptConnection;
  reserveServer: (self: IRoom) -> IRoom;
  readyPlayer: (self: IRoom, playerID: number) -> IRoom;
  delete: (self: IRoom) -> ();
}

export type IRoom = RoomProperties & RoomMethods;

return {};