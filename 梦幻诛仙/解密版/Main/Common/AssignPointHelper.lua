local Lplus = require("Lplus")
local AssignPointHelper = Lplus.Class("AssignPointHelper")
local def = AssignPointHelper.define
def.const("table").PressedButtonType = {
  Inc = 1,
  Dec = 2,
  Other = 3
}
def.const("number").LONG_PRESS_CRITICAL_TIME = 0.5
def.const("number").LONG_PRESS_INTERVAL_TIME = 0.06
def.const("number").CONTINUALLY_CLICK_INTERVAL_TIME = 1.5
def.const("number").CONTINUALLY_CLICK_MAX_TIMES = 5
def.field("number").pressedButtonType = 0
def.field("string").pressedButtonId = ""
def.field("number").pressedTime = 0
def.field("number").pressedActTime = 0
def.field("string").lastClickedButtonId = ""
def.field("number").lastClickButtonTime = 0
def.field("number").continuallyClickTimes = 0
def.field("table").functionMap = nil
local instance
def.static("=>", AssignPointHelper).Instance = function()
  if instance == nil then
    instance = AssignPointHelper()
  end
  return instance
end
def.method("table").RegisterCallbackFuncs = function(self, funcs)
  self.functionMap = funcs or {}
end
def.method("string", "number", "boolean").TogglePressedButtonTimer = function(self, id, type, state)
  self.pressedButtonType = type
  if self.pressedButtonType == AssignPointHelper.PressedButtonType.Other then
    return
  end
  if state == true then
    self.pressedButtonId = id
    self.pressedTime = 0
    self.pressedActTime = 0
    Timer:RegisterIrregularTimeListener(self.PressedButtonTimer, self)
  else
    self:StopPressTimer()
  end
end
def.method("number").PressedButtonTimer = function(self, dt)
  self.pressedTime = self.pressedTime + dt
  if self.pressedTime < AssignPointHelper.LONG_PRESS_CRITICAL_TIME then
    return
  end
  local interval = AssignPointHelper.LONG_PRESS_INTERVAL_TIME
  self.pressedActTime = self.pressedActTime + dt
  if interval <= self.pressedActTime then
    self:OnButtonCalled(self.pressedButtonId, self.pressedButtonType)
    self.pressedActTime = self.pressedActTime - interval
  end
end
def.method().StopPressTimer = function(self)
  Timer:RemoveIrregularTimeListener(self.PressedButtonTimer)
  self.pressedTime = 0
  self.pressedActTime = 0
end
def.method("string").OnButtonClick = function(self, id)
  if self.lastClickedButtonId ~= id then
    self:ResetContinuallyClickState()
    self.lastClickedButtonId = id
    self.lastClickButtonTime = GameUtil.GetTickCount()
  else
    local curTime = GameUtil.GetTickCount()
    local interval = curTime - self.lastClickButtonTime
    interval = interval / 1000
    if interval < AssignPointHelper.CONTINUALLY_CLICK_INTERVAL_TIME then
      self:IncContinuallyClick()
    else
      self:ResetContinuallyClickState()
    end
    self.lastClickButtonTime = curTime
  end
end
def.method().ResetContinuallyClickState = function(self)
  self.continuallyClickTimes = 0
end
def.method().IncContinuallyClick = function(self)
  self.continuallyClickTimes = self.continuallyClickTimes + 1
  if self.continuallyClickTimes >= AssignPointHelper.CONTINUALLY_CLICK_MAX_TIMES then
    self:OnContinuallyClick(self.lastClickedButtonId)
    self:ResetContinuallyClickState()
  end
end
def.method("string").OnContinuallyClick = function(self, id)
  local func = self.functionMap.OnContinuallyClick
  if func then
    func(id)
  end
end
def.method("string", "number").OnButtonCalled = function(self, id, type)
  local func = self.functionMap.OnButtonCalled
  if func then
    func(id, type)
  end
end
return AssignPointHelper.Commit()
