--!strict

local cameraPart = workspace:FindFirstChild("CameraPart");
assert(cameraPart and cameraPart:IsA("BasePart"), "CameraPart not found or not a BasePart");

local camera = game.Workspace.CurrentCamera;
camera.CameraType = Enum.CameraType.Scriptable;
camera.CFrame = cameraPart.CFrame;