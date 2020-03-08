local CGetRoleAttendIndianaInfoReq = class("CGetRoleAttendIndianaInfoReq")
CGetRoleAttendIndianaInfoReq.TYPEID = 12629007
function CGetRoleAttendIndianaInfoReq:ctor(activity_cfg_id, turn)
  self.id = 12629007
  self.activity_cfg_id = activity_cfg_id or nil
  self.turn = turn or nil
end
function CGetRoleAttendIndianaInfoReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.turn)
end
function CGetRoleAttendIndianaInfoReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.turn = os:unmarshalInt32()
end
function CGetRoleAttendIndianaInfoReq:sizepolicy(size)
  return size <= 65535
end
return CGetRoleAttendIndianaInfoReq
