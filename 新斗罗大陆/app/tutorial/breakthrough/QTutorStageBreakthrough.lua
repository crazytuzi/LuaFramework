--
-- Author: Your Name
-- Date: 2014-08-13 16:11:29
--
local QTutorialStage = import("..QTutorialStage")
local QTutorStageBreakthrough = class("QTutorStageBreakthrough", QTutorialStage)

local QTutorialPhase01InBreakthrough = import(".QTutorialPhase01InBreakthrough")
local QTutorialPhase02InBreakthrough = import(".QTutorialPhase02InBreakthrough")

function QTutorStageBreakthrough:ctor()
	QTutorStageBreakthrough.super.ctor(self)
    self._enableTouch = false
end

function QTutorStageBreakthrough:_createTouchNode()
	local touchNode = CCNode:create()
    touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    touchNode:setTouchSwallowEnabled(true)
    app.tutorialNode:addChild(touchNode)
    self._touchNode = touchNode
end

function QTutorStageBreakthrough:enableTouch(func)
	self._enableTouch = true
	self._touchCallBack = func
end

function QTutorStageBreakthrough:disableTouch()
	self._enableTouch = false
	self._touchCallBack = nil
end

function QTutorStageBreakthrough:_createPhases()
	table.insert(self._phases, QTutorialPhase01InBreakthrough.new(self))
  table.insert(self._phases, QTutorialPhase02InBreakthrough.new(self))

	self._phaseCount = table.nums(self._phases)
end

function QTutorStageBreakthrough:start()
	self:_createTouchNode()
	self._touchNode:setTouchEnabled(true)
	self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QTutorStageBreakthrough._onTouch))
	QTutorStageBreakthrough.super.start(self)
end

function QTutorStageBreakthrough:ended()	
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

function QTutorStageBreakthrough:_onTouch(event)
	if self._enableTouch == true and self._touchCallBack ~= nil then
		return self._touchCallBack(event)
    elseif event.name == "began" then
        return true
    end
end

return QTutorStageBreakthrough