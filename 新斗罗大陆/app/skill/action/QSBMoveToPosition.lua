--[[
    移动到目标点
	参数x , y
--]]

local QSBAction = import(".QSBAction")
local QSBMoveToPosition = class("QSBMoveToPosition", QSBAction)

local MOVE_TIMEOUT = 0.7 -- 多少秒以后依然没有移动认为超时，该动作结束

function QSBMoveToPosition:_execute(dt)

	local myX = self._options.x
	local myY = self._options.y
	if 	self._first == nil then
		local actor = self._attacker
		app.grid:moveActorTo(actor,{x = myX, y = myY}, false)
    	self._first = true
    	actor:lockDrag()
	end

	if self._attacker:isWalking() then
		self._moveStarted = true
	else
	    if self._moveStarted == true then
	        self:finished()
        elseif self._moveWaitFrom == nil then 
            self._moveWaitFrom = app.battle:getTime()
        elseif app.battle:getTime() - self._moveWaitFrom >= MOVE_TIMEOUT then
            self:finished()
        end
   end

end

function QSBMoveToPosition:_onCancel()
	if self._first == true then
		self._attacker:unlockDrag()
	end
end

function QSBMoveToPosition:finished()
	QSBMoveToPosition.super.finished(self)

	if self._first == true then
		self._attacker:unlockDrag()
	end
end

return QSBMoveToPosition
