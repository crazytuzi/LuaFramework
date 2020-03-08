local AwardBean = require("netio.protocol.mzm.gsp.award.AwardBean")
local SUseGiftBagItemRes = class("SUseGiftBagItemRes")
SUseGiftBagItemRes.TYPEID = 12584763
function SUseGiftBagItemRes:ctor(itemid, usednum, awardbean)
  self.id = 12584763
  self.itemid = itemid or nil
  self.usednum = usednum or nil
  self.awardbean = awardbean or AwardBean.new()
end
function SUseGiftBagItemRes:marshal(os)
  os:marshalInt32(self.itemid)
  os:marshalInt32(self.usednum)
  self.awardbean:marshal(os)
end
function SUseGiftBagItemRes:unmarshal(os)
  self.itemid = os:unmarshalInt32()
  self.usednum = os:unmarshalInt32()
  self.awardbean = AwardBean.new()
  self.awardbean:unmarshal(os)
end
function SUseGiftBagItemRes:sizepolicy(size)
  return size <= 65535
end
return SUseGiftBagItemRes
