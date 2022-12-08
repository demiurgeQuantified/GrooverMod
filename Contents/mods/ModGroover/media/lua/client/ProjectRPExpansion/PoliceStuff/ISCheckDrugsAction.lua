require 'ProjectRP/PoliceStuff/ISCheckDrugsAction'

function ISCheckDrugsAction:perform()
    self.character:Say("Cannabis amount: " .. (ISCheckDrugsAction.edible + ISCheckDrugsAction.stoned))
    self.character:Say("Alcohol amount: " .. ISCheckDrugsAction.alco)
    ISBaseTimedAction.perform(self);
end