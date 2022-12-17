local Commands = {}

Commands.revive = function(args)
    if args.patient == getPlayer():getUsername() then
        if getPlayer():getBodyDamage():getHealth() < 30 then
            getPlayer():getBodyDamage():setOverallBodyHealth(100)
        end
    end
end

Events.OnServerCommand.Add(function(module, command, args)
    if not isClient() then return end
    if module == "ProjectRP" and Commands[command] then
        Commands[command](args)
    end
end)

return Commands