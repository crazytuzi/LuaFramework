local SGetInviteFriendsRebateBindYuanbaoResp = class("SGetInviteFriendsRebateBindYuanbaoResp")
SGetInviteFriendsRebateBindYuanbaoResp.TYPEID = 12600350
SGetInviteFriendsRebateBindYuanbaoResp.ERR_NOT_ENOUGH = -1
SGetInviteFriendsRebateBindYuanbaoResp.ERR_DAILY_LIMIT = -2
function SGetInviteFriendsRebateBindYuanbaoResp:ctor(retcode, rebate_bind_yuanbao)
  self.id = 12600350
  self.retcode = retcode or nil
  self.rebate_bind_yuanbao = rebate_bind_yuanbao or nil
end
function SGetInviteFriendsRebateBindYuanbaoResp:marshal(os)
  os:marshalInt32(self.retcode)
  os:marshalInt64(self.rebate_bind_yuanbao)
end
function SGetInviteFriendsRebateBindYuanbaoResp:unmarshal(os)
  self.retcode = os:unmarshalInt32()
  self.rebate_bind_yuanbao = os:unmarshalInt64()
end
function SGetInviteFriendsRebateBindYuanbaoResp:sizepolicy(size)
  return size <= 65535
end
return SGetInviteFriendsRebateBindYuanbaoResp
