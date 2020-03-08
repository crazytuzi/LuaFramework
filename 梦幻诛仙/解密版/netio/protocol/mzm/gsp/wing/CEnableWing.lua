local CEnableWing = class("CEnableWing")
CEnableWing.TYPEID = 12596489
function CEnableWing:ctor(index)
  self.id = 12596489
  self.index = index or nil
end
function CEnableWing:marshal(os)
  os:marshalInt32(self.index)
end
function CEnableWing:unmarshal(os)
  self.index = os:unmarshalInt32()
end
function CEnableWing:sizepolicy(size)
  return size <= 65535
end
return CEnableWing
