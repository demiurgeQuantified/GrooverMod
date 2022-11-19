require 'ProjectRP/General/PrivateArea/PrivateAreaSetAccessRightsUI'

function PrivateAreaSetAccessRightsUI:new(square)
	local o = {}
	local w = 1200
	local h = 600
	o = ISPanelJoypad:new(0, 0, w, h);
	setmetatable(o, self)
	self.__index = self

    o.x = getCore():getScreenWidth() / 2 - (w / 2);
    o:setX(o.x)
	o.y = getCore():getScreenHeight() / 2 - (h / 2);
    o:setY(o.y)

	o.name = nil;
	o.backgroundColor = {r=0, g=0, b=0, a=0.5};
	o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
	o.width = w;
	o.height = h;
    o.square = square

	local zones = ModData.getOrCreate("PrivateZones")
	local x = o.square:getX()
	local y = o.square:getY()
	for i, zone in ipairs(zones) do
		if x >= zone.x1 and x <= zone.x2 or x >= zone.x2 and x <= zone.x1 then
			if y >= zone.y1 and y <= zone.y2 or y >= zone.y2 and y <= zone.y1 then
				o.zone = zone				
				break
			end
		end
	end

	o.anchorLeft = true;
	o.anchorRight = true;
	o.anchorTop = true;
	o.anchorBottom = true;
	o.titlebarbkg = getTexture("media/ui/Panel_TitleBar.png");
	return o;
end