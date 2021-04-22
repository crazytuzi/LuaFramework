--
-- Author: xurui
-- Date: 2015-08-17 10:40:34
--
local QTutorialStage = import("..QTutorialStage")
local QTutorialStageUnlockHelp = class("QTutorialStageUnlockHelp", QTutorialStage)
local QTutorialPhase01UnlockHelp = import(".QTutorialPhase01UnlockHelp")

function QTutorialStageUnlockHelp:ctor(options)
	QTutorialStageUnlockHelp.super.ctor(self)
	self._enableTouch = false
end

function QTutorialStageUnlockHelp:_createTouchNode()
  	local touchNode = CCNode:create()
    touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    touchNode:setTouchSwallowEnabled(true)
    app.tutorialNode:addChild(touchNode)
    self._touchNode = touchNode
end

function QTutorialStageUnlockHelp:_createPhases()
  table.insert(self._phases, QTutorialPhase01UnlockHelp.new(self))

  self._phaseCount = table.nums(self._phases)
end

function QTutorialStageUnlockHelp:enableTouch(func)
  self._enableTouch = true
  self._touchCallBack = func
end

function QTutorialStageUnlockHelp:disableTouch()
  self._enableTouch = false
  self._touchCallBack = nil
end

function QTutorialStageUnlockHelp:start()
  self:_createTouchNode()
  self._touchNode:setTouchEnabled(true)
  self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QTutorialStageUnlockHelp._onTouch))
  QTutorialStageUnlockHelp.super.start(self)
end

function QTutorialStageUnlockHelp:ended() 
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

function QTutorialStageUnlockHelp:_onTouch(event)
  if self._enableTouch == true and self._touchCallBack ~= nil then
    return self._touchCallBack(event)
    elseif event.name == "began" then
        return true
    end
end

return QTutorialStageUnlockHelp
