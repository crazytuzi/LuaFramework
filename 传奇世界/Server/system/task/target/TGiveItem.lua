--TGiveItem.lua
--/*-----------------------------------------------------------------
 --* Module:  TGiveItem.lua
 --* Author:  seezon
 --* Modified: 2016年1月13日
 --* Purpose: 提交物品
 -------------------------------------------------------------------*/

TGiveItem=class(TargetBase)

function TGiveItem:__init(task, context, state)
	self._state = state or 0
	
	if not self._context.param2 then
		self._context.param2 = 0
	end
	
	--行会公共任务
	if  self:getTaskPlayer() then
		self:setState(self:findMatCount(self._context.param2))
	end

	if not self:completed() or self:belongFactionTask() == true then	
		self:addWatcher("onMatChange")
	end
end

function TGiveItem:onMatChange(player, matId)
	if self._context.param2 == matId then
		--行会公共任务
		if  self:getTaskPlayer() then
			--self:setState(self._state + 1)
		else
			self:setState(self:findMatCount(matId))
		end

		if self:completed() then
			self:removeWatcher("onMatChange")
			self._task:validate()
		end

		self:taskInfoSave()
	end
end

function TGiveItem:findMatCount(matId)
	local itemMgr = self:getTaskPlayer():getItemMgr()
	local num = itemMgr:getItemCount(matId) or 0
	return num
end

function TGiveItem:onTaskFinished()
	local num = self._context.param1
	local itemID = self._context.param2
	
	local itemMgr = self:getTaskPlayer():getItemMgr()
	itemMgr:destoryItem(itemID, num, 0) 
	g_logManager:writePropChange(self:getTaskPlayer():getSerialID(), 2 ,55, itemID, 0, num, 0)
end

function TGiveItem:completed()
	return self:findMatCount(self._context.param2) >= self._context.param1
	--return self._state >= self._context.param1
end