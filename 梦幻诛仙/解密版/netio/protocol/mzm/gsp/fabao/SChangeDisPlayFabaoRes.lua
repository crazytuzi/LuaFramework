local SChangeDisPlayFabaoRes = class("SChangeDisPlayFabaoRes")
SChangeDisPlayFabaoRes.TYPEID = 12595992
function SChangeDisPlayFabaoRes:ctor(faobaotype)
  self.id = 12595992
  self.faobaotype = faobaotype or nil
end
function SChangeDisPlayFabaoRes:marshal(os)
  os:marshalInt32(self.faobaotype)
end
function SChangeDisPlayFabaoRes:unmarshal(os)
  self.faobaotype = os:unmarshalInt32()
end
function SChangeDisPlayFabaoRes:sizepolicy(size)
  return size <= 65535
end
return SChangeDisPlayFabaoRes
