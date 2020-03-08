local CAttendFightActivityReq = class("CAttendFightActivityReq")
CAttendFightActivityReq.TYPEID = 12614172
function CAttendFightActivityReq:ctor(activity_cfg_id, sortid)
  self.id = 12614172
  self.activity_cfg_id = activity_cfg_id or nil
  self.sortid = sortid or nil
end
function CAttendFightActivityReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.sortid)
end
function CAttendFightActivityReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.sortid = os:unmarshalInt32()
end
function CAttendFightActivityReq:sizepolicy(size)
  return size <= 65535
end
return CAttendFightActivityReq
