local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local EntityBase = import(".EntityBase")
local CourtyardGroundEntity = Lplus.Extend(EntityBase, CUR_CLASS_NAME)
local def = CourtyardGroundEntity.define
local homelandModule = gmodule.moduleMgr:GetModule(ModuleId.HOMELAND)
local HomelandUtils = require("Main.Homeland.HomelandUtils")
def.override().OnCreate = function(self)
end
def.override("table").UnmarshalExtraInfo = function(self, extra_info)
end
def.override().OnDestroy = function(self)
  self:OnLeaveView()
end
def.override().OnEnterView = function(self)
  self:UpdateGroundInfo()
end
def.override().OnLeaveView = function(self)
end
def.override("number", "table", "table").OnInfoChange = function(self, cfgid, loc, extra_info)
  self.cfgid = cfgid
  self:UnmarshalExtraInfo(extra_info)
  self:UpdateGroundInfo()
end
def.override("table", "table").OnExtraInfoChange = function(self, extra_info, remove_extra_info_keys)
  self:UnmarshalExtraInfo(extra_info)
  self:UpdateGroundInfo()
end
def.method().UpdateGroundInfo = function(self)
  local furnitureId = self.cfgid
  HomelandUtils.SetCourtyardGroundById(furnitureId)
end
return CourtyardGroundEntity.Commit()
