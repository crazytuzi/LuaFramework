--TEquipStrength.lua
--/*-----------------------------------------------------------------
 --* Module:  TEquipStrength.lua
 --* Author:  seezon
 --* Modified: 2014年10月8日
 --* Purpose: 装备强化
 -------------------------------------------------------------------*/

TEquipStrength=class(TargetBase)

function TEquipStrength:__init(task, context, state)
	self._state = state or 0
	if not self:completed() or self:belongFactionTask() == true then	
		self:addWatcher("onEquipStrength")
	end
end

function TEquipStrength:onEquipStrength(player, equipId, level)
	self:setState(level)
	--self:setState(self:findMatCount(matID))
	if self:completed() then
		self:removeWatcher("onEquipStrength")
		self._task:validate()
	end

	self:taskInfoSave()
end

function TEquipStrength:completed()
	return self._state >= self._context.param1
end