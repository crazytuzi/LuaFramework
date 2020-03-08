local AwardBean = require("netio.protocol.mzm.gsp.award.AwardBean")
local SKillBossAwardNotify = class("SKillBossAwardNotify")
SKillBossAwardNotify.TYPEID = 12613645
function SKillBossAwardNotify:ctor(bossid, award)
  self.id = 12613645
  self.bossid = bossid or nil
  self.award = award or AwardBean.new()
end
function SKillBossAwardNotify:marshal(os)
  os:marshalInt32(self.bossid)
  self.award:marshal(os)
end
function SKillBossAwardNotify:unmarshal(os)
  self.bossid = os:unmarshalInt32()
  self.award = AwardBean.new()
  self.award:unmarshal(os)
end
function SKillBossAwardNotify:sizepolicy(size)
  return size <= 65535
end
return SKillBossAwardNotify
