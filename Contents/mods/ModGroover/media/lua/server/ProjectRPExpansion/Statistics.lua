ProjectRP.Server.Stats = {}
ProjectRP.Server.Stats.Data = {}

ProjectRP.Server.Stats.toFile = function()
    ProjectRP.Server.Stats.updateMoneyAtms()
    local data = {}
    data['hour'] = getGameTime():getHour()
    data['day'] = getGameTime():getDay() + 1
    data['month'] = getGameTime():getMonth() + 1
    data['year'] = getGameTime():getYear()

    for k,v in pairs(ProjectRP.Server.Stats.Data) do
        data[k] = v
    end

    local fileWriter = getFileWriter('projectrp_stats.json', true, false)

    fileWriter:write(ProjectRP.Utils.Json.Encode(data))

    fileWriter:close()
end

ProjectRP.Server.Stats.updateMoneyAtms = function()
    local moneyBalance = ModData.get("MoneyBalance")
    local sum = 0
    for _,v in pairs(moneyBalance) do
        sum = sum + v.num
    end
    ProjectRP.Server.Stats.Data.moneyAtms = sum
end

Events.EveryHours.Add(ProjectRP.Server.Stats.toFile)