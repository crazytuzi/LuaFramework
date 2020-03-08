local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local EntityBase = Lplus.Class(CUR_CLASS_NAME)
local def = EntityBase.define
local Location = require("netio.protocol.mzm.gsp.map.Location")
def.const("table").MapEntityExtraInfoType = require("netio.protocol.mzm.gsp.map.MapEntityExtraInfoType")
local EntityStatus = {
  NONE = 0,
  NORMAL = 1,
  DESTROY = 2
}
def.const("table").EntityStatus = EntityStatus
def.field("number").m_status = EntityStatus.NONE
def.field("number").type = 0
def.field("userdata").instanceid = nil
def.field("number").cfgid = 0
def.field("table").loc = nil
def.field("table").locs = nil
def.method("number", "userdata", "number", "table", "table").Create = function(self, entityType, instanceid, cfgid, locs, extra_info)
  self.type = entityType
  self.instanceid = instanceid
  self.cfgid = cfgid
  self.locs = locs or {}
  self.loc = self:CalcStartLocation(self.locs)
  self:UnmarshalExtraInfo(extra_info)
  self.m_status = EntityStatus.NORMAL
  self:OnCreate()
end
def.virtual("table").UnmarshalExtraInfo = function(self, extra_info)
end
def.virtual().OnCreate = function(self)
end
def.virtual().Destroy = function(self)
  self:OnDestroy()
  self.m_status = EntityStatus.DESTROY
end
def.virtual().OnDestroy = function(self)
  self:OnLeaveView()
end
def.virtual().OnEnterView = function(self)
end
def.virtual().OnLeaveView = function(self)
end
def.virtual("number", "table", "table").OnInfoChange = function(self, cfgid, loc, extra_info)
end
def.virtual("table", "table").OnExtraInfoChange = function(self, extra_info, remove_extra_info_keys)
end
def.virtual("table").OnSyncMove = function(self, locs)
end
def.virtual("number").Update = function(self, dt)
end
def.method("=>", "boolean").IsEmptyUpdate = function(self)
  return self.Update == EntityBase.Update
end
def.method("=>", "boolean").IsDestroyed = function(self)
  return self.m_status == EntityStatus.DESTROY
end
def.method("table", "=>", "table").CalcStartLocation = function(self, locs)
  if locs == nil or #locs == 0 then
    return Location.new(0, 0)
  else
    return locs[1]
  end
end
def.method().EnterView = function(self)
  self:OnEnterView()
  if self.locs and #self.locs > 1 then
    self:OnSyncMove(self.locs)
  end
end
def.method("number", "table", "table").InfoChange = function(self, cfgid, locs, extra_info)
  local loc = self:CalcStartLocation(locs)
  self:OnInfoChange(cfgid, loc, extra_info)
  self.loc = loc
  self.locs = locs or {}
  if locs and #locs > 1 then
    self:OnSyncMove(locs)
  end
end
def.method("table").SyncMove = function(self, locs)
  self.locs = locs or {}
  self:OnSyncMove(self.locs)
end
def.method("=>", "table").GetLocation = function(self)
  return self.loc
end
def.virtual("=>", "table").GetPos = function(self)
  return self.loc
end
return EntityBase.Commit()
