local SAttendCommitPetActivityFail = class("SAttendCommitPetActivityFail")
SAttendCommitPetActivityFail.TYPEID = 12614166
SAttendCommitPetActivityFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SAttendCommitPetActivityFail.ROLE_STATUS_ERROR = -2
SAttendCommitPetActivityFail.PARAM_ERROR = -3
SAttendCommitPetActivityFail.CHECK_NPC_SERVICE_ERROR = -4
SAttendCommitPetActivityFail.SERVER_LEVEL_NOT_ENOUGH = -5
SAttendCommitPetActivityFail.CAN_NOT_JOIN_ACTIVITY = 1
SAttendCommitPetActivityFail.PET_NOT_ENOUGH = 2
SAttendCommitPetActivityFail.AWARD_FAIL = 3
function SAttendCommitPetActivityFail:ctor(res)
  self.id = 12614166
  self.res = res or nil
end
function SAttendCommitPetActivityFail:marshal(os)
  os:marshalInt32(self.res)
end
function SAttendCommitPetActivityFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SAttendCommitPetActivityFail:sizepolicy(size)
  return size <= 65535
end
return SAttendCommitPetActivityFail
