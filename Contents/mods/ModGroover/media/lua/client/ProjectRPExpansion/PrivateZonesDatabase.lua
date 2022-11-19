require('ProjectRP/ClientDataBase')

ProjectRP.Client.ClientDataBase.PrivateZones = {}

local function sortCoords(a, b)
    if a > b then return b, a
    else return a, b end
end

ProjectRP.Client.ClientDataBase.PrivateZones.setZoneData = function(x1, x2, y1, y2, z1, z2, data)
    local zones = ModData.getOrCreate('LocalPrivateZones')
    x1, x2 = sortCoords(x1, x2)
    y1, y2 = sortCoords(y1, y2)
    z1, z2 = sortCoords(z1, z2)

    for x = x1, x2 do
        for y = y1, y2 do
            for z = z1, z2 do
                local id = tostring(x) .. '|' .. tostring(y) .. '|' .. tostring(z)
                zones[id] = data
            end
        end
    end
end

ProjectRP.Client.ClientDataBase.PrivateZones.UpdatePrivateZone = function(data)
    local player = getPlayer()
    local username = player:getUsername()

    local tAccessToContainers = data.accessEveryone.accessToContainers or ProjectRP.Client.ClientDataBase.HaveProfessionAccessToContainers(player, data) or data.accessUsers[username] and data.accessUsers[username].accessToContainers or data.owner == username
    local tAccessToGrabDrop = data.accessEveryone.accessToGrabDrop or ProjectRP.Client.ClientDataBase.HaveProfessionAccessToContainers(player, data) or data.accessUsers[username] and data.accessUsers[username].accessToGrabDrop or data.owner == username
    local tAccessToAll = data.accessEveryone.accessToAll or ProjectRP.Client.ClientDataBase.HaveProfessionAccessToContainers(player, data) or data.accessUsers[username] and data.accessUsers[username].accessToAll or data.owner == username

    local zoneData = { accessToContainers = tAccessToContainers, accessToGrabDrop = tAccessToGrabDrop, accessToAll = tAccessToAll }

    ProjectRP.Client.ClientDataBase.PrivateZones.setZoneData(data.x1, data.x2, data.y1, data.y2, data.z1, data.z2, zoneData)
end

ProjectRP.Client.ClientDataBase.PrivateZones.RemoveZone = function(data)
    ProjectRP.Client.ClientDataBase.PrivateZones.setZoneData(data.x1, data.x2, data.y1, data.y2, data.z1, data.z2, nil)
end

local function onServerCommand(module, command, args)
    if module ~= 'LocalPrivateZones' then return end
    ProjectRP.Client.ClientDataBase.PrivateZones[command](args)
end

Events.OnServerCommand.Add(onServerCommand)