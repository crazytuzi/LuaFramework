--
-- Author: Your Name
-- Date: 2016-08-03 17:43:40
--QTutorialStageGemstone
local QTutorialStage = import("..QTutorialStage")
local QTutorialStageGemstone = class("QTutorialStageGemstone", QTutorialStage)
local QTutorialPhase01Gemstone = import(".QTutorialPhase01Gemstone")

function QTutorialStageGemstone:ctor(options)
	QTutorialStageGemstone.super.ctor(self)
	self._enableTouch = false
end

function QTutorialStageGemstone:_createTouchNode()
  	local touchNode = CCNode:create()
    touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    touchNode:setTouchSwallowEnabled(true)
    app.tutorialNode:addChild(touchNode)
    self._touchNode = touchNode
end

function QTutorialStageGemstone:_createPhases()
  table.insert(self._phases, QTutorialPhase01Gemstone.new(self))

  self._phaseCount = table.nums(self._phases)
end

function QTutorialStageGemstone:enableTouch(func)
  self._enableTouch = true
  self._touchCallBack = func
end

function QTutorialStageGemstone:disableTouch()
  self._enableTouch = false
  self._touchCallBack = nil
end

function QTutorialStageGemstone:start()
  self:_createTouchNode()
  self._touchNode:setTouchEnabled(true)
  self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QTutorialStageGemstone._onTouch))
  QTutorialStageGemstone.super.start(self)
end

function QTutorialStageGemstone:ended() 
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

function QTutorialStageGemstone:_onTouch(event)
  if self._enableTouch == true and self._touchCallBack ~= nil then
    return self._touchCallBack(event)
    elseif event.name == "began" then
        return true
    end
end

return QTutorialStageGemstone

