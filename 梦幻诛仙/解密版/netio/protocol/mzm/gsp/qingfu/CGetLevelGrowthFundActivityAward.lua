local CGetLevelGrowthFundActivityAward = class("CGetLevelGrowthFundActivityAward")
CGetLevelGrowthFundActivityAward.TYPEID = 12588811
function CGetLevelGrowthFundActivityAward:ctor(activity_id, sort_id)
  self.id = 12588811
  self.activity_id = activity_id or nil
  self.sort_id = sort_id or nil
end
function CGetLevelGrowthFundActivityAward:marshal(os)
  os:marshalInt32(self.activity_id)
  os:marshalInt32(self.sort_id)
end
function CGetLevelGrowthFundActivityAward:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
  self.sort_id = os:unmarshalInt32()
end
function CGetLevelGrowthFundActivityAward:sizepolicy(size)
  return size <= 65535
end
return CGetLevelGrowthFundActivityAward
