local QTutorialStage = import("..QTutorialStage")
local QTutorialStageSkill = class("QTutorialStageSkill", QTutorialStage)

local QTutorialPhase01InSkill = import(".QTutorialPhase01Skill")

function QTutorialStageSkill:ctor()
  QTutorialStageSkill.super.ctor(self)
    self._enableTouch = false
end

function QTutorialStageSkill:_createTouchNode()
  local touchNode = CCNode:create()
    touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    touchNode:setTouchSwallowEnabled(true)
    app.tutorialNode:addChild(touchNode)
    self._touchNode = touchNode
end

function QTutorialStageSkill:enableTouch(func)
  self._enableTouch = true
  self._touchCallBack = func
end

function QTutorialStageSkill:disableTouch()
  self._enableTouch = false
  self._touchCallBack = nil
end

function QTutorialStageSkill:_createPhases()
  table.insert(self._phases, QTutorialPhase01InSkill.new(self))

  self._phaseCount = table.nums(self._phases)
end

function QTutorialStageSkill:start()
  self:_createTouchNode()
  self._touchNode:setTouchEnabled(true)
  self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QTutorialStageSkill._onTouch))
  QTutorialStageSkill.super.start(self)
end

function QTutorialStageSkill:ended()
    if self._forceStop == false then
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

function QTutorialStageSkill:_onTouch(event)
  if self._enableTouch == true and self._touchCallBack ~= nil then
    return self._touchCallBack(event)
    elseif event.name == "began" then
        return true
    end
end

return QTutorialStageSkill