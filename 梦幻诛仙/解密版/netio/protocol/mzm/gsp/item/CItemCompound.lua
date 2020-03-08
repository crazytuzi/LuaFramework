local CItemCompound = class("CItemCompound")
CItemCompound.TYPEID = 12584727
function CItemCompound:ctor(uuid, itemnum)
  self.id = 12584727
  self.uuid = uuid or nil
  self.itemnum = itemnum or nil
end
function CItemCompound:marshal(os)
  os:marshalInt64(self.uuid)
  os:marshalInt32(self.itemnum)
end
function CItemCompound:unmarshal(os)
  self.uuid = os:unmarshalInt64()
  self.itemnum = os:unmarshalInt32()
end
function CItemCompound:sizepolicy(size)
  return size <= 65535
end
return CItemCompound
