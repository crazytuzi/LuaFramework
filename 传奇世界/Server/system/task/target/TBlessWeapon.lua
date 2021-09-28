--TBlessWeapon.lua
--/*-----------------------------------------------------------------
 --* Module:  TBlessWeapon.lua
 --* Author:  seezon
 --* Modified: 2016年1月18日
 --* Purpose: 祝福武器
 -------------------------------------------------------------------*/

TBlessWeapon=class(TargetBase)

function TBlessWeapon:__init(task, context, state)
	self._state = state or 0
	
	if not self:completed() or self:belongFactionTask() == true then	
		self:addWatcher("onBlessWeapon")
	end
end

function TBlessWeapon:onBlessWeapon(player)
	self:setState(self:getState() + 1)
	if self:completed() then
		self:removeWatcher("onBlessWeapon")
		self._task:validate()
	end

	self:taskInfoSave()
end

function TBlessWeapon:completed()
	return self._state >= self._context.param1
end