local SSynHasCustomizedRes = class("SSynHasCustomizedRes")
SSynHasCustomizedRes.TYPEID = 12601436
function SSynHasCustomizedRes:ctor(subid, index, pubOrsell)
  self.id = 12601436
  self.subid = subid or nil
  self.index = index or nil
  self.pubOrsell = pubOrsell or nil
end
function SSynHasCustomizedRes:marshal(os)
  os:marshalInt32(self.subid)
  os:marshalInt32(self.index)
  os:marshalInt32(self.pubOrsell)
end
function SSynHasCustomizedRes:unmarshal(os)
  self.subid = os:unmarshalInt32()
  self.index = os:unmarshalInt32()
  self.pubOrsell = os:unmarshalInt32()
end
function SSynHasCustomizedRes:sizepolicy(size)
  return size <= 65535
end
return SSynHasCustomizedRes
