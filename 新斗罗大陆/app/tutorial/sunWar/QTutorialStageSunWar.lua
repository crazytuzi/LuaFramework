--
-- Author: Kumo
-- Date: 2015-08-17 10:40:34
-- 海神岛引导
--
local QTutorialStage = import("..QTutorialStage")
local QTutorialStageSunWar = class("QTutorialStageSunWar", QTutorialStage)
local QTutorialPhase01SunWar = import(".QTutorialPhase01SunWar")

function QTutorialStageSunWar:ctor(options)
  QTutorialStageSunWar.super.ctor(self)
  self._enableTouch = false
end

function QTutorialStageSunWar:_createTouchNode()
    local touchNode = CCNode:create()
    touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    touchNode:setTouchSwallowEnabled(true)
    app.tutorialNode:addChild(touchNode)
    self._touchNode = touchNode
end

function QTutorialStageSunWar:_createPhases()
  table.insert(self._phases, QTutorialPhase01SunWar.new(self))

  self._phaseCount = table.nums(self._phases)
end

function QTutorialStageSunWar:enableTouch(func)
  self._enableTouch = true
  self._touchCallBack = func
end

function QTutorialStageSunWar:disableTouch()
  self._enableTouch = false
  self._touchCallBack = nil
end

function QTutorialStageSunWar:start()
  self:_createTouchNode()
  self._touchNode:setTouchEnabled(true)
  self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QTutorialStageSunWar._onTouch))
  QTutorialStageSunWar.super.start(self)
end

function QTutorialStageSunWar:ended() 
  if self._forceStop ~= true then
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    if page and page.buildLayer then
      page:buildLayer()
    end
    scheduler.performWithDelayGlobal(function()
      if page and page.checkGuiad then
        page:checkGuiad()
      end
    end,0)
  end
  if self._touchNode ~= nil then
    self._touchNode:setTouchEnabled( false )
    self._touchNode:removeFromParent()
    self._touchNode = nil
  end
end

function QTutorialStageSunWar:_onTouch(event)
  if self._enableTouch == true and self._touchCallBack ~= nil then
    return self._touchCallBack(event)
    elseif event.name == "began" then
        return true
    end
end

return QTutorialStageSunWar
