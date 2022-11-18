require 'ProjectRP/General/RespawnSystem/ISPreDeathAction'

local numBodyParts = BodyPartType.ToIndex(BodyPartType.MAX)

function ISPreDeathAction:update()
    if self.character:getBodyDamage():getHealth() < 25 then
        self.character:getBodyDamage():AddGeneralHealth((25 - self.character:getBodyDamage():getHealth()) * numBodyParts)
    end
end

local oldISHealthPanel_createChildren = ISHealthPanel.createChildren
function ISHealthPanel:createChildren()
    oldISHealthPanel_createChildren(self)
    if not ProjectRP.Client.TagSystem.HaveProfessionTag(getPlayer(), "ems") then
        self.revive = ISButton:new(0, 0, 60, 18, "Revive", self, function(healthWindow) 
            sendClientCommand(getPlayer(), 'ProjectRP', 'revive', { patient = healthWindow:getPatient():getUsername() })
        end)
        self.revive:initialise();
        self.revive:instantiate();
        self:addChild(self.revive);
    end
end