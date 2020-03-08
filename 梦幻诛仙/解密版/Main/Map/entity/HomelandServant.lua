local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local EntityBase = import(".EntityBase")
local HomelandServant = Lplus.Extend(EntityBase, CUR_CLASS_NAME)
local def = HomelandServant.define
local homelandModule = gmodule.moduleMgr:GetModule(ModuleId.HOMELAND)
local HomelandUtils = require("Main.Homeland.HomelandUtils")
def.field("string").name = ""
def.field("table").m_ecmodel = nil
def.override().OnCreate = function(self)
end
def.override("table").UnmarshalExtraInfo = function(self, extra_info)
  local ExtraInfoType = EntityBase.MapEntityExtraInfoType
  local name = extra_info.string_extra_infos[ExtraInfoType.MET_SERVANT_NAME]
  self.name = name and _G.GetStringFromOcts(name) or self.name
end
def.override().OnDestroy = function(self)
  self:OnLeaveView()
end
def.override().OnEnterView = function(self)
  self:UpdateHomelandServantInfo()
end
def.override().OnLeaveView = function(self)
  if self.m_ecmodel and not self.m_ecmodel:IsDestroyed() then
    self.m_ecmodel:Destroy()
  end
  self.m_ecmodel = nil
end
def.override("number", "table", "table").OnInfoChange = function(self, cfgid, loc, extra_info)
  if self.cfgid ~= cfgid then
    self.m_ecmodel:Destroy()
    self.m_ecmodel = nil
  end
  self.loc = loc
  self:UnmarshalExtraInfo(extra_info)
  self:UpdateHomelandServantInfo()
end
def.override("table", "table").OnExtraInfoChange = function(self, extra_info, remove_extra_info_keys)
  self:UnmarshalExtraInfo(extra_info)
  self:UpdateHomelandServantInfo()
end
def.method().UpdateHomelandServantInfo = function(self)
  if self.m_ecmodel and not self.m_ecmodel:IsDestroyed() then
    self.m_ecmodel:SetName(self.name, nil)
    return
  end
  local homelandInfo = gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):GetCurHomelandInfo()
  local houseCfg = HomelandUtils.GetHouseCfg(homelandInfo.houseLevel)
  local servantId = self.cfgid
  local npcId = HomelandUtils.GetServantCfg(servantId).npcId
  local mapId = gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapId()
  local npcdata = {
    insanceid = self.instanceid,
    x = self.loc.x,
    y = self.loc.y,
    dir = houseCfg.maidDir,
    npcId = npcId,
    name = self.name,
    mapId = mapId,
    extraInfo = {}
  }
  local npc = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):CreateUserNpc(npcdata)
  npc.extraInfo.npc = npc
  npc.extraInfo.entityType = self.type
  npc.extraInfo.instanceid = self.instanceid
  self.m_ecmodel = npc
  self:UpdateOwnerInfo()
  homelandInfo:SetServant(self)
end
def.method().UpdateOwnerInfo = function(self)
  local homelandInfo = gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):GetCurHomelandInfo()
  if homelandInfo == nil then
    return
  end
  if self.m_ecmodel == nil then
    return
  end
  if not gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):IsInSelfHomeland() then
    local text
    if homelandInfo.partnerInfo then
      text = string.format(textRes.Homeland[54], homelandInfo.createrInfo.name, homelandInfo.partnerInfo.name)
    else
      text = string.format(textRes.Homeland[53], homelandInfo.createrInfo.name)
    end
    self.m_ecmodel.extraInfo.customTalkTexts = {text}
  end
end
def.method("=>", "table").GetECModel = function(self)
  return self.m_ecmodel
end
def.method("number", "number", "number", "=>", "table").FindPath = function(self, x, y, distance)
  if self.m_ecmodel == nil or self.m_ecmodel:IsDestroyed() then
    return nil
  end
  return gmodule.moduleMgr:GetModule(ModuleId.MAP):FindPath(self.m_ecmodel.m_node2d.localPosition.x, self.m_ecmodel.m_node2d.localPosition.y, x, y, distance)
end
def.override("table").OnSyncMove = function(self, locs)
  if self.m_ecmodel == nil or self.m_ecmodel:IsDestroyed() then
    return
  end
  self.m_ecmodel:RunPath(locs, self.m_ecmodel.runSpeed, cb)
end
def.override("=>", "table").GetPos = function(self)
  if self.m_ecmodel == nil or self.m_ecmodel:IsDestroyed() then
    return self.loc
  end
  return self.m_ecmodel:GetPos()
end
return HomelandServant.Commit()
