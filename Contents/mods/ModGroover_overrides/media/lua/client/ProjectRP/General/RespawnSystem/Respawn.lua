-- local spawn = { x = 12698, y = 2348, z = 0 }

require("ProjectRP/Client")

ProjectRP.Client.Respawn = {};
ProjectRP.Client.Respawn.playerDataBackup = nil;
ProjectRP.Client.Respawn.dropItemsOnDeath = true

--[[
-- TEMP
ProjectRP.Client.Respawn.KeyPressed = function(key) 
	if (key == Keyboard.KEY_Z) then
		local player = getPlayer();
		if (player:isDead()) then
			ISPostDeathUI.OnPlayerDeath(player);
		else
			getPlayer():setHealth(0);
		end
	end
end
Events.OnKeyPressed.Add(ProjectRP.Client.Respawn.KeyPressed)
--]]

function ISPostDeathUI:createChildren()
	local buttonWid = 250
	local buttonHgt = 40
	local buttonGapY = 12
	local buttonX = 0
	local buttonY = 0
	local totalHgt = (buttonHgt * 2) + (buttonGapY * 1)

	self:setWidth(buttonWid)
	self:setHeight(totalHgt)
	-- must set these after setWidth/setHeight or getKeepOnScreen will mess them up
	self:setX(self.screenX + (self.screenWidth - buttonWid) / 2)
	self:setY(self.screenHeight - 40 - totalHgt)

	local button = ISButton:new(buttonX - 50, buttonY - (buttonHgt + buttonGapY), buttonWid + 100, buttonHgt, "Don't exit without respawn character!")
	self:configButton(button)
	self:addChild(button)

	local button = ISButton:new(buttonX, buttonY, buttonWid, buttonHgt, "Respawn in Hospital", self, self.onTrueRespawn)
	self:configButton(button)
	self:addChild(button)
	self.buttonExit = button
	buttonY = buttonY + buttonHgt + buttonGapY

	button = ISButton:new(buttonX, buttonY, buttonWid, buttonHgt, getText("IGUI_PostDeath_Respawn"), self, self.onRespawn)
	self:configButton(button)
	self:addChild(button)
	self.buttonRespawn = button
	buttonY = buttonY + buttonHgt + buttonGapY

	button = ISButton:new(buttonX, buttonY + 99999, buttonWid, buttonHgt, getText("IGUI_PostDeath_Quit"), self, self.onQuitToDesktop)
	self:configButton(button)
	self:addChild(button)
	self.buttonQuit = button
end

function ISPostDeathUI.preDeathState()
	local oldData = ProjectRP.Client.Respawn.playerDataBackup;
	local oldDesc = oldData.Descriptor;
	
	local cellX = math.floor(oldData.X / 300.0)
	local cellY = math.floor(oldData.Y / 300.0)
	local x = oldData.X - cellX*300
	local y = oldData.Y - cellY*300
	local z = oldData.Z

	-- spawn point
	getWorld():setLuaSpawnCellX(cellX);
	getWorld():setLuaSpawnCellY(cellY);
	getWorld():setLuaPosX(x);
	getWorld():setLuaPosY(y);
	getWorld():setLuaPosZ(z);

	-- create new char
	local desc = SurvivorFactory.CreateSurvivor();
	desc:setFemale(oldDesc.Female);
	desc:setProfession(oldDesc.Profession);
	local humanVisual = desc:getHumanVisual();
	humanVisual:setHairModel(oldDesc.Hair.Model);
	humanVisual:setHairColor(oldDesc.Hair.Color);
	humanVisual:setBodyHairIndex(oldDesc.BodyHair);
	humanVisual:setBeardModel(oldDesc.Beard.Model);
	humanVisual:setBeardColor(oldDesc.Beard.Color);
	humanVisual:setSkinTextureName(oldDesc.Skin.Texture);
	humanVisual:setSkinTextureIndex(oldDesc.Skin.TextureIndex);
	humanVisual:setSkinColor(oldDesc.Skin.Color);
	getWorld():setLuaPlayerDesc(desc);

	desc:setForename(oldDesc.Forename);
	desc:setSurname(oldDesc.Surname);

	setPlayerMouse(nil)
end


function ISPostDeathUI:onTrueRespawn()
	if MainScreen.instance:isReallyVisible() then return end
	self:setVisible(false)
	CoopCharacterCreation.setVisibleAllUI(false)

	if UIManager.getSpeedControls() and not IsoPlayer.allPlayersDead() then
		setShowPausedMessage(false)
		UIManager.getSpeedControls():SetCurrentGameSpeed(0)
	end

	local oldData = ProjectRP.Client.Respawn.playerDataBackup;
	local oldDesc = oldData.Descriptor;
	
	-- spawn point
	getWorld():setLuaSpawnCellX(39);
	getWorld():setLuaSpawnCellY(22);
	getWorld():setLuaPosX(180);
	getWorld():setLuaPosY(287);
	getWorld():setLuaPosZ(0);

	-- create new char
	local desc = SurvivorFactory.CreateSurvivor();
	desc:setFemale(oldDesc.Female);
	desc:setProfession(oldDesc.Profession);
	local humanVisual = desc:getHumanVisual();
	humanVisual:setHairModel(oldDesc.Hair.Model);
	humanVisual:setHairColor(oldDesc.Hair.Color);
	humanVisual:setBodyHairIndex(oldDesc.BodyHair);
	humanVisual:setBeardModel(oldDesc.Beard.Model);
	humanVisual:setBeardColor(oldDesc.Beard.Color);
	humanVisual:setSkinTextureName(oldDesc.Skin.Texture);
	humanVisual:setSkinTextureIndex(oldDesc.Skin.TextureIndex);
	humanVisual:setSkinColor(oldDesc.Skin.Color);
	getWorld():setLuaPlayerDesc(desc);

	desc:setForename(oldDesc.Forename);
	desc:setSurname(oldDesc.Surname);

	if UIManager.getSpeedControls() and not IsoPlayer.allPlayersDead() then
		setShowPausedMessage(true)
		UIManager.getSpeedControls():SetCurrentGameSpeed(1)
	end

	if ISPostDeathUI.instance[self.playerIndex] then
		ISPostDeathUI.instance[self.playerIndex]:removeFromUIManager()
		ISPostDeathUI.instance[self.playerIndex] = nil
	end

	setPlayerMouse(nil)
	CoopCharacterCreation.setVisibleAllUI(true);
end

local clothesPlayer = nil
local function respawnClothes()
	if clothesPlayer ~= nil then
		local gown = clothesPlayer:getInventory():AddItem("Base.HospitalGown")
		clothesPlayer:setWornItem(gown:getBodyLocation(), gown)

		local shoes = clothesPlayer:getInventory():AddItem("Base.Shoes_Slippers")
		local color = Color.new(1, 1, 1, 1);
		shoes:setColor(color);
		shoes:getVisual():setTint(ImmutableColor.new(color));
		shoes:setCustomColor(true);
		clothesPlayer:setWornItem(shoes:getBodyLocation(), shoes)

		Events.OnTick.Remove(respawnClothes)
	end
	if ISPostDeathUI.isTrueDeath then
		ISPostDeathUI.isTrueDeath = false
	end
end

local function setBodyPartDamage(playerObj)
	local data = ProjectRP.Client.Respawn.playerDataBackup.BodyPartsData

	local bodyParts = playerObj:getBodyDamage():getBodyParts()
	for i=1,bodyParts:size() do
        local bodyPart = bodyParts:get(i-1)
		local index = bodyPart:getIndex()
		bodyPart:setScratched(data[index].scratched, false)
		bodyPart:setDeepWounded(data[index].deepWounded)
		bodyPart:setStitched(data[index].stitched)
		bodyPart:SetBitten(data[index].bitten)
		bodyPart:setBleeding(data[index].bleeding)
		bodyPart:setBandaged(data[index].bandaged, data[index].bandageLife, false, data[index].bandageType)
		--bodyPart:SetHealth(data[index].health)
		bodyPart:setHaveBullet(data[index].haveBullet, 0)
		bodyPart:setCut(data[index].isCut)
		bodyPart:setAdditionalPain(data[index].additionalPain)
		bodyPart:SetBleedingStemmed(data[index].bleedingStemmed)
		bodyPart:setFractureTime(data[index].fractureTime)
		bodyPart:setHaveGlass(data[index].haveGlass)
		bodyPart:setStitchTime(data[index].stitchTime)
		bodyPart:setAlcoholLevel(data[index].alcoholLevel)
		bodyPart:setSplintFactor(data[index].splintFactor)
		bodyPart:setBurnTime(data[index].burnTime)
		bodyPart:setSplintItem(data[index].splintItem)
	end
end

ProjectRP.Client.Respawn.onSpawn = function(int, player) 
	if (player ~= getPlayer()) then
		return;
	end
	if (ProjectRP.Client.Respawn.playerDataBackup) then
		local oldData = ProjectRP.Client.Respawn.playerDataBackup;
		local data = player:getModData();
		for k,v in pairs(oldData.ModData) do
			data[k] = v;
		end
		local inv = player:getInventory();
		local items = inv:getItems()
		for i = items:size()-1, 0, -1 do
			local item = items:get(i)
			inv:DoRemoveItem(item)
		end

		for i, val in ipairs(ProjectRP.Client.Respawn.BodyItems) do
			inv:AddItem(val)
		end

		if ISPostDeathUI.isTrueDeath then
			clothesPlayer = player
			Events.OnTick.Add(respawnClothes)
		else
			setBodyPartDamage(player)
			player:getBodyDamage():ReduceGeneralHealth(90)
		end

		ProjectRP.Client.Respawn.playerDataBackup = nil;
	end
end
Events.OnCreatePlayer.Add(ProjectRP.Client.Respawn.onSpawn);


Events.OnPlayerDeath.Remove(ISPostDeathUI.OnPlayerDeath)
function ISPostDeathUI.OnPlayerDeath2(playerObj)
	if ISPostDeathUI.isTrueDeath then
		local playerNum = playerObj:getPlayerNum()
		local panel = ISPostDeathUI:new(playerNum)
		panel.timeOfDeath = getTimestamp()
		panel.lines = {}
		table.insert(panel.lines, getGameTime():getDeathString(playerObj))
		local s = getGameTime():getZombieKilledText(playerObj)
		if s then
			table.insert(panel.lines, s)
		end
		s = getGameTime():getGameModeText()
		if s then
			table.insert(panel.lines, s)
		end
		panel:addToUIManager()
		if MainScreen.instance:isVisible() then
			table.insert(ISUIHandler.visibleUI, panel.javaObject:toString())
			panel:setVisible(false)
			if JoypadState.players[playerNum+1] and JoypadState.saveFocus then
				JoypadState.saveFocus[playerNum+1] = panel
			end
		else
			if JoypadState.players[playerNum+1] then
				JoypadState.players[playerNum+1].focus = panel
			end
		end
	end
end
Events.OnPlayerDeath.Add(ISPostDeathUI.OnPlayerDeath2)

local function tableCopy(data)
    local result = {}
    for key, val in pairs(data) do
        result[key] = val
    end
    return result
end

local keyExceptions = { ["CarKey"] = true, ["KeyRing"] = true, ["Key1"] = true, ["Key2"] = true, ["Key3"] = true, ["Key4"] = true, ["Key5"] = true}
local function isNotKey(item)
	return not keyExceptions[item:getType()]
end

function ProjectRP.Client.Respawn.RemoveBody()
	for i=0, ProjectRP.Client.Respawn.DeathSquare:getStaticMovingObjects():size()-1 do
		if instanceof(ProjectRP.Client.Respawn.DeathSquare:getStaticMovingObjects():get(i), "IsoDeadBody") then
			local item = ProjectRP.Client.Respawn.DeathSquare:getStaticMovingObjects():get(i)
			local container = item:getItemContainer()
			if container ~= nil then
				ProjectRP.Client.Respawn.BodyItems = {}
				local items = container:getItems()
				for j = 0, items:size()-1 do
					local item2 = items:get(j)
					if ProjectRP.Client.Respawn.dropItemsOnDeath and isNotKey(item2) and not item2:getModData().KeepOnDeath then
						ProjectRP.Client.Respawn.DeathSquare:AddWorldInventoryItem(item2, (ZombRand(0, 10)-5)/10.0, (ZombRand(0, 10)-5)/10.0, (ZombRand(0, 10)-5)/10.0)
					else
						table.insert(ProjectRP.Client.Respawn.BodyItems, item2)
					end
					
				end
			end
			ProjectRP.Client.Respawn.DeathSquare:removeCorpse(item, false);
			Events.OnTick.Remove(ProjectRP.Client.Respawn.RemoveBody)
			if not ISPostDeathUI.isTrueDeath then
				ISPostDeathUI.preDeathState()
			end
		end
	end
end

local function getBodyPartsData(playerObj)
	local data = {}
	local bodyParts = playerObj:getBodyDamage():getBodyParts()
	for i=1,bodyParts:size() do
        local bodyPart = bodyParts:get(i-1)
		local index = bodyPart:getIndex()
		data[index] = {}
		data[index].scratched = bodyPart:scratched()
		data[index].deepWounded = bodyPart:deepWounded()
		data[index].stitched = bodyPart:stitched()
		data[index].bitten = bodyPart:bitten()
		data[index].bleeding = bodyPart:bleeding()
		data[index].isBurnt = bodyPart:isBurnt()
		data[index].bandaged = bodyPart:bandaged()
		data[index].bandageType = bodyPart:getBandageType()
		data[index].bandageLife = bodyPart:getBandageLife()
		data[index].health = bodyPart:getHealth()
		data[index].haveBullet = bodyPart:haveBullet()
		data[index].isCut = bodyPart:isCut()
		data[index].additionalPain = bodyPart:getAdditionalPain(false)
		data[index].bleedingStemmed = bodyPart:IsBleedingStemmed()
		data[index].fractureTime = bodyPart:getFractureTime()
		data[index].haveGlass = bodyPart:haveGlass()
		data[index].stitchTime = bodyPart:getStitchTime()
		data[index].alcoholLevel = bodyPart:getAlcoholLevel()
		data[index].splintFactor = bodyPart:getSplintFactor()
		data[index].burnTime = bodyPart:getBurnTime()
		data[index].splintItem = bodyPart:getSplintItem()
	end
	return data
end

---@param playerObj IsoPlayer
function ProjectRP.Client.Respawn.BackupPlayerData(playerObj)
	if (playerObj ~= getPlayer()) then
		return;
	end
	-- backup data we want to keep!
	local descriptor = playerObj:getDescriptor();
	local humanVisual = playerObj:getHumanVisual();

	ProjectRP.Client.Respawn.playerDataBackup = {
		Perks = playerObj:getPerkList(),
		ModData = tableCopy(playerObj:getModData()),
		Keys = KeysData,
		X = playerObj:getX(),
		Y = playerObj:getY(),
		Z = playerObj:getZ(),
		BodyPartsData = getBodyPartsData(playerObj),
		Descriptor = {
			Female = descriptor:isFemale(),
			Forename = descriptor:getForename(),
			Surname = descriptor:getSurname(),
			Profession = descriptor:getProfession(),
			Hair = {
				Model = humanVisual:getHairModel(),
				Color = humanVisual:getHairColor(),
			},
			BodyHair = humanVisual:getBodyHairIndex(),
			Beard = {
				Model = humanVisual:getBeardModel(),
				Color = humanVisual:getBeardColor(),
			},
			Skin = {
				Color = humanVisual:getSkinColor(),
				Texture = humanVisual:getSkinTexture(),
				TextureIndex = humanVisual:getSkinTextureIndex(),
			}
		},
	};

	ProjectRP.Client.Respawn.DeathSquare = playerObj:getSquare()
	Events.OnTick.Add(ProjectRP.Client.Respawn.RemoveBody)
end
Events.OnPlayerDeath.Add(ProjectRP.Client.Respawn.BackupPlayerData)