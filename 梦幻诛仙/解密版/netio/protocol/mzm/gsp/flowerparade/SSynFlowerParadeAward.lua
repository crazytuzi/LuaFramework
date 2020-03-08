local AwardBean = require("netio.protocol.mzm.gsp.award.AwardBean")
local SSynFlowerParadeAward = class("SSynFlowerParadeAward")
SSynFlowerParadeAward.TYPEID = 12625679
SSynFlowerParadeAward.TYPE_FOLLOW = 1
SSynFlowerParadeAward.TYPE_DANCE = 2
function SSynFlowerParadeAward:ctor(awardType, award)
  self.id = 12625679
  self.awardType = awardType or nil
  self.award = award or AwardBean.new()
end
function SSynFlowerParadeAward:marshal(os)
  os:marshalInt32(self.awardType)
  self.award:marshal(os)
end
function SSynFlowerParadeAward:unmarshal(os)
  self.awardType = os:unmarshalInt32()
  self.award = AwardBean.new()
  self.award:unmarshal(os)
end
function SSynFlowerParadeAward:sizepolicy(size)
  return size <= 65535
end
return SSynFlowerParadeAward
