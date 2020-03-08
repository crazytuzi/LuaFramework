local SMapGroupInfo = class("SMapGroupInfo")
SMapGroupInfo.TYPEID = 12590939
function SMapGroupInfo:ctor(group_type, groupid, group_velocity, leader, other_members, key_point_path, extra_infos)
  self.id = 12590939
  self.group_type = group_type or nil
  self.groupid = groupid or nil
  self.group_velocity = group_velocity or nil
  self.leader = leader or nil
  self.other_members = other_members or {}
  self.key_point_path = key_point_path or {}
  self.extra_infos = extra_infos or {}
end
function SMapGroupInfo:marshal(os)
  os:marshalInt32(self.group_type)
  os:marshalInt64(self.groupid)
  os:marshalInt32(self.group_velocity)
  os:marshalInt64(self.leader)
  os:marshalCompactUInt32(table.getn(self.other_members))
  for _, v in ipairs(self.other_members) do
    os:marshalInt64(v)
  end
  os:marshalCompactUInt32(table.getn(self.key_point_path))
  for _, v in ipairs(self.key_point_path) do
    v:marshal(os)
  end
  local _size_ = 0
  for _, _ in pairs(self.extra_infos) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.extra_infos) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SMapGroupInfo:unmarshal(os)
  self.group_type = os:unmarshalInt32()
  self.groupid = os:unmarshalInt64()
  self.group_velocity = os:unmarshalInt32()
  self.leader = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.other_members, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.map.Location")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.key_point_path, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.extra_infos[k] = v
  end
end
function SMapGroupInfo:sizepolicy(size)
  return size <= 65535
end
return SMapGroupInfo
