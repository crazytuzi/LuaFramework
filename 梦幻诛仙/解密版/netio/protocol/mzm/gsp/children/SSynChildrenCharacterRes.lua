local SSynChildrenCharacterRes = class("SSynChildrenCharacterRes")
SSynChildrenCharacterRes.TYPEID = 12609409
SSynChildrenCharacterRes.TIP_TYPE_NORMAL = 0
SSynChildrenCharacterRes.TIP_TYPE_FIGHT = 1
function SSynChildrenCharacterRes:ctor(childrenid, character, tipType)
  self.id = 12609409
  self.childrenid = childrenid or nil
  self.character = character or nil
  self.tipType = tipType or nil
end
function SSynChildrenCharacterRes:marshal(os)
  os:marshalInt64(self.childrenid)
  os:marshalInt32(self.character)
  os:marshalInt32(self.tipType)
end
function SSynChildrenCharacterRes:unmarshal(os)
  self.childrenid = os:unmarshalInt64()
  self.character = os:unmarshalInt32()
  self.tipType = os:unmarshalInt32()
end
function SSynChildrenCharacterRes:sizepolicy(size)
  return size <= 65535
end
return SSynChildrenCharacterRes
