local SMapGroupSyncPos = class("SMapGroupSyncPos")
SMapGroupSyncPos.TYPEID = 12590941
function SMapGroupSyncPos:ctor(group_type, groupid, key_point_path, map_cfgid, map_instance_id)
  self.id = 12590941
  self.group_type = group_type or nil
  self.groupid = groupid or nil
  self.key_point_path = key_point_path or {}
  self.map_cfgid = map_cfgid or nil
  self.map_instance_id = map_instance_id or nil
end
function SMapGroupSyncPos:marshal(os)
  os:marshalInt32(self.group_type)
  os:marshalInt64(self.groupid)
  os:marshalCompactUInt32(table.getn(self.key_point_path))
  for _, v in ipairs(self.key_point_path) do
    v:marshal(os)
  end
  os:marshalInt32(self.map_cfgid)
  os:marshalInt32(self.map_instance_id)
end
function SMapGroupSyncPos:unmarshal(os)
  self.group_type = os:unmarshalInt32()
  self.groupid = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.map.Location")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.key_point_path, v)
  end
  self.map_cfgid = os:unmarshalInt32()
  self.map_instance_id = os:unmarshalInt32()
end
function SMapGroupSyncPos:sizepolicy(size)
  return size <= 65535
end
return SMapGroupSyncPos
