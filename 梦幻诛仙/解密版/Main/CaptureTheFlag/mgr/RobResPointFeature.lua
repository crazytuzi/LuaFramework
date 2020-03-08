local Lplus = require("Lplus")
local BattleFeature = require("Main.CaptureTheFlag.mgr.BattleFeature")
local RobResPointFeature = Lplus.Extend(BattleFeature, "RobResPointFeature")
local BattleFieldMgr = Lplus.ForwardDeclare("BattleFieldMgr")
local CaptureTheFlagUtils = require("Main.CaptureTheFlag.CaptureTheFlagUtils")
local PlayType = require("consts.mzm.gsp.singlebattle.confbean.PlayType")
local def = RobResPointFeature.define
def.field("table").m_resPoints = nil
def.field("table").m_contributeResources = nil
def.field("function").m_statisticReq = nil
local instance
def.final("=>", "table").Instance = function()
  if instance == nil then
    instance = RobResPointFeature()
    instance.playType = PlayType.RESOURCE_POINT
  end
  return instance
end
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.singlebattle.SSynResourcePointInfo", RobResPointFeature.OnSSynResourcePointInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.singlebattle.SSynResourcePointUpdateInfo", RobResPointFeature.OnSSynResourcePointUpdateInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.singlebattle.SSynAddResourceSum", RobResPointFeature.OnSSynAddResourceSum)
end
def.override().OnEnterBattle = function(self, data)
end
def.override("number").OnEnterStage = function(self, stage)
end
def.override().OnQuitBattle = function(self)
  self:Reset()
end
def.override().Reset = function(self)
  self.m_resPoints = nil
  self.m_statisticReq = nil
  self.m_contributeResources = nil
end
def.override("=>", "string").GetExtraName = function(self)
  return textRes.CaptureTheFlag[101]
end
def.override("=>", "string").GetExtraSprite = function(self)
  return "Img_Point"
end
def.override("userdata", "=>", "string").GetExtraData = function(self, roleId)
  return tostring(self:GetRoleResPoint(roleId))
end
def.override("userdata", "=>", "string").GetFinalData = function(self, roleId)
  return tostring(self:GetRoleResContribution(roleId))
end
def.override("function").IsStatisticsReady = function(self, func)
  if self.m_contributeResources == nil then
    self.m_statisticReq = func
  else
    func()
  end
end
def.method("userdata", "=>", "number").GetRoleResPoint = function(self, roleId)
  if self.m_resPoints == nil then
    return 0
  end
  return self.m_resPoints[tostring(roleId)] or 0
end
def.method("userdata", "=>", "number").GetRoleResContribution = function(self, roleId)
  if self.m_contributeResources == nil then
    return 0
  end
  return self.m_contributeResources[tostring(roleId)] or 0
end
def.static("table").OnSSynResourcePointInfo = function(p)
  local self = instance
  self.m_resPoints = {}
  for k, v in pairs(p.resource_point_infos) do
    self.m_resPoints[tostring(k)] = v
  end
  Event.DispatchEvent(ModuleId.CTF, gmodule.notifyId.CTF.SyncAllResPoint, {
    self.m_resPoints
  })
end
def.static("table").OnSSynResourcePointUpdateInfo = function(p)
  local self = instance
  if self.m_resPoints == nil then
    error("OnSSynResourcePointUpdateInfo")
  end
  local roleIds = {}
  for roleId, point in pairs(p.resource_point_update_infos) do
    self.m_resPoints[tostring(roleId)] = point
    table.insert(roleIds, roleId)
  end
  if p.reason == p.class.REASON_FIGHT then
    local winnerId = p.long_extra_infos[p.class.EXTRA_INFO_TYPE_WINNER_ID]
    local loserId = p.long_extra_infos[p.class.EXTRA_INFO_TYPE_LOSER_ID]
    if BattleFieldMgr.Instance():IsEnemy(loserId) then
      local roleInfoData = BattleFieldMgr.Instance():GetRoleInfoData()
      local winnerInfo = roleInfoData:GetRoleInfo(winnerId)
      local loserInfo = roleInfoData:GetRoleInfo(loserId)
      if winnerInfo and loserInfo then
        local text = textRes.CaptureTheFlag[102]:format(winnerInfo.name, loserInfo.name)
        CaptureTheFlagUtils.ShowInBattlefieldChannel(text)
      end
    end
  end
  Event.DispatchEvent(ModuleId.CTF, gmodule.notifyId.CTF.RoleResPointUpdate, {
    p.resource_point_update_infos
  })
  Event.DispatchEvent(ModuleId.CTF, gmodule.notifyId.CTF.RoleDataChange, roleIds)
end
def.static("table").OnSSynAddResourceSum = function(p)
  local self = instance
  self.m_contributeResources = {}
  for k, v in pairs(p.add_resource_sums) do
    self.m_contributeResources[tostring(k)] = v
  end
  if self.m_statisticReq then
    self.m_statisticReq()
    self.m_statisticReq = nil
  end
end
return RobResPointFeature.Commit()
