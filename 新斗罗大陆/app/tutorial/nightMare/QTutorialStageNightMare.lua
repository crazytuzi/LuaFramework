-- @Author: xurui
-- @Date:   2016-09-02 15:28:23
-- @Last Modified by:   xurui
-- @Last Modified time: 2016-09-02 17:22:46
local QTutorialStage = import("..QTutorialStage")
local QTutorialStageNightMare = class("QTutorialStageNightMare", QTutorialStage)
local QTutorialPhase01NightMare = import(".QTutorialPhase01NightMare")

function QTutorialStageNightMare:ctor(options)
	QTutorialStageNightMare.super.ctor(self)
	self._enableTouch = false
end

function QTutorialStageNightMare:_createTouchNode()
  	local touchNode = CCNode:create()
    touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    touchNode:setTouchSwallowEnabled(true)
    app.tutorialNode:addChild(touchNode)
    self._touchNode = touchNode
end

function QTutorialStageNightMare:_createPhases()
  table.insert(self._phases, QTutorialPhase01NightMare.new(self))

  self._phaseCount = table.nums(self._phases)
end

function QTutorialStageNightMare:enableTouch(func)
  self._enableTouch = true
  self._touchCallBack = func
end

function QTutorialStageNightMare:disableTouch()
  self._enableTouch = false
  self._touchCallBack = nil
end

function QTutorialStageNightMare:start()
  self:_createTouchNode()
  self._touchNode:setTouchEnabled(true)
  self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QTutorialStageNightMare._onTouch))
  QTutorialStageNightMare.super.start(self)
end

function QTutorialStageNightMare:ended() 
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

function QTutorialStageNightMare:_onTouch(event)
  if self._enableTouch == true and self._touchCallBack ~= nil then
    return self._touchCallBack(event)
    elseif event.name == "began" then
        return true
    end
end

return QTutorialStageNightMare