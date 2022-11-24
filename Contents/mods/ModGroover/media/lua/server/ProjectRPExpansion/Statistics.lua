if isClient() then return end
ProjectRP.Server.Stats = {}
ProjectRP.Server.Stats.SuspiciousTransferAmount = 1000

ProjectRP.Server.Stats.GetMoneyAtms = function()
    local moneyBalance = ModData.get("MoneyBalance")
    local sum = 0

    for _,v in pairs(moneyBalance) do
        sum = sum + v.num
    end

    return sum
end

ProjectRP.Server.Stats.GetMoneyInventory = function()
    local statsCache = ModData.getOrCreate("StatisticsCache")
    local sum = 0
    local cutoff = getGameTime():getDaysSurvived() - 7

    for _,v in pairs(statsCache) do
        if not v.lastSeen then v.lastSeen = cutoff + 7 end -- backwards compatibility TODO: remove this line in next patch as it only needs to run once ever
        if v.lastSeen < cutoff then v = nil; return end
        sum = sum + v.inventoryMoney
    end

    return sum
end



ProjectRP.Server.Stats.LogTransfer = function(transferDetails)
    print('SUSPICIOUS: ' .. transferDetails)

    local fileWriter = getFileWriter('projectrp_log.txt', true, true)
    fileWriter:write(transferDetails)
    fileWriter:close()
end

ProjectRP.Server.Stats.ToFile = function()
    local fileReader = getFileReader('projectrp_stats.json', false)
    local result = ''
    while true do
        local line = fileReader:readLine()
        if not line then break end
        result = result .. line
    end
    fileReader:close()

    local data = {}
    if result ~= '' then
        data = ProjectRP.Utils.Json.Decode(result)
    end

    local datetime = getGameTime():getMonth() + 1 .. "/" .. getGameTime():getDay() + 1 .. "/" .. getGameTime():getYear() - 30 .. " " .. getGameTime():getHour() .. ":00:00"
    data[datetime] = {}
    data[datetime].moneyAtms = ProjectRP.Server.Stats.GetMoneyAtms()
    data[datetime].moneyInventory = ProjectRP.Server.Stats.GetMoneyInventory()

    local fileWriter = getFileWriter('projectrp_stats.json', true, false)
    fileWriter:write(ProjectRP.Utils.Json.Encode(data))
    fileWriter:close()

    fileWriter = getFileWriter('projectrp_money.json', true, false)
    fileWriter:write(ProjectRP.Utils.Json.Encode(ModData.get("MoneyBalance")))
    fileWriter:close()
end



ProjectRP.Server.Stats.RequestMoneyInventory = function()
    local onlineplayers = getOnlinePlayers()
    for i = 0, onlineplayers:size()-1 do
        sendServerCommand(onlineplayers:get(i), 'ProjectRPStatistics', 'ReportInventoryMoney', {})
    end
end

ProjectRP.Server.Stats.ReportInventoryMoney = function(player, args)
    local statsCache = ModData.getOrCreate('StatisticsCache')
    statsCache[player:getUsername()] = statsCache[player:getUsername()] or {}
    statsCache[player:getUsername()].inventoryMoney = args.money
    statsCache[player:getUsername()].lastSeen = getGameTime():getDaysSurvived()
end

ProjectRP.Server.Stats.OnClientCommand = function(mod, command, player, args)
    if mod ~= 'ProjectRPStatistics' then return end
    ProjectRP.Server.Stats[command](player, args)
end

Events.OnClientCommand.Add(ProjectRP.Server.Stats.OnClientCommand)

ProjectRP.Server.Stats.EveryHours = function()
    ProjectRP.Server.Stats.RequestMoneyInventory()
    ProjectRP.Utils.Delay.DelayFunction(ProjectRP.Server.Stats.ToFile, 50)
end

Events.EveryHours.Add(ProjectRP.Server.Stats.EveryHours)