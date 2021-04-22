--
-- Author: Your Name
-- Date: 2015-12-24 15:16:33
--
local QTutorialStage = import("..QTutorialStage")
local QTutorialStageAddHero = class("QTutorialStageAddHero", QTutorialStage)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("...ui.QUIViewController")
local QTutorialPhase01AddHero = import(".QTutorialPhase01AddHero")

function QTutorialStageAddHero:ctor()
	QTutorialStageAddHero.super.ctor(self)
    self._enableTouch = false
end

function QTutorialStageAddHero:_createTouchNode()
	local touchNode = CCNode:create()
    touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    touchNode:setTouchSwallowEnabled(true)
    app.tutorialNode:addChild(touchNode)
    self._touchNode = touchNode
end

function QTutorialStageAddHero:enableTouch(func)
	self._enableTouch = true
	self._touchCallBack = func
end

function QTutorialStageAddHero:disableTouch()
	self._enableTouch = false
	self._touchCallBack = nil
end

function QTutorialStageAddHero:_createPhases()
	table.insert(self._phases, QTutorialPhase01AddHero.new(self))

	self._phaseCount = table.nums(self._phases)
end

function QTutorialStageAddHero:start()
	self:_createTouchNode()
	self._touchNode:setTouchEnabled(true)
	self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QTutorialStageAddHero._onTouch))
	QTutorialStageAddHero.super.start(self)
end

function QTutorialStageAddHero:ended()
	if self._touchNode ~= nil then
		self._touchNode:setTouchEnabled( false )
		self._touchNode:removeFromParent()
		self._touchNode = nil
	end
end

function QTutorialStageAddHero:_onTouch(event)
	if self._enableTouch == true and self._touchCallBack ~= nil then
		return self._touchCallBack(event)
    elseif event.name == "began" then
        return true
    end
end

return QTutorialStageAddHero