require 'ProjectRP/ServerDataBase'

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
    sendClientCommand('LocalPrivateZones', 'UpdatePrivateZone', zoneData)
end

ProjectRP.Server.ServerDataBase.Commands.PrivateZones.RemoveData = function(playerObj, args)
    local zones = ModData.get("PrivateZones")
    for i, zone in ipairs(zones) do
		if args.x >= zone.x1 and args.x <= zone.x2 then
			if args.y >= zone.y1 and args.y <= zone.y2 then
                if args.type == "profession" then
                    zone.accessProfessions[args.val] = nil
                elseif args.type == "user" then
                    zone.accessUsers[args.val] = nil
                end
                sendClientCommand('LocalPrivateZones', 'UpdatePrivateZone', zone)
				return
			end
		end
	end
end

ProjectRP.Server.ServerDataBase.Commands.PrivateZones.SetData = function(playerObj, args)
    local zones = ModData.get("PrivateZones")
    for i, zone in ipairs(zones) do
		if args.x >= zone.x1 and args.x <= zone.x2 then
			if args.y >= zone.y1 and args.y <= zone.y2 then
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
                sendClientCommand('LocalPrivateZones', 'UpdatePrivateZone', zone)
				return
			end
		end
	end
end

ProjectRP.Server.ServerDataBase.Commands.PrivateZones.RefreshAreas = function(playerObj, args)
    return
end

ProjectRP.Server.ServerDataBase.Commands.PrivateZones.SetOwner = function(playerObj, args)
    local zones = ModData.get("PrivateZones")
    for i, zone in ipairs(zones) do
		if args.x >= zone.x1 and args.x <= zone.x2 then
			if args.y >= zone.y1 and args.y <= zone.y2 then
                zone.owner = args.owner
                sendClientCommand('LocalPrivateZones', 'UpdatePrivateZone', zone)
            end
        end
    end
end

ProjectRP.Server.ServerDataBase.Commands.PrivateZones.RemoveZone = function(playerObj, args)
    local zones = ModData.get("PrivateZones")
    local index = -1
    local zoneData
    for i, zone in ipairs(zones) do
		if args.x >= zone.x1 and args.x <= zone.x2 then
			if args.y >= zone.y1 and args.y <= zone.y2 then
                zoneData = {x1 = zone.x1, x2 = zone.x2, y1 = zone.y1, y2 = zone.y2, z1 = zone.z1, z2 = zone.z2}
                index = i
                break
            end
        end
    end
    if index == -1 then return end
    table.remove(zones, index)
    sendClientCommand('LocalPrivateZones', 'RemoveZone', zoneData)
end