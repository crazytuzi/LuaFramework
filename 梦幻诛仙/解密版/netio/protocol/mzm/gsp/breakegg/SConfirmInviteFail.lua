local SConfirmInviteFail = class("SConfirmInviteFail")
SConfirmInviteFail.TYPEID = 12623366
SConfirmInviteFail.ERROR_SYSTEM = 1
SConfirmInviteFail.ERROR_USERID = 2
SConfirmInviteFail.ERROR_CFG = 3
SConfirmInviteFail.ERROR_PARAM = 4
SConfirmInviteFail.ERROR_ALREADY_IN = 5
SConfirmInviteFail.ERROR_INVITER_CANNOT_CHOOSE = 6
SConfirmInviteFail.ERROR_NOT_IN_RANGE = 7
SConfirmInviteFail.ERROR_TIME_OUT = 8
SConfirmInviteFail.ERROR_CHOOSED_ALREADY = 9
SConfirmInviteFail.ERROR_LEVEL_NOT_FIT = 10
function SConfirmInviteFail:ctor(invite_type, sessionid, error_code)
  self.id = 12623366
  self.invite_type = invite_type or nil
  self.sessionid = sessionid or nil
  self.error_code = error_code or nil
end
function SConfirmInviteFail:marshal(os)
  os:marshalInt32(self.invite_type)
  os:marshalInt64(self.sessionid)
  os:marshalInt32(self.error_code)
end
function SConfirmInviteFail:unmarshal(os)
  self.invite_type = os:unmarshalInt32()
  self.sessionid = os:unmarshalInt64()
  self.error_code = os:unmarshalInt32()
end
function SConfirmInviteFail:sizepolicy(size)
  return size <= 65535
end
return SConfirmInviteFail
