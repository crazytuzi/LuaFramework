local CAttendCommitItemActivityReq = class("CAttendCommitItemActivityReq")
CAttendCommitItemActivityReq.TYPEID = 12614147
function CAttendCommitItemActivityReq:ctor(activity_cfg_id)
  self.id = 12614147
  self.activity_cfg_id = activity_cfg_id or nil
end
function CAttendCommitItemActivityReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function CAttendCommitItemActivityReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function CAttendCommitItemActivityReq:sizepolicy(size)
  return size <= 65535
end
return CAttendCommitItemActivityReq
