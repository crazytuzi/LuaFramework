--
-- Kumo.Wang
-- 新版魂师图鉴引导
--

local QTutorialStage = import("..QTutorialStage")
local QTutorialStageHandbook = class("QTutorialStageHandbook", QTutorialStage)
local QTutorialPhase01Handbook = import(".QTutorialPhase01Handbook")

function QTutorialStageHandbook:ctor(options)
	QTutorialStageHandbook.super.ctor(self)
	self._enableTouch = false
end

function QTutorialStageHandbook:_createTouchNode()
  	local touchNode = CCNode:create()
    touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    touchNode:setTouchSwallowEnabled(true)
    app.tutorialNode:addChild(touchNode)
    self._touchNode = touchNode
end

function QTutorialStageHandbook:_createPhases()
  table.insert(self._phases, QTutorialPhase01Handbook.new(self))

  self._phaseCount = table.nums(self._phases)
end

function QTutorialStageHandbook:enableTouch(func)
  self._enableTouch = true
  self._touchCallBack = func
end

function QTutorialStageHandbook:disableTouch()
  self._enableTouch = false
  self._touchCallBack = nil
end

function QTutorialStageHandbook:start()
  self:_createTouchNode()
  self._touchNode:setTouchEnabled(true)
  self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QTutorialStageHandbook._onTouch))
  QTutorialStageHandbook.super.start(self)
end

function QTutorialStageHandbook:ended() 
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

function QTutorialStageHandbook:_onTouch(event)
  if self._enableTouch == true and self._touchCallBack ~= nil then
    return self._touchCallBack(event)
    elseif event.name == "began" then
        return true
    end
end

return QTutorialStageHandbook
