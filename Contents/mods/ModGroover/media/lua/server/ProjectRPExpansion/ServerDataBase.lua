require 'ProjectRP/ServerDataBase'

ProjectRP.Server.ServerDataBase.Commands.MoneyBalance.DecreaseMoneyBalance = function(playerObj, args)
    local balance = ModData.get("MoneyBalance")
    if balance[playerObj:getUsername()] == nil then
        ProjectRP.Server.ServerDataBase.Commands.MoneyBalance.CreatePlayerAccount(playerObj)
    end
    balance[playerObj:getUsername()].num = balance[playerObj:getUsername()].num - args.num

    if args.num > ProjectRP.Server.Stats.SuspiciousTransferAmount then
        ProjectRP.Server.Stats.LogTransfer(playerObj:getUsername() .. ' withdrew ' .. args.num)
    end

    ModData.transmit("MoneyBalance")
end

ProjectRP.Server.ServerDataBase.Commands.MoneyBalance.IncreaseMoneyBalance = function(playerObj, args)
    local balance = ModData.get("MoneyBalance")
    if balance[playerObj:getUsername()] == nil then
        ProjectRP.Server.ServerDataBase.Commands.MoneyBalance.CreatePlayerAccount(playerObj)
    end
    balance[playerObj:getUsername()].num = balance[playerObj:getUsername()].num + args.num

    if args.num > ProjectRP.Server.Stats.SuspiciousTransferAmount then
        ProjectRP.Server.Stats.LogTransfer(playerObj:getUsername() .. ' deposited ' .. args.num)
    end

    ModData.transmit("MoneyBalance")
end

ProjectRP.Server.ServerDataBase.Commands.MoneyBalance.TransferMoney = function(playerObj, args)
    local balance = ModData.get("MoneyBalance")
    if balance[args.nickname] ~= nil then
        balance[args.nickname].num = balance[args.nickname].num + args.num
    else
        print("Wrong transfer operation:" .. args.nickname .. " " .. args.num)
    end

    if args.num > ProjectRP.Server.Stats.SuspiciousTransferAmount then
        ProjectRP.Server.Stats.LogTransfer(playerObj:getUsername() .. ' sent ' .. args.num .. ' to ' .. args.nickname)
    end

    ModData.transmit("MoneyBalance")
end

local function pointIsInZone(x, y, zone)
    return (x >= zone.x1 and x <= zone.x2 or x >= zone.x2 and x <= zone.x1) and (y >= zone.y1 and y <= zone.y2 or y >= zone.y2 and y <= zone.y1)
end

ProjectRP.Server.ServerDataBase.Commands.PrivateZones.AddPrivateZone = function(playerObj, args)
    local zones = ModData.get("PrivateZones")
    local zoneData = {
        owner = "NONE",
        x1 = args.x1,
        y1 = args.y1,
        x2 = args.x2,
        y2 = args.y2,
        z1 = args.z1,
        z2 = args.z2,
        accessProfessions = {},
        accessUsers = {},
        accessEveryone = {}
    }
    table.insert(zones, zoneData)
    ModData.transmit('PrivateZones')
    sendServerCommand('LocalPrivateZones', 'UpdatePrivateZone', zoneData)
end

ProjectRP.Server.ServerDataBase.Commands.PrivateZones.RemoveData = function(playerObj, args)
    local zones = ModData.get("PrivateZones")
    for i, zone in ipairs(zones) do
		if pointIsInZone(args.x, args.y, zone) then
            if args.type == "profession" then
                zone.accessProfessions[args.val] = nil
            elseif args.type == "user" then
                zone.accessUsers[args.val] = nil
            end
            ModData.transmit('PrivateZones')
            sendServerCommand('LocalPrivateZones', 'UpdatePrivateZone', zone)
            return
		end
	end
end

ProjectRP.Server.ServerDataBase.Commands.PrivateZones.SetData = function(playerObj, args)
    local zones = ModData.get("PrivateZones")
    for i, zone in ipairs(zones) do
		if pointIsInZone(args.x, args.y, zone) then
            if args.type == "profession" then
                zone.accessProfessions[args.val] = {
                    accessToContainers = args.accessToContainers,  
                    accessToGrabDrop = args.accessToGrabDrop,
                    accessToAll = args.accessToAll
                }
            elseif args.type == "user" then
                zone.accessUsers[args.val] = {
                    accessToContainers = args.accessToContainers,  
                    accessToGrabDrop = args.accessToGrabDrop,
                    accessToAll = args.accessToAll
                }
            else
                zone.accessEveryone = {
                    accessToContainers = args.accessToContainers,  
                    accessToGrabDrop = args.accessToGrabDrop,
                    accessToAll = args.accessToAll
                }
            end
            ModData.transmit('PrivateZones')
            sendServerCommand('LocalPrivateZones', 'UpdatePrivateZone', zone)
            return
		end
	end
end

ProjectRP.Server.ServerDataBase.Commands.PrivateZones.RefreshAreas = function(playerObj, args)
    return
end

ProjectRP.Server.ServerDataBase.Commands.PrivateZones.SetOwner = function(playerObj, args)
    local zones = ModData.get("PrivateZones")
    for i, zone in ipairs(zones) do
		if pointIsInZone(args.x, args.y, zone) then
            zone.owner = args.owner
            ModData.transmit('PrivateZones')
            sendServerCommand('LocalPrivateZones', 'UpdatePrivateZone', zone)
        end
    end
end

ProjectRP.Server.ServerDataBase.Commands.PrivateZones.RemoveZone = function(playerObj, args)
    local zones = ModData.get("PrivateZones")
    local index = -1
    local zoneData
    for i, zone in ipairs(zones) do
		if pointIsInZone(args.x, args.y, zone) then
            zoneData = {x1 = zone.x1, x2 = zone.x2, y1 = zone.y1, y2 = zone.y2, z1 = zone.z1, z2 = zone.z2}
            index = i
            break
        end
    end
    if index == -1 then return end
    table.remove(zones, index)
    ModData.transmit('PrivateZones')
    sendServerCommand('LocalPrivateZones', 'RemoveZone', zoneData)
end