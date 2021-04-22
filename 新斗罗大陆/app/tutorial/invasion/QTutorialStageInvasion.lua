--
-- Author: Kumo
-- Date: 2015-08-17 10:40:34
-- 魂收入侵引导
--
local QTutorialStage = import("..QTutorialStage")
local QTutorialStageInvasion = class("QTutorialStageInvasion", QTutorialStage)
local QTutorialPhase01Invasion = import(".QTutorialPhase01Invasion")

function QTutorialStageInvasion:ctor(options)
  QTutorialStageInvasion.super.ctor(self)
  self._enableTouch = false
end

function QTutorialStageInvasion:_createTouchNode()
    local touchNode = CCNode:create()
    touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    touchNode:setTouchSwallowEnabled(true)
    app.tutorialNode:addChild(touchNode)
    self._touchNode = touchNode
end

function QTutorialStageInvasion:_createPhases()
  table.insert(self._phases, QTutorialPhase01Invasion.new(self))

  self._phaseCount = table.nums(self._phases)
end

function QTutorialStageInvasion:enableTouch(func)
  self._enableTouch = true
  self._touchCallBack = func
end

function QTutorialStageInvasion:disableTouch()
  self._enableTouch = false
  self._touchCallBack = nil
end

function QTutorialStageInvasion:start()
  self:_createTouchNode()
  self._touchNode:setTouchEnabled(true)
  self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QTutorialStageInvasion._onTouch))
  QTutorialStageInvasion.super.start(self)
end

function QTutorialStageInvasion:ended() 
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

function QTutorialStageInvasion:_onTouch(event)
  if self._enableTouch == true and self._touchCallBack ~= nil then
    return self._touchCallBack(event)
    elseif event.name == "began" then
        return true
    end
end

return QTutorialStageInvasion
