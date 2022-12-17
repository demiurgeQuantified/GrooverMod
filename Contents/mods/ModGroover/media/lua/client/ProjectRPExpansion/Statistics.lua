ProjectRP.Client.Stats = {}
ProjectRP.Client.Stats.SuspiciousTransferAmount = 5000

ProjectRP.Client.Stats.ReportInventoryMoney = function()
    ---@type ItemContainer
    local inventory = getPlayer():getInventory()
    local sum = ProjectRP.Client.Money.getMoneyCountInContainer(inventory)
    for walletType,_ in pairs(ProjectRP.Client.Money.WalletTypes) do
        local wallets = inventory:getAllType(walletType)
        for i = 0, wallets:size()-1 do
            sum = sum + wallets:get(i):getModData().moneyCount
        end
    end
    sendClientCommand('ProjectRPStatistics', 'ReportInventoryMoney',  {money = sum})
end

---@param amount number
---@param container ItemContainer
ProjectRP.Client.Stats.ReportTransfer = function(amount, container)
    local containerLoc = container:getParent()
    local toInventory = instanceof(containerLoc, 'IsoPlayer')
    sendClientCommand('ProjectRPStatistics', 'ReportTransfer',  {money = amount, toInventory=toInventory, x=containerLoc:getX(), y=containerLoc:getY(), z=containerLoc:getZ()})
end

ProjectRP.Client.Stats.OnServerCommand = function(mod, command, args)
    if mod ~= 'ProjectRPStatistics' then return end
    ProjectRP.Client.Stats[command](args)
end

Events.OnServerCommand.Add(ProjectRP.Client.Stats.OnServerCommand)

local old_transferItem = ISInventoryTransferAction.transferItem
---@param item InventoryItem
function ISInventoryTransferAction:transferItem(item)
    if ProjectRP.Client.Money.Values[item:getType()] then
        if not self.moneyCount then self.moneyCount = 0 end
        self.moneyCount = self.moneyCount + ProjectRP.Client.Money.Values[item:getType()].v
    end
    if self.moneyCount and #self.queueList == 0 then
        if self.moneyCount > ProjectRP.Client.Stats.SuspiciousTransferAmount then
            ProjectRP.Client.Stats.ReportTransfer(self.moneyCount, self.destContainer)
        end
    end
    old_transferItem(self, item)
end