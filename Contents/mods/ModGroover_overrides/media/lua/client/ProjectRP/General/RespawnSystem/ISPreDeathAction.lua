ISPreDeathAction = ISBaseTimedAction:derive("ISPreDeathAction");
ISPreDeathAction.type = "predeath"

function ISPreDeathAction:isValid()
	return true;
end

local numBodyParts = BodyPartType.ToIndex(BodyPartType.MAX)

function ISPreDeathAction:update()
    if self.character:getBodyDamage():getHealth() < 25 then
        self.character:getBodyDamage():AddGeneralHealth((25 - self.character:getBodyDamage():getHealth()) * numBodyParts)
    end
end

function ISPreDeathAction:start()
    self.action:setUseProgressBar(false)
    if self.character:getCurrentState() ~= FitnessState.instance() then
        self.character:setVariable("ExerciseType", "PreDeathState");
        self.character:reportEvent("EventFitness");
        self.character:clearVariable("ExerciseStarted");
        self.character:clearVariable("ExerciseEnded");
        self.character:reportEvent("EventUpdateFitness");
    end
end

function ISPreDeathAction:stop()
    ISBaseTimedAction.stop(self);
end

function ISPreDeathAction:perform()
end

function ISPreDeathAction:new(character)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character;
	o.stopOnWalk = false;
	o.stopOnRun = false;
	o.maxTime = 100000;
	return o
end

------------

local function onTick()
    local player = getPlayer()
    local queue = ISTimedActionQueue.queues[player];
    if player:getBodyDamage():getHealth() <= 30 then
        if not queue or queue and #queue.queue == 0 then
            ISTimedActionQueue.add(ISPreDeathAction:new(player))
        elseif queue and queue.queue[1].type ~= "predeath" then
            ISTimedActionQueue.clear(player)
            ISTimedActionQueue.add(ISPreDeathAction:new(player))
        end
    elseif queue and #queue.queue ~= 0 and queue.queue[1].type == "predeath" then
        ISTimedActionQueue.clear(player)
        player:PlayAnim("Idle");
	    player:setVariable("ExerciseEnded", true);
    end
end
Events.OnTick.Add(onTick)

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