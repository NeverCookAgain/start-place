--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local React = require(ReplicatedStorage.Shared.Packages.react);
local IRoom = require(ReplicatedStorage.Client.IRoom);
local Button = require(ReplicatedStorage.Client.Components.Button);
local PlayerSection = require(script.PlayerSection);

type IRoom = IRoom.IRoom;

local function Window()

  local room: IRoom?, setRoom = React.useState(nil :: IRoom?);

  React.useEffect(function()

    task.spawn(function()
    
      local room;
      local gotRoom = pcall(function()

        room = ReplicatedStorage.Shared.Functions.JoinRoom:InvokeServer();

      end);

      if not gotRoom then

        room = ReplicatedStorage.Shared.Functions.CreateRoom:InvokeServer();

      end

      setRoom(room);

    end);

  end, {});

  React.useEffect(function()
  
    if not room then return end;

    local roomChangedEvent = ReplicatedStorage.Shared.Events.RoomUpdated.OnClientEvent:Connect(function(newRoom: IRoom)

      if room.id == newRoom.id then
    
        setRoom(newRoom);

      end;

    end);

    return function()

      roomChangedEvent:Disconnect();

    end;

  end, {room});

  local playerSections = {};
  if room then

    for index, player in room.players do

      local playerSection = React.createElement(PlayerSection, {
        room = room;
        player = player;
        layoutOrder = index;
        key = `{room.id}-{player.userID}`;
      });
      
      table.insert(playerSections, playerSection);

    end;

  end;

  return React.createElement("Frame", {
    BackgroundTransparency = 0.5;
    BackgroundColor3 = Color3.new();
    Size = UDim2.fromScale(1, 1);
    BorderSizePixel = 0;
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      Padding = UDim.new(0, 15);
      SortOrder = Enum.SortOrder.LayoutOrder;
    });
    UIPadding = React.createElement("UIPadding", {
      PaddingTop = UDim.new(0, 15);
      PaddingBottom = UDim.new(0, 15);
      PaddingLeft = UDim.new(0, 15);
      PaddingRight = UDim.new(0, 15);
    });
    Content = React.createElement("Frame", {
      BackgroundTransparency = 1;
      LayoutOrder = 1;
      Size = UDim2.fromScale(1, 1);
    }, {
      UIFlexItem = React.createElement("UIFlexItem", {
        FlexMode = Enum.UIFlexMode.Fill;
      });
      UIListLayout = React.createElement("UIListLayout", {
        Padding = UDim.new(0, 15);
        SortOrder = Enum.SortOrder.LayoutOrder;
      });
      PlayerSections = React.createElement(React.Fragment, {}, playerSections);
    });
    Options = React.createElement("Frame", {
      AutomaticSize = Enum.AutomaticSize.Y;
      BackgroundTransparency = 1;
      LayoutOrder = 2;
      Size = UDim2.fromScale(1, 0);
    }, {
      UIListLayout = React.createElement("UIListLayout", {
        Padding = UDim.new(0, 15);
        SortOrder = Enum.SortOrder.LayoutOrder;
        FillDirection = Enum.FillDirection.Horizontal;
        HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween;
      });
      LeftButtons = React.createElement("Frame", {
        AutomaticSize = Enum.AutomaticSize.XY;
        BackgroundTransparency = 1;
        LayoutOrder = 1;
      }, {
        UIListLayout = React.createElement("UIListLayout", {
          Padding = UDim.new(0, 15);
          SortOrder = Enum.SortOrder.LayoutOrder;
          FillDirection = Enum.FillDirection.Horizontal;
        });
        BackButton = React.createElement(Button, {
          layoutOrder = 1;
          text = "Main Menu";
          width = 100;
          textSize = 30;
          onClick = function()

            ReplicatedStorage.Client.Events.MenuChanged:Fire("MainMenu");

          end;
        });
      });
      RightButtons = React.createElement("Frame", {
        AutomaticSize = Enum.AutomaticSize.XY;
        BackgroundTransparency = 1;
        LayoutOrder = 2;
      }, {
        UIListLayout = React.createElement("UIListLayout", {
          Padding = UDim.new(0, 15);
          SortOrder = Enum.SortOrder.LayoutOrder;
          FillDirection = Enum.FillDirection.Horizontal;
        });
        PlayButton = React.createElement(Button, {
          layoutOrder = 1;
          text = "Change character";
          width = 100;
          textSize = 30;
          onClick = function()

            ReplicatedStorage.Client.Events.MenuChanged:Fire("MatchMenu");

          end;
        });
      });
    });
  });

end;

return Window;