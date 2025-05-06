--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");

local React = require(ReplicatedStorage.Shared.Packages.react);
local ReactRoblox = require(ReplicatedStorage.Shared.Packages["react-roblox"]);

local Window = require(script.Window);

local screenGUI = Instance.new("ScreenGui");
screenGUI.Name = "MainMenu";
screenGUI.Parent = Players.LocalPlayer:WaitForChild("PlayerGui");

local root = ReactRoblox.createRoot(screenGUI);
root:render(React.createElement(Window));