-- SERVICES --
local Players = game:GetService("Players");
local DataStoreService = game:GetService("DataStoreService");
local HttpService = game:GetService("HttpService");

-- VARIABLES --
local playerClasses = {} -- Table to store player classes

-- Table of functions to handle player joining based on whether they have existing data or not
local onJoinTable = {
	-- Function to handle new players
	[true] = function(player, result)
		print("New player, creating data :", player.Name);
		-- Create a new player class instance and store it
		local playerClass = require(script.PlayerClass).new(player);
		playerClasses[Players:GetUserIdFromNameAsync(player.Name)] = playerClass;
		-- Send the player class data to the client
		game.ReplicatedStorage.Remotes.Events.SetData:FireClient(player, playerClass)
	end,
	-- Function to handle returning players with existing data
	[false] = function(player, result)
		print("Loading data for :", player.Name);
		-- Create a player class instance with existing data and store it
		local playerClass = require(script.PlayerClass).new(player, HttpService:JSONDecode(result));
		playerClass:setCharacter(player.Character);
		playerClass:setName(player.Name);
		playerClasses[Players:GetUserIdFromNameAsync(player.Name)] = playerClass;
		-- Send the existing player data to the client
		game.ReplicatedStorage.Remotes.Events.SetData:FireClient(player, HttpService:JSONDecode(result))	
	end,
}

-- datastore for player class data
local playerClassDB = DataStoreService:GetDataStore("_playerClassData");

-- FUNCTIONS --

-- Function to get a player's ID
local function getPlayerId(player: Player)
	return Players:GetUserIdFromNameAsync(player.Name)
end

-- Function to save player data to the datastore
local function saveData(PlayerID: number, playerClass)
	local success, err = pcall(function()
		local jsonStructure = HttpService:JSONEncode(playerClass);
		playerClassDB:SetAsync(PlayerID, jsonStructure);
	end)
	return success, err
end

-- Function to erase player data from the datastore
local function eraseData(PlayerID)
	playerClassDB:RemoveAsync(PlayerID)
end

-- Function to handle player joining
function playerJoining(player)
	local PlayerID = getPlayerId(player);
	local success, result = pcall(function()
		return playerClassDB:GetAsync(PlayerID)
	end)
	if not success then 
		warn("Failed to load data for :", player.Name);
	end
	-- Call the appropriate function from the onJoinTable based on whether player has existing data
	onJoinTable[result == nil or result == "null"](player, result)
end

-- Function to handle player leaving
function playerLeaving(player)
	local PlayerID = getPlayerId(player)
	saveData(PlayerID, playerClasses[PlayerID]);
end

-- EVENTS --
Players.PlayerAdded:Connect(playerJoining);
Players.PlayerRemoving:Connect(playerLeaving);

-- Event handler for when the server shuts down
game:BindToClose(function()
	print("Server Shutdown")
	-- Loop through player classes and save their data before shutting down
	for PlayerID, playerClass in pairs(playerClasses) do
		saveData(PlayerID, playerClass);
	end
end)
