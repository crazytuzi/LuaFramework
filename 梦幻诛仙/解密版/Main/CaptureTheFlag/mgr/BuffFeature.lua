local Lplus = require("Lplus")
local BattleFeature = require("Main.CaptureTheFlag.mgr.BattleFeature")
local BuffFeature = Lplus.Extend(BattleFeature, "BuffFeature")
local BattleFieldMgr = Lplus.ForwardDeclare("BattleFieldMgr")
local CaptureTheFlagUtils = require("Main.CaptureTheFlag.CaptureTheFlagUtils")
local PlayType = require("consts.mzm.gsp.singlebattle.confbean.PlayType")
local BuffUtility = require("Main.Buff.BuffUtility")
local def = BuffFeature.define
def.field("table").m_buffCfgIds = nil
local instance
def.final("=>", "table").Instance = function()
  if instance == nil then
    instance = BuffFeature()
    instance.playType = PlayType.GRAB_BUFF
  end
  return instance
end
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.singlebattle.SBrdRoleGetBuff", BuffFeature.OnSBrdRoleGetBuff)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.singlebattle.SRoleBuffInfo", BuffFeature.OnSRoleBuffInfo)
end
def.override().OnEnterBattle = function(self, data)
end
def.override("number").OnEnterStage = function(self, stage)
end
def.override().OnQuitBattle = function(self)
  local myRoleId = GetMyRoleID()
  if self.m_buffCfgIds then
    local roleBuffCfgIds = self.m_buffCfgIds[tostring(myRoleId)]
    local role = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetRole(myRoleId)
    if roleBuffCfgIds and role then
      self:SyncRoleBuffEffects(role, {}, roleBuffCfgIds)
    end
  end
  self:Reset()
end
def.override().Reset = function(self)
  self.m_buffCfgIds = nil
end
def.override("=>", "string").GetExtraName = function(self)
  return ""
end
def.override("=>", "string").GetExtraSprite = function(self)
  return ""
end
def.override("userdata", "=>", "string").GetExtraData = function(self, roleId)
  return ""
end
def.override("userdata", "=>", "string").GetFinalData = function(self, roleId)
  return ""
end
def.override("function").IsStatisticsReady = function(self, func)
  func()
end
def.static("table").OnSBrdRoleGetBuff = function(p)
  local self = instance
  local roleId = p.roleid
  local buffCfgId = p.buff_cfg_id
  local roleInfoData = BattleFieldMgr.Instance():GetRoleInfoData()
  local roleInfo = roleInfoData:GetRoleInfo(roleId)
  if roleInfo == nil then
    Debug.LogError(string.fromat("OnSBrdRoleGetBuff: role info not found for roleId = %s", tostring(roleId)))
    return
  end
  local myRoleId = _G.GetMyRoleID()
  local myRoleInfo = roleInfoData:GetRoleInfo(myRoleId)
  local isOpposite = myRoleInfo.teamId ~= roleInfo.teamId
  local function colour(name)
    if isOpposite then
      return string.format("<font color=#ff0000>%s</font>", name)
    else
      return string.format("<font color=#00ff00>%s</font>", name)
    end
  end
  local buffCfg = BuffUtility.GetBuffCfg(buffCfgId)
  local buffName = buffCfg and buffCfg.name or "$buff_cfg_id_" .. buffCfgId
  local campCfg = CaptureTheFlagUtils.GetCampCfg(roleInfo.teamId or 0)
  local campName = campCfg and campCfg.campName or "$camp_cfg_id_" .. tostring(roleInfo.teamId)
  local msg = textRes.CaptureTheFlag[111]:format(colour(campName), colour(roleInfo.name), buffName)
  CaptureTheFlagUtils.ShowInBattlefieldChannel(msg)
end
def.method("number", "=>", "string").GetEffectPathByBuffCfgId = function(self, buffCfgId)
  local buffInfoId = CaptureTheFlagUtils.GetBuffInfoCfgIdByBuffCfgId(buffCfgId)
  local buffInfoCfg = CaptureTheFlagUtils.GetBuffInfoCfg(buffInfoId)
  local effectId = buffInfoCfg and buffInfoCfg.effect_id or 0
  local effectRes = _G.GetEffectRes(effectId)
  return effectRes and effectRes.path or ""
end
def.method("table", "table", "table").SyncRoleBuffEffects = function(self, role, added, removed)
  if role == nil then
    return
  end
  for buffCfgId, v in pairs(removed) do
    local effectPath = self:GetEffectPathByBuffCfgId(buffCfgId)
    if effectPath ~= "" then
      role:StopChildEffect(effectPath)
    end
  end
  local part = BODY_PART.BODY
  local boneName = ""
  local offsetH = 0
  for buffCfgId, v in pairs(added) do
    local effectPath = self:GetEffectPathByBuffCfgId(buffCfgId)
    if effectPath ~= "" then
      role:AddChildEffect(effectPath, part, boneName, offsetH)
    end
  end
end
def.static("table", "table").OnSRoleBuffInfo = function(role, p)
  local self = instance
  if role == nil then
    return
  end
  if p then
    self.m_buffCfgIds = self.m_buffCfgIds or {}
    local roleBuffCfgIds = self.m_buffCfgIds[tostring(role.roleId)] or {}
    local removedCfgIds = {}
    for buffCfgId, v in pairs(roleBuffCfgIds) do
      if p.buff_cfg_ids[buffCfgId] == nil then
        removedCfgIds[buffCfgId] = buffCfgId
      end
    end
    local addedCfgIds = p.buff_cfg_ids
    self.m_buffCfgIds[tostring(role.roleId)] = addedCfgIds
    self:SyncRoleBuffEffects(role, addedCfgIds, removedCfgIds)
  else
    if self.m_buffCfgIds == nil then
      return
    end
    local roleBuffCfgIds = self.m_buffCfgIds[tostring(role.roleId)]
    if roleBuffCfgIds then
      local addedCfgIds = {}
      local removedCfgIds = roleBuffCfgIds
      self.m_buffCfgIds[tostring(role.roleId)] = nil
      self:SyncRoleBuffEffects(role, addedCfgIds, removedCfgIds)
    end
  end
end
def.method().OnLeaveBattlefield = function(self)
end
return BuffFeature.Commit()
