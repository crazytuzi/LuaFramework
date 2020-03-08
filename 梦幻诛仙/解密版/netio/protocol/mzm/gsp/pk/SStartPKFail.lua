local SStartPKFail = class("SStartPKFail")
SStartPKFail.TYPEID = 12619788
SStartPKFail.UNKNOWN = -1
SStartPKFail.PK_NOT_ENABLED = 1
SStartPKFail.LEVEL_TOO_LOW = 2
SStartPKFail.TEAM_CHANGED_AFTER_CONFIRMATION = 3
SStartPKFail.TARGET_TOO_FAR_AWAY = 4
SStartPKFail.IN_COMBAT = 5
SStartPKFail.TARGET_IN_SAFE_MAP = 6
SStartPKFail.IN_PROTECTION = 7
SStartPKFail.IN_FORCE_PROTECTION = 8
SStartPKFail.OTHER_STATUS_CONFLICT = 9
SStartPKFail.TARGET_IN_ABNORMAL_TEAM_STATE = 10
SStartPKFail.IN_OUT_PRISON_PROTECTION = 11
SStartPKFail.REACH_MAX_PK_TIMES = 12
SStartPKFail.ZERO_MORAL_VALUE = 13
function SStartPKFail:ctor(retcode, role_type, role_name)
  self.id = 12619788
  self.retcode = retcode or nil
  self.role_type = role_type or nil
  self.role_name = role_name or nil
end
function SStartPKFail:marshal(os)
  os:marshalInt32(self.retcode)
  os:marshalInt32(self.role_type)
  os:marshalOctets(self.role_name)
end
function SStartPKFail:unmarshal(os)
  self.retcode = os:unmarshalInt32()
  self.role_type = os:unmarshalInt32()
  self.role_name = os:unmarshalOctets()
end
function SStartPKFail:sizepolicy(size)
  return size <= 65535
end
return SStartPKFail
