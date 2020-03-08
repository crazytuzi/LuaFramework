local SGetInviteFriendsInfoResp = class("SGetInviteFriendsInfoResp")
SGetInviteFriendsInfoResp.TYPEID = 12600351
function SGetInviteFriendsInfoResp:ctor(invite_code, invitee_num, award_gift_times, rebate_bind_yuanbao)
  self.id = 12600351
  self.invite_code = invite_code or nil
  self.invitee_num = invitee_num or nil
  self.award_gift_times = award_gift_times or nil
  self.rebate_bind_yuanbao = rebate_bind_yuanbao or nil
end
function SGetInviteFriendsInfoResp:marshal(os)
  os:marshalOctets(self.invite_code)
  os:marshalInt32(self.invitee_num)
  os:marshalInt32(self.award_gift_times)
  os:marshalInt64(self.rebate_bind_yuanbao)
end
function SGetInviteFriendsInfoResp:unmarshal(os)
  self.invite_code = os:unmarshalOctets()
  self.invitee_num = os:unmarshalInt32()
  self.award_gift_times = os:unmarshalInt32()
  self.rebate_bind_yuanbao = os:unmarshalInt64()
end
function SGetInviteFriendsInfoResp:sizepolicy(size)
  return size <= 65535
end
return SGetInviteFriendsInfoResp
