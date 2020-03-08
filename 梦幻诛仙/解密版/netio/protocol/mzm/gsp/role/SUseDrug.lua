local SUseDrug = class("SUseDrug")
SUseDrug.TYPEID = 12586006
function SUseDrug:ctor(itemKey, bagid, drugBuffId, collisionBuffId)
  self.id = 12586006
  self.itemKey = itemKey or nil
  self.bagid = bagid or nil
  self.drugBuffId = drugBuffId or nil
  self.collisionBuffId = collisionBuffId or nil
end
function SUseDrug:marshal(os)
  os:marshalInt32(self.itemKey)
  os:marshalInt32(self.bagid)
  os:marshalInt32(self.drugBuffId)
  os:marshalInt32(self.collisionBuffId)
end
function SUseDrug:unmarshal(os)
  self.itemKey = os:unmarshalInt32()
  self.bagid = os:unmarshalInt32()
  self.drugBuffId = os:unmarshalInt32()
  self.collisionBuffId = os:unmarshalInt32()
end
function SUseDrug:sizepolicy(size)
  return size <= 65535
end
return SUseDrug
