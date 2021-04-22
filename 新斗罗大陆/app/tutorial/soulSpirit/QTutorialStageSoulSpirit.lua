--
-- zxs
-- 暗器引导
--
local QTutorialStage = import("..QTutorialStage")
local QTutorialStageSoulSpirit = class("QTutorialStageSoulSpirit", QTutorialStage)
local QTutorialPhase01SoulSpirit = import(".QTutorialPhase01SoulSpirit")

function QTutorialStageSoulSpirit:ctor(options)
	QTutorialStageSoulSpirit.super.ctor(self)
	self._enableTouch = false
end

function QTutorialStageSoulSpirit:_createTouchNode()
  	local touchNode = CCNode:create()
    touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    touchNode:setTouchSwallowEnabled(true)
    app.tutorialNode:addChild(touchNode)
    self._touchNode = touchNode
end

function QTutorialStageSoulSpirit:_createPhases()
    table.insert(self._phases, QTutorialPhase01SoulSpirit.new(self))

    self._phaseCount = table.nums(self._phases)
end

function QTutorialStageSoulSpirit:enableTouch(func)
    self._enableTouch = true
    self._touchCallBack = func
end

function QTutorialStageSoulSpirit:disableTouch()
    self._enableTouch = false
    self._touchCallBack = nil
end

function QTutorialStageSoulSpirit:start()
    self:_createTouchNode()
    self._touchNode:setTouchEnabled(true)
    self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QTutorialStageSoulSpirit._onTouch))
    QTutorialStageSoulSpirit.super.start(self)
end

function QTutorialStageSoulSpirit:ended() 
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

function QTutorialStageSoulSpirit:_onTouch(event)
    if self._enableTouch == true and self._touchCallBack ~= nil then
        return self._touchCallBack(event)
    elseif event.name == "began" then
        return true
    end
end

return QTutorialStageSoulSpirit

