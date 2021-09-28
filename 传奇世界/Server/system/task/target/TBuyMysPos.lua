--TBuyMysPos.lua
--/*-----------------------------------------------------------------
 --* Module:  TBuyMysPos.lua
 --* Author:  seezon
 --* Modified: 2016年1月18日
 --* Purpose: 开启神秘商店的格子
 -------------------------------------------------------------------*/

TBuyMysPos=class(TargetBase)

function TBuyMysPos:__init(task, context, state)
	self._state = state or 0
	
	if not self:completed() or self:belongFactionTask() == true then	
		self:addWatcher("onBuyMysPos")
	end
end

function TBuyMysPos:onBuyMysPos(player)
	self:setState(self:getState() + 1)
	if self:completed() then
		self:removeWatcher("onBuyMysPos")
		self._task:validate()
	end

	self:taskInfoSave()
end

function TBuyMysPos:completed()
	return self._state >= self._context.param1
end