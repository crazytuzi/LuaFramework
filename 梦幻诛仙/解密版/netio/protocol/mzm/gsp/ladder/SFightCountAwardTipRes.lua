local AwardBean = require("netio.protocol.mzm.gsp.award.AwardBean")
local SFightCountAwardTipRes = class("SFightCountAwardTipRes")
SFightCountAwardTipRes.TYPEID = 12607261
function SFightCountAwardTipRes:ctor(fightCountAwardInfo, count)
  self.id = 12607261
  self.fightCountAwardInfo = fightCountAwardInfo or AwardBean.new()
  self.count = count or nil
end
function SFightCountAwardTipRes:marshal(os)
  self.fightCountAwardInfo:marshal(os)
  os:marshalInt32(self.count)
end
function SFightCountAwardTipRes:unmarshal(os)
  self.fightCountAwardInfo = AwardBean.new()
  self.fightCountAwardInfo:unmarshal(os)
  self.count = os:unmarshalInt32()
end
function SFightCountAwardTipRes:sizepolicy(size)
  return size <= 65535
end
return SFightCountAwardTipRes
