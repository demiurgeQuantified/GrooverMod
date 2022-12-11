if isClient() then return end

local getX = __classmetatables[zombie.iso.IsoGridSquare.class].__index.getX
local getY = __classmetatables[zombie.iso.IsoGridSquare.class].__index.getY
local getChunk = __classmetatables[zombie.iso.IsoGridSquare.class].__index.getChunk
local getSquare = __classmetatables[zombie.iso.IsoChunk.class].__index.getGridSquare
local getWorldObjects = __classmetatables[zombie.iso.IsoGridSquare.class].__index.getWorldObjects
local getLuaTileObjectList = __classmetatables[zombie.iso.IsoGridSquare.class].__index.getLuaTileObjectList
local size = __classmetatables[java.util.ArrayList.class].__index.size
local get = __classmetatables[java.util.ArrayList.class].__index.get
local getItem = __classmetatables[zombie.iso.objects.IsoWorldInventoryObject.class].__index.getItem
local removeItem = __classmetatables[zombie.iso.objects.IsoWorldInventoryObject.class].__index.removeFromSquare
local addItem = __classmetatables[zombie.inventory.ItemContainer.class].__index.AddItem
local insert = table.insert
-- this code runs on LoadGridsquare, so i really want it to run fast ^^
-- in my testing, pulling java functions into the local namespace like this was about 22% faster
-- disclosure: the code doesn't run very long anyway, and i did not repeat the experiment
-- it makes your code much harder to read, but in cases like this, i think it may be justified

local ConsolidateFloorItems = {}
ConsolidateFloorItems.MaxAllowedItems = 200

function ConsolidateFloorItems.LoadGridsquare(square)
    if getX(square) % 10 ~= 0 or getY(square) % 10 ~= 0 then return end
    local chunk = getChunk(square)
    local nearbyItems = {}
    local freeSquare = false
    for x = 0,9 do
        for y = 0,9 do
            local square = getSquare(chunk, x, y, 0)
            local objects = getWorldObjects(square)
            for i=0,size(objects)-1 do
                insert(nearbyItems, get(objects, i))
            end
            if not freeSquare then
                freeSquare = #getLuaTileObjectList(square) < 2 and square
            end
        end
    end
    if freeSquare and #nearbyItems > ConsolidateFloorItems.MaxAllowedItems then
        local crate = IsoObject.new(freeSquare, 'furniture_storage_02_17', 'furniture_storage_02_18')
        local container = ItemContainer.new('Excess Item Container', freeSquare, crate)
        crate:setContainer(container)
        for i=1,#nearbyItems do
            local worldItem = nearbyItems[i]
            addItem(container, getItem(worldItem))
            removeItem(worldItem)
        end
        freeSquare:AddTileObject(crate)
    end
end

Events.LoadGridsquare.Add(ConsolidateFloorItems.LoadGridsquare)

return ConsolidateFloorItems