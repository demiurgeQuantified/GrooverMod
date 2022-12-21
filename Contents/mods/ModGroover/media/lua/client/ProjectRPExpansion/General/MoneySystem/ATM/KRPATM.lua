require 'ProjectRP/General/MoneySystem/ATM/KRPATM'

ProjectRP.Client.Money.ATM.ATMSprites = {location_business_bank_01_64 = true, location_business_bank_01_65 = true,
                                     location_business_bank_01_66 = true, location_business_bank_01_67 = true,
                                     ProjectRP_0 = true, ProjectRP_1 = true}

---@param playerObj IsoPlayer
---@param nnum number
ProjectRP.Client.Money.ATM.decreaseMoneyBalance = function(playerObj, nnum)
    playerObj:StopAllActionQueue()
    sendClientCommand(playerObj, 'ProjectRPDataBase', 'DecreaseMoneyBalance', { tableName = "MoneyBalance", num = nnum } )
end

---@param playerObj IsoPlayer
---@param nnum number
ProjectRP.Client.Money.ATM.increaseMoneyBalance = function(playerObj, nnum)
    playerObj:StopAllActionQueue()
    sendClientCommand(playerObj, 'ProjectRPDataBase', 'IncreaseMoneyBalance', { tableName = "MoneyBalance", num = nnum } )
end

local old_isValid = ISInventoryTransferAction.isValid
function ISInventoryTransferAction:isValid()
    if KRPATMWindow.instance and KRPATMWindow.instance:isVisible() then
        return false;
    end
    return old_isValid(self)
end