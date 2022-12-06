require('ProjectRP/ClientDataBase')
Events.OnReceiveGlobalModData.Remove(ProjectRP.Client.ClientDataBase.OnReceiveGlobalModData)
Events.OnConnected.Remove(ProjectRP.Client.ClientDataBase.OnConnected)

local privateZonesRequested = false

function ProjectRP.Client.ClientDataBase.OnReceiveGlobalModData(key, modData)
    if modData then
    	ModData.remove(key)
        ModData.add(key, modData)

        if privateZonesRequested and key == 'PrivateZones' then
            privateZonesRequested = false
            ProjectRP.Client.ClientDataBase.CreateLocalPrivateZonesDatabase(modData)
        end
    end
end
Events.OnReceiveGlobalModData.Add(ProjectRP.Client.ClientDataBase.OnReceiveGlobalModData)

function ProjectRP.Client.ClientDataBase.OnConnected()
    privateZonesRequested = true
	ModData.request('PrivateZones')
    ModData.request('MoneyBalance')
end
Events.OnConnected.Add(ProjectRP.Client.ClientDataBase.OnConnected)