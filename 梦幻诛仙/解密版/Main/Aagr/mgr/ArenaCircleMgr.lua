local Lplus = require("Lplus")
local AagrData = require("Main.Aagr.data.AagrData")
local SafeZoneModel = require("Main.Aagr.model.SafeZoneModel")
local MapUtility = require("Main.Map.MapUtility")
local ArenaCircleMgr = Lplus.Class("ArenaCircleMgr")
local def = ArenaCircleMgr.define
local instance
def.static("=>", ArenaCircleMgr).Instance = function()
  if instance == nil then
    instance = ArenaCircleMgr()
  end
  return instance
end
def.field("boolean")._bShowing = false
def.field("table")._arenaInfo = nil
def.field(SafeZoneModel)._zoneModel = nil
local WARNING_PRE_TIME = 5
local UPDATE_INTERVAL = 1
def.field("number")._timerID = 0
def.method("boolean").OnOpenChange = function(self, bOpen)
  self:HandleEventListeners(bOpen)
  if not bOpen then
    self:Clear()
  end
end
def.method("boolean").HandleEventListeners = function(self, bRigister)
  if bRigister then
    Event.RegisterEventWithContext(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, ArenaCircleMgr.OnEnterWorld, self)
    Event.RegisterEventWithContext(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, ArenaCircleMgr.OnLeaveWorld, self)
    Event.RegisterEventWithContext(ModuleId.AAGR, gmodule.notifyId.Aagr.AAGR_ENTER_ARENA, ArenaCircleMgr.OnEnterArenaMap, self)
    Event.RegisterEventWithContext(ModuleId.AAGR, gmodule.notifyId.Aagr.AAGR_LEAVE_ARENA, ArenaCircleMgr.OnLeaveArenaMap, self)
  else
    Event.UnregisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, ArenaCircleMgr.OnEnterWorld)
    Event.UnregisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, ArenaCircleMgr.OnLeaveWorld)
    Event.UnregisterEvent(ModuleId.AAGR, gmodule.notifyId.Aagr.AAGR_ENTER_ARENA, ArenaCircleMgr.OnEnterArenaMap)
    Event.UnregisterEvent(ModuleId.AAGR, gmodule.notifyId.Aagr.AAGR_LEAVE_ARENA, ArenaCircleMgr.OnLeaveArenaMap)
  end
end
def.method("table").OnEnterWorld = function(self, params)
  self:TryStart()
end
def.method("table").OnLeaveWorld = function(self, params)
  self:Clear()
end
def.method("table").OnEnterArenaMap = function(self, params)
  self:TryStart()
end
def.method("table").OnLeaveArenaMap = function(self, params)
  self:Clear()
end
def.method().OnSSyncGameStatus = function(self)
  self:TryStart()
end
def.method().OnSNotifyCircleReduceEvent = function(self)
  if self._bShowing then
    self:UpdateCircle()
  end
end
def.method().TryStart = function(self)
  if not _G.IsEnteredWorld() then
    warn("[ERROR][ArenaCircleMgr:TryStart] show fail! not enter world.")
    return
  end
  if self._bShowing then
    warn("[ERROR][ArenaCircleMgr:TryStart] show fail! already showing.")
    return
  end
  if not AagrData.Instance():IsInArena() then
    warn("[ERROR][ArenaCircleMgr:TryStart] show fail! not in arena!")
    return
  end
  self._arenaInfo = AagrData.Instance():GetArenaInfo()
  if nil == self._arenaInfo then
    warn("[ERROR][ArenaCircleMgr:TryStart] show fail, arenaInfo nil!")
    return
  end
  self:_DoStart()
end
def.method()._DoStart = function(self)
  warn("[ArenaCircleMgr:_DoStart] start show safezone, cur circleIdx:", self._arenaInfo.circleIdx)
  self._bShowing = true
  self._timerID = GameUtil.AddGlobalTimer(UPDATE_INTERVAL, false, function()
    self:_Update()
  end)
  self:UpdateCircle()
end
def.method().Clear = function(self)
  self._bShowing = false
  self._arenaInfo = nil
  self:_ClearTimer()
  self:_ClearCircle()
end
def.method().UpdateCircle = function(self)
  if not self._bShowing then
    warn("[ERROR][ArenaCircleMgr:UpdateCircle] update fail! not Showing.")
    return
  end
  warn("[ArenaCircleMgr:UpdateCircle] circleIdx:", self._arenaInfo.circleIdx)
  if not _G.IsNil(self._zoneModel) then
    self._zoneModel:UpdateZone(self._arenaInfo.circleIdx)
  else
    self:_CreateSafeZone()
  end
end
def.method("=>", SafeZoneModel)._CreateSafeZone = function(self)
  local circleCfg = AagrData.Instance():GetCurCircleCfg()
  local mapCfg = MapUtility.GetMapCfg(AagrData.Instance():GetArenaMapId())
  local circleIdx = self._arenaInfo.circleIdx
  self._zoneModel = SafeZoneModel.new(circleCfg, circleIdx, mapCfg)
  if not _G.IsNil(self._zoneModel) then
    self._zoneModel:LoadZone(function(ret)
      if ret then
        self._zoneModel:UpdateZone(self._arenaInfo.circleIdx)
      end
    end)
  else
    warn("[ERROR][ArenaCircleMgr:_CreateSafeZone] create SafeZoneModel fail.")
  end
  return self._zoneModel
end
def.method()._ClearCircle = function(self)
  if self._zoneModel then
    self._zoneModel:Destroy()
    self._zoneModel = nil
  end
end
def.method()._Update = function(self)
  if self._arenaInfo and self._arenaInfo:GetShrinkRemainTime() == WARNING_PRE_TIME then
    warn("[ArenaCircleMgr:_Update] shrink pre warning! cur circle, curTime, shrinkTime:", self._arenaInfo.circleIdx, os.date("%c", _G.GetServerTime()), os.date("%c", self._arenaInfo:GetNextShrinkTime()))
    Toast(textRes.Aagr.ARENA_CIRCLE_SHRINK)
  end
end
def.method()._ClearTimer = function(self)
  if self._timerID > 0 then
    GameUtil.RemoveGlobalTimer(self._timerID)
    self._timerID = 0
  end
end
ArenaCircleMgr.Commit()
return ArenaCircleMgr
