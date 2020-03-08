local SResetAddPotentialPrefRes = class("SResetAddPotentialPrefRes")
SResetAddPotentialPrefRes.TYPEID = 12609399
function SResetAddPotentialPrefRes:ctor(childrenid)
  self.id = 12609399
  self.childrenid = childrenid or nil
end
function SResetAddPotentialPrefRes:marshal(os)
  os:marshalInt64(self.childrenid)
end
function SResetAddPotentialPrefRes:unmarshal(os)
  self.childrenid = os:unmarshalInt64()
end
function SResetAddPotentialPrefRes:sizepolicy(size)
  return size <= 65535
end
return SResetAddPotentialPrefRes
