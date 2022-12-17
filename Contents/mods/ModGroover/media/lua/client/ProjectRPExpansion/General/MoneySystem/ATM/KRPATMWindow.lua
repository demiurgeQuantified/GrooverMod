require 'ProjectRP/General/MoneySystem/ATM/KRPATMWindow'

---@param character IsoGameCharacter
function KRPATMWindow:new(character)
    local o = {}
    local width = 999;
    local height = 572;
    o = ISPanel:new(0, 0, width, height);
    setmetatable(o, self)
    self.__index = self
    o.playerNum = character:getPlayerNum()
    o.x = getCore():getScreenWidth() / 2 - (width / 2);
    o.y = getCore():getScreenHeight() / 2 - (height / 2);
    o:setX(o.x)
    o:setY(o.y)
    o.backgroundColor = {r=0, g=0, b=0, a=0};
    o.texture = getTexture("media/ui/ATM_background.png")
    o.leftButtonTexture = getTexture("media/ui/ATM_leftButton.png")
    o.rightButtonTexture = getTexture("media/ui/ATM_rightButton.png")

    o.width = width;
    o.height = height;
    o.char = character;

    o.interactX = character:getX()
    o.interactY = character:getY()

    KRPATMWindow.instance = o

    return o;
end