-- @Author: xurui
-- @Date:   2019-03-27 14:53:30
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-03-27 15:39:48
local QTutorialStage = import("..QTutorialStage")
local QTutorialStageMaritime = class("QTutorialStageMaritime", QTutorialStage)
local QTutorialPhase01Maritime = import(".QTutorialPhase01Maritime")

function QTutorialStageMaritime:ctor(options)
	QTutorialStageMaritime.super.ctor(self)
	self._enableTouch = false
end

function QTutorialStageMaritime:_createTouchNode()
  	local touchNode = CCNode:create()
    touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    touchNode:setTouchSwallowEnabled(true)
    app.tutorialNode:addChild(touchNode)
    self._touchNode = touchNode
end

function QTutorialStageMaritime:_createPhases()
  table.insert(self._phases, QTutorialPhase01Maritime.new(self))

  self._phaseCount = table.nums(self._phases)
end

function QTutorialStageMaritime:enableTouch(func)
  self._enableTouch = true
  self._touchCallBack = func
end

function QTutorialStageMaritime:disableTouch()
  self._enableTouch = false
  self._touchCallBack = nil
end

function QTutorialStageMaritime:start()
  self:_createTouchNode()
  self._touchNode:setTouchEnabled(true)
  self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QTutorialStageMaritime._onTouch))
  QTutorialStageMaritime.super.start(self)
end

function QTutorialStageMaritime:ended() 
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

function QTutorialStageMaritime:_onTouch(event)
  if self._enableTouch == true and self._touchCallBack ~= nil then
    return self._touchCallBack(event)
    elseif event.name == "began" then
        return true
    end
end

return QTutorialStageMaritime
