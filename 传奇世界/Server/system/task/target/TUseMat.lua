--TUseMat.lua
--/*-----------------------------------------------------------------
 --* Module:  TUseMat.lua
 --* Author:  seezon
 --* Modified: 2014年10月8日
 --* Purpose: 在使用物品
 -------------------------------------------------------------------*/

TUseMat=class(TargetBase)

function TUseMat:__init(task, context, state)
	self._state = state or 0
	
	if not self._context.param2 then
		self._context.param2 = 0
	end

	if not self._context.param3 then
		self._context.param3 = 0
	end

	if not self._context.param4 then
		self._context.param4 = 0
	end

	if not self._context.param5 then
		self._context.param5 = 0
	end

	if not self:completed() or self:belongFactionTask() == true then	
		self:addWatcher("onUseMat")
	end
end

function TUseMat:onUseMat(player, matId, count)
	if self._context.param2 == matId or self._context.param3 == matId or self._context.param4 == matId or self._context.param5 == matId then
		self:setState(self._state + count)
		--self:setState(self:findMatCount(matID))
		if self:completed() then
			self:removeWatcher("onUseMat")
			self._task:validate()
		end

		self:taskInfoSave()
	end
end

function TUseMat:completed()
	return self._state >= self._context.param1
end