--AcquireInfoGuide.lua

require("app.scenes.common.acquireInfo.acquire_guide_info")

local AcquireInfoGuide = class("AcquireInfoGuide", function ( ... )
	return CCNode:create()
end)

function AcquireInfoGuide.runGuide( ... )
	local aquireInfo = AcquireInfoGuide.new( ... )
	return aquireInfo:doRunGuide()
end

function AcquireInfoGuide:ctor( ... )
	self._curFunctionId = 0
	self._curChapterId = 0
	self._curDungeonId = 0

	self._curGuideStep = 0
	self._guideLayer = nil

	self:_initGuideInfo( ... )
end

function AcquireInfoGuide:_initGuideInfo( functionId, chatperId, dungeonId )
	self._curFunctionId = functionId or 0
	self._curChapterId = chatperId or 0
	self._curDungeonId = dungeonId or 0
	__Log("functionId:%d, chatperId:%d, dungeonId:%d", functionId, chatperId, dungeonId)

	if self._curFunctionId == 1 then 
		self._curGuideStep = 1
	elseif self._curFunctionId == 3 then 
	 	self._curGuideStep = 20
	-- elseif self._curFunctionId == 8 then 
	-- 	self._curGuideStep = 30
	elseif self._curFunctionId == 7 then 
		self._curGuideStep = 40
	elseif self._curFunctionId == 8 then 
		self._curGuideStep = 50
	elseif self._curFunctionId == 9 then 
		self._curGuideStep = 60
	elseif self._curFunctionId == 10 then
		self._curGuideStep = 80
	elseif self._curFunctionId == 11 then
		self._curGuideStep = 100
	elseif self._curFunctionId == 20 then
		self._curGuideStep = 200
	elseif self._curFunctionId == 24 then
		self._curGuideStep = 210
	elseif self._curFunctionId == 30 then
		self._curGuideStep = 215
	elseif self._curFunctionId == 35 then
		self._curGuideStep = 350
	elseif self._curFunctionId == 50 then
		self._curGuideStep = 500
	else
		__LogError("AcquireInfoGuide: can't find according step for funtioinId:%d", self._curFunctionId)
	end

	uf_notifyLayer:getGuideNode():addChild(self)
end

function AcquireInfoGuide:doRunGuide( ... )
	if self._curGuideStep == 0 then 
		return false
	end

	local flag = self:_doRunStep(self._curGuideStep)
	if not flag then 
		self:exitGuide()
	end

	return flag
end

function AcquireInfoGuide:_doRunStep( stepId )
	stepId = stepId or 0
	local acquireInfo = acquire_guide_info.get(stepId)
	if not acquireInfo then 
		__Log("acquireInfo is nil for stepId:%d", stepId or 0)
		return false
	end

	if not self._guideLayer then 
		self._guideLayer = require("app.scenes.common.acquireInfo.AcquireGuideLayer").create()
	end

	self._guideLayer:filterWithStepId(stepId, self._curFunctionId, self._curChapterId, self._curDungeonId, function ( event, step_id  )
		self:_onFinishGuideStep( event, step_id  )
	end)

	return true
end

function AcquireInfoGuide:_onFinishGuideStep( event, step_id )
	__Log("finish current step:[%d] and event:%s", step_id, event)
	
	if event == "cancel" then 
		self:exitGuide()
	else
		self._curGuideStep = self._curGuideStep + 1
		if not self:_doRunStep(self._curGuideStep) then 
			self:exitGuide()
		end
	end
end

function AcquireInfoGuide:exitGuide( ... )
	__Log("AcquireInfoGuide exitGuide")
	if self._guideLayer then
		self._guideLayer:finishGuide()
		self._guideLayer = nil
	end

	self:removeFromParentAndCleanup(true)
end


return AcquireInfoGuide
