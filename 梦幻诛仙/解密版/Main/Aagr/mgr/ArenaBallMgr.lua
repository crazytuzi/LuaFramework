local Lplus = require("Lplus")
local AagrData = require("Main.Aagr.data.AagrData")
local BallInfo = require("Main.Aagr.data.BallInfo")
local ArenaBallMgr = Lplus.Class("ArenaBallMgr")
local def = ArenaBallMgr.define
local instance
def.static("=>", ArenaBallMgr).Instance = function()
  if instance == nil then
    instance = ArenaBallMgr()
  end
  return instance
end
def.field("table")._ballInfoMap = nil
def.method("boolean").OnOpenChange = function(self, bOpen)
  self:HandleEventListeners(bOpen)
  if not bOpen then
    self:Clear()
  end
end
def.method("boolean").HandleEventListeners = function(self, bRigister)
  if bRigister then
    Event.RegisterEventWithContext(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, ArenaBallMgr.OnLeaveWorld, self)
    Event.RegisterEventWithContext(ModuleId.AAGR, gmodule.notifyId.Aagr.AAGR_ENTER_ARENA, ArenaBallMgr.OnEnterArenaMap, self)
    Event.RegisterEventWithContext(ModuleId.AAGR, gmodule.notifyId.Aagr.AAGR_LEAVE_ARENA, ArenaBallMgr.OnLeaveArenaMap, self)
    Event.RegisterEventWithContext(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.MAP_ROLE_LEAVE_VIEW, ArenaBallMgr.OnRoleLeaveView, self)
  else
    Event.UnregisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, ArenaBallMgr.OnLeaveWorld)
    Event.UnregisterEvent(ModuleId.AAGR, gmodule.notifyId.Aagr.AAGR_ENTER_ARENA, ArenaBallMgr.OnEnterArenaMap)
    Event.UnregisterEvent(ModuleId.AAGR, gmodule.notifyId.Aagr.AAGR_LEAVE_ARENA, ArenaBallMgr.OnLeaveArenaMap)
    Event.UnregisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.MAP_ROLE_LEAVE_VIEW, ArenaBallMgr.OnRoleLeaveView)
  end
end
def.method("table").OnLeaveWorld = function(self, params)
  self:Clear()
end
def.method("table").OnEnterArenaMap = function(self, params)
end
def.method("table").OnLeaveArenaMap = function(self, params)
  self:Clear()
end
def.method("table").OnRoleLeaveView = function(self, params)
  if AagrData.Instance():IsInArena() then
    warn("[ArenaBallMgr:OnRoleLeaveView] RoleLeaveView, Clear Status:", params and params.roleId and Int64.tostring(params.roleId))
    local roleId = params.roleId
    local ballInfo = self:GetBallInfo(roleId)
    if ballInfo then
      ballInfo:ClearStatus()
    end
  end
end
def.method("table").OnSNotifyMaxLevelEvent = function(self, p)
  local ballInfo = self:_GetOrCreateBallInfo(p.role_id)
  if ballInfo then
    ballInfo:SyncCoolTime(p.level_reset_time)
    Event.DispatchEvent(ModuleId.AAGR, gmodule.notifyId.Aagr.AAGR_ARENA_BALL_INFO_CHANGE, {
      roleId = p.role_id
    })
  end
end
def.method("table", "table").OnSBallBattlePlayerStatus = function(self, role, p)
  local ballInfo = self:_GetOrCreateBallInfo(role.roleId)
  if ballInfo then
    ballInfo:SyncStatus(p.status)
    Event.DispatchEvent(ModuleId.AAGR, gmodule.notifyId.Aagr.AAGR_ARENA_BALL_INFO_CHANGE, {
      roleId = role.roleId
    })
  end
end
def.method("userdata", "=>", BallInfo).GetBallInfo = function(self, roleId)
  if nil == roleId then
    return nil
  end
  if nil == self._ballInfoMap then
    return nil
  else
    local roleKey = Int64.tostring(roleId)
    return self._ballInfoMap[roleKey]
  end
end
def.method("userdata", "=>", "number").GetBallLevel = function(self, roleId)
  local ballInfo = self:GetBallInfo(roleId)
  if ballInfo then
    return ballInfo:GetLevel()
  else
    return 0
  end
end
def.method("userdata", "=>", BallInfo)._GetOrCreateBallInfo = function(self, roleId)
  if nil == roleId then
    return nil
  end
  if nil == self._ballInfoMap then
    self._ballInfoMap = {}
  end
  local roleKey = Int64.tostring(roleId)
  local ballInfo = self._ballInfoMap[roleKey]
  if nil == ballInfo then
    ballInfo = BallInfo.New(roleId, nil, 0)
    self._ballInfoMap[roleKey] = ballInfo
  end
  return ballInfo
end
def.method("userdata", "=>", BallInfo).RemoveBallInfo = function(self, roleId)
  if nil == roleId then
    return nil
  end
  if nil == self._ballInfoMap then
    return nil
  else
    local roleKey = Int64.tostring(roleId)
    local ballInfo = self._ballInfoMap[roleKey]
    self._ballInfoMap[roleKey] = nil
    return ballInfo
  end
end
def.method().Clear = function(self)
  self._ballInfoMap = nil
end
ArenaBallMgr.Commit()
return ArenaBallMgr
