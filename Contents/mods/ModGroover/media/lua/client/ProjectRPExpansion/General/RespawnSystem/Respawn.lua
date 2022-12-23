require 'ProjectRP/General/RespawnSystem/Respawn'
Events.OnCreatePlayer.Remove(ProjectRP.Client.Respawn.onSpawn);

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

	local button = ISButton:new(buttonX - 50, buttonY - (buttonHgt + buttonGapY), buttonWid + 100, buttonHgt, "Don't exit without respawning!")
	self:configButton(button)
	self:addChild(button)

	local button = ISButton:new(buttonX, buttonY, buttonWid, buttonHgt, "Respawn in Hospital", self, self.onTrueRespawn)
	self:configButton(button)
	self:addChild(button)
	self.buttonExit = button
	buttonY = buttonY + buttonHgt + buttonGapY

	button = ISButton:new(buttonX, buttonY + 99999, buttonWid, buttonHgt, getText("IGUI_PostDeath_Respawn"), self, self.onRespawn)
	self:configButton(button)
	self:addChild(button)
	self.buttonRespawn = button
	buttonY = buttonY + buttonHgt + buttonGapY

	button = ISButton:new(buttonX, buttonY + 99999, buttonWid, buttonHgt, getText("IGUI_PostDeath_Quit"), self, self.onQuitToDesktop)
	self:configButton(button)
	self:addChild(button)
	self.buttonQuit = button
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

local keyExceptions = { ["CarKey"] = true, ["KeyRing"] = true, ["Key1"] = true, ["Key2"] = true, ["Key3"] = true, ["Key4"] = true, ["Key5"] = true}
local function isNotKey(item)
	return not keyExceptions[item:getType()]
end
local function isWallet(item)
	return ProjectRP.Client.Money.WalletTypes[item:getType()]
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
					if ProjectRP.Client.Respawn.dropItemsOnDeath and isNotKey(item2) and not item2:getModData().KeepOnDeath and not isWallet(item2) then
						ProjectRP.Client.Respawn.DeathSquare:AddWorldInventoryItem(item2, (ZombRand(0, 10)-5)/10.0, (ZombRand(0, 10)-5)/10.0, (ZombRand(0, 10)-5)/10.0)
					elseif isWallet(item2) then
						if item2:getModData().moneyCount > 0 then
							local moneyWallet = InventoryItemFactory.CreateItem(item2:getFullType()) -- new wallet at death location with their money in it
							moneyWallet:getModData().moneyCount = item2:getModData().moneyCount
							ProjectRP.Client.Respawn.DeathSquare:AddWorldInventoryItem(moneyWallet, (ZombRand(0, 10)-5)/10.0, (ZombRand(0, 10)-5)/10.0, (ZombRand(0, 10)-5)/10.0)
							item2:getModData().moneyCount = 0
						end
						table.insert(ProjectRP.Client.Respawn.BodyItems, item2)
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

--TEMP FIX: death loops are still happening, so just force respawn them if they die too many times in a short period
--TODO: fix death loops so we don't have to do this!
local diedThisMinute = false
local preventDeathLoop = function()
	if diedThisMinute then
		ISPostDeathUI.isTrueDeath = true
	end
	diedThisMinute = true
end
Events.OnPlayerDeath.Add(preventDeathLoop)

Events.OnPlayerDeath.Remove(ISPostDeathUI.OnPlayerDeath2)
Events.OnPlayerDeath.Add(ISPostDeathUI.OnPlayerDeath2)

local resetDeathLoopCounter = function()
	diedThisMinute = false
end
Events.EveryTenMinutes.Add(resetDeathLoopCounter)