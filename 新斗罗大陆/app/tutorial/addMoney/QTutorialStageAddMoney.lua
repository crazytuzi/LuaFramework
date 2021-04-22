--
-- Author: Your Name
-- Date: 2015-08-31 14:37:38
--
local QTutorialStage = import("..QTutorialStage")
local QTutorialStageAddMoney = class("QTutorialStageAddMoney", QTutorialStage)
local QTutorialPhase01AddMoney = import(".QTutorialPhase01AddMoney")

function QTutorialStageAddMoney:ctor(options)
	QTutorialStageAddMoney.super.ctor(self)
	self._enableTouch = false
end

function QTutorialStageAddMoney:_createTouchNode()
  	local touchNode = CCNode:create()
    touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    touchNode:setTouchSwallowEnabled(true)
    app.tutorialNode:addChild(touchNode)
    self._touchNode = touchNode
end

function QTutorialStageAddMoney:_createPhases()
  table.insert(self._phases, QTutorialPhase01AddMoney.new(self))

  self._phaseCount = table.nums(self._phases)
end

function QTutorialStageAddMoney:enableTouch(func)
  self._enableTouch = true
  self._touchCallBack = func
end

function QTutorialStageAddMoney:disableTouch()
  self._enableTouch = false
  self._touchCallBack = nil
end

function QTutorialStageAddMoney:start()
  self:_createTouchNode()
  self._touchNode:setTouchEnabled(true)
  self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QTutorialStageAddMoney._onTouch))
  QTutorialStageAddMoney.super.start(self)
end

function QTutorialStageAddMoney:ended() 
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

function QTutorialStageAddMoney:_onTouch(event)
  if self._enableTouch == true and self._touchCallBack ~= nil then
    return self._touchCallBack(event)
    elseif event.name == "began" then
        return true
    end
end

return QTutorialStageAddMoney
