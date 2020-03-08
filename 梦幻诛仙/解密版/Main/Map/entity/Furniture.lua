local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local EntityBase = import(".EntityBase")
local Furniture = Lplus.Extend(EntityBase, CUR_CLASS_NAME)
local def = Furniture.define
local homelandModule = gmodule.moduleMgr:GetModule(ModuleId.HOMELAND)
def.field("number").dir = 0
def.override().OnCreate = function(self)
end
def.override("table").UnmarshalExtraInfo = function(self, extra_info)
  local ExtraInfoType = EntityBase.MapEntityExtraInfoType
  self.dir = extra_info.int_extra_infos[ExtraInfoType.MET_FURNITURE_DIRECTION] or self.dir
end
def.override().OnDestroy = function(self)
  self:OnLeaveView()
end
def.override().OnEnterView = function(self)
  self:UpdateFurnitureInfo()
end
def.override().OnLeaveView = function(self)
  local furniture = homelandModule:FindFurnitureByUUID(self.instanceid)
  if furniture then
    homelandModule:DestroyFurniture(furniture.m_id)
  end
end
def.override("number", "table", "table").OnInfoChange = function(self, cfgid, loc, extra_info)
  self.loc = loc
  self:UnmarshalExtraInfo(extra_info)
  self:UpdateFurnitureInfo()
end
def.override("table", "table").OnExtraInfoChange = function(self, extra_info, remove_extra_info_keys)
  self:UnmarshalExtraInfo(extra_info)
  self:UpdateFurnitureInfo()
end
def.method().UpdateFurnitureInfo = function(self)
  local furnitureId = self.cfgid
  local uuid = self.instanceid
  local pos = self.loc
  local dir = self.dir
  local context
  homelandModule:PlaceFurniture(furnitureId, uuid, pos, dir, context)
end
return Furniture.Commit()
