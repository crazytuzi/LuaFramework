--[[
    Class name QSBRemoveBuff
    Create by julian 
--]]
local QSBAction = import(".QSBAction")
local QSBRemoveBuff = class("QSBRemoveBuff", QSBAction)

local QActor = import("...models.QActor")

function QSBRemoveBuff:_execute(dt)
	local targets = {}
	if self._options.multiple_target_with_skill == true and self._skill:getRangeType() == self._skill.MULTIPLE then
		targets = self._attacker:getMultipleTargetWithSkill(self._skill)
	elseif self._options.teammate_and_self then
		targets = app.battle:getMyTeammates(self._attacker, true)
	elseif self._options.enemy then
		targets = app.battle:getMyEnemies(self._attacker)
	elseif self._options.selectTarget then
		table.insert(targets, self._options.selectTarget)
	elseif self._options.selectTargets then
		targets = self._options.selectTargets
	elseif self._options.enemies_except_target then
		local enemies = app.battle:getMyEnemies(self._attacker)
		table.removebyvalue(enemies, self._target)
		targets = enemies
	else
		local actor = self._attacker
		if self._options.is_target == true then
			actor = self._target
		end
		table.insert(targets, actor)
	end

	if #targets > 0 and self._options.buff_id ~= nil then
		if type(self._options.buff_id) == "table" then
			for k,buffid in pairs(self._options.buff_id) do
				for _, actor in ipairs(targets) do
					if self._options.remove_all_same_buff_id then
						actor:removeSameBuffByID(buffid)
					else
						actor:removeBuffByID(buffid)
					end
					self._director:removeBuffId(buffid, actor)
				end
			end
		else
			for _, actor in ipairs(targets) do
				if self._options.remove_all_same_buff_id then
					actor:removeSameBuffByID(self._options.buff_id)
				else
					actor:removeBuffByID(self._options.buff_id)
				end
				self._director:removeBuffId(self._options.buff_id, actor)
			end
		end
	end
	self:finished()
end

return QSBRemoveBuff