local AwardBean = require("netio.protocol.mzm.gsp.award.AwardBean")
local ParadeRoleInfo = require("netio.protocol.mzm.gsp.marriage.ParadeRoleInfo")
local SMarrigeParadeGetMoney = class("SMarrigeParadeGetMoney")
SMarrigeParadeGetMoney.TYPEID = 12599840
function SMarrigeParadeGetMoney:ctor(awardBean, role1Info, role2Info)
  self.id = 12599840
  self.awardBean = awardBean or AwardBean.new()
  self.role1Info = role1Info or ParadeRoleInfo.new()
  self.role2Info = role2Info or ParadeRoleInfo.new()
end
function SMarrigeParadeGetMoney:marshal(os)
  self.awardBean:marshal(os)
  self.role1Info:marshal(os)
  self.role2Info:marshal(os)
end
function SMarrigeParadeGetMoney:unmarshal(os)
  self.awardBean = AwardBean.new()
  self.awardBean:unmarshal(os)
  self.role1Info = ParadeRoleInfo.new()
  self.role1Info:unmarshal(os)
  self.role2Info = ParadeRoleInfo.new()
  self.role2Info:unmarshal(os)
end
function SMarrigeParadeGetMoney:sizepolicy(size)
  return size <= 65535
end
return SMarrigeParadeGetMoney
