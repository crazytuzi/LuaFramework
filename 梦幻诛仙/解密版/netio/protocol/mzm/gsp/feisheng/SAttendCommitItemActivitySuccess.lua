local SAttendCommitItemActivitySuccess = class("SAttendCommitItemActivitySuccess")
SAttendCommitItemActivitySuccess.TYPEID = 12614145
function SAttendCommitItemActivitySuccess:ctor(activity_cfg_id)
  self.id = 12614145
  self.activity_cfg_id = activity_cfg_id or nil
end
function SAttendCommitItemActivitySuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function SAttendCommitItemActivitySuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function SAttendCommitItemActivitySuccess:sizepolicy(size)
  return size <= 65535
end
return SAttendCommitItemActivitySuccess
