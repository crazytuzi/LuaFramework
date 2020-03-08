local SItemFromBaitanOrShanhuiRes = class("SItemFromBaitanOrShanhuiRes")
SItemFromBaitanOrShanhuiRes.TYPEID = 12584830
function SItemFromBaitanOrShanhuiRes:ctor(baitanorshanghui)
  self.id = 12584830
  self.baitanorshanghui = baitanorshanghui or nil
end
function SItemFromBaitanOrShanhuiRes:marshal(os)
  os:marshalInt32(self.baitanorshanghui)
end
function SItemFromBaitanOrShanhuiRes:unmarshal(os)
  self.baitanorshanghui = os:unmarshalInt32()
end
function SItemFromBaitanOrShanhuiRes:sizepolicy(size)
  return size <= 65535
end
return SItemFromBaitanOrShanhuiRes
