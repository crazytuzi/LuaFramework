--
-- Author: Kumo
-- Date: 2015-08-17 10:40:34
-- 大魂师赛引导
--
local QTutorialStage = import("..QTutorialStage")
local QTutorialStageGloryTower = class("QTutorialStageGloryTower", QTutorialStage)
local QTutorialPhase01GloryTower = import(".QTutorialPhase01GloryTower")

function QTutorialStageGloryTower:ctor(options)
  QTutorialStageGloryTower.super.ctor(self)
  self._enableTouch = false
end

function QTutorialStageGloryTower:_createTouchNode()
    local touchNode = CCNode:create()
    touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    touchNode:setTouchSwallowEnabled(true)
    app.tutorialNode:addChild(touchNode)
    self._touchNode = touchNode
end

function QTutorialStageGloryTower:_createPhases()
  table.insert(self._phases, QTutorialPhase01GloryTower.new(self))

  self._phaseCount = table.nums(self._phases)
end

function QTutorialStageGloryTower:enableTouch(func)
  self._enableTouch = true
  self._touchCallBack = func
end

function QTutorialStageGloryTower:disableTouch()
  self._enableTouch = false
  self._touchCallBack = nil
end

function QTutorialStageGloryTower:start()
  self:_createTouchNode()
  self._touchNode:setTouchEnabled(true)
  self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QTutorialStageGloryTower._onTouch))
  QTutorialStageGloryTower.super.start(self)
end

function QTutorialStageGloryTower:ended() 
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

function QTutorialStageGloryTower:_onTouch(event)
  if self._enableTouch == true and self._touchCallBack ~= nil then
    return self._touchCallBack(event)
    elseif event.name == "began" then
        return true
    end
end

return QTutorialStageGloryTower
