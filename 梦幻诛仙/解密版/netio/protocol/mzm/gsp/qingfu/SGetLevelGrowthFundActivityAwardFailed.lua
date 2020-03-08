local SGetLevelGrowthFundActivityAwardFailed = class("SGetLevelGrowthFundActivityAwardFailed")
SGetLevelGrowthFundActivityAwardFailed.TYPEID = 12588815
SGetLevelGrowthFundActivityAwardFailed.ERROR_NOT_PURCHASE_FUND = -1
SGetLevelGrowthFundActivityAwardFailed.ERROR_LEVEL_NOT_MEET = -2
SGetLevelGrowthFundActivityAwardFailed.ERROR_ALREADY_GET_AWARD = -3
function SGetLevelGrowthFundActivityAwardFailed:ctor(activity_id, sortid, retcode)
  self.id = 12588815
  self.activity_id = activity_id or nil
  self.sortid = sortid or nil
  self.retcode = retcode or nil
end
function SGetLevelGrowthFundActivityAwardFailed:marshal(os)
  os:marshalInt32(self.activity_id)
  os:marshalInt32(self.sortid)
  os:marshalInt32(self.retcode)
end
function SGetLevelGrowthFundActivityAwardFailed:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
  self.sortid = os:unmarshalInt32()
  self.retcode = os:unmarshalInt32()
end
function SGetLevelGrowthFundActivityAwardFailed:sizepolicy(size)
  return size <= 65535
end
return SGetLevelGrowthFundActivityAwardFailed
