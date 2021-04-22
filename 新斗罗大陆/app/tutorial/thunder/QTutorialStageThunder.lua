--
-- Author: Kumo
-- Date: 2015-08-17 10:40:34
-- 杀戮之都引导
--
local QTutorialStage = import("..QTutorialStage")
local QTutorialStageThunder = class("QTutorialStageThunder", QTutorialStage)
local QTutorialPhase01Thunder = import(".QTutorialPhase01Thunder")

function QTutorialStageThunder:ctor(options)
  QTutorialStageThunder.super.ctor(self)
  self._enableTouch = false
end

function QTutorialStageThunder:_createTouchNode()
    local touchNode = CCNode:create()
    touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    touchNode:setTouchSwallowEnabled(true)
    app.tutorialNode:addChild(touchNode)
    self._touchNode = touchNode
end

function QTutorialStageThunder:_createPhases()
  table.insert(self._phases, QTutorialPhase01Thunder.new(self))

  self._phaseCount = table.nums(self._phases)
end

function QTutorialStageThunder:enableTouch(func)
  self._enableTouch = true
  self._touchCallBack = func
end

function QTutorialStageThunder:disableTouch()
  self._enableTouch = false
  self._touchCallBack = nil
end

function QTutorialStageThunder:start()
  self:_createTouchNode()
  self._touchNode:setTouchEnabled(true)
  self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QTutorialStageThunder._onTouch))
  QTutorialStageThunder.super.start(self)
end

function QTutorialStageThunder:ended() 
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

function QTutorialStageThunder:_onTouch(event)
  if self._enableTouch == true and self._touchCallBack ~= nil then
    return self._touchCallBack(event)
    elseif event.name == "began" then
        return true
    end
end

return QTutorialStageThunder
