--TUseTile.lua
--/*-----------------------------------------------------------------
 --* Module:  TUseTile.lua
 --* Author:  seezon
 --* Modified: 2014年10月8日
 --* Purpose: 穿戴某个称号
 -------------------------------------------------------------------*/

TUseTile=class(TargetBase)

function TUseTile:__init(task, context, state)
	self._state = state or 0
	self.targetTitleID = self._context.param1

	--行会公共任务
	if self:getTaskPlayer() then
		local school = self:getTaskPlayer():getSchool()
		if school == 2 then
			self.targetTitleID = self._context.param2
		elseif school == 3 then
			self.targetTitleID = self._context.param3
		end

		if self:getTaskPlayer():getTitle() == self.targetTitleID then
			self:setState(1)
		end
	end

	if not self:completed() or self:belongFactionTask() == true then	
		self:addWatcher("onUseTile")
	end
end

function TUseTile:onUseTile(player, titleID)
	if not (titleID == self.targetTitleID) then
		return
	end

	self:setState(1)
	--self:setState(self:findMatCount(matID))
	if self:completed() then
		self:removeWatcher("onUseTile")
		self._task:validate()
	end

	self:taskInfoSave()
end

function TUseTile:completed()
	return self._state >= 1
end