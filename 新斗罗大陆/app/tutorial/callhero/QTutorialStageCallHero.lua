--
-- Author: xurui
-- Date: 2015-06-03 14:32:43
--
local QTutorialStage = import("..QTutorialStage")
local QTutorialStageCallHero = class("QTutorialStageCallHero", QTutorialStage)
local QTutorialPhase01CallHero = import(".QTutorialPhase01CallHero")

function QTutorialStageCallHero:ctor(options)
	QTutorialStageCallHero.super.ctor(self)
	self._enableTouch = false
end

function QTutorialStageCallHero:_createTouchNode()
	local touchNode = CCNode:create()
	touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
	touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
	touchNode:setTouchSwallowEnabled(true)
	app.tutorialNode:addChild(touchNode)
	self._touchNode = touchNode
end

function QTutorialStageCallHero:_createPhases()
	table.insert(self._phases, QTutorialPhase01CallHero.new(self))

	self._phaseCount = table.nums(self._phases)
end

function QTutorialStageCallHero:enableTouch(func)
	self._enableTouch = true
	self._touchCallBack = func
end

function QTutorialStageCallHero:disableTouch()
	self._enableTouch = false
	self._touchCallBack = nil
end

function QTutorialStageCallHero:start()
	self:_createTouchNode()
	self._touchNode:setTouchEnabled(true)
	self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QTutorialStageCallHero._onTouch))
	QTutorialStageCallHero.super.start(self)
end

function QTutorialStageCallHero:ended()
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

function QTutorialStageCallHero:_onTouch(event)
	if self._enableTouch == true and self._touchCallBack ~= nil then
		return self._touchCallBack(event)
	elseif event.name == "began" then
		return true
	end
end

return QTutorialStageCallHero
