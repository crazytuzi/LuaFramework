--TWingPromote.lua
--/*-----------------------------------------------------------------
 --* Module:  TWingPromote.lua
 --* Author:  seezon
 --* Modified: 2014年10月8日
 --* Purpose: 光翼进阶
 -------------------------------------------------------------------*/

TWingPromote=class(TargetBase)

function TWingPromote:__init(task, context, state)
	self._state = state or 0
	if not self:completed() or self:belongFactionTask() == true then	
		self:addWatcher("onWingPromote")
	end
end

function TWingPromote:getWingLevel()
	local level = 1
	local roleId = self:getTaskPlayer():getID()
	local roleInfo = g_wingMgr:getRoleWingInfo(roleId)
	if roleInfo then
		level = roleInfo:getWingLevel()
	end
	return level
end

function TWingPromote:onWingPromote(player)
	self:setState(self:getState() + 1)
	--self:setState(self:findMatCount(matID))
	if self:completed() then
		self:removeWatcher("onWingPromote")
		self._task:validate()
	end

	self:taskInfoSave()
end

function TWingPromote:completed()
	return self._state >= self._context.param1
end