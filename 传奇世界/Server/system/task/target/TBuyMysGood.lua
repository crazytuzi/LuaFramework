--TBuyMysGood.lua
--/*-----------------------------------------------------------------
 --* Module:  TBuyMysGood.lua
 --* Author:  seezon
 --* Modified: 2016年1月18日
 --* Purpose: 购买神秘商店物品
 -------------------------------------------------------------------*/

TBuyMysGood=class(TargetBase)

function TBuyMysGood:__init(task, context, state)
	self._state = state or 0
	
	if not self:completed() or self:belongFactionTask() == true then	
		self:addWatcher("onBuyMysGood")
	end
end

function TBuyMysGood:onBuyMysGood(player)
	self:setState(self:getState() + 1)
	if self:completed() then
		self:removeWatcher("onBuyMysGood")
		self._task:validate()
	end

	self:taskInfoSave()
end

function TBuyMysGood:completed()
	return self._state >= self._context.param1
end