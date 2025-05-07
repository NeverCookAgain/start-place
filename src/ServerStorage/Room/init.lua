--!strict

local Players = game:GetService("Players");
local HttpService = game:GetService("HttpService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local MessagingService = game:GetService("MessagingService");
local MemoryStoreService = game:GetService("MemoryStoreService");
local TeleportService = game:GetService("TeleportService");

local PlaceMap = require(ReplicatedStorage.Shared.PlaceMap);

local IRoom = require(script.IRoom);
type IRoom = IRoom.IRoom;

local Room = {}

export type ConstructorProperties = {
  id: string;
  serverAccessCode: string?;
  privateServerID: number?;
  players: {IRoom.RoomPlayer}?;
}

function Room.new(properties: ConstructorProperties): IRoom

  local function addPlayer(self: IRoom, player: IRoom.RoomPlayer): IRoom

    table.insert(self.players, player);
    return self:save();

  end;

  local function removePlayer(self: IRoom, playerID: number): IRoom

    for i, player in self.players do

      if playerID == player.userID then

        table.remove(self.players, i);

      end;

    end;

    return self:save();

  end;

  local function toString(self: IRoom): string

    return HttpService:JSONEncode(self);

  end;

  local function watch(self: IRoom): RBXScriptConnection

    return MessagingService:SubscribeAsync(`Room{self.id}`, function(message)
  
      local room = Room.new(HttpService:JSONDecode(message.Data));
      ReplicatedStorage.Shared.Events.RoomUpdated:FireAllClients(room);

      if room.serverAccessCode then

        for _, player in Players:GetPlayers() do

          for _, roomPlayer in room.players do

            if player.UserId == roomPlayer.userID then

              local success, errorMessage = pcall(function()

                local teleportOptions = Instance.new("TeleportOptions");
                teleportOptions.ReservedServerAccessCode = room.serverAccessCode;
                TeleportService:TeleportAsync(PlaceMap.Kitchen, {player}, teleportOptions);

              end);

              if not success then

                error(`Failed to teleport player {player.Name} to private server: {errorMessage}`);

              end;

            end;

          end;

        end;
        
      end;

    end);

  end;

  local function save(self: IRoom): IRoom

    MemoryStoreService:GetSortedMap("Rooms"):SetAsync(self.id, self:toString(), 6000);
    MessagingService:PublishAsync(`Room{self.id}`, self:toString());
    return Room.get(self.id);

  end;

  local function reserveServer(self: IRoom): IRoom

    local isReserved, errorMessage = pcall(function()

      local serverAccessCode, privateServerID = TeleportService:ReserveServer(PlaceMap.Kitchen);
      self.serverAccessCode = serverAccessCode;
      self.privateServerID = privateServerID;

      MemoryStoreService:GetSortedMap("RoomIDs"):SetAsync(privateServerID, self.id, 1000);
      
    end);

    if not isReserved then

      error(`Failed to reserve server: {errorMessage}`);

    end;

    return self:save();

  end;

  local function readyPlayer(self: IRoom, playerID: number): IRoom

    local shouldTeleport = true;

    for i, player in self.players do

      if playerID == player.userID then

        player.isReady = true;

      end;

      if not player.isReady then

        shouldTeleport = false;

      end;

    end;

    self = self:save();

    return if shouldTeleport then self:reserveServer() else self;

  end;

  local function delete(self: IRoom): ()

    MemoryStoreService:GetSortedMap("Rooms"):RemoveAsync(self.id);

  end;

  local room = {
    id = properties.id;
    players = properties.players or {},
    privateServerID = properties.privateServerID or nil;
    serverAccessCode = properties.serverAccessCode or nil;
    addPlayer = addPlayer;
    removePlayer = removePlayer;
    toString = toString;
    watch = watch;
    readyPlayer = readyPlayer;
    save = save;
    reserveServer = reserveServer;
    delete = delete;
  }

  return room;

end;

function Room.create(): IRoom

  local room = Room.new({
    id = HttpService:GenerateGUID(false);
  });

  return room:save();

end;

function Room.get(roomID: string): IRoom

  local encodedRoomData = MemoryStoreService:GetSortedMap("Rooms"):GetAsync(roomID);
  assert(encodedRoomData, `Room {roomID} does not exist.`);

  local roomData = HttpService:JSONDecode(encodedRoomData);
  local room = Room.new(roomData);

  return room;

end;

function Room.getByPrivateServerID(privateServerID: number): IRoom

  local roomID = MemoryStoreService:GetSortedMap("RoomIDs"):GetAsync(privateServerID);
  assert(roomID, `Room with private server ID {privateServerID} does not exist.`);

  return Room.get(roomID);

end;

function Room.random(): IRoom

  local room: IRoom? = nil;
  local encodedRoomDataList = MemoryStoreService:GetSortedMap("Rooms"):GetRangeAsync(Enum.SortDirection.Ascending, 100);
  while not room and #encodedRoomDataList > 0 and task.wait() do

    local randomIndex = math.random(1, #encodedRoomDataList);
    local randomEncodedRoomData = encodedRoomDataList[randomIndex].value;
    local roomData = HttpService:JSONDecode(randomEncodedRoomData);
    local possibleRoom = Room.new(roomData);

    local areAllPlayersReady = true;
    for _, player in possibleRoom.players do

      if not player.isReady then
        
        areAllPlayersReady = false;
        break;

      end;

    end;

    if areAllPlayersReady then

      table.remove(encodedRoomDataList, randomIndex);

    else

      room = possibleRoom;

    end;

  end;

  assert(room, "No available rooms.");

  return room;

end;

return Room;