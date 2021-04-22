--魂师强化引导
local QTutorialStage = import("..QTutorialStage")
local QTutorialStageIntensify = class("QTutorialStageIntensify", QTutorialStage)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("...ui.QUIViewController")
local QTutorialPhase01Intensify = import(".QTutorialPhase01Intensify")

function QTutorialStageIntensify:ctor()
  QTutorialStageIntensify.super.ctor(self)
    self._enableTouch = false
end

function QTutorialStageIntensify:_createTouchNode()
  local touchNode = CCNode:create()
    touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    touchNode:setTouchSwallowEnabled(true)
    app.tutorialNode:addChild(touchNode)
    self._touchNode = touchNode
end

function QTutorialStageIntensify:enableTouch(func)
  self._enableTouch = true
  self._touchCallBack = func
end

function QTutorialStageIntensify:disableTouch()
  self._enableTouch = false
  self._touchCallBack = nil
end

function QTutorialStageIntensify:_createPhases()
  table.insert(self._phases, QTutorialPhase01Intensify.new(self))

  self._phaseCount = table.nums(self._phases)
end

function QTutorialStageIntensify:start()
  self:_createTouchNode()
  self._touchNode:setTouchEnabled(true)
  self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QTutorialStageIntensify._onTouch))
  QTutorialStageIntensify.super.start(self)
end

function QTutorialStageIntensify:ended()
  if self._forceStop ~= true then
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:buildLayer()
    scheduler.performWithDelayGlobal(function()
      page:checkGuiad()
    end,0)
  end
  if self._touchNode ~= nil then
    self._touchNode:setTouchEnabled(false)
    self._touchNode:removeFromParent()
    self._touchNode = nil
  end
end

function QTutorialStageIntensify:_onTouch(event)
  if self._enableTouch == true and self._touchCallBack ~= nil then
    return self._touchCallBack(event)
    elseif event.name == "began" then
        return true
    end
end

return QTutorialStageIntensify