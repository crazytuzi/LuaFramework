--
-- Author: Your Name
-- Date: 2015-09-01 19:50:03
--
local QTutorialStage = import("..QTutorialStage")
local QTutorialStageJewelry = class("QTutorialStageJewelry", QTutorialStage)
local QTutorialPhase01Jewelry = import(".QTutorialPhase01Jewelry")

function QTutorialStageJewelry:ctor(options)
	QTutorialStageJewelry.super.ctor(self)
	self._enableTouch = false
end

function QTutorialStageJewelry:_createTouchNode()
  	local touchNode = CCNode:create()
    touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    touchNode:setTouchSwallowEnabled(true)
    app.tutorialNode:addChild(touchNode)
    self._touchNode = touchNode
end

function QTutorialStageJewelry:_createPhases()
  table.insert(self._phases, QTutorialPhase01Jewelry.new(self))

  self._phaseCount = table.nums(self._phases)
end

function QTutorialStageJewelry:enableTouch(func)
  self._enableTouch = true
  self._touchCallBack = func
end

function QTutorialStageJewelry:disableTouch()
  self._enableTouch = false
  self._touchCallBack = nil
end

function QTutorialStageJewelry:start()
  self:_createTouchNode()
  self._touchNode:setTouchEnabled(true)
  self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QTutorialStageJewelry._onTouch))
  QTutorialStageJewelry.super.start(self)
end

function QTutorialStageJewelry:ended() 
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

function QTutorialStageJewelry:_onTouch(event)
  if self._enableTouch == true and self._touchCallBack ~= nil then
    return self._touchCallBack(event)
    elseif event.name == "began" then
        return true
    end
end

return QTutorialStageJewelry

