--[[
    Class name QSBDelayTime
    Create by julian 
--]]

local QSBAction = import(".QSBAction")
local QSBDelayTime = class("QSBDelayTime", QSBAction)

function QSBDelayTime:_execute(dt)
	if self._isExecuting == true then
        self._accumulated_time = self._accumulated_time + dt
        if self._accumulated_time >= self._delay then
            self:finished()
        end
		return
	end


    local coefficient = self._attacker:getMaxHasteCoefficient()
    if self:isAffectedByHaste() == false then
        coefficient = 1
    end
	
	local delay = self._options.delay_time or 0
    if delay == 0 and self._options.delay_frame ~= nil then
        delay = self._options.delay_frame / 30.0
    end

    delay = delay * (1 / coefficient)

    self._delay = delay
    self._accumulated_time = 0
    self._isExecuting = true 
end

function QSBDelayTime:_onCancel()

end

return QSBDelayTime