require 'ProjectRP/General/WorldObjectContextMenu'
Events.OnFillWorldObjectContextMenu.Remove(ProjectRP.Client.WOContext.OnFillWorldObjectContextMenu)

local ATMSprites = {location_business_bank_01_64 = true, location_business_bank_01_65 = true,
                    location_business_bank_01_66 = true, location_business_bank_01_67 = true,
                    ProjectRP_0 = true, ProjectRP_1 = true}

function ProjectRP.Client.WOContext.OnFillWorldObjectContextMenu(player, context, worldObjects, test)
	local playerObj = getSpecificPlayer(player)
    worldObjects = ProjectRP.Client.WOContext.removeDuplicates(worldObjects)

    local subMenuAdmin = nil
    local subMenuTilePicker = nil
    local subMenuTilePicker_Copy = nil
    local subMenuTilePicker_Destroy = nil
    if isClient() and isAdmin() or not isClient() then
        local adminOption = context:addOption("ADMIN", worldobjects)
        subMenuAdmin = context:getNew(context)
        context:addSubMenu(adminOption, subMenuAdmin)

        local TPOption = subMenuAdmin:addOption("Tile Picker", worldobjects)
        subMenuTilePicker = subMenuAdmin:getNew(subMenuAdmin)
        subMenuAdmin:addSubMenu(TPOption, subMenuTilePicker)

        subMenuTilePicker:addOption("Choose tile", player, ProjectRP.Client.WOContext.initTilePickerUI)

        local TPCopyOption = subMenuTilePicker:addOption("Copy tile", worldobjects)
        subMenuTilePicker_Copy = subMenuTilePicker:getNew(subMenuTilePicker)
        subMenuTilePicker:addSubMenu(TPCopyOption, subMenuTilePicker_Copy)

        local TPDestroyOption = subMenuTilePicker:addOption("Destroy tile", worldobjects)
        subMenuTilePicker_Destroy = subMenuTilePicker:getNew(subMenuTilePicker)
        subMenuTilePicker:addSubMenu(TPDestroyOption, subMenuTilePicker_Destroy)
    end

    local square = nil
    for i,v in ipairs(worldObjects) do
        local sq = v:getSquare()
        if sq ~= nil then
            square = sq
        end

        if isClient() and isAdmin() or not isClient() then
            if v:getSprite() ~= nil and v:getSprite():getName() ~= nil then
                subMenuTilePicker_Copy:addOption(v:getSprite():getName(), v:getSprite():getName(), ProjectRP.Client.WOContext.copyTile, playerObj)
            end
            if v:getSprite() ~= nil and v:getSprite():getName() ~= nil then
                subMenuTilePicker_Destroy:addOption(v:getSprite():getName(), v, ProjectRP.Client.WOContext.destroyTile)
            end
        end

        if instanceof(v, "IsoWindow") then
            v:getProperties():UnSet(IsoFlagType.makeWindowInvincible)
            context:addOption("Open/Close Window", nil, ISWorldObjectContextMenu.onOpenCloseWindow, v, playerObj:getPlayerNum())
        end

        if instanceof(v, "IsoDoor") then
            subMenuAdmin:addOption("Check door is force locked", v, function(door, pl) 
                if door:getProperties():Is("forceLocked") then
                    pl:Say("True")
                else
                    pl:Say("False")
                end
            
            end, playerObj)    
            subMenuAdmin:addOption("Set door force locked", v, function(door, pl) 
                door:setKeyId(door:getSquare():getBuilding():getDef():getKeyId())
                door:getProperties():Set("forceLocked", "true")            
            end, playerObj)    
		end
        if not (KRPATMWindow.instance and KRPATMWindow.instance:isVisible()) then
            if v:getSprite() ~= nil and ATMSprites[v:getSprite():getName()] then
                context:addOption("Use ATM", playerObj, function(pl)
                    local win = KRPATMWindow:new(pl);
                    win:initialise();
                    win:addToUIManager();
                end)
            end
        end
    end

    if square ~= nil then
        local vehicle = square:getVehicleContainer()

        if vehicle ~= nil then
            if isClient() and isAdmin() or not isClient() then
                context:addOption("Set vehicle owner", vehicle, function(veh)
                    local win = KRPVehicleOwnerUI:new(veh)
                    win:initialise();
                    win:addToUIManager();                
                end)
            end
            if ProjectRP.Client.TagSystem.HaveProfessionTag(playerObj, "mechanic") or (isClient() and isAdmin()) then
                context:addOption("Set vehicle condition", vehicle, function(veh)                    
                    local win = SetVehicleConditionUI:new(veh)
                    win:initialise();
                    win:addToUIManager();  
                end)
            end
        end

        local mobjs = square:getMovingObjects()
        for i = 0, mobjs:size()-1 do
            local mObj = mobjs:get(i)
            if instanceof(mObj, "IsoPlayer") then
                if isClient() and isAdmin() or not isClient() then
                    subMenuAdmin:addOption("Config profession tags", mObj, function(tagPlayer) 
                        local win = TagWindow:new(tagPlayer);
                        win:initialise();
                        win:addToUIManager();
                    end)
                end
                context:addOption("Check player inventory", mObj, function(pl)
                    sendClientCommand(playerObj, 'ProjectRP', 'checkInventory', { parentUsername = playerObj:getUsername(), checkUsername = pl:getUsername(), isPolice = ProjectRP.Client.TagSystem.HaveProfessionTag(playerObj, "police") })
                end)

                if ProjectRP.Client.TagSystem.HaveProfessionTag(playerObj, "police") then
                    context:addOption("Check for Drugs", mObj, function(pl)
                        ISTimedActionQueue.add(ISCheckDrugsAction:new(getPlayer(), pl))
                    end)
                end
            end
        end

        local localZones = ModData.getOrCreate("LocalPrivateZones")
        local id = tostring(square:getX()) .. "|" .. tostring(square:getY()) .. "|" .. tostring(square:getZ())
        if isClient() and isAdmin() or not isClient() then
            if ProjectRP.Client.WOContext.isPointHere(sq) then
                subMenuAdmin:addOption("Remove Point", playerObj, ProjectRP.Client.WOContext.removePoint, sq)
            else
                local addPointOption = subMenuAdmin:addOption("Add Point")
                local subMenuAddPoint = subMenuAdmin:getNew(subMenuAdmin)
                subMenuAdmin:addSubMenu(addPointOption, subMenuAddPoint)
                subMenuAddPoint:addOption("Vehicle shop", playerObj, ProjectRP.Client.WOContext.addPoint, sq, "vehicleshop")
            end
            
            if localZones[id] == nil then
                subMenuAdmin:addOption("Add private area", square, function(sq)
                    local win = PrivateAreaChooseUI:new(sq)
                    win:initialise();
                    win:addToUIManager(); 
                end)
            else
                local configAreaOption = subMenuAdmin:addOption("Configure area")
                local subMenuConfigArea = subMenuAdmin:getNew(subMenuAdmin)
                subMenuAdmin:addSubMenu(configAreaOption, subMenuConfigArea)
                subMenuConfigArea:addOption("Set owner", square, function(sq)
                    local win = PrivateAreaSetOwnerUI:new(sq)
                    win:initialise();
                    win:addToUIManager(); 
                end)
                subMenuConfigArea:addOption("Configure area", square, function(sq)
                    local win = PrivateAreaSetAccessRightsUI:new(sq)
                    win:initialise();
                    win:addToUIManager();
                end)
                subMenuConfigArea:addOption("Remove area", square, function(sq) sendClientCommand(getPlayer(), 'ProjectRPDataBase', 'RemoveZone', { tableName = "PrivateZones", x = sq:getX(), y = sq:getY() }) end)
            end
        end   
        
        if localZones[id] ~= nil then
            local zones = ModData.getOrCreate("PrivateZones")
            local x = square:getX()
            local y = square:getY()
            for i, zone in ipairs(zones) do
                if x >= zone.x1 and x <= zone.x2 then
                    if y >= zone.y1 and y <= zone.y2 then
                        if zone.owner == playerObj:getUsername() then
                            context:addOption("Configure area", square, function(tsq)
                                local win = PrivateAreaSetAccessRightsUI:new(tsq)
                                win:initialise();
                                win:addToUIManager();
                            end)
                        end                        
                        break
                    end
                end
            end
        end
    end

    if playerObj:getBodyDamage():getHealth() <= 30 then
        context:addOption("Call EMS", playerObj, function(pl)  
            sendClientCommand(pl, 'ProjectRP', 'callEMS', { x = math.floor(pl:getX()), y = math.floor(pl:getY()), z = math.floor(pl:getZ()) })
        end)
        --[[context:addOption("Die", playerObj, function(pl)
            ISPostDeathUI.isTrueDeath = true
            pl:setHealth(0)
        end)]]
    end
end
Events.OnFillWorldObjectContextMenu.Add(ProjectRP.Client.WOContext.OnFillWorldObjectContextMenu)