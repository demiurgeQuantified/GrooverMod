local ISPreDeathAction = ISBaseTimedAction:derive("ISPreDeathAction");
ISPreDeathAction.Type = "ISPreDeathAction"

---@param character IsoGameCharacter
function ISPreDeathAction:new(character)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.bodyParts = character:getBodyDamage():getBodyParts()
    o.previousPartHealth = {}
    o.stopOnWalk = false
    o.stopOnRun = false
    o.maxTime = 100000
    return o
end

function ISPreDeathAction:start()
    self.action:setUseProgressBar(false)
    self.character:setVariable("ExerciseType", "PreDeathState");
    self.character:reportEvent("EventFitness");
    self.character:clearVariable("ExerciseStarted");
    self.character:clearVariable("ExerciseEnded");
    self.character:reportEvent("EventUpdateFitness");
    for i = 0, self.bodyParts:size()-1 do
        self.previousPartHealth[i] = self.bodyParts:get(i):getHealth()
    end
    self.character:setAvoidDamage(true)
    self.character:setBlockMovement(true)
end

function ISPreDeathAction:isValid()
    return self.character:getBodyDamage():getHealth() <= 30
end

function ISPreDeathAction:update()
    for i = 0, self.bodyParts:size()-1 do
        self.bodyParts:get(i):SetHealth(self.previousPartHealth[i])
    end
end

function ISPreDeathAction:stop()
    self.character:setAvoidDamage(false)
    self.character:setBlockMovement(false)
    self.character:PlayAnim("Idle");
    self.character:setVariable("ExerciseEnded", true);
    ISBaseTimedAction.stop(self)
end



-- not actually a part of the timed action
---@param player IsoPlayer
---@param _damageType string
---@param _damage number
function ISPreDeathAction.onPlayerGetDamage(player, _damageType, _damage)
    if not instanceof(player, 'IsoPlayer') then return end
    local queue = ISTimedActionQueue.getTimedActionQueue(player)
    if queue.queue and queue.queue[1] and queue.queue[1].Type == 'ISPreDeathAction' then return end

    local bodyDamage = player:getBodyDamage()
    if bodyDamage:getHealth() <= 25 then
        ISTimedActionQueue.clear(player)
        ISTimedActionQueue.add(ISPreDeathAction:new(player))
    end
end

Events.OnPlayerGetDamage.Add(ISPreDeathAction.onPlayerGetDamage)

local oldISHealthPanel_createChildren = ISHealthPanel.createChildren
function ISHealthPanel:createChildren()
    oldISHealthPanel_createChildren(self)
    self.revive = ISButton:new(0, 0, 60, 18, "Revive", self, function(healthWindow)
        sendClientCommand(getPlayer(), 'ProjectRP', 'revive', { patient = healthWindow:getPatient():getUsername() })
    end)
    self.revive:initialise();
    self.revive:instantiate();
    self:addChild(self.revive);
end

local old_isPlayerDoingActionThatCanBeCancelled = isPlayerDoingActionThatCanBeCancelled
---@param playerObj IsoPlayer
function isPlayerDoingActionThatCanBeCancelled(playerObj)
    if not playerObj then return false end
    local queue = ISTimedActionQueue.getTimedActionQueue(playerObj)
    if queue.queue and queue.queue[1] and queue.queue[1].Type == 'ISPreDeathAction' then return false end
    return old_isPlayerDoingActionThatCanBeCancelled(playerObj)
end

return ISPreDeathAction