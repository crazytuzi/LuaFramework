--
-- Author: xurui
-- Date: 2015-12-25 18:13:07
--
local QTutorialStage = import("..QTutorialStage")
local QTutorialStageArena = class("QTutorialStageArena", QTutorialStage)
local QTutorialPhase01Arena = import(".QTutorialPhase01Arena")

function QTutorialStageArena:ctor(options)
	QTutorialStageArena.super.ctor(self)
	self._enableTouch = false
end

function QTutorialStageArena:_createTouchNode()
  	local touchNode = CCNode:create()
    touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    touchNode:setTouchSwallowEnabled(true)
    app.tutorialNode:addChild(touchNode)
    self._touchNode = touchNode
end

function QTutorialStageArena:_createPhases()
  table.insert(self._phases, QTutorialPhase01Arena.new(self))

  self._phaseCount = table.nums(self._phases)
end

function QTutorialStageArena:enableTouch(func)
  self._enableTouch = true
  self._touchCallBack = func
end

function QTutorialStageArena:disableTouch()
  self._enableTouch = false
  self._touchCallBack = nil
end

function QTutorialStageArena:start()
  self:_createTouchNode()
  self._touchNode:setTouchEnabled(true)
  self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QTutorialStageArena._onTouch))
  QTutorialStageArena.super.start(self)
end

function QTutorialStageArena:ended() 
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

function QTutorialStageArena:_onTouch(event)
  if self._enableTouch == true and self._touchCallBack ~= nil then
    return self._touchCallBack(event)
    elseif event.name == "began" then
        return true
    end
end

return QTutorialStageArena
