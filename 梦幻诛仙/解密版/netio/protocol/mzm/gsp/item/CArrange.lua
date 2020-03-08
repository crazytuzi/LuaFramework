local CArrange = class("CArrange")
CArrange.TYPEID = 12584743
function CArrange:ctor(bagid)
  self.id = 12584743
  self.bagid = bagid or nil
end
function CArrange:marshal(os)
  os:marshalInt32(self.bagid)
end
function CArrange:unmarshal(os)
  self.bagid = os:unmarshalInt32()
end
function CArrange:sizepolicy(size)
  return size <= 65535
end
return CArrange
