-- @Author: xurui
-- @Date:   2016-12-01 15:31:06
-- @Last Modified by:   xurui
-- @Last Modified time: 2016-12-01 15:32:33
local QTutorialStage = import("..QTutorialStage")
local QTutorialStageRefine = class("QTutorialStageRefine", QTutorialStage)
local QTutorialPhase01Refine = import(".QTutorialPhase01Refine")

function QTutorialStageRefine:ctor(options)
	QTutorialStageRefine.super.ctor(self)
	self._enableTouch = false
end

function QTutorialStageRefine:_createTouchNode()
  	local touchNode = CCNode:create()
    touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    touchNode:setTouchSwallowEnabled(true)
    app.tutorialNode:addChild(touchNode)
    self._touchNode = touchNode
end

function QTutorialStageRefine:_createPhases()
  table.insert(self._phases, QTutorialPhase01Refine.new(self))

  self._phaseCount = table.nums(self._phases)
end

function QTutorialStageRefine:enableTouch(func)
  self._enableTouch = true
  self._touchCallBack = func
end

function QTutorialStageRefine:disableTouch()
  self._enableTouch = false
  self._touchCallBack = nil
end

function QTutorialStageRefine:start()
  self:_createTouchNode()
  self._touchNode:setTouchEnabled(true)
  self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QTutorialStageRefine._onTouch))
  QTutorialStageRefine.super.start(self)
end

function QTutorialStageRefine:ended() 
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

function QTutorialStageRefine:_onTouch(event)
  if self._enableTouch == true and self._touchCallBack ~= nil then
    return self._touchCallBack(event)
    elseif event.name == "began" then
        return true
    end
end

return QTutorialStageRefine