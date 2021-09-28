--TUseSkill.lua
--/*-----------------------------------------------------------------
 --* Module:  TUseTile.lua
 --* Author:  seezon
 --* Modified: 2014年10月8日
 --* Purpose: 穿戴某个称号
 -------------------------------------------------------------------*/

TUseSkill=class(TargetBase)

function TUseSkill:__init(task, context, state)
	self._state = state or 0

	if not self:completed() or self:belongFactionTask() == true then	
		self:addWatcher("onUseSkill")
	end
end

function TUseSkill:onUseSkill(player, skillID)
	local targetSkillID = self._context.param2

	--行会公共任务
	if self:getTaskPlayer() then
		local school = self:getTaskPlayer():getSchool()
		if school == 2 then
			targetTitleID = self._context.param3
		elseif school == 3 then
			targetTitleID = self._context.param4
		end
	end

	if not (skillID == targetSkillID) then
		return
	end

	self:setState(self._state + 1)
	--self:setState(self:findMatCount(matID))
	if self:completed() then
		self:removeWatcher("onUseSkill")
		self._task:validate()
	end

	self:taskInfoSave()
end

function TUseSkill:completed()
	return self._state >= self._context.param1
end