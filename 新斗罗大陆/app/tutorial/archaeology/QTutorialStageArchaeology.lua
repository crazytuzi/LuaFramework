--
-- Author: xurui
-- Date: 2015-09-11 17:35:06
--
local QTutorialStage = import("..QTutorialStage")
local QTutorialStageArchaeology = class("QTutorialStageArchaeology", QTutorialStage)
local QTutorialPhase01Archaeology = import(".QTutorialPhase01Archaeology")

function QTutorialStageArchaeology:ctor(options)
	QTutorialStageArchaeology.super.ctor(self)
	self._enableTouch = false
end

function QTutorialStageArchaeology:_createTouchNode()
  	local touchNode = CCNode:create()
    touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    touchNode:setTouchSwallowEnabled(true)
    app.tutorialNode:addChild(touchNode)
    self._touchNode = touchNode
end

function QTutorialStageArchaeology:_createPhases()
  table.insert(self._phases, QTutorialPhase01Archaeology.new(self))

  self._phaseCount = table.nums(self._phases)
end

function QTutorialStageArchaeology:enableTouch(func)
  self._enableTouch = true
  self._touchCallBack = func
end

function QTutorialStageArchaeology:disableTouch()
  self._enableTouch = false
  self._touchCallBack = nil
end

function QTutorialStageArchaeology:start()
  self:_createTouchNode()
  self._touchNode:setTouchEnabled(true)
  self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QTutorialStageArchaeology._onTouch))
  QTutorialStageArchaeology.super.start(self)
end

function QTutorialStageArchaeology:ended() 
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

function QTutorialStageArchaeology:_onTouch(event)
  if self._enableTouch == true and self._touchCallBack ~= nil then
    return self._touchCallBack(event)
    elseif event.name == "began" then
        return true
    end
end

return QTutorialStageArchaeology
