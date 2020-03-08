local AwardBean = require("netio.protocol.mzm.gsp.award.AwardBean")
local SChooseCardExtraRes = class("SChooseCardExtraRes")
SChooseCardExtraRes.TYPEID = 12612103
function SChooseCardExtraRes:ctor(constellation, index, award, extra_award)
  self.id = 12612103
  self.constellation = constellation or nil
  self.index = index or nil
  self.award = award or AwardBean.new()
  self.extra_award = extra_award or AwardBean.new()
end
function SChooseCardExtraRes:marshal(os)
  os:marshalInt32(self.constellation)
  os:marshalInt32(self.index)
  self.award:marshal(os)
  self.extra_award:marshal(os)
end
function SChooseCardExtraRes:unmarshal(os)
  self.constellation = os:unmarshalInt32()
  self.index = os:unmarshalInt32()
  self.award = AwardBean.new()
  self.award:unmarshal(os)
  self.extra_award = AwardBean.new()
  self.extra_award:unmarshal(os)
end
function SChooseCardExtraRes:sizepolicy(size)
  return size <= 65535
end
return SChooseCardExtraRes
