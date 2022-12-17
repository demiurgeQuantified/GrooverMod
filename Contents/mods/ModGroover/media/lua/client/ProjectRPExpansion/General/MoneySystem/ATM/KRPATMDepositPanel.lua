require 'ProjectRP/General/MoneySystem/ATM/KRPATMDepositPanel'

---@param item InventoryItem
function KRPATMDepositPanel:addItemToYourOffer(item)
    if not instanceof(item:getContainer():getParent(), 'IsoPlayer') then return end
    local add = true;
    for i,v in ipairs(self.depositDatas.items) do
        if v.item == item then
            add = false;
            break;
        end
    end
    if add then
        self.depositDatas:addItem(item:getName(), item);
        if #self.depositDatas.items == 1 then
            self.depositDatas.selected = 1;
        end
    end
end