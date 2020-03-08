local SUseMoshuFragmentRes = class("SUseMoshuFragmentRes")
SUseMoshuFragmentRes.TYPEID = 12584844
function SUseMoshuFragmentRes:ctor(itemId, cutItemNum, exchangeType)
  self.id = 12584844
  self.itemId = itemId or nil
  self.cutItemNum = cutItemNum or nil
  self.exchangeType = exchangeType or nil
end
function SUseMoshuFragmentRes:marshal(os)
  os:marshalInt32(self.itemId)
  os:marshalInt32(self.cutItemNum)
  os:marshalInt32(self.exchangeType)
end
function SUseMoshuFragmentRes:unmarshal(os)
  self.itemId = os:unmarshalInt32()
  self.cutItemNum = os:unmarshalInt32()
  self.exchangeType = os:unmarshalInt32()
end
function SUseMoshuFragmentRes:sizepolicy(size)
  return size <= 65535
end
return SUseMoshuFragmentRes
