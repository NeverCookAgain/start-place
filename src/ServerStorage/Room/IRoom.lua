--!strict

export type RoomProperties = {
  id: string;
  playerIDs: {number};
  serverAccessCode: string?;
  privateServerID: number?;
}

export type RoomMethods = {
  addPlayerID: (self: IRoom, playerID: number) -> ();
  removePlayerID: (self: IRoom, playerID: number) -> ();
  toString: (self: IRoom) -> string;
  save: (self: IRoom) -> IRoom;
  watch: (self: IRoom) -> RBXScriptConnection;
  reserveServer: (self: IRoom) -> IRoom;
}

export type IRoom = RoomProperties & RoomMethods;

return {};