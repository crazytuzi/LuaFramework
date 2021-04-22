--[[
    Class name QSBTriggerSkill
    Create by julian 
--]]
local QSBAction = import(".QSBAction")
local QSBTriggerSkill = class("QSBTriggerSkill", QSBAction)

local QActor 			= import("...models.QActor")
local QSkill 			= import("...models.QSkill")

function QSBTriggerSkill:_execute(dt)
	local actor = self._attacker
	local skill_id = self:getOptions().skill_id
	local wait_finish = self:getOptions().wait_finish == nil and true or self:getOptions().wait_finish
	local targetType = self:getOptions().target_type
	local skill_level = self:getOptions().skill_level
	local target = nil
	if targetType == "skill_target" then
		target = self._target
	end

	if skill_id == nil or skill_id == "" then
		self:finished()
		return	
	end 

	if skill_level and skill_level < 1 then
		skill_level = self._skill:getSkillLevel()
	end

	if self._triggered == true then
		local finished = true
		for _, sbDirector in ipairs(actor._sbDirectors) do
			if sbDirector == self._triggerSBDirector then
				finished = false 
				break
			end
		end
		if finished then
			self:finished()
		end
		return
	end

	local triggerSkill = actor._skills[skill_id]
    if triggerSkill == nil then
        triggerSkill = QSkill.new(skill_id, db:getSkillByID(skill_id), actor, skill_level)
        actor._skills[skill_id] = triggerSkill
    end
    if triggerSkill:isReadyAndConditionMet() then
        self._triggerSBDirector = actor:triggerAttack(triggerSkill, target)
        self._triggered = true

        if not wait_finish then
        	self:finished()
        end
    else
    	self:finished()
    end
end

return QSBTriggerSkill