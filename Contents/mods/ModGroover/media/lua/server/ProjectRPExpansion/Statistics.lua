if isClient() then return end
ProjectRP.Server.Stats = {}

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

    for _,v in pairs(statsCache) do
        sum = sum + v.inventoryMoney
    end

    return sum
end



ProjectRP.Server.Stats.ToFile = function()
    local data = {}
    data.hour = getGameTime():getHour()
    data.day = getGameTime():getDay() + 1
    data.month = getGameTime():getMonth() + 1
    data.year = getGameTime():getYear()
    data.moneyAtms = ProjectRP.Server.Stats.GetMoneyAtms()
    data.moneyInventory = ProjectRP.Server.Stats.GetMoneyInventory()

    local fileWriter = getFileWriter('projectrp_stats.json', true, false)
    fileWriter:write(ProjectRP.Utils.Json.Encode(data))
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