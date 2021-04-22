--
-- Author: xurui
-- 宝箱新手引导
-- Date: 2014-08-20 18:34:17
--
local QTutorialStage = import("..QTutorialStage")
local QTutorialStageTreasure = class("QTutorialStageTreasure", QTutorialStage)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("...ui.QUIViewController")
local QTutorialPhase01InTreasure = import(".QTutorialPhase01InTreasure")

function QTutorialStageTreasure:ctor()
	QTutorialStageTreasure.super.ctor(self)
	self._enableTouch = false
end

function QTutorialStageTreasure:_createTouchNode()
	local touchNode = CCNode:create()
	touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
	touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
	touchNode:setTouchSwallowEnabled(true)
	-- local layer = CCLayerColor:create(ccc4(0, 0, 0, 255), display.width, display.height)
	-- app.tutorialNode:addChild(layer)
	app.tutorialNode:addChild(touchNode)

	self._touchNode = touchNode
end

function QTutorialStageTreasure:enableTouch(func)
	self._enableTouch = true
	self._touchCallBack = func
end

function QTutorialStageTreasure:disableTouch()
	self._enableTouch = false
	self._touchCallBack = nil
end

function QTutorialStageTreasure:_createPhases()
	table.insert(self._phases, QTutorialPhase01InTreasure.new(self))

	self._phaseCount = table.nums(self._phases)
end

function QTutorialStageTreasure:start()
	self:_createTouchNode()
	self._touchNode:setTouchEnabled(true)
	self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QTutorialStageTreasure._onTouch))
	QTutorialStageTreasure.super.start(self)
end

function QTutorialStageTreasure:ended()
	if self._forceStop == false then
        local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
        page:buildLayer()
        scheduler.performWithDelayGlobal(function()
          page:checkGuiad()
        end,0)
    end
	if self._touchNode ~= nil then
		self._touchNode:setTouchEnabled(false)
		self._touchNode:removeFromParent()
		self._touchNode = nil
	end
end

function QTutorialStageTreasure:_onTouch(event)
	if self._enableTouch == true and self._touchCallBack ~= nil then
		return self._touchCallBack(event)
	elseif event.name == "began" then
		return true
	end
end

return QTutorialStageTreasure
