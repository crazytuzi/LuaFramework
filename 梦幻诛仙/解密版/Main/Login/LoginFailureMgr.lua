local Lplus = require("Lplus")
local LoginFailureMgr = Lplus.Class("LoginFailureMgr")
local LoginModule = Lplus.ForwardDeclare("LoginModule")
local def = LoginFailureMgr.define
local CHECK_OPEN = true
if Application.isEditor then
  CHECK_OPEN = false
end
def.const("number").MAX_CONTINUOUS_FAILUER_TIMES = 4
def.const("number").CONTINUOUS_FAILUER_DURATION = 45
def.const("number").FIRST_LOGIN_RESUME_TIME = 10
def.const("number").NORMAL_LOGIN_RESUME_TIME = 30
def.field("table").state = nil
def.field("number").timerId = 0
local instance
def.static("=>", LoginFailureMgr).Instance = function()
  if instance == nil then
    instance = LoginFailureMgr()
  end
  return instance
end
def.method().Init = function(self)
  self:LoadState()
end
def.method().InitState = function(self)
  self.state = {}
  self.state.failureTimes = {}
  self.state.loginResumeDuration = LoginFailureMgr.FIRST_LOGIN_RESUME_TIME
end
def.method().RecordLoginFailure = function(self)
  if LoginModule.Instance():IsInWorld() then
    return
  end
  local timestamp = os.time()
  table.insert(self.state.failureTimes, timestamp)
  if #self.state.failureTimes > LoginFailureMgr.MAX_CONTINUOUS_FAILUER_TIMES then
    table.remove(self.state.failureTimes, 1)
  end
end
def.method().ClearCurrentFailures = function(self)
  self.state.failureTimes = {}
end
def.method().ResetFailures = function(self)
  self:ClearCurrentFailures()
  self.state.loginResumeDuration = LoginFailureMgr.FIRST_LOGIN_RESUME_TIME
  self:SaveState()
end
def.method("=>", "boolean").IsFrequentlyLoginFailure = function(self)
  if CHECK_OPEN == false then
    return false
  end
  if LoginModule.Instance():IsInWorld() then
    return false
  end
  local count = #self.state.failureTimes
  if count < LoginFailureMgr.MAX_CONTINUOUS_FAILUER_TIMES then
    return false
  end
  local oldestTime = self.state.failureTimes[1]
  local newestTime = self.state.failureTimes[count]
  local interval = math.abs(newestTime - oldestTime)
  if interval > LoginFailureMgr.CONTINUOUS_FAILUER_DURATION then
    return false
  end
  local curTime = os.time()
  if newestTime > curTime then
    return false
  end
  if curTime - newestTime >= self.state.loginResumeDuration then
    return false
  end
  return true
end
def.method("=>", "boolean").FrequentlyLoginFailureDetected = function(self)
  if self:IsFrequentlyLoginFailure() then
    local count = #self.state.failureTimes
    local newestTime = self.state.failureTimes[count]
    local curTime = os.time()
    local duration = self.state.loginResumeDuration - (curTime - newestTime)
    if self.timerId == 0 then
      self.timerId = GameUtil.AddGlobalTimer(duration, true, function(...)
        self:ClearCurrentFailures()
        self.timerId = 0
        self.state.loginResumeDuration = LoginFailureMgr.NORMAL_LOGIN_RESUME_TIME
      end)
    end
    if duration < 1 then
      duration = 1
    end
    self:ShowLaterRetryConfirm(duration)
    self:SaveState()
    return true
  else
    return false
  end
end
def.method("number").ShowLaterRetryConfirm = function(self, seconds)
  local title = textRes.Login[57]
  local timeText = _G.SeondsToTimeText(seconds)
  local promoteText = string.format(textRes.Login[58], timeText)
  require("GUI.CommonConfirmDlg").ShowCerternConfirm(title, promoteText, "", function()
    Event.DispatchEvent(ModuleId.LOGIN, gmodule.notifyId.Login.RESET_UI, nil)
  end, {
    unique = LoginFailureMgr.ShowLaterRetryConfirm
  })
end
local KEY = "LoginFailureMgr_StateTable"
def.method().LoadState = function(self)
  local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
  if not LuaPlayerPrefs.HasGlobalKey(KEY) then
    self:InitState()
  else
    self.state = LuaPlayerPrefs.GetGlobalTable(KEY)
  end
end
def.method().SaveState = function(self)
  local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
  LuaPlayerPrefs.SetGlobalTable(KEY, self.state)
  LuaPlayerPrefs.Save()
end
return LoginFailureMgr.Commit()
