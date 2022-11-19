local function duplicateItem(item, times)
    for i=1, times do
        local playerObj = getPlayer();
        local inventory = playerObj:getInventory();

        if instanceof(item, "InventoryItem") and item:getCategory() == "Container" then

            local itemInventory = item:getInventory();
            local items = itemInventory:getItems();

            local newBag = inventory:AddItem(item:getFullType());
            newBag:setName(item:getName());

            local newBagInventory = newBag:getInventory();

            for i=0, items:size()-1 do
                local _item = items:get(i);
                local itemType = _item:getFullType();
                newBagInventory:AddItem(itemType);
            end
        else

            local newItem = inventory:AddItem(item:getFullType());
            newItem:setName(item:getName());

        end
    end
end

local function OnFillInventoryObjectContextMenu(player, context, items)
    if not (isDebugEnabled() or (isClient() and isAdmin())) then return true; end

    local text = "[DEBUG]"
    if isClient() and isAdmin() then
        text = "[ADMIN]"
    end

    local duplicateOption = context:addOption(text .. " Duplicate:")
    local subMenuDuplicate = ISContextMenu:getNew(context)
    context:addSubMenu(duplicateOption, subMenuDuplicate)

    for i, item in ipairs(items) do
        local doMenu = false
        if type(item) == "table" then
            item = item.items[1]
            doMenu = true
        elseif instanceof(item, "InventoryItem") then
            doMenu = true
        end
        if doMenu then
            local itemOption = subMenuDuplicate:addOption(item:getDisplayName());
            local subMenuAmount = ISContextMenu:getNew(subMenuDuplicate)
            subMenuDuplicate:addSubMenu(itemOption, subMenuAmount)
            subMenuAmount:addOption('1', item, duplicateItem, 1)
            subMenuAmount:addOption('5', item, duplicateItem, 5)
            subMenuAmount:addOption('10', item, duplicateItem, 10)
            subMenuAmount:addOption('25', item, duplicateItem, 25)
            subMenuAmount:addOption('50', item, duplicateItem, 50)
        end
    end

end
Events.OnFillInventoryObjectContextMenu.Add(OnFillInventoryObjectContextMenu);
