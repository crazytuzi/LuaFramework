--TEquipBaptize.lua
--/*-----------------------------------------------------------------
 --* Module:  TEquipBaptize.lua
 --* Author:  seezon
 --* Modified: 2016年1月18日
 --* Purpose: 装备洗炼
 -------------------------------------------------------------------*/

TEquipBaptize=class(TargetBase)

function TEquipBaptize:__init(task, context, state)
	self._state = state or 0
	
	if not self:completed() or self:belongFactionTask() == true then	
		self:addWatcher("onEquipBaptize")
	end
end

function TEquipBaptize:onEquipBaptize(player)
	self:setState(self:getState() + 1)
	if self:completed() then
		self:removeWatcher("onEquipBaptize")
		self._task:validate()
	end

	self:taskInfoSave()
end

function TEquipBaptize:completed()
	return self._state >= self._context.param1
end