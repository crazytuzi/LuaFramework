local CUseDrug = class("CUseDrug")
CUseDrug.TYPEID = 12586015
function CUseDrug:ctor(itemKey, bagid)
  self.id = 12586015
  self.itemKey = itemKey or nil
  self.bagid = bagid or nil
end
function CUseDrug:marshal(os)
  os:marshalInt32(self.itemKey)
  os:marshalInt32(self.bagid)
end
function CUseDrug:unmarshal(os)
  self.itemKey = os:unmarshalInt32()
  self.bagid = os:unmarshalInt32()
end
function CUseDrug:sizepolicy(size)
  return size <= 65535
end
return CUseDrug
