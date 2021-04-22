--
-- Author: Your Name
-- Date: 2016-01-24 11:40:06
--QTutorialStageActivity
local QTutorialStage = import("..QTutorialStage")
local QTutorialStageActivity = class("QTutorialStageActivity", QTutorialStage)
local QTutorialPhase01Activity = import(".QTutorialPhase01Activity")

function QTutorialStageActivity:ctor(options)
	QTutorialStageActivity.super.ctor(self)
	self._enableTouch = false
end

function QTutorialStageActivity:_createTouchNode()
  	local touchNode = CCNode:create()
    touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    touchNode:setTouchSwallowEnabled(true)
    app.tutorialNode:addChild(touchNode)
    self._touchNode = touchNode
end

function QTutorialStageActivity:_createPhases()
  table.insert(self._phases, QTutorialPhase01Activity.new(self))

  self._phaseCount = table.nums(self._phases)
end

function QTutorialStageActivity:enableTouch(func)
  self._enableTouch = true
  self._touchCallBack = func
end

function QTutorialStageActivity:disableTouch()
  self._enableTouch = false
  self._touchCallBack = nil
end

function QTutorialStageActivity:start()
  self:_createTouchNode()
  self._touchNode:setTouchEnabled(true)
  self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QTutorialStageActivity._onTouch))
  QTutorialStageActivity.super.start(self)
end

function QTutorialStageActivity:ended() 
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

function QTutorialStageActivity:_onTouch(event)
  if self._enableTouch == true and self._touchCallBack ~= nil then
    return self._touchCallBack(event)
    elseif event.name == "began" then
        return true
    end
end

return QTutorialStageActivity

