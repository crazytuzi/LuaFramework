local CResetWing = class("CResetWing")
CResetWing.TYPEID = 12596506
function CResetWing:ctor(index)
  self.id = 12596506
  self.index = index or nil
end
function CResetWing:marshal(os)
  os:marshalInt32(self.index)
end
function CResetWing:unmarshal(os)
  self.index = os:unmarshalInt32()
end
function CResetWing:sizepolicy(size)
  return size <= 65535
end
return CResetWing
