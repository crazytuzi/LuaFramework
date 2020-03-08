local SGetInviteFriendsGiftResp = class("SGetInviteFriendsGiftResp")
SGetInviteFriendsGiftResp.TYPEID = 12600349
SGetInviteFriendsGiftResp.ERR_NOT_ENOUGH = -1
function SGetInviteFriendsGiftResp:ctor(retcode, award_gift_times)
  self.id = 12600349
  self.retcode = retcode or nil
  self.award_gift_times = award_gift_times or nil
end
function SGetInviteFriendsGiftResp:marshal(os)
  os:marshalInt32(self.retcode)
  os:marshalInt32(self.award_gift_times)
end
function SGetInviteFriendsGiftResp:unmarshal(os)
  self.retcode = os:unmarshalInt32()
  self.award_gift_times = os:unmarshalInt32()
end
function SGetInviteFriendsGiftResp:sizepolicy(size)
  return size <= 65535
end
return SGetInviteFriendsGiftResp
