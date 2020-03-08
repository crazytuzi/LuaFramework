local SAttendCommitPetActivitySuccess = class("SAttendCommitPetActivitySuccess")
SAttendCommitPetActivitySuccess.TYPEID = 12614168
function SAttendCommitPetActivitySuccess:ctor(activity_cfg_id)
  self.id = 12614168
  self.activity_cfg_id = activity_cfg_id or nil
end
function SAttendCommitPetActivitySuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function SAttendCommitPetActivitySuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function SAttendCommitPetActivitySuccess:sizepolicy(size)
  return size <= 65535
end
return SAttendCommitPetActivitySuccess
