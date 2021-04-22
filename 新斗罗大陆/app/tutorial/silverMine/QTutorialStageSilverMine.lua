--
-- Author: Your Name
-- Date: 2016-08-03 19:04:03
--
local QTutorialStage = import("..QTutorialStage")
local QTutorialStageSilverMine = class("QTutorialStageSilverMine", QTutorialStage)
local QTutorialPhase01SilverMine = import(".QTutorialPhase01SilverMine")

function QTutorialStageSilverMine:ctor(options)
	QTutorialStageSilverMine.super.ctor(self)
	self._enableTouch = false
end

function QTutorialStageSilverMine:_createTouchNode()
  	local touchNode = CCNode:create()
    touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    touchNode:setTouchSwallowEnabled(true)
    app.tutorialNode:addChild(touchNode)
    self._touchNode = touchNode
end

function QTutorialStageSilverMine:_createPhases()
  table.insert(self._phases, QTutorialPhase01SilverMine.new(self))

  self._phaseCount = table.nums(self._phases)
end

function QTutorialStageSilverMine:enableTouch(func)
  self._enableTouch = true
  self._touchCallBack = func
end

function QTutorialStageSilverMine:disableTouch()
  self._enableTouch = false
  self._touchCallBack = nil
end

function QTutorialStageSilverMine:start()
  self:_createTouchNode()
  self._touchNode:setTouchEnabled(true)
  self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QTutorialStageSilverMine._onTouch))
  QTutorialStageSilverMine.super.start(self)
end

function QTutorialStageSilverMine:ended() 
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

function QTutorialStageSilverMine:_onTouch(event)
  if self._enableTouch == true and self._touchCallBack ~= nil then
    return self._touchCallBack(event)
    elseif event.name == "began" then
        return true
    end
end

return QTutorialStageSilverMine

