--
-- Author: Qinyuanji
-- Date: 2015-01-13
-- 
-- This tutorial stage is used to prompt user to pick up a name before entering Arena
-- User is forced to choose a name, so cancel and outbound click doesn't work

local QTutorialStage = import("..QTutorialStage")
local QTutorialStageArenaAddName = class("QTutorialStageArenaAddName", QTutorialStage)
local QTutorialPhase01ArenaAddName = import(".QTutorialPhase01ArenaAddName")

function QTutorialStageArenaAddName:ctor(options)
	QTutorialStageArenaAddName.super.ctor(self)
	self._enableTouch = false
end

function QTutorialStageArenaAddName:_createTouchNode()
  	local touchNode = CCNode:create()
    touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    touchNode:setTouchSwallowEnabled(true)
    app.tutorialNode:addChild(touchNode)
    self._touchNode = touchNode
end

function QTutorialStageArenaAddName:_createPhases()
  table.insert(self._phases, QTutorialPhase01ArenaAddName.new(self))

  self._phaseCount = table.nums(self._phases)
end

function QTutorialStageArenaAddName:enableTouch(func)
  self._enableTouch = true
  self._touchCallBack = func
end

function QTutorialStageArenaAddName:disableTouch()
  self._enableTouch = false
  self._touchCallBack = nil
end

function QTutorialStageArenaAddName:start()
  self:_createTouchNode()
  self._touchNode:setTouchEnabled(true)
  self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QTutorialStageArenaAddName._onTouch))
  QTutorialStageArenaAddName.super.start(self)
end

function QTutorialStageArenaAddName:ended()
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

function QTutorialStageArenaAddName:_onTouch(event)
  if self._enableTouch == true and self._touchCallBack ~= nil then
    return self._touchCallBack(event)
    elseif event.name == "began" then
        return true
    end
end

return QTutorialStageArenaAddName
