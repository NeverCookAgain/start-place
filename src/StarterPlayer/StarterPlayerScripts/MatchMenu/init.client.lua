--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");

local React = require(ReplicatedStorage.Shared.Packages.react);
local ReactRoblox = require(ReplicatedStorage.Shared.Packages["react-roblox"]);

local Window = require(script.Window);

local screenGUI = Instance.new("ScreenGui");
screenGUI.Name = "MatchMenu";
screenGUI.ScreenInsets = Enum.ScreenInsets.None;
screenGUI.Parent = Players.LocalPlayer:WaitForChild("PlayerGui");

local root = ReactRoblox.createRoot(screenGUI);

local function renderMenu()

  root:render(React.createElement(Window));

end;

ReplicatedStorage.Client.Events.MenuChanged.Event:Connect(function(menuName: string)

  if menuName == screenGUI.Name then

    renderMenu();

  else

    root:unmount();

  end

end);