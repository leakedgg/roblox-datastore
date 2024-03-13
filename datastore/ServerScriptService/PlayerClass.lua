-- THIS NEEDS TO BE A MODULE! -- 

-- Define a table representing the player class
local playerClass = {}

-- Set the metatable to itself to enable indexing
playerClass.__index = playerClass

-- Constructor function to create a new player object
function playerClass.new(player, self)
	-- Wait until the player's character is loaded
	repeat task.wait() until player.Character ~= nil

	-- Check if 'self' is provided, if so, return it
	if self then return setmetatable(self, playerClass) end

	-- If 'self' is not provided, create a new instance of the player class
	self = setmetatable({}, playerClass)

	-- Initialize player attributes
	self.name = player.Name
	self.character = player.Character
	self.coins = 0
	self.level = 1
	self.skins = {}

	-- Return the newly created instance
	return self
end

-- Method to set the player's character
function playerClass:setCharacter(character)
	self.character = character
end

-- Method to set the player's name
function playerClass:setName(name)
	self.name = name
end

-- Method to teleport the player to a new position
function playerClass:teleportPlayer(new)
	self.character.HumanoidRootPart.CFrame = new
end

-- Method to add coins to the player's balance
function playerClass:addCoins(value)
	self.coins += value
end

-- Method to remove coins from the player's balance
function playerClass:removeCoins(value)
	-- Check if removing coins would result in a negative balance
	if (self.coins >= 0) or (self.coins - value <= -1 or 0) then 
		self.coins -= value
	else 
		warn("Coins is in the negative or 0 : ", self.coins)
		--self.coins = 0 -- Reset coins to 0 if desired
	end
end

-- Method to add a skin to the player's collection
function playerClass:addSkin(value)
	-- Check if the skin is not already in the player's collection
	if not table.find(self.skins, value) then 
		table.insert(self.skins, value)
	else 
		warn("Player already has skin : ", value)
	end
end

-- Method to remove a skin from the player's collection
function playerClass:removeSkin(value)
	-- Find the index of the skin in the player's collection
	local index = table.find(self.skins, value)
	if index then 
		table.remove(self.skins, index)
	else 
		warn("Cannot find skin : ", value)
	end
end

-- Method to get the player's coin balance
function playerClass:getCoins()
	return self.coins
end

-- Method to get the player's skins
function playerClass:getSkins()
	return self.skins
end

-- Method to get the player's level
function playerClass:getLevel()
	return self.level
end

-- Return the player class table
return playerClass
