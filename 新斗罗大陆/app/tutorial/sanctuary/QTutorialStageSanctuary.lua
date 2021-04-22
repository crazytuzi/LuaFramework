-- 
-- zxs
-- 全大陆精英赛引导
-- 

local QTutorialStage = import("..QTutorialStage")
local QTutorialStageSanctuary = class("QTutorialStageSanctuary", QTutorialStage)
local QTutorialPhase01Sanctuary = import(".QTutorialPhase01Sanctuary")

function QTutorialStageSanctuary:ctor(options)
	QTutorialStageSanctuary.super.ctor(self)
	self._enableTouch = false
end

function QTutorialStageSanctuary:_createTouchNode()
  	local touchNode = CCNode:create()
    touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    touchNode:setTouchSwallowEnabled(true)
    app.tutorialNode:addChild(touchNode)
    self._touchNode = touchNode
end

function QTutorialStageSanctuary:_createPhases()
    table.insert(self._phases, QTutorialPhase01Sanctuary.new(self))

    self._phaseCount = table.nums(self._phases)
end

function QTutorialStageSanctuary:enableTouch(func)
    self._enableTouch = true
    self._touchCallBack = func
end

function QTutorialStageSanctuary:disableTouch()
    self._enableTouch = false
    self._touchCallBack = nil
end

function QTutorialStageSanctuary:start()
    self:_createTouchNode()
    self._touchNode:setTouchEnabled(true)
    self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QTutorialStageSanctuary._onTouch))
    QTutorialStageSanctuary.super.start(self)
end

function QTutorialStageSanctuary:ended() 
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

function QTutorialStageSanctuary:_onTouch(event)
    if self._enableTouch == true and self._touchCallBack ~= nil then
        return self._touchCallBack(event)
    elseif event.name == "began" then
        return true
    end
end

return QTutorialStageSanctuary
