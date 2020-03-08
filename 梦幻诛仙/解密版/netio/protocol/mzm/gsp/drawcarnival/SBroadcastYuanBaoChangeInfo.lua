local SBroadcastYuanBaoChangeInfo = class("SBroadcastYuanBaoChangeInfo")
SBroadcastYuanBaoChangeInfo.TYPEID = 12630023
function SBroadcastYuanBaoChangeInfo:ctor(award_pool_yuan_bao_count)
  self.id = 12630023
  self.award_pool_yuan_bao_count = award_pool_yuan_bao_count or nil
end
function SBroadcastYuanBaoChangeInfo:marshal(os)
  os:marshalInt64(self.award_pool_yuan_bao_count)
end
function SBroadcastYuanBaoChangeInfo:unmarshal(os)
  self.award_pool_yuan_bao_count = os:unmarshalInt64()
end
function SBroadcastYuanBaoChangeInfo:sizepolicy(size)
  return size <= 65535
end
return SBroadcastYuanBaoChangeInfo
