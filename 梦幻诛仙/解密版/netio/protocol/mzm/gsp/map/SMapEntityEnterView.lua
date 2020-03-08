local MapEntityExtraInfo = require("netio.protocol.mzm.gsp.map.MapEntityExtraInfo")
local SMapEntityEnterView = class("SMapEntityEnterView")
SMapEntityEnterView.TYPEID = 12590948
function SMapEntityEnterView:ctor(entity_type, instanceid, cfgid, locs, extra_info)
  self.id = 12590948
  self.entity_type = entity_type or nil
  self.instanceid = instanceid or nil
  self.cfgid = cfgid or nil
  self.locs = locs or {}
  self.extra_info = extra_info or MapEntityExtraInfo.new()
end
function SMapEntityEnterView:marshal(os)
  os:marshalInt32(self.entity_type)
  os:marshalInt64(self.instanceid)
  os:marshalInt32(self.cfgid)
  os:marshalCompactUInt32(table.getn(self.locs))
  for _, v in ipairs(self.locs) do
    v:marshal(os)
  end
  self.extra_info:marshal(os)
end
function SMapEntityEnterView:unmarshal(os)
  self.entity_type = os:unmarshalInt32()
  self.instanceid = os:unmarshalInt64()
  self.cfgid = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.map.Location")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.locs, v)
  end
  self.extra_info = MapEntityExtraInfo.new()
  self.extra_info:unmarshal(os)
end
function SMapEntityEnterView:sizepolicy(size)
  return size <= 65535
end
return SMapEntityEnterView
