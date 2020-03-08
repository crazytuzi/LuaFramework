local CCancelWing = class("CCancelWing")
CCancelWing.TYPEID = 12596481
function CCancelWing:ctor(index)
  self.id = 12596481
  self.index = index or nil
end
function CCancelWing:marshal(os)
  os:marshalInt32(self.index)
end
function CCancelWing:unmarshal(os)
  self.index = os:unmarshalInt32()
end
function CCancelWing:sizepolicy(size)
  return size <= 65535
end
return CCancelWing
