-- 
-- Kumo.Wang
-- 西尔维斯大斗魂场引导
--

local QTutorialStage = import("..QTutorialStage")
local QTutorialStateSilvesArenaPeak = class("QTutorialStateSilvesArenaPeak", QTutorialStage)
local QTutorialPhase01SilvesArenaPeak = import(".QTutorialPhase01SilvesArenaPeak")

function QTutorialStateSilvesArenaPeak:ctor(options)
	QTutorialStateSilvesArenaPeak.super.ctor(self)
	self._enableTouch = false
end

function QTutorialStateSilvesArenaPeak:_createTouchNode()
  	local touchNode = CCNode:create()
    touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    touchNode:setTouchSwallowEnabled(true)
    app.tutorialNode:addChild(touchNode)
    self._touchNode = touchNode
end

function QTutorialStateSilvesArenaPeak:_createPhases()
  table.insert(self._phases, QTutorialPhase01SilvesArenaPeak.new(self))

  self._phaseCount = table.nums(self._phases)
end

function QTutorialStateSilvesArenaPeak:enableTouch(func)
  self._enableTouch = true
  self._touchCallBack = func
end

function QTutorialStateSilvesArenaPeak:disableTouch()
  self._enableTouch = false
  self._touchCallBack = nil
end

function QTutorialStateSilvesArenaPeak:start()
  self:_createTouchNode()
  self._touchNode:setTouchEnabled(true)
  self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QTutorialStateSilvesArenaPeak._onTouch))
  QTutorialStateSilvesArenaPeak.super.start(self)
end

function QTutorialStateSilvesArenaPeak:ended() 
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

function QTutorialStateSilvesArenaPeak:_onTouch(event)
  if self._enableTouch == true and self._touchCallBack ~= nil then
    return self._touchCallBack(event)
    elseif event.name == "began" then
        return true
    end
end

return QTutorialStateSilvesArenaPeak
