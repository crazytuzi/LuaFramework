local CMakeWuQIFuReq = class("CMakeWuQIFuReq")
CMakeWuQIFuReq.TYPEID = 12589061
function CMakeWuQIFuReq:ctor(skillBagId, itemId)
  self.id = 12589061
  self.skillBagId = skillBagId or nil
  self.itemId = itemId or nil
end
function CMakeWuQIFuReq:marshal(os)
  os:marshalInt32(self.skillBagId)
  os:marshalInt32(self.itemId)
end
function CMakeWuQIFuReq:unmarshal(os)
  self.skillBagId = os:unmarshalInt32()
  self.itemId = os:unmarshalInt32()
end
function CMakeWuQIFuReq:sizepolicy(size)
  return size <= 65535
end
return CMakeWuQIFuReq
