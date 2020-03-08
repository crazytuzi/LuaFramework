local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local EntityBase = import(".EntityBase")
local ExplorerCat = Lplus.Extend(EntityBase, CUR_CLASS_NAME)
local def = ExplorerCat.define
local homelandModule = gmodule.moduleMgr:GetModule(ModuleId.HOMELAND)
def.field("string").name = ""
def.field("string").rolename = ""
def.field("userdata").ownerId = nil
def.field("table").m_ecmodel = nil
def.field("number").m_dir = 0
def.field("number").m_state = 0
def.override().OnCreate = function(self)
end
def.override("table").UnmarshalExtraInfo = function(self, extra_info)
  local ExtraInfoType = EntityBase.MapEntityExtraInfoType
  local name = extra_info.string_extra_infos[ExtraInfoType.MGT_EXPLORE_CAT_NAME]
  self.name = name and _G.GetStringFromOcts(name) or self.name
  local rolename = extra_info.string_extra_infos[ExtraInfoType.MGT_EXPLORE_CAT_TITLE]
  self.rolename = rolename and _G.GetStringFromOcts(rolename) or self.rolename
  self.ownerId = extra_info.long_extra_infos[ExtraInfoType.MGT_EXPLORE_CAT_OWNER] or self.ownerId
  self.m_dir = extra_info.long_extra_infos[ExtraInfoType.MGT_EXPLORE_CAT_DIRECTION] or self.m_dir
  self.m_state = extra_info.int_extra_infos[ExtraInfoType.MGT_EXPLORE_CAT_STATE] or self.m_dir
end
def.override().OnDestroy = function(self)
  self:OnLeaveView()
end
def.override().OnEnterView = function(self)
  self:UpdateExplorerCatInfo()
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.EXPLORE_CAT_ENTER_VIEW, {self})
end
def.override().OnLeaveView = function(self)
  self:DestroyNpc()
end
def.override("number", "table", "table").OnInfoChange = function(self, cfgid, loc, extra_info)
  self.cfgid = cfgid
  self.loc = loc
  self:UnmarshalExtraInfo(extra_info)
  self:UpdateExplorerCatInfo()
end
def.override("table", "table").OnExtraInfoChange = function(self, extra_info, remove_extra_info_keys)
  self:UnmarshalExtraInfo(extra_info)
  self:UpdateExplorerCatInfo()
end
def.method().DestroyNpc = function(self)
  if self.m_ecmodel and not self.m_ecmodel:IsDestroyed() then
    self.m_ecmodel:Destroy()
  end
  self.m_ecmodel = nil
end
def.method().UpdateExplorerCatInfo = function(self)
  local cfgid = self.cfgid
  local catcfg = gmodule.moduleMgr:GetModule(ModuleId.CAT):GetCatCfg(cfgid)
  local npcId
  local state = self.m_state
  local CatInfo = require("netio.protocol.mzm.gsp.cat.CatInfo")
  if state == CatInfo.STATE_EXPLORE then
    npcId = catcfg.explore_npcid
  else
    npcId = catcfg.npcid
  end
  if npcId == nil then
    warn(string.format("Not found cat cfg for id = %d", cfgid))
    return
  end
  if self.m_ecmodel and self.m_ecmodel.m_cfgId ~= npcId then
    self:DestroyNpc()
  end
  if self.m_ecmodel and not self.m_ecmodel:IsDestroyed() then
    self.m_ecmodel:SetName(self.name, nil)
    return
  end
  local instanceid = self.instanceid
  local x = self.loc.x
  local y = self.loc.y
  local dir = self.m_dir
  local name = self.name
  local entityType = self.type
  local mapId = gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapId()
  local npcdata = {
    insanceid = instanceid,
    x = x,
    y = y,
    dir = dir,
    npcId = npcId,
    name = name,
    mapId = mapId,
    extraInfo = {}
  }
  local npc = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):CreateUserNpc(npcdata)
  npc.extraInfo.npc = npc
  npc.extraInfo.entityType = entityType
  npc.extraInfo.instanceid = instanceid
  npc.extraInfo.ownerId = self.ownerId
  npc:SetTitle(gmodule.moduleMgr:GetModule(ModuleId.CAT):GetTitle(self.rolename))
  self.m_ecmodel = npc
end
def.method("=>", "table").GetECModel = function(self)
  return self.m_ecmodel
end
return ExplorerCat.Commit()
