local SGetAttendIndianaNumSuccess = class("SGetAttendIndianaNumSuccess")
SGetAttendIndianaNumSuccess.TYPEID = 12629001
function SGetAttendIndianaNumSuccess:ctor(activity_cfg_id, turn, attend_nums)
  self.id = 12629001
  self.activity_cfg_id = activity_cfg_id or nil
  self.turn = turn or nil
  self.attend_nums = attend_nums or {}
end
function SGetAttendIndianaNumSuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.turn)
  os:marshalCompactUInt32(table.getn(self.attend_nums))
  for _, v in ipairs(self.attend_nums) do
    os:marshalInt32(v)
  end
end
function SGetAttendIndianaNumSuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.turn = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.attend_nums, v)
  end
end
function SGetAttendIndianaNumSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetAttendIndianaNumSuccess
