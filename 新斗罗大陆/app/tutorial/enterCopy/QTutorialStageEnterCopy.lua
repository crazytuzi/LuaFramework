--
-- Author: Your Name
-- Date: 2016-06-12 16:48:20
--
--阵容和副本新手引导

local QTutorialStage = import("..QTutorialStage")
local QTutorialStageEnterCopy = class("QTutorialStageEnterCopy", QTutorialStage)

local QTutorialPhase01EnterCopy = import(".QTutorialPhase01EnterCopy")

function QTutorialStageEnterCopy:ctro()
  QTutorialStageEnterCopy.super.ctro(self)
  self._enableTouch = false
end

function QTutorialStageEnterCopy:_createTouchNode()
  local touchNode = CCNode:create()
  touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
  touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
  touchNode:setTouchSwallowEnabled(true)
  app.tutorialNode:addChild(touchNode)
  self._touchNode = touchNode
end

function QTutorialStageEnterCopy:enableTouch(func)
  self._enableTouch = true
  self._touchCallBack = func
end

function QTutorialStageEnterCopy:displayTouch()
  self._enableTouch = true
  self._touchCallBack = nil
end

function QTutorialStageEnterCopy:_createPhases()
  table.insert(self._phases, QTutorialPhase01EnterCopy.new(self))
  
  self._phaseCount = table.nums(self._phases)
end

function QTutorialStageEnterCopy:start()
  self:_createTouchNode()
  self._touchNode:setTouchEnabled(true)
  self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self._onTouch))
  QTutorialStageEnterCopy.super.start(self)
end

function QTutorialStageEnterCopy:ended()
    if self._touchNode ~= nil then
        self._touchNode:setTouchEnabled(false)
        self._touchNode:removeFromParent()
        self._touchNode = nil
    end
end

function QTutorialStageEnterCopy:_onTouch(event)
  if self._enableTouch == true and self._touchCallBack ~= nil then
    return self._touchCallBack(event)
  elseif event.name == "began" then
    return true
  end
end

return QTutorialStageEnterCopy