local CGetAttendIndianaNumReq = class("CGetAttendIndianaNumReq")
CGetAttendIndianaNumReq.TYPEID = 12628996
function CGetAttendIndianaNumReq:ctor(activity_cfg_id, turn)
  self.id = 12628996
  self.activity_cfg_id = activity_cfg_id or nil
  self.turn = turn or nil
end
function CGetAttendIndianaNumReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.turn)
end
function CGetAttendIndianaNumReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.turn = os:unmarshalInt32()
end
function CGetAttendIndianaNumReq:sizepolicy(size)
  return size <= 65535
end
return CGetAttendIndianaNumReq
