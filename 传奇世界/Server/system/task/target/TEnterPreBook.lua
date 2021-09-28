--TEnterPreBook.lua
--/*-----------------------------------------------------------------
 --* Module:  TEnterPreBook.lua
 --* Author:  seezon
 --* Modified: 2016年9月9日
 --* Purpose: 预体验副本
 -------------------------------------------------------------------*/

TEnterPreBook=class(TargetBase)

function TEnterPreBook:__init(task, context, state)
	self._state = state or 0
	self:addWatcher("onEnterPreBookFail")
	if not self:completed() or self:belongFactionTask() == true then	
		self:addWatcher("onEnterPreBookSuc")
		g_copySystem:enterSingleInstByCopyID(self:getTaskPlayer():getID(), self._context.param1)
	end
end

function TEnterPreBook:onEnterPreBookSuc(player, bookId)
	if self._context.param1 ~= bookId then
		return
	end
	self:setState(1)
	if self:completed() then
		self:removeWatcher("onEnterPreBookSuc")
		self._task:validate()
	end
	self:taskInfoSave()
end

function TEnterPreBook:onEnterPreBookFail(player)
	if self._task:getStatus() and self._task:getStatus() ~= TaskStatus.Done then
		self:removeWatcher("onEnterPreBookFail")
		g_taskMgr:mainTaskFail(player, self._task)
	end
end

function TEnterPreBook:completed()
	return self._state >= 1
end