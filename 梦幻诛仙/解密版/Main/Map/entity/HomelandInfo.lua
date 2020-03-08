local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local EntityBase = import(".EntityBase")
local HomelandInfo = Lplus.Extend(EntityBase, CUR_CLASS_NAME)
local def = HomelandInfo.define
local homelandModule = gmodule.moduleMgr:GetModule(ModuleId.HOMELAND)
local HomelandUtils = require("Main.Homeland.HomelandUtils")
def.field("number").houseLevel = 0
def.field("number").courtyardLevel = 1
def.field("number").geomancy = 0
def.field("number").cleanness = 0
def.field("table").createrInfo = nil
def.field("table").partnerInfo = nil
def.field("table").servant = nil
def.field("number").courtyardCleanness = 0
def.field("number").courtyardBeauty = 0
def.override().OnCreate = function(self)
end
def.override("table").UnmarshalExtraInfo = function(self, extra_info)
  local ExtraInfoType = EntityBase.MapEntityExtraInfoType
  self.houseLevel = extra_info.int_extra_infos[ExtraInfoType.MGT_HOME_LAND_BASIC_INFO_LEVEL] or self.houseLevel
  self.geomancy = extra_info.int_extra_infos[ExtraInfoType.MGT_HOME_LAND_BASIC_INFO_FENG_SHUI] or self.geomancy
  self.cleanness = extra_info.int_extra_infos[ExtraInfoType.MGT_HOME_LAND_BASIC_INFO_CLEANLINESS] or self.cleanness
  self.courtyardLevel = extra_info.int_extra_infos[ExtraInfoType.MET_HOME_LAND_BASIC_INFO_COURT_YARD_LEVEL] or self.courtyardLevel
  self.courtyardCleanness = extra_info.int_extra_infos[ExtraInfoType.MET_HOME_LAND_BASIC_INFO_COURT_YARD_CLEANLINESS] or self.courtyardCleanness
  self.courtyardBeauty = extra_info.int_extra_infos[ExtraInfoType.MET_HOME_LAND_BASIC_INFO_COURT_YARD_BEAUTIFUL] or self.courtyardBeauty
  if extra_info.long_extra_infos[ExtraInfoType.MGT_HOME_LAND_BASIC_INFO_CREATOR_ROLEID] then
    self.createrInfo = {}
    self.createrInfo.id = extra_info.long_extra_infos[ExtraInfoType.MGT_HOME_LAND_BASIC_INFO_CREATOR_ROLEID]
    self.createrInfo.name = _G.GetStringFromOcts(extra_info.string_extra_infos[ExtraInfoType.MGT_HOME_LAND_BASIC_INFO_CREATOR_NAME])
  end
  if extra_info.long_extra_infos[ExtraInfoType.MGT_HOME_LAND_BASIC_INFO_PARTNER_ROLEID] then
    self.partnerInfo = {}
    self.partnerInfo.id = extra_info.long_extra_infos[ExtraInfoType.MGT_HOME_LAND_BASIC_INFO_PARTNER_ROLEID]
    self.partnerInfo.name = _G.GetStringFromOcts(extra_info.string_extra_infos[ExtraInfoType.MGT_HOME_LAND_BASIC_INFO_PARTNER_NAME])
  end
end
def.override().OnDestroy = function(self)
  self:OnLeaveView()
end
def.override().OnEnterView = function(self)
  local homeland = gmodule.moduleMgr:GetModule(ModuleId.HOMELAND)
  homeland:SetCurHomelandInfo(self)
  if homeland.m_waitingHomelandInfo then
    homeland:EnterHome()
  end
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.SyncHomelandBasicInfo, {self})
end
def.override().OnLeaveView = function(self)
  local homeland = gmodule.moduleMgr:GetModule(ModuleId.HOMELAND)
  homeland:SetCurHomelandInfo(nil)
end
def.override("number", "table", "table").OnInfoChange = function(self, cfgid, loc, extra_info)
end
def.override("table", "table").OnExtraInfoChange = function(self, extra_info, remove_extra_info_keys)
  local ExtraInfoType = EntityBase.MapEntityExtraInfoType
  local lastGeomancy = self.geomancy
  local lastCleanness = self.cleanness
  local lastCourtyardCleanness = self.courtyardCleanness
  local lastCourtyardBeauty = self.courtyardBeauty
  self:UnmarshalExtraInfo(extra_info)
  if remove_extra_info_keys[ExtraInfoType.MGT_HOME_LAND_BASIC_INFO_PARTNER_ROLEID] then
    self.partnerInfo = nil
    if self.servant then
      self.servant:UpdateOwnerInfo()
    end
  end
  if lastGeomancy ~= self.geomancy then
    Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.GeomancyChange, {
      self.geomancy,
      lastGeomancy
    })
  end
  if lastCleanness ~= self.cleanness then
    Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.CleannessChange, {
      self.cleanness,
      lastCleanness
    })
  end
  if lastCourtyardCleanness ~= self.courtyardCleanness then
    Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.CourtyardCleannessChange, {
      self.courtyardCleanness,
      lastCourtyardCleanness
    })
  end
  if lastCourtyardBeauty ~= self.courtyardBeauty then
    Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.CourtyardBeautyChange, {
      self.courtyardBeauty,
      lastCourtyardBeauty
    })
  end
end
def.method("table").SetServant = function(self, servant)
  self.servant = servant
end
def.method("table", "=>", "boolean").IsOwnerEqual = function(self, homelandInfo)
  if homelandInfo == nil then
    return false
  end
  if homelandInfo.createrInfo == nil then
    return false
  end
  if self.createrInfo == nil then
    return false
  end
  if homelandInfo.createrInfo.id ~= self.createrInfo.id then
    return false
  end
  return true
end
def.method("=>", "userdata").GetCreaterID = function(self)
  if self.createrInfo == nil then
    return nil
  end
  return self.createrInfo.id
end
def.method("=>", "number").GetHouseLevel = function(self)
  return self.houseLevel
end
def.method("=>", "number").GetCourtyardLevel = function(self)
  return self.courtyardLevel
end
def.method("=>", "number").GetHouseGeomancy = function(self)
  return self.geomancy
end
def.method("=>", "number").GetHouseCleanness = function(self)
  return self.cleanness
end
def.method("=>", "number").GetCourtyardCleanness = function(self)
  return self.courtyardCleanness
end
def.method("=>", "number").GetCourtyardBeauty = function(self)
  return self.courtyardBeauty
end
return HomelandInfo.Commit()
