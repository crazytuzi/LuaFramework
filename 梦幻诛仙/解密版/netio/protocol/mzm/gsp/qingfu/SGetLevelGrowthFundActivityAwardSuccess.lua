local SGetLevelGrowthFundActivityAwardSuccess = class("SGetLevelGrowthFundActivityAwardSuccess")
SGetLevelGrowthFundActivityAwardSuccess.TYPEID = 12588816
function SGetLevelGrowthFundActivityAwardSuccess:ctor(activity_id, sortid)
  self.id = 12588816
  self.activity_id = activity_id or nil
  self.sortid = sortid or nil
end
function SGetLevelGrowthFundActivityAwardSuccess:marshal(os)
  os:marshalInt32(self.activity_id)
  os:marshalInt32(self.sortid)
end
function SGetLevelGrowthFundActivityAwardSuccess:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
  self.sortid = os:unmarshalInt32()
end
function SGetLevelGrowthFundActivityAwardSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetLevelGrowthFundActivityAwardSuccess
