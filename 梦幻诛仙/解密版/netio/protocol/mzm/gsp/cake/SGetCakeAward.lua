local AwardBean = require("netio.protocol.mzm.gsp.award.AwardBean")
local SGetCakeAward = class("SGetCakeAward")
SGetCakeAward.TYPEID = 12627724
SGetCakeAward.ITEM_BELONG_TYPE__SELF = 1
SGetCakeAward.ITEM_BELONG_TYPE__OTHER = 2
function SGetCakeAward:ctor(belongType, awardBean, leftNum)
  self.id = 12627724
  self.belongType = belongType or nil
  self.awardBean = awardBean or AwardBean.new()
  self.leftNum = leftNum or nil
end
function SGetCakeAward:marshal(os)
  os:marshalInt32(self.belongType)
  self.awardBean:marshal(os)
  os:marshalInt32(self.leftNum)
end
function SGetCakeAward:unmarshal(os)
  self.belongType = os:unmarshalInt32()
  self.awardBean = AwardBean.new()
  self.awardBean:unmarshal(os)
  self.leftNum = os:unmarshalInt32()
end
function SGetCakeAward:sizepolicy(size)
  return size <= 65535
end
return SGetCakeAward
