local AwardBean = require("netio.protocol.mzm.gsp.award.AwardBean")
local SFightAwardTipRes = class("SFightAwardTipRes")
SFightAwardTipRes.TYPEID = 12607262
function SFightAwardTipRes:ctor(fightCountAwardInfo)
  self.id = 12607262
  self.fightCountAwardInfo = fightCountAwardInfo or AwardBean.new()
end
function SFightAwardTipRes:marshal(os)
  self.fightCountAwardInfo:marshal(os)
end
function SFightAwardTipRes:unmarshal(os)
  self.fightCountAwardInfo = AwardBean.new()
  self.fightCountAwardInfo:unmarshal(os)
end
function SFightAwardTipRes:sizepolicy(size)
  return size <= 65535
end
return SFightAwardTipRes
