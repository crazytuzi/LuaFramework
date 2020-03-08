local MapGroupMemberInfo = require("netio.protocol.mzm.gsp.map.MapGroupMemberInfo")
local Location = require("netio.protocol.mzm.gsp.map.Location")
local SMapGroupEnterView = class("SMapGroupEnterView")
SMapGroupEnterView.TYPEID = 12590938
function SMapGroupEnterView:ctor(group_type, groupid, group_velocity, leader_info, other_member_infos, key_point_path, direction, cur_pos, extra_infos)
  self.id = 12590938
  self.group_type = group_type or nil
  self.groupid = groupid or nil
  self.group_velocity = group_velocity or nil
  self.leader_info = leader_info or MapGroupMemberInfo.new()
  self.other_member_infos = other_member_infos or {}
  self.key_point_path = key_point_path or {}
  self.direction = direction or nil
  self.cur_pos = cur_pos or Location.new()
  self.extra_infos = extra_infos or {}
end
function SMapGroupEnterView:marshal(os)
  os:marshalInt32(self.group_type)
  os:marshalInt64(self.groupid)
  os:marshalInt32(self.group_velocity)
  self.leader_info:marshal(os)
  os:marshalCompactUInt32(table.getn(self.other_member_infos))
  for _, v in ipairs(self.other_member_infos) do
    v:marshal(os)
  end
  os:marshalCompactUInt32(table.getn(self.key_point_path))
  for _, v in ipairs(self.key_point_path) do
    v:marshal(os)
  end
  os:marshalInt32(self.direction)
  self.cur_pos:marshal(os)
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
function SMapGroupEnterView:unmarshal(os)
  self.group_type = os:unmarshalInt32()
  self.groupid = os:unmarshalInt64()
  self.group_velocity = os:unmarshalInt32()
  self.leader_info = MapGroupMemberInfo.new()
  self.leader_info:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.map.MapGroupMemberInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.other_member_infos, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.map.Location")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.key_point_path, v)
  end
  self.direction = os:unmarshalInt32()
  self.cur_pos = Location.new()
  self.cur_pos:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.extra_infos[k] = v
  end
end
function SMapGroupEnterView:sizepolicy(size)
  return size <= 65535
end
return SMapGroupEnterView
