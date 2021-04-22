--
-- Author: xurui
-- Date: 2015-09-01 19:40:17
--
local QTutorialStage = import("..QTutorialStage")
local QTutorialStageTraining = class("QTutorialStageTraining", QTutorialStage)
local QTutorialPhase01Training = import(".QTutorialPhase01Training")

function QTutorialStageTraining:ctor(options)
	QTutorialStageTraining.super.ctor(self)
	self._enableTouch = false
end

function QTutorialStageTraining:_createTouchNode()
  	local touchNode = CCNode:create()
    touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    touchNode:setTouchSwallowEnabled(true)
    app.tutorialNode:addChild(touchNode)
    self._touchNode = touchNode
end

function QTutorialStageTraining:_createPhases()
  table.insert(self._phases, QTutorialPhase01Training.new(self))

  self._phaseCount = table.nums(self._phases)
end

function QTutorialStageTraining:enableTouch(func)
  self._enableTouch = true
  self._touchCallBack = func
end

function QTutorialStageTraining:disableTouch()
  self._enableTouch = false
  self._touchCallBack = nil
end

function QTutorialStageTraining:start()
  self:_createTouchNode()
  self._touchNode:setTouchEnabled(true)
  self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QTutorialStageTraining._onTouch))
  QTutorialStageTraining.super.start(self)
end

function QTutorialStageTraining:ended() 
  if self._forceStop ~= true then
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:buildLayer()
    scheduler.performWithDelayGlobal(function()
      page:checkGuiad()
    end,0)
  end
	if self._touchNode ~= nil then
		self._touchNode:setTouchEnabled( false )
		self._touchNode:removeFromParent()
		self._touchNode = nil
	end
end

function QTutorialStageTraining:_onTouch(event)
  if self._enableTouch == true and self._touchCallBack ~= nil then
    return self._touchCallBack(event)
    elseif event.name == "began" then
        return true
    end
end

return QTutorialStageTraining

