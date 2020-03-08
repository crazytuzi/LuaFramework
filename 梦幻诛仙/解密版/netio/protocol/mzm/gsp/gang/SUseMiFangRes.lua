local SUseMiFangRes = class("SUseMiFangRes")
SUseMiFangRes.TYPEID = 12589920
function SUseMiFangRes:ctor(itemId)
  self.id = 12589920
  self.itemId = itemId or nil
end
function SUseMiFangRes:marshal(os)
  os:marshalInt32(self.itemId)
end
function SUseMiFangRes:unmarshal(os)
  self.itemId = os:unmarshalInt32()
end
function SUseMiFangRes:sizepolicy(size)
  return size <= 65535
end
return SUseMiFangRes
