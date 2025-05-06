--!strict

local ServerStorage = game:GetService("ServerStorage");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local Room = require(ServerStorage.Room);

local roomChangedEvents = {};

ReplicatedStorage.Shared.Functions.CreateRoom.OnServerInvoke = function(player: Player)

  local room = Room.create();
  room = room:addPlayerID(player.UserId);

  if not roomChangedEvents[room.id] then

    roomChangedEvents[room.id] = room:watch();

  end;

  return room;

end;

ReplicatedStorage.Shared.Functions.JoinRoom.OnServerInvoke = function(player: Player, roomID: unknown)

  assert(typeof(roomID) == "string", "Room ID must be a string.");

  local room = Room.get(roomID);
  room = room:addPlayerID(player.UserId);

  if not roomChangedEvents[room.id] then

    roomChangedEvents[room.id] = room:watch();

  end;

  return room;

end;

ReplicatedStorage.Shared.Functions.ReserveServer.OnServerInvoke = function(player: Player, roomID: unknown)

  assert(typeof(roomID) == "string", "Room ID must be a string.");

  local room = Room.get(roomID);
  room = room:reserveServer();

  return room;

end;