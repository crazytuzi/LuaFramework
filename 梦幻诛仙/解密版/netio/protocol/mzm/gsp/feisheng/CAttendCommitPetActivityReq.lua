local CAttendCommitPetActivityReq = class("CAttendCommitPetActivityReq")
CAttendCommitPetActivityReq.TYPEID = 12614164
function CAttendCommitPetActivityReq:ctor(activity_cfg_id)
  self.id = 12614164
  self.activity_cfg_id = activity_cfg_id or nil
end
function CAttendCommitPetActivityReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function CAttendCommitPetActivityReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function CAttendCommitPetActivityReq:sizepolicy(size)
  return size <= 65535
end
return CAttendCommitPetActivityReq
