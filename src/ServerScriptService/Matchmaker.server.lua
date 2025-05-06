--!strict

local Players = game:GetService("Players");
local ServerStorage = game:GetService("ServerStorage");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local Room = require(ServerStorage.Room);

local roomChangedEvents = {};
local playerRoomIDs: {[number]: string} = {};

ReplicatedStorage.Shared.Functions.CreateRoom.OnServerInvoke = function(player: Player)

  local room = Room.create();
  room = room:addPlayer({
    userID = player.UserId;
    characterName = "Bill Burgers";
    isReady = false;
  });

  if not roomChangedEvents[room.id] then

    roomChangedEvents[room.id] = room:watch();

  end;

  playerRoomIDs[player.UserId] = room.id;

  return room;

end;

ReplicatedStorage.Shared.Functions.JoinRoom.OnServerInvoke = function(player: Player, roomID: unknown)

  assert(not roomID or typeof(roomID) == "string", "Room ID must be a string.");

  local room = if roomID then Room.get(roomID) else Room.random();
  local characterNames = {"Bill Burgers", "Cousin Ricky", "Rigatoni", "Sweaty Todd"};
  for _, player in room.players do

    local characterNameIndex = table.find(characterNames, player.characterName);
    if characterNameIndex then

      table.remove(characterNames, characterNameIndex);

    end;

  end;
  
  room = room:addPlayer({
    userID = player.UserId;
    characterName = characterNames[1];
    isReady = false;
  });

  if not roomChangedEvents[room.id] then

    roomChangedEvents[room.id] = room:watch();

  end;

  playerRoomIDs[player.UserId] = room.id;

  return room;

end;

ReplicatedStorage.Shared.Functions.ReadyPlayer.OnServerInvoke = function(player: Player, roomID: unknown)

  assert(typeof(roomID) == "string", "Room ID must be a string.");
  local room = Room.get(roomID);

  return room:readyPlayer(player.UserId);

end;

Players.PlayerRemoving:Connect(function(player: Player)

  local roomID = playerRoomIDs[player.UserId];
  if not roomID then return end;

  local room = Room.get(roomID);
  room = room:removePlayer(player.UserId);

  if #room.players == 0 then

    room:delete();
    roomChangedEvents[roomID] = nil;

  end;

end);