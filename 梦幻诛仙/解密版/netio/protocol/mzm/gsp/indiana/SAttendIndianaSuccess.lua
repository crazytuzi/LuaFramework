local SAttendIndianaSuccess = class("SAttendIndianaSuccess")
SAttendIndianaSuccess.TYPEID = 12628994
function SAttendIndianaSuccess:ctor(activity_cfg_id, turn, sortid, number)
  self.id = 12628994
  self.activity_cfg_id = activity_cfg_id or nil
  self.turn = turn or nil
  self.sortid = sortid or nil
  self.number = number or nil
end
function SAttendIndianaSuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.turn)
  os:marshalInt32(self.sortid)
  os:marshalInt32(self.number)
end
function SAttendIndianaSuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.turn = os:unmarshalInt32()
  self.sortid = os:unmarshalInt32()
  self.number = os:unmarshalInt32()
end
function SAttendIndianaSuccess:sizepolicy(size)
  return size <= 65535
end
return SAttendIndianaSuccess
