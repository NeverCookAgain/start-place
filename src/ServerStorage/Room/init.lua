--!strict

local Players = game:GetService("Players");
local HttpService = game:GetService("HttpService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local MessagingService = game:GetService("MessagingService");
local MemoryStoreService = game:GetService("MemoryStoreService");
local TeleportService = game:GetService("TeleportService");

local IRoom = require(script.IRoom);
type IRoom = IRoom.IRoom;

local Room = {}

export type ConstructorProperties = {
  id: string;
  serverAccessCode: string?;
  privateServerID: number?;
  playerIDs: {number}?;
}

function Room.new(properties: ConstructorProperties): IRoom

  local function addPlayerID(self: IRoom, playerID: number): IRoom

    table.insert(self.playerIDs, playerID);
    return self:save();

  end;

  local function removePlayerID(self: IRoom, playerID: number): IRoom

    for i, id in self.playerIDs do

      if id == playerID then

        table.remove(self.playerIDs, i);
        break;

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

          if table.find(room.playerIDs, player.UserId) then

            local success, errorMessage = pcall(function()

              local teleportOptions = Instance.new("TeleportOptions");
              teleportOptions.ReservedServerAccessCode = room.serverAccessCode;
              TeleportService:TeleportAsync(106198121236214, {player}, teleportOptions);

            end);

            if not success then

              error(`Failed to teleport player {player.Name} to private server: {errorMessage}`);

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

      local serverAccessCode, privateServerID = TeleportService:ReserveServer(106198121236214);
      self.serverAccessCode = serverAccessCode;
      self.privateServerID = privateServerID;
      
    end);

    if not isReserved then

      error(`Failed to reserve server: {errorMessage}`);

    end;

    return self:save();

  end;

  local room = {
    id = properties.id;
    playerIDs = properties.playerIDs or {},
    privateServerID = properties.privateServerID or nil;
    serverAccessCode = properties.serverAccessCode or nil;
    addPlayerID = addPlayerID;
    removePlayerID = removePlayerID;
    toString = toString;
    watch = watch;
    save = save;
    reserveServer = reserveServer;
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

function Room.random(): IRoom

  local encodedRoomDataList = MemoryStoreService:GetSortedMap("Rooms"):GetRangeAsync(Enum.SortDirection.Ascending, 100);
  local randomIndex = math.random(1, #encodedRoomDataList);
  local randomEncodedRoomData = encodedRoomDataList[randomIndex].value;
  local roomData = HttpService:JSONDecode(randomEncodedRoomData);
  local room = Room.new(roomData);
  return room;

end;

return Room;