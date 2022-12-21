local Delay = {}
Delay.currentTick = 0
Delay.Delays = {}

Delay.DelayFunction = function(func, time)
    Delay.Delays[Delay.currentTick + time] = Delay.Delays[Delay.currentTick + time] or {}
    table.insert(Delay.Delays[Delay.currentTick + time], func)
end

Delay.OnTick = function(tick)
    Delay.currentTick = tick
    local delaysThisTick = Delay.Delays[tick]
    if not delaysThisTick then return end
    for i = 1, #delaysThisTick do
        delaysThisTick[i]()
    end
end

Events.OnTick.Add(Delay.OnTick)

return Delay