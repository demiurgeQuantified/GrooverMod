ProjectRP.Client.Stats = {}

ProjectRP.Client.Stats.ReportInventoryMoney = function()
    ---@type ItemContainer
    local inventory = getPlayer():getInventory()
    local sum = ProjectRP.Client.Money.getMoneyCountInContainer(inventory)
    for _,walletType in pairs(ProjectRP.Client.Money.WalletTypes) do
        local wallets = inventory:getAllType(walletType)
        for _,wallet in pairs(wallets) do
            sum = sum + wallet:getModData().moneyCount
        end
    end
    sendClientCommand('ProjectRPStatistics', 'ReportInventoryMoney',  {money = sum})
end

ProjectRP.Client.Stats.OnServerCommand = function(mod, command, args)
    if mod ~= 'ProjectRPStatistics' then return end
    ProjectRP.Client.Stats[command](args)
end

Events.OnServerCommand.Add(ProjectRP.Client.Stats.OnServerCommand)