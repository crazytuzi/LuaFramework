local Lplus = require("Lplus")
local AagrData = require("Main.Aagr.data.AagrData")
local GUIFxMan = require("Fx.GUIFxMan")
local ArenaCountdownMgr = Lplus.Class("ArenaCountdownMgr")
local def = ArenaCountdownMgr.define
local instance
def.static("=>", ArenaCountdownMgr).Instance = function()
  if instance == nil then
    instance = ArenaCountdownMgr()
  end
  return instance
end
def.field("function")._callback = nil
def.field("number")._effectId = 0
def.field("userdata")._effect = nil
def.const("number").MIN_COUNTDOWN = 0
def.method("boolean").OnOpenChange = function(self, bOpen)
  self:HandleEventListeners(bOpen)
  if not bOpen then
    self:Clear()
  end
end
def.method("boolean").HandleEventListeners = function(self, bRigister)
  if bRigister then
    Event.RegisterEventWithContext(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, ArenaCountdownMgr.OnLeaveWorld, self)
    Event.RegisterEventWithContext(ModuleId.AAGR, gmodule.notifyId.Aagr.AAGR_ENTER_ARENA, ArenaCountdownMgr.OnEnterArenaMap, self)
    Event.RegisterEventWithContext(ModuleId.AAGR, gmodule.notifyId.Aagr.AAGR_LEAVE_ARENA, ArenaCountdownMgr.OnLeaveArenaMap, self)
  else
    Event.UnregisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, ArenaCountdownMgr.OnLeaveWorld)
    Event.UnregisterEvent(ModuleId.AAGR, gmodule.notifyId.Aagr.AAGR_ENTER_ARENA, ArenaCountdownMgr.OnEnterArenaMap)
    Event.UnregisterEvent(ModuleId.AAGR, gmodule.notifyId.Aagr.AAGR_LEAVE_ARENA, ArenaCountdownMgr.OnLeaveArenaMap)
  end
end
def.method("table").OnLeaveWorld = function(self, params)
  self:Clear()
end
def.method("table").OnEnterArenaMap = function(self, params)
  self:TryShow(nil)
end
def.method("table").OnLeaveArenaMap = function(self, params)
  self:Clear()
end
def.method().OnSSyncGameStatus = function(self)
  self:TryShow(nil)
end
def.method("function").TryShow = function(self, callback)
  if not AagrData.Instance():IsInArena() then
    warn("[ERROR][ArenaCountdownMgr:TryShow] show fail! not in arena!")
    return
  end
  local arenaInfo = AagrData.Instance():GetArenaInfo()
  if nil == arenaInfo then
    warn("[ERROR][ArenaCountdownMgr:TryShow] show fail, arenaInfo nil!")
    return
  end
  local countdown = self:GetCountdown()
  if countdown <= ArenaCountdownMgr.MIN_COUNTDOWN then
    warn("[ERROR][ArenaCountdownMgr:TryShow] show fail, countdown =", countdown)
    return
  end
  self:_DoShow(countdown, callback)
end
def.method("number", "function")._DoShow = function(self, countdown, callback)
  warn("[ArenaCountdownMgr:_DoShow] show count down panel, countdown:", countdown)
  self:Clear()
  local AagrStartPanel = require("Main.Aagr.ui.AagrStartPanel")
  if not AagrStartPanel.Instance():IsShow() then
    AagrStartPanel.ShowPanel(countdown)
  end
end
def.method("=>", "number").GetCountdown = function(self)
  local arenaInfo = AagrData.Instance():GetArenaInfo()
  if arenaInfo then
    local countdown = arenaInfo.startTime - _G.GetServerTime()
    countdown = math.max(countdown, 0)
    return countdown
  else
    return 0
  end
end
def.method()._Callback = function(self)
  if self._callback then
    self._callback()
  end
end
def.method().Clear = function(self)
  self._callback = nil
  local AagrStartPanel = require("Main.Aagr.ui.AagrStartPanel")
  AagrStartPanel.Instance():DestroyPanel()
end
ArenaCountdownMgr.Commit()
return ArenaCountdownMgr
