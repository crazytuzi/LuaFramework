local AwardBean = require("netio.protocol.mzm.gsp.award.AwardBean")
local SFinishGangTaskeNotice = class("SFinishGangTaskeNotice")
SFinishGangTaskeNotice.TYPEID = 12587579
function SFinishGangTaskeNotice:ctor(targetAwardBean)
  self.id = 12587579
  self.targetAwardBean = targetAwardBean or AwardBean.new()
end
function SFinishGangTaskeNotice:marshal(os)
  self.targetAwardBean:marshal(os)
end
function SFinishGangTaskeNotice:unmarshal(os)
  self.targetAwardBean = AwardBean.new()
  self.targetAwardBean:unmarshal(os)
end
function SFinishGangTaskeNotice:sizepolicy(size)
  return size <= 65535
end
return SFinishGangTaskeNotice
