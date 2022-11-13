local old_showRadialMenu = ISVehicleMenu.showRadialMenu

function ISVehicleMenu.showRadialMenu(playerObj)
    old_showRadialMenu(playerObj)
    local menu = getPlayerRadialMenu(playerObj:getPlayerNum())
    local oldSlices = menu.slices
    menu:clear()
    for i, data in ipairs(oldSlices) do
        if data.text ~= getText("ContextMenu_VehicleHotwire") and data.text ~= getText("ContextMenu_VehicleHotwireSkill") and (data.command[1] ~= ISVehicleMenu.onMechanic or playerObj:getVehicle() == nil) and data.text ~= getText("IGUI_OpenHood") then
            menu:addSlice(data.text, data.texture, data.command[1], data.command[2], data.command[3], data.command[4], data.command[5], data.command[6], data.command[7])
        elseif data.text == getText("ContextMenu_VehicleHotwire") or data.text == getText("ContextMenu_VehicleHotwireSkill") then
            if not (playerObj:getPerkLevel(Perks.Electricity) == 10 and playerObj:getPerkLevel(Perks.Mechanics) == 10) then
                menu:addSlice(getText("ContextMenu_VehicleHotwireSkill10"), getTexture("media/ui/vehicles/vehicle_ignitionOFF.png"), nil)
            else
                menu:addSlice(getText("ContextMenu_VehicleHotwire"), getTexture("media/ui/vehicles/vehicle_ignitionON.png"), ISVehicleMenu.onHotwire, playerObj)
            end
        end
    end
end