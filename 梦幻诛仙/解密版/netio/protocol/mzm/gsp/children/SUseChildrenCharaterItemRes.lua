local SUseChildrenCharaterItemRes = class("SUseChildrenCharaterItemRes")
SUseChildrenCharaterItemRes.TYPEID = 12609410
function SUseChildrenCharaterItemRes:ctor(character, childrenid, itemKey)
  self.id = 12609410
  self.character = character or nil
  self.childrenid = childrenid or nil
  self.itemKey = itemKey or nil
end
function SUseChildrenCharaterItemRes:marshal(os)
  os:marshalInt32(self.character)
  os:marshalInt64(self.childrenid)
  os:marshalInt32(self.itemKey)
end
function SUseChildrenCharaterItemRes:unmarshal(os)
  self.character = os:unmarshalInt32()
  self.childrenid = os:unmarshalInt64()
  self.itemKey = os:unmarshalInt32()
end
function SUseChildrenCharaterItemRes:sizepolicy(size)
  return size <= 65535
end
return SUseChildrenCharaterItemRes
