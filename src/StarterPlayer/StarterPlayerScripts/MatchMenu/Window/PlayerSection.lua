--!strict

local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local React = require(ReplicatedStorage.Shared.Packages.react);
local IRoom = require(ReplicatedStorage.Client.IRoom);

local Button = require(ReplicatedStorage.Client.Components.Button);

type IRoom = IRoom.IRoom;

export type Properties = {
  room: IRoom;
  player: IRoom.RoomPlayer;
  layoutOrder: number;
};

local function PlayerSection(properties: Properties)

  local playerName, setPlayerName = React.useState("Loading...");
  local shouldReady, setShouldReady = React.useState(false);

  React.useEffect(function()

    local gotPlayerName, errorMessage = pcall(function()
    
      local playerName = Players:GetNameFromUserIdAsync(properties.player.userID);
      setPlayerName(playerName);

    end);

    if not gotPlayerName then

      warn("Failed to get player name: " .. errorMessage);
      setPlayerName("Unknown Player");

    end

  end, {properties.player});

  React.useEffect(function()

    if not properties.player.isReady and shouldReady then

      local canReadyPlayer, errorMessage = pcall(function()
        
        ReplicatedStorage.Shared.Functions.ReadyPlayer:InvokeServer(properties.room.id);

      end);

      if not canReadyPlayer then

        warn(`Failed to ready player: {errorMessage}`);
        setShouldReady(false);

      end

    end;

  end, {properties.player :: unknown, shouldReady});

  return React.createElement("Frame", {
    AutomaticSize = Enum.AutomaticSize.XY;
    LayoutOrder = properties.layoutOrder;
    BackgroundTransparency = 1;
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder;
      Padding = UDim.new(0, 15);
    });
    PlayerName = React.createElement("TextLabel", {
      BackgroundTransparency = 1;
      AutomaticSize = Enum.AutomaticSize.XY;
      Text = playerName;
      TextColor3 = Color3.new(1, 1, 1);
      FontFace = Font.fromName("Kalam", Enum.FontWeight.Bold);
      TextSize = 24;
      LayoutOrder = 1;
    });
    ReadyStatus = React.createElement("TextLabel", {
      BackgroundTransparency = 1;
      AutomaticSize = Enum.AutomaticSize.XY;
      Text = if properties.player.isReady then "Ready" else "Not Ready";
      TextColor3 = Color3.new(1, 1, 1);
      FontFace = Font.fromName("Kalam");
      TextSize = 24;
      LayoutOrder = 2;
    });
    ReadyButton = if properties.player.userID == Players.LocalPlayer.UserId and not properties.player.isReady then
      React.createElement(Button, {
        layoutOrder = 3;
        text = "Ready";
        width = 100;
        textSize = 24;
        isDisabled = shouldReady;
        onClick = function()

          setShouldReady(true);

        end;
      })
    else nil;
  })

end;

return PlayerSection;