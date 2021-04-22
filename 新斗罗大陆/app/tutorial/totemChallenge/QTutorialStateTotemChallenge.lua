-- @Author: xurui
-- @Date:   2020-01-03 17:57:58
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-03-27 12:07:50
local QTutorialStage = import("..QTutorialStage")
local QTutorialStateTotemChallenge = class("QTutorialStateTotemChallenge", QTutorialStage)
local QTutorialPhase01TotemChallenge = import(".QTutorialPhase01TotemChallenge")

function QTutorialStateTotemChallenge:ctor(options)
	QTutorialStateTotemChallenge.super.ctor(self)
	self._enableTouch = false
end

function QTutorialStateTotemChallenge:_createTouchNode()
  	local touchNode = CCNode:create()
    touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    touchNode:setTouchSwallowEnabled(true)
    app.tutorialNode:addChild(touchNode)
    self._touchNode = touchNode
end

function QTutorialStateTotemChallenge:_createPhases()
  table.insert(self._phases, QTutorialPhase01TotemChallenge.new(self))

  self._phaseCount = table.nums(self._phases)
end

function QTutorialStateTotemChallenge:enableTouch(func)
  self._enableTouch = true
  self._touchCallBack = func
end

function QTutorialStateTotemChallenge:disableTouch()
  self._enableTouch = false
  self._touchCallBack = nil
end

function QTutorialStateTotemChallenge:start()
  self:_createTouchNode()
  self._touchNode:setTouchEnabled(true)
  self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QTutorialStateTotemChallenge._onTouch))
  QTutorialStateTotemChallenge.super.start(self)
end

function QTutorialStateTotemChallenge:ended() 
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

function QTutorialStateTotemChallenge:_onTouch(event)
  if self._enableTouch == true and self._touchCallBack ~= nil then
    return self._touchCallBack(event)
    elseif event.name == "began" then
        return true
    end
end

return QTutorialStateTotemChallenge
