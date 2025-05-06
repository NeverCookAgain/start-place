--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);

export type Properties = {
  layoutOrder: number;
  onClick: () -> ();
  text: string;
  width: number;
  textSize: number;
}

local function Button(properties: Properties)

  return React.createElement("ImageButton", {
    BackgroundTransparency = 1;
    LayoutOrder = properties.layoutOrder;
    Image = "rbxassetid://119649376156285";
    Size = UDim2.new(0, properties.width, 0, properties.width);
    [React.Event.Activated] = function()

      properties.onClick()

    end;
  }, {
    UIAspectRatioConstraint = React.createElement("UIAspectRatioConstraint", {
      AspectRatio = 2.28;
    });
    TextLabel = React.createElement("TextLabel", {
      AnchorPoint = Vector2.new(0.5, 0.5);
      AutomaticSize = Enum.AutomaticSize.XY;
      BackgroundTransparency = 1;
      Position = UDim2.new(0.5, 0, 0.5, 0);
      Size = UDim2.new();
      TextColor3 = Color3.new(1, 1, 1);
      FontFace = Font.fromName("Kalam");
      Text = properties.text;
      TextSize = properties.textSize;
    });
  });

end;

return Button;