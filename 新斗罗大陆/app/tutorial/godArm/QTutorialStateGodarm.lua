-- @Author: liaoxianbo
-- @Date:   2020-01-08 11:28:35
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-01-08 11:33:48

local QTutorialStage = import("..QTutorialStage")
local QTutorialStateGodarm = class("QTutorialStateGodarm", QTutorialStage)
local QTutorialPhase01Godarm = import(".QTutorialPhase01Godarm")

function QTutorialStateGodarm:ctor(options)
	QTutorialStateGodarm.super.ctor(self)
	self._enableTouch = false
end

function QTutorialStateGodarm:_createTouchNode()
  	local touchNode = CCNode:create()
    touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    touchNode:setTouchSwallowEnabled(true)
    app.tutorialNode:addChild(touchNode)
    self._touchNode = touchNode
end

function QTutorialStateGodarm:_createPhases()
    table.insert(self._phases, QTutorialPhase01Godarm.new(self))

    self._phaseCount = table.nums(self._phases)
end

function QTutorialStateGodarm:enableTouch(func)
    self._enableTouch = true
    self._touchCallBack = func
end

function QTutorialStateGodarm:disableTouch()
    self._enableTouch = false
    self._touchCallBack = nil
end

function QTutorialStateGodarm:start()
    self:_createTouchNode()
    self._touchNode:setTouchEnabled(true)
    self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QTutorialStateGodarm._onTouch))
    QTutorialStateGodarm.super.start(self)
end

function QTutorialStateGodarm:ended() 
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

function QTutorialStateGodarm:_onTouch(event)
    if self._enableTouch == true and self._touchCallBack ~= nil then
        return self._touchCallBack(event)
    elseif event.name == "began" then
        return true
    end
end

return QTutorialStateGodarm