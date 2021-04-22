-- @Author: zxs
-- @Date:   2018-08-16 21:11:29
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-07-02 20:20:18
local QTutorialStage = import("..QTutorialStage")
local QTutorialStageBlackRock = class("QTutorialStageBlackRock", QTutorialStage)
local QTutorialPhase01BlackRock = import(".QTutorialPhase01BlackRock")

function QTutorialStageBlackRock:ctor(options)
	QTutorialStageBlackRock.super.ctor(self)
	self._enableTouch = false
end

function QTutorialStageBlackRock:_createTouchNode()
  	local touchNode = CCNode:create()
    touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    touchNode:setTouchSwallowEnabled(true)
    app.tutorialNode:addChild(touchNode)
    self._touchNode = touchNode
end

function QTutorialStageBlackRock:_createPhases()
    table.insert(self._phases, QTutorialPhase01BlackRock.new(self))

    self._phaseCount = table.nums(self._phases)
end

function QTutorialStageBlackRock:enableTouch(func)
    self._enableTouch = true
    self._touchCallBack = func
end

function QTutorialStageBlackRock:disableTouch()
    self._enableTouch = false
    self._touchCallBack = nil
end

function QTutorialStageBlackRock:start()
    self:_createTouchNode()
    self._touchNode:setTouchEnabled(true)
    self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QTutorialStageBlackRock._onTouch))
    QTutorialStageBlackRock.super.start(self)
end

function QTutorialStageBlackRock:ended() 
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

function QTutorialStageBlackRock:_onTouch(event)
    if self._enableTouch == true and self._touchCallBack ~= nil then
        return self._touchCallBack(event)
    elseif event.name == "began" then
        return true
    end
end

return QTutorialStageBlackRock
