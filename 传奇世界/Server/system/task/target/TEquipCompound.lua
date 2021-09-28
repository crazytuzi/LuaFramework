--TEquipCompound.lua
--/*-----------------------------------------------------------------
 --* Module:  TEquipCompound.lua
 --* Author:  seezon
 --* Modified: 2016年7月7日
 --* Purpose: 装备合成
 -------------------------------------------------------------------*/

TEquipCompound=class(TargetBase)

function TEquipCompound:__init(task, context, state)
	self._state = state or 0
	if not self:completed() or self:belongFactionTask() == true then	
		self:addWatcher("onCompound")
	end
end

function TEquipCompound:onCompound(player, equipId)
	if self._context.param2 > 0 and self._context.param2 ~= equipId then
		return
	end
	self:setState(self._state + 1)
	if self:completed() then
		self:removeWatcher("onCompound")
		self._task:validate()
	end

	self:taskInfoSave()
end

function TEquipCompound:completed()
	return self._state >= self._context.param1
end