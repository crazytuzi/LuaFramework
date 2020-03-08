local SBreakEggInviteFail = class("SBreakEggInviteFail")
SBreakEggInviteFail.TYPEID = 12623365
SBreakEggInviteFail.ERROR_SYSTEM = 1
SBreakEggInviteFail.ERROR_USERID = 2
SBreakEggInviteFail.ERROR_CFG = 3
SBreakEggInviteFail.ERROR_PARAM = 4
SBreakEggInviteFail.ERROR_NO_TIMES = 5
SBreakEggInviteFail.ERROR_IN_INVITE = 6
SBreakEggInviteFail.ERROR_NOT_IN_GANG = 7
function SBreakEggInviteFail:ctor(activity_id, error_code)
  self.id = 12623365
  self.activity_id = activity_id or nil
  self.error_code = error_code or nil
end
function SBreakEggInviteFail:marshal(os)
  os:marshalInt32(self.activity_id)
  os:marshalInt32(self.error_code)
end
function SBreakEggInviteFail:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
  self.error_code = os:unmarshalInt32()
end
function SBreakEggInviteFail:sizepolicy(size)
  return size <= 65535
end
return SBreakEggInviteFail
