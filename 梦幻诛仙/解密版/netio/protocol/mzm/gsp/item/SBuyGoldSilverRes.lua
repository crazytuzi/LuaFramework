local SBuyGoldSilverRes = class("SBuyGoldSilverRes")
SBuyGoldSilverRes.TYPEID = 12584789
function SBuyGoldSilverRes:ctor(yuanbaonum, moneytype, value)
  self.id = 12584789
  self.yuanbaonum = yuanbaonum or nil
  self.moneytype = moneytype or nil
  self.value = value or nil
end
function SBuyGoldSilverRes:marshal(os)
  os:marshalInt32(self.yuanbaonum)
  os:marshalInt32(self.moneytype)
  os:marshalInt32(self.value)
end
function SBuyGoldSilverRes:unmarshal(os)
  self.yuanbaonum = os:unmarshalInt32()
  self.moneytype = os:unmarshalInt32()
  self.value = os:unmarshalInt32()
end
function SBuyGoldSilverRes:sizepolicy(size)
  return size <= 65535
end
return SBuyGoldSilverRes
