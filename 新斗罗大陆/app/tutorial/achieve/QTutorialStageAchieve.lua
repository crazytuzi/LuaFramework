--
-- Author: xurui
-- Date: 2015-06-03 14:32:43
--
local QTutorialStage = import("..QTutorialStage")
local QTutorialStageAchieve = class("QTutorialStageAchieve", QTutorialStage)
local QTutorialPhase01Achieve = import(".QTutorialPhase01Achieve")

function QTutorialStageAchieve:ctor(options)
	QTutorialStageAchieve.super.ctor(self)
	self._enableTouch = false
end

function QTutorialStageAchieve:_createTouchNode()
  	local touchNode = CCNode:create()
    touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    touchNode:setTouchSwallowEnabled(true)
    app.tutorialNode:addChild(touchNode)
    self._touchNode = touchNode
end

function QTutorialStageAchieve:_createPhases()
  table.insert(self._phases, QTutorialPhase01Achieve.new(self))

  self._phaseCount = table.nums(self._phases)
end

function QTutorialStageAchieve:enableTouch(func)
  self._enableTouch = true
  self._touchCallBack = func
end

function QTutorialStageAchieve:disableTouch()
  self._enableTouch = false
  self._touchCallBack = nil
end

function QTutorialStageAchieve:start()
  self:_createTouchNode()
  self._touchNode:setTouchEnabled(true)
  self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QTutorialStageAchieve._onTouch))
  QTutorialStageAchieve.super.start(self)
end

function QTutorialStageAchieve:ended()
  if self._forceStop == false then
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

function QTutorialStageAchieve:_onTouch(event)
  if self._enableTouch == true and self._touchCallBack ~= nil then
    return self._touchCallBack(event)
    elseif event.name == "began" then
        return true
    end
end

return QTutorialStageAchieve
