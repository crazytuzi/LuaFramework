--TEquipInherit.lua
--/*-----------------------------------------------------------------
 --* Module:  TEquipInherit.lua
 --* Author:  seezon
 --* Modified: 2015年3月9日
 --* Purpose: 装备传承
 -------------------------------------------------------------------*/

TEquipInherit=class(TargetBase)

function TEquipInherit:__init(task, context, state)
	self._state = state or 0
	
	if not self:completed() or self:belongFactionTask() == true then	
		self:addWatcher("onEquipInherit")
	end
end

function TEquipInherit:onEquipInherit(player)
	self:setState(1)
	if self:completed() then
		self:removeWatcher("onEquipInherit")
		self._task:validate()
	end

	self:taskInfoSave()
end

function TEquipInherit:completed()
	return self._state >= 1
end