local QSBNode = import("..QSBNode")
local QSBArgsFindDragPosBySkillRange = class("QSBArgsFindDragPosBySkillRange", QSBNode)
function QSBArgsFindDragPosBySkillRange:ctor(...)
	QSBArgsFindDragPosBySkillRange.super.ctor(self, ...)
	local assassin_list = {}
	for i,id in ipairs(self._options.assassin_list or {}) do
		assassin_list[id] = true
	end
	self._assassin_list = assassin_list
end

function QSBArgsFindDragPosBySkillRange:_execute(dt)
    local skill = self._attacker:getTalentSkill()
    local pos = self._attacker:getDragPosition()
    if skill then
    	if self._attacker:isRanged() then
    		
    	elseif self._assassin_list[self._attacker:getActorID(true)] then
    		if self._target then
    			pos = clone(self._target:getPosition())
    			local distance = (self._attacker:getRect().size.width + self._target:getRect().size.width) / 2
				if self._target:getDirection() == self._target.DIRECTION_RIGHT then
					pos.x = pos.x - distance
				else
					pos.x = pos.x + distance
				end
    		end
    	else
    		if self._target then
    			local gridPos = app.grid:_findBestPositionByTarget(self._attacker, self._target, true)
    			pos = app.grid:_toScreenPos(gridPos)
    		end
    	end
    end
    self:finished({pos = pos})
end

return QSBArgsFindDragPosBySkillRange