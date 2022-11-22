local Delay = {}
Delay.DelayFunction = function(closure, time)
    Delay.Delays[Delay.currentTick + time] = Delay.Delays[Delay.currentTick + time] or {}
    table.add(Delay.Delays[Delay.currentTick + time], closure)
end

Delay.OnTick = function(tick)
    Delay.currentTick = tick
    if Delay.Delays[tick] then
        for _,closure in pairs(Delay.Delays[tick]) do
            closure()
        end
    end
end

Events.OnTick.Add(Delay.OnTick)

return Delay