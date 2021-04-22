--阵容和副本新手引导

local QTutorialStage = import("..QTutorialStage")
local QTutorialStageEquipmentEnchant = class("QTutorialStageEquipmentEnchant", QTutorialStage)

local QTutorialPhase01EquipmentEnchant = import(".QTutorialPhase01EquipmentEnchant")

function QTutorialStageEquipmentEnchant:ctro()
  QTutorialStageEquipmentEnchant.super.ctro(self)
  self._enableTouch = false
end

function QTutorialStageEquipmentEnchant:_createTouchNode()
  local touchNode = CCNode:create()
  touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
  touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
  touchNode:setTouchSwallowEnabled(true)
  app.tutorialNode:addChild(touchNode)
  self._touchNode = touchNode
end

function QTutorialStageEquipmentEnchant:enableTouch(func)
  self._enableTouch = true
  self._touchCallBack = func
end

function QTutorialStageEquipmentEnchant:displayTouch()
  self._enableTouch = true
  self._touchCallBack = nil
end

function QTutorialStageEquipmentEnchant:_createPhases()
  table.insert(self._phases, QTutorialPhase01EquipmentEnchant.new(self))
  
  self._phaseCount = table.nums(self._phases)
end

function QTutorialStageEquipmentEnchant:start()
  self:_createTouchNode()
  self._touchNode:setTouchEnabled(true)
  self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self._onTouch))
  QTutorialStageEquipmentEnchant.super.start(self)
end

function QTutorialStageEquipmentEnchant:ended()
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

function QTutorialStageEquipmentEnchant:_onTouch(event)
  if self._enableTouch == true and self._touchCallBack ~= nil then
    return self._touchCallBack(event)
  elseif event.name == "began" then
    return true
  end
end

return QTutorialStageEquipmentEnchant