local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ActivityCountDown = Lplus.Extend(ECPanelBase, "ActivityCountDown")
local EC = require("Types.Vector3")
local def = ActivityCountDown.define
local instance
def.field("userdata")._timerInfo = nil
def.field("number")._timerID = -1
def.field("number")._leftTime = 0
def.field("string")._activityInfo = ""
def.field("function")._timerCallback = nil
def.static("=>", ActivityCountDown).Instance = function()
  if instance == nil then
    instance = ActivityCountDown()
  end
  return instance
end
def.method("string", "number").StartActivityTimer = function(self, activityInfo, second)
  self:StartActivityTimerWithCallback(activityInfo, second, nil)
end
def.method("string", "number", "function").StartActivityTimerWithCallback = function(self, activityInfo, second, callback)
  self._activityInfo = activityInfo
  self._leftTime = second
  self._timerCallback = callback
  if self._timerID == -1 then
    self:CreateTimer()
  end
end
def.method().CreateTimer = function(self)
  self:CreatePanel(RESPATH.PREFAB_UI_ACTIVITY_COUNTDOWN, 0)
  self._timerID = GameUtil.AddGlobalTimer(1, false, ActivityCountDown.UpdateTimer)
end
def.override().OnCreate = function(self)
  self._timerInfo = self.m_panel:FindDirect("Img_Bg/Label")
  self:SetDepth(GUIDEPTH.BOTTOMMOST)
  self:UpdateTimerInfo()
end
def.static().UpdateTimer = function()
  if instance ~= nil then
    instance._leftTime = instance._leftTime - 1
    if instance._timerInfo ~= nil then
      instance:UpdateTimerInfo()
    end
    if instance._leftTime <= 0 then
      instance:_TimerEnd()
      instance:StopTimer()
    end
  end
end
def.method().UpdateTimerInfo = function(self)
  local minutes = self._leftTime / 60
  local seconds = self._leftTime % 60
  local info = string.format(textRes.activity[341], self._activityInfo, minutes, seconds)
  self._timerInfo:GetComponent("UILabel"):set_text(info)
end
def.method()._TimerEnd = function(self)
  if self._timerCallback ~= nil then
    self._timerCallback()
  end
end
def.method().StopTimer = function(self)
  if self.m_panel ~= nil then
    self:DestroyPanel()
  end
end
def.override().OnDestroy = function(self)
  self:_ClearData()
end
def.method()._ClearData = function(self)
  GameUtil.RemoveGlobalTimer(self._timerID)
  self._timerID = -1
  self._timerInfo = nil
  self._activityInfo = ""
  self._timerCallback = nil
  self._leftTime = 0
end
def.method("number", "number").SetPositon = function(self, x, y)
  if self.m_panel ~= nil then
    self.m_panel.localPosition = EC.Vector3.new(x, y, 0)
  end
end
ActivityCountDown.Commit()
return ActivityCountDown
