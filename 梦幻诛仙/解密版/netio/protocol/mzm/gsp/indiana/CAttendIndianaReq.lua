local CAttendIndianaReq = class("CAttendIndianaReq")
CAttendIndianaReq.TYPEID = 12628995
function CAttendIndianaReq:ctor(activity_cfg_id, turn, sortid)
  self.id = 12628995
  self.activity_cfg_id = activity_cfg_id or nil
  self.turn = turn or nil
  self.sortid = sortid or nil
end
function CAttendIndianaReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.turn)
  os:marshalInt32(self.sortid)
end
function CAttendIndianaReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.turn = os:unmarshalInt32()
  self.sortid = os:unmarshalInt32()
end
function CAttendIndianaReq:sizepolicy(size)
  return size <= 65535
end
return CAttendIndianaReq
