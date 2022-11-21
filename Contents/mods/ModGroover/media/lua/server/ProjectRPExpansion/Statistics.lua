ProjectRP.Server.Stats = {}
ProjectRP.Server.Stats.Data = {}

ProjectRP.Server.Stats.toFile = function()
    local data = {}
    data['hour'] = getGameTime():getHour()
    data['day'] = getGameTime():getDay()
    data['month'] = getGameTime():getMonth()
    data['year'] = getGameTime():getYear()

    for k,v in pairs(ProjectRP.Server.Stats.Data) do
        data[k] = v
    end

    local fileWriter = getFileWriter('projectrp_stats.json', true, false)

    fileWriter:write(ProjectRP.Utils.Json.Encode(data))

    fileWriter:close()
end

Events.EveryHours.Add(ProjectRP.Server.Stats.toFile)