local SGetRoleAttendIndianaInfoSuccess = class("SGetRoleAttendIndianaInfoSuccess")
SGetRoleAttendIndianaInfoSuccess.TYPEID = 12629008
function SGetRoleAttendIndianaInfoSuccess:ctor(activity_cfg_id, turn, attend_sortids)
  self.id = 12629008
  self.activity_cfg_id = activity_cfg_id or nil
  self.turn = turn or nil
  self.attend_sortids = attend_sortids or {}
end
function SGetRoleAttendIndianaInfoSuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.turn)
  local _size_ = 0
  for _, _ in pairs(self.attend_sortids) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, _ in pairs(self.attend_sortids) do
    os:marshalInt32(k)
  end
end
function SGetRoleAttendIndianaInfoSuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.turn = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.attend_sortids[v] = v
  end
end
function SGetRoleAttendIndianaInfoSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetRoleAttendIndianaInfoSuccess
