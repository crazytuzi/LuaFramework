--
-- Author: wkwang
-- 阵容&副本引导
-- Date: 2014-08-11 11:04:15
--
local QTutorialStage = import("..QTutorialStage")
local QTutorialStageTeamAndDungeon = class("QTutorialStageTeamAndDungeon", QTutorialStage)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("...ui.QUIViewController")
local QTutorialPhase01InTeamAndDungeon = import(".QTutorialPhase01InTeamAndDungeon")

function QTutorialStageTeamAndDungeon:ctor()
	QTutorialStageTeamAndDungeon.super.ctor(self)
    self._enableTouch = false
end

function QTutorialStageTeamAndDungeon:_createTouchNode()
	local touchNode = CCNode:create()
    touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    touchNode:setTouchSwallowEnabled(true)
    app.tutorialNode:addChild(touchNode)
    self._touchNode = touchNode
end

function QTutorialStageTeamAndDungeon:enableTouch(func)
	self._enableTouch = true
	self._touchCallBack = func
end

function QTutorialStageTeamAndDungeon:disableTouch()
	self._enableTouch = false
	self._touchCallBack = nil
end

function QTutorialStageTeamAndDungeon:_createPhases()
	table.insert(self._phases, QTutorialPhase01InTeamAndDungeon.new(self))

	self._phaseCount = table.nums(self._phases)
end

function QTutorialStageTeamAndDungeon:start()
	self:_createTouchNode()
	self._touchNode:setTouchEnabled(true)
	self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QTutorialStageTeamAndDungeon._onTouch))
	QTutorialStageTeamAndDungeon.super.start(self)
end

function QTutorialStageTeamAndDungeon:ended()
	if self._touchNode ~= nil then
		self._touchNode:setTouchEnabled( false )
		self._touchNode:removeFromParent()
		self._touchNode = nil
	end
end

function QTutorialStageTeamAndDungeon:_onTouch(event)
	if self._enableTouch == true and self._touchCallBack ~= nil then
		return self._touchCallBack(event)
    elseif event.name == "began" then
        return true
    end
end

return QTutorialStageTeamAndDungeon