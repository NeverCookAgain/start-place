--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local React = require(ReplicatedStorage.Shared.Packages.react);

local useResponsiveDesign = require(ReplicatedStorage.Client.Modules.useResponsiveDesign);
local Button = require(ReplicatedStorage.Client.Components.Button);

local function Window()

  local isLargerThanPhone = useResponsiveDesign({
    minimumWidth = 738;
  });

  return React.createElement(React.Fragment, {}, {
    UIListLayout = React.createElement("UIListLayout", {
      FillDirection = Enum.FillDirection.Horizontal;
      HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween;
      SortOrder = Enum.SortOrder.LayoutOrder;
    });
    UIPadding = React.createElement("UIPadding", {
      PaddingTop = UDim.new(0, 15);
      PaddingBottom = UDim.new(0, 15);
      PaddingLeft = UDim.new(0, 15);
      PaddingRight = UDim.new(0, 15);
    });
    Logo = React.createElement("ImageLabel", {
      BackgroundTransparency = 1;
      Size = UDim2.new(0.3, 0, 0.5, 0);
      Image = "rbxassetid://96811403965455";
      LayoutOrder = 1;
    }, {
      UIAspectRatioConstraint = React.createElement("UIAspectRatioConstraint", {
        AspectRatio = 1.02;
      });
    });
    Options = React.createElement("Frame", {
      AutomaticSize = Enum.AutomaticSize.X;
      BackgroundTransparency = 1;
      LayoutOrder = 2;
      Size = UDim2.new(0, 0, 1, 0);
    }, {
      UIListLayout = React.createElement("UIListLayout", {
        Padding = UDim.new(0, 15);
        SortOrder = Enum.SortOrder.LayoutOrder;
        VerticalAlignment = Enum.VerticalAlignment.Bottom;
      });
      PlayButton = React.createElement(Button, {
        layoutOrder = 1;
        text = "Play";
        width = if isLargerThanPhone then 150 else 100;
        textSize = if isLargerThanPhone then 40 else 30;
        onClick = function()

          ReplicatedStorage.Client.Events.MenuChanged:Fire("MatchMenu");

        end;
      })
    });
  });

end

return Window;