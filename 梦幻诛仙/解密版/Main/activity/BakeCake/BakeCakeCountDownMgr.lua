local MODULE_NAME = (...)
local Lplus = require("Lplus")
local BakeCakeCountDownMgr = Lplus.Class(MODULE_NAME)
local def = BakeCakeCountDownMgr.define
local BakeCakeTip = require("Main.activity.BakeCake.ui.BakeCakeTip")
local instance
def.static("=>", BakeCakeCountDownMgr).Instance = function()
  if instance == nil then
    instance = BakeCakeCountDownMgr()
    instance:Init()
  end
  return instance
end
def.field("number").m_timerId = 0
def.field("number").m_endTime = 0
def.method().Init = function(self)
end
def.method("number").StartCountDown = function(self, endTime)
  self.m_endTime = endTime
  BakeCakeTip.Instance():ShowPanel("")
  self:RemoveCountDownTimer()
  self.m_timerId = GameUtil.AddGlobalTimer(1, false, function()
    self:UpdateCountDown()
  end)
  self:UpdateCountDown()
  Event.RegisterEventWithContext(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, BakeCakeCountDownMgr.OnLeaveWorld, self)
end
def.method().EndCountDown = function(self)
  Event.UnregisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, BakeCakeCountDownMgr.OnLeaveWorld)
  BakeCakeTip.Instance():DestroyPanel()
  self:RemoveCountDownTimer()
end
def.method().UpdateCountDown = function(self)
  local curTime = _G.GetServerTime()
  local leftSeconds = self.m_endTime - curTime
  if leftSeconds < 0 then
    self:EndCountDown()
  end
  local timeText = _G.SeondsToTimeText(leftSeconds)
  local content = textRes.BakeCake[4]:format(timeText)
  BakeCakeTip.Instance():SetContent(content)
end
def.method().RemoveCountDownTimer = function(self)
  if self.m_timerId ~= 0 then
    GameUtil.RemoveGlobalTimer(self.m_timerId)
  end
  self.m_timerId = 0
end
def.method("table").OnLeaveWorld = function(self, params)
  self:RemoveCountDownTimer()
  self.m_endTime = 0
end
return BakeCakeCountDownMgr.Commit()
