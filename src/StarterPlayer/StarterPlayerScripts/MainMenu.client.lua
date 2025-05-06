--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local room = ReplicatedStorage.Shared.Functions.CreateRoom:InvokeServer();
ReplicatedStorage.Shared.Functions.ReserveServer:InvokeServer(room.id);