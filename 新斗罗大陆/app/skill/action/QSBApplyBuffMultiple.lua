--[[
    Class name QSBApplyBuffMultiple
    Create by julian 
--]]
local QSBAction = import(".QSBAction")
local QSBApplyBuffMultiple = class("QSBApplyBuffMultiple", QSBAction)

local QSkill = import("...models.QSkill")

function QSBApplyBuffMultiple:_execute(dt)
	local actors = nil
	local target_type = self._options.target_type
	if target_type == QSkill.ENEMY then
		actors = app.battle:getMyEnemies(self._attacker)
	elseif target_type == QSkill.TEAMMATE then
		actors = app.battle:getMyTeammates(self._attacker, false)
	elseif target_type == QSkill.TEAMMATE_AND_SELF then
		actors = app.battle:getMyTeammates(self._attacker, true)
	end

	if actors ~= nil and self._options.buff_id ~= nil then
		local id, level = q.parseIDAndLevel(self._options.buff_id, 1, self._skill)
		local buffInfo = db:getBuffByID(id)
	    if buffInfo == nil then
	        printError("buff id: %s does not exist!", self._options.buff_id)
	    else
	    	local actor
	    	for i = 1, #actors do
	    		actor = actors[i]
	    		actor:applyBuff(self._options.buff_id, self._attacker, self._skill)
	    	end
	    end
	end
	self:finished()
end

return QSBApplyBuffMultiple