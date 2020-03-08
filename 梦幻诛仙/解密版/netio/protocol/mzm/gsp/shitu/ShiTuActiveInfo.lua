local OctetsStream = require("netio.OctetsStream")
local ShiTuActiveInfo = class("ShiTuActiveInfo")
function ShiTuActiveInfo:ctor(role_id, relation_start_time, active_value, award_active_index_id_set)
  self.role_id = role_id or nil
  self.relation_start_time = relation_start_time or nil
  self.active_value = active_value or nil
  self.award_active_index_id_set = award_active_index_id_set or {}
end
function ShiTuActiveInfo:marshal(os)
  os:marshalInt64(self.role_id)
  os:marshalInt32(self.relation_start_time)
  os:marshalInt32(self.active_value)
  local _size_ = 0
  for _, _ in pairs(self.award_active_index_id_set) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, _ in pairs(self.award_active_index_id_set) do
    os:marshalInt32(k)
  end
end
function ShiTuActiveInfo:unmarshal(os)
  self.role_id = os:unmarshalInt64()
  self.relation_start_time = os:unmarshalInt32()
  self.active_value = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.award_active_index_id_set[v] = v
  end
end
return ShiTuActiveInfo
