--TSkillLevelUp.lua
--/*-----------------------------------------------------------------
 --* Module:  TSkillLevelUp.lua
 --* Author:  seezon
 --* Modified: 2014年10月8日
 --* Purpose: 技能升级
 -------------------------------------------------------------------*/

TSkillLevelUp=class(TargetBase)

function TSkillLevelUp:__init(task, context, state)
	self._state = state or 0

	if not self:completed() or self:belongFactionTask() == true then	
		self:addWatcher("onSkillLevelUp")
	end
end

function TSkillLevelUp:onSkillLevelUp(player, level)
	self:setState(level)
	--self:setState(self:findMatCount(matID))
	if self:completed() then
		self:removeWatcher("onSkillLevelUp")
		self._task:validate()
	end

	self:taskInfoSave()
end

function TSkillLevelUp:completed()
	return self._state >= self._context.param1
end