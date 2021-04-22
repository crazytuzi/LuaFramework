
local QTutorialPhase = class("QTutorialPhase")

function QTutorialPhase:ctor(stage)
	self._stage = stage
	self._isFinished = false
	self._oneTimeCheck = true
end

function QTutorialPhase:start()

end

function QTutorialPhase:visit(dt)
	
end

function QTutorialPhase:finished()
	self._isFinished = true
end

function QTutorialPhase:isPhaseFinished()
	return self._isFinished
end

function QTutorialPhase:oneTimeCheck()
	if self._oneTimeCheck then
		self._oneTimeCheck = false
		return true
	else
		return false
	end
end

function QTutorialPhase:_autoTouchEnded(second, checkFunc)
    scheduler.performWithDelayGlobal(function()
        if checkFunc == nil or checkFunc() then
            self:_onTouch({name = "ended", x = -100, y = -100})
        end
    end, second)
end

return QTutorialPhase