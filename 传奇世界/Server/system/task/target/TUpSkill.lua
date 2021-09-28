--TUpSkill.lua
--/*-----------------------------------------------------------------
 --* Module:  TUpSkill.lua
 --* Author:  seezon

 -------------------------------------------------------------------*/

TUpSkill=class(TargetBase)

function TUpSkill:__init(task, context, state)
	self._state = state or 0

	if not self:completed() or self:belongFactionTask() == true then	
		self:addWatcher("onUpSkill")
	end
end

function TUpSkill:onUpSkill(player)
	self:setState(self._state + 1)
	if self:completed() then
		self:removeWatcher("onUpSkill")
		self._task:validate()
	end

	self:taskInfoSave()
end

function TUpSkill:completed()
	return self._state >= self._context.param1
end