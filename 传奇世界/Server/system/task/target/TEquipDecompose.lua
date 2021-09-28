--TEquipDecompose.lua
--/*-----------------------------------------------------------------
 --* Module:  TEquipDecompose.lua
 --* Author:  seezon
 --* Modified: 2014年10月8日
 --* Purpose: 分解装备
 -------------------------------------------------------------------*/

TEquipDecompose=class(TargetBase)

function TEquipDecompose:__init(task, context, state)
	self._state = state or 0

	if not self:completed() or self:belongFactionTask() == true then	
		self:addWatcher("onEquipDecompose")
	end
end

function TEquipDecompose:onEquipDecompose(player)
	self:setState(self._state + 1)
	--self:setState(self:findMatCount(matID))
	if self:completed() then
		self:removeWatcher("onEquipDecompose")
		self._task:validate()
	end

	self:taskInfoSave()
end

function TEquipDecompose:completed()
	return self._state >= self._context.param1
end