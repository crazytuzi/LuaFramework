
local QTutorialStage = class("QTutorialStage")

function QTutorialStage:ctor()
	self._phases = {}
	self._phaseCount = 0
	self._index = 1
	self._forceStop = false
end

function QTutorialStage:_createPhases()
	
end

function QTutorialStage:start()
	self:_createPhases()
	self:_startPhase()
end

function QTutorialStage:_startPhase()
	if self:isStageFinished() == true then
		return
	end
	local phase = self._phases[self._index]
	phase:start()
end

function QTutorialStage:visit(dt)
	if self:isStageFinished() == true then
		return
	end

	local phase = self._phases[self._index]
	phase:visit(dt)
	if phase:isPhaseFinished() == true then
		self._index = self._index + 1
		self:_startPhase()
	end
end

function QTutorialStage:ended()

end

function QTutorialStage:jumpFinished()
	self._index = self._phaseCount + 1
	self._forceStop = true
end

function QTutorialStage:isStageFinished()
	return (self._index > self._phaseCount)
end

return QTutorialStage