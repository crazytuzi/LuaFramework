--阵容和副本新手引导

local QTutorialStage = import("..QTutorialStage")
local QTutorialStageEquipment = class("QTutorialStageEquipment", QTutorialStage)

local QTutorialPhase01Equipment = import(".QTutorialPhase01Equipment")

function QTutorialStageEquipment:ctro()
  QTutorialStageEquipment.super.ctro(self)
  self._enableTouch = false
end

function QTutorialStageEquipment:_createTouchNode()
  local touchNode = CCNode:create()
  touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
  touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
  touchNode:setTouchSwallowEnabled(true)
  app.tutorialNode:addChild(touchNode)
  self._touchNode = touchNode
end

function QTutorialStageEquipment:enableTouch(func)
  self._enableTouch = true
  self._touchCallBack = func
end

function QTutorialStageEquipment:displayTouch()
  self._enableTouch = true
  self._touchCallBack = nil
end

function QTutorialStageEquipment:_createPhases()
  table.insert(self._phases, QTutorialPhase01Equipment.new(self))
  
  self._phaseCount = table.nums(self._phases)
end

function QTutorialStageEquipment:start()
  self:_createTouchNode()
  self._touchNode:setTouchEnabled(true)
  self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self._onTouch))
  QTutorialStageEquipment.super.start(self)
end

function QTutorialStageEquipment:ended()
    if self._forceStop == false then
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

function QTutorialStageEquipment:_onTouch(event)
  if self._enableTouch == true and self._touchCallBack ~= nil then
    return self._touchCallBack(event)
  elseif event.name == "began" then
    return true
  end
end

return QTutorialStageEquipment