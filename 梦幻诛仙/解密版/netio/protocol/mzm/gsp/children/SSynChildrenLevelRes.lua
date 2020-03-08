local SSynChildrenLevelRes = class("SSynChildrenLevelRes")
SSynChildrenLevelRes.TYPEID = 12609429
function SSynChildrenLevelRes:ctor(childrenid, level)
  self.id = 12609429
  self.childrenid = childrenid or nil
  self.level = level or nil
end
function SSynChildrenLevelRes:marshal(os)
  os:marshalInt64(self.childrenid)
  os:marshalInt32(self.level)
end
function SSynChildrenLevelRes:unmarshal(os)
  self.childrenid = os:unmarshalInt64()
  self.level = os:unmarshalInt32()
end
function SSynChildrenLevelRes:sizepolicy(size)
  return size <= 65535
end
return SSynChildrenLevelRes
