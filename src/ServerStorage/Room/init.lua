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

    return MessagingService:SubscribeAsync(`Room{self.id}`, function()
  
      local roomData = MemoryStoreService:GetSortedMap("Rooms"):GetAsync(self.id);
      local room = Room.new(roomData);
      ReplicatedStorage.Shared.Events.RoomUpdated:FireAllClients(room);

      if room.serverAccessCode then

        for _, player in Players:GetPlayers() do

          if table.find(room.playerIDs, player.UserId) then

            local success, errorMessage = pcall(function()

              local teleportOptions = Instance.new("TeleportOptions");
              teleportOptions.ReservedServerAccessCode = room.serverAccessCode;
              TeleportService:TeleportAsync(1234567890, {player}, teleportOptions);

            end);

            if not success then
              warn(`Failed to teleport player {player.Name} to private server: {errorMessage}`);
            end;

          end;

        end;
        
      end;

    end);

  end;

  local function save(self: IRoom): IRoom

    MemoryStoreService:GetSortedMap("Rooms"):SetAsync(self.id, self:toString(), 6000);
    return Room.get(self.id);

  end;

  local function reserveServer(self: IRoom): IRoom

    local serverAccessCode, privateServerId = TeleportService:ReserveServer(1234567890);
    self.serverAccessCode = serverAccessCode;
    self.privateServerID = privateServerId;

    MemoryStoreService:GetSortedMap("Rooms"):SetAsync(self.id, self:toString(), 6000);

    return Room.get(self.id);

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

function Room.get(roomId: string): IRoom

  local roomData = MemoryStoreService:GetSortedMap("Rooms"):GetAsync(roomId);
  assert(roomData, `Room {roomId} does not exist.`);
  local room = Room.new(roomData);

  return room;

end;

return Room;