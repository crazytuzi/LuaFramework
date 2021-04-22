--[[
    Class name QSBPetApplyBuff
    Create by julian 
--]]
local QSBAction = import(".QSBAction")
local QSBPetApplyBuff = class("QSBPetApplyBuff", QSBAction)

function QSBPetApplyBuff:_execute(dt)
	local pet = self._attacker:getHunterPet()
	if pet == nil or pet:isDead() then
		self:finished()
		return
	end

	local actor = pet

	if actor ~= nil and self._options.buff_id ~= nil then
		local id, level = q.parseIDAndLevel(self._options.buff_id, 1, self._skill)
		local buffInfo = db:getBuffByID(id)
	    if buffInfo == nil then
	        printError("buff id: %s does not exist!", self._options.buff_id)
	    else
	    	actor:applyBuff(self._options.buff_id, self._attacker, self._skill)
	    	if not self._options.no_cancel then
	    		self._director:addBuffId(self._options.buff_id, actor) 
	    	end
	    end
	end
	self:finished()
end

return QSBPetApplyBuff