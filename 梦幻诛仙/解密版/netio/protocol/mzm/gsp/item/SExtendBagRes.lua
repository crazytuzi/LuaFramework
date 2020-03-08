local SExtendBagRes = class("SExtendBagRes")
SExtendBagRes.TYPEID = 12584722
function SExtendBagRes:ctor(bagid, capcity)
  self.id = 12584722
  self.bagid = bagid or nil
  self.capcity = capcity or nil
end
function SExtendBagRes:marshal(os)
  os:marshalInt32(self.bagid)
  os:marshalInt32(self.capcity)
end
function SExtendBagRes:unmarshal(os)
  self.bagid = os:unmarshalInt32()
  self.capcity = os:unmarshalInt32()
end
function SExtendBagRes:sizepolicy(size)
  return size <= 65535
end
return SExtendBagRes
