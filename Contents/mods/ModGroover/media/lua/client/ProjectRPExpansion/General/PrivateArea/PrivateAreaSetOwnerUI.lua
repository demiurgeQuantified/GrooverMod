require 'ProjectRP/General/PrivateArea/PrivateAreaSetOwnerUI'

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)

function PrivateAreaSetOwnerUI:initialise()
	ISPanelJoypad.initialise(self);
	
	local fontHgt = FONT_HGT_SMALL
	local buttonWid = 150
	local buttonHgt = math.max(fontHgt + 6, 25)
	local padBottom = 10
	
	self.close = ISButton:new(self:getWidth()/2 - buttonWid/2, self:getHeight() - padBottom - buttonHgt, buttonWid, buttonHgt, getText("UI_Close"), self, PrivateAreaSetOwnerUI.onClick);
	self.close.internal = "CLOSE";
	self.close:initialise();
	self.close:instantiate();
	self.close.borderColor = {r=1, g=1, b=1, a=0.1};
	self:addChild(self.close);

	self.apply = ISButton:new(self:getWidth()/2 - buttonWid/2, self.close:getY() - padBottom - buttonHgt, buttonWid, buttonHgt, "Apply", self, PrivateAreaSetOwnerUI.onClick);
	self.apply.internal = "APPLY";
	self.apply:initialise();
	self.apply:instantiate();
	self.apply.borderColor = {r=1, g=1, b=1, a=0.1};
	self:addChild(self.apply);

	local owner = "NONE"
	local zones = ModData.getOrCreate("PrivateZones")
	local x = self.square:getX()
	local y = self.square:getY()
	for i, zone in ipairs(zones) do
		if x >= zone.x1 and x <= zone.x2 or x >= zone.x2 and x <= zone.x1 then
			if y >= zone.y1 and y <= zone.y2 or y >= zone.y2 and y <= zone.y1 then
				owner = zone.owner				
				break
			end
		end
	end
    
    local txt = "Owner: " .. owner
    self.labelOwner = ISLabel:new(self:getWidth()/2 - getTextManager():MeasureStringX(UIFont.Large, txt)/2, 30, FONT_HGT_LARGE, txt, 1, 1, 1, 1, UIFont.Large, true)
	self.labelOwner:initialise()
	self:addChild(self.labelOwner)

    self.entryName = ISTextEntryBox:new("", 10, self.labelOwner:getBottom() + 10, 180, FONT_HGT_MEDIUM)
	self.entryName.font = UIFont.Medium
	self.entryName:initialise();
	self.entryName:instantiate();
	self:addChild(self.entryName)
end