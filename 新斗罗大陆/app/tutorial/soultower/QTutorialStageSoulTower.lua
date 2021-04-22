-- @Author: zxs
-- @Date:   2018-08-16 21:11:29
-- @Last Modified by:   DELL
-- @Last Modified time: 2020-04-16 19:02:03
local QTutorialStage = import("..QTutorialStage")
local QTutorialStageSoulTower = class("QTutorialStageSoulTower", QTutorialStage)
local QTutorialPhase01SoulTower = import(".QTutorialPhase01SoulTower")

function QTutorialStageSoulTower:ctor(options)
	QTutorialStageSoulTower.super.ctor(self)
	self._enableTouch = false
end

function QTutorialStageSoulTower:_createTouchNode()
  	local touchNode = CCNode:create()
    touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    touchNode:setTouchSwallowEnabled(true)
    app.tutorialNode:addChild(touchNode)
    self._touchNode = touchNode
end

function QTutorialStageSoulTower:_createPhases()
    table.insert(self._phases, QTutorialPhase01SoulTower.new(self))

    self._phaseCount = table.nums(self._phases)
end

function QTutorialStageSoulTower:enableTouch(func)
    self._enableTouch = true
    self._touchCallBack = func
end

function QTutorialStageSoulTower:disableTouch()
    self._enableTouch = false
    self._touchCallBack = nil
end

function QTutorialStageSoulTower:start()
    self:_createTouchNode()
    self._touchNode:setTouchEnabled(true)
    self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QTutorialStageSoulTower._onTouch))
    QTutorialStageSoulTower.super.start(self)
end

function QTutorialStageSoulTower:ended() 
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

function QTutorialStageSoulTower:_onTouch(event)
    if self._enableTouch == true and self._touchCallBack ~= nil then
        return self._touchCallBack(event)
    elseif event.name == "began" then
        return true
    end
end

return QTutorialStageSoulTower
