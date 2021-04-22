--[[
    Class name QSBPetUseSkill
    Create by julian 
--]]
local QSBAction = import(".QSBAction")
local QSBPetUseSkill = class("QSBPetUseSkill", QSBAction)

local QActor = import("...models.QActor")

-- order hunter pet set target to hunter's target, and use skill.
function QSBPetUseSkill:_execute(dt)
	local actor = self._attacker
	local target = self._target
	local pet = actor:getHunterPet()
	local skill_id = self:getOptions().skill_id

	if pet == nil or pet:isDead() or skill_id  == nil then
		self:finished()
		return
	end

	if target and not target:isDead() then
		pet:setTarget(target)
	end

	pet:_cancelCurrentSkill()
	pet:petAttackByID(skill_id)

	self:finished()
end

return QSBPetUseSkill