local AwardBean = require("netio.protocol.mzm.gsp.award.AwardBean")
local SChooseCardNormalRes = class("SChooseCardNormalRes")
SChooseCardNormalRes.TYPEID = 12612105
function SChooseCardNormalRes:ctor(constellation, index, award)
  self.id = 12612105
  self.constellation = constellation or nil
  self.index = index or nil
  self.award = award or AwardBean.new()
end
function SChooseCardNormalRes:marshal(os)
  os:marshalInt32(self.constellation)
  os:marshalInt32(self.index)
  self.award:marshal(os)
end
function SChooseCardNormalRes:unmarshal(os)
  self.constellation = os:unmarshalInt32()
  self.index = os:unmarshalInt32()
  self.award = AwardBean.new()
  self.award:unmarshal(os)
end
function SChooseCardNormalRes:sizepolicy(size)
  return size <= 65535
end
return SChooseCardNormalRes
