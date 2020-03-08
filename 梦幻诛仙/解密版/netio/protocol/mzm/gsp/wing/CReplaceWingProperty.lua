local CReplaceWingProperty = class("CReplaceWingProperty")
CReplaceWingProperty.TYPEID = 12596488
function CReplaceWingProperty:ctor(index)
  self.id = 12596488
  self.index = index or nil
end
function CReplaceWingProperty:marshal(os)
  os:marshalInt32(self.index)
end
function CReplaceWingProperty:unmarshal(os)
  self.index = os:unmarshalInt32()
end
function CReplaceWingProperty:sizepolicy(size)
  return size <= 65535
end
return CReplaceWingProperty
