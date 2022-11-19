require('ProjectRP/ClientDataBase')

ProjectRP.Client.ClientDataBase.PrivateZones = {}

ProjectRP.Client.ClientDataBase.PrivateZones.UpdatePrivateZone = function(data)
    local zones = ModData.getOrCreate('LocalPrivateZones')
    local player = getPlayer()
    local username = player:getUsername()
    for x = data.x1, data.x2 do
        for y = data.y1, data.y2 do
            for z = data.z1, data.z2 do
                local id = tostring(x) .. '|' .. tostring(y) .. '|' .. tostring(z)
                local tAccessToContainers = data.accessEveryone.accessToContainers or ProjectRP.Client.ClientDataBase.HaveProfessionAccessToContainers(player, data) or data.accessUsers[username] and data.accessUsers[username].accessToContainers or data.owner == username
                local tAccessToGrabDrop = data.accessEveryone.accessToGrabDrop or ProjectRP.Client.ClientDataBase.HaveProfessionAccessToContainers(player, data) or data.accessUsers[username] and data.accessUsers[username].accessToGrabDrop or data.owner == username
                local tAccessToAll = data.accessEveryone.accessToAll or ProjectRP.Client.ClientDataBase.HaveProfessionAccessToContainers(player, data) or data.accessUsers[username] and data.accessUsers[username].accessToAll or data.owner == username
                zones[id] = { accessToContainers = tAccessToContainers, accessToGrabDrop = tAccessToGrabDrop, accessToAll = tAccessToAll }
            end
        end
    end
end

ProjectRP.Client.ClientDataBase.PrivateZones.RemoveZone = function(data)
    local zones = ModData.getOrCreate('LocalPrivateZones')
    for x = data.x1, data.x2 do
        for y = data.y1, data.y2 do
            for z = data.z1, data.z2 do
                local id = tostring(x) .. '|' .. tostring(y) .. '|' .. tostring(z)
                zones[id] = nil
            end
        end
    end
end

local function onServerCommand(module, command, args)
    if module ~= 'LocalPrivateZones' then return end
    ProjectRP.Client.ClientDataBase.PrivateZones[command](args)
end

Events.OnServerCommand.Add(onServerCommand)