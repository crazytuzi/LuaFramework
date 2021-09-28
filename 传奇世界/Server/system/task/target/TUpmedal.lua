--TUpmedal.lua
--/*-----------------------------------------------------------------
 --* Module:  TUpmedal.lua
 --* Author:  seezon
 --* Modified: 2016年1月18日
 --* Purpose: 升级勋章
 -------------------------------------------------------------------*/

TUpmedal=class(TargetBase)

function TUpmedal:__init(task, context, state)
	self._state = state or 0
	
	if not self:completed() or self:belongFactionTask() == true then	
		self:addWatcher("onUpmedal")
	end
end

function TUpmedal:onUpmedal(player)
	self:setState(self:getState() + 1)
	if self:completed() then
		self:removeWatcher("onUpmedal")
		self._task:validate()
	end

	self:taskInfoSave()
end

function TUpmedal:completed()
	return self._state >= self._context.param1
end