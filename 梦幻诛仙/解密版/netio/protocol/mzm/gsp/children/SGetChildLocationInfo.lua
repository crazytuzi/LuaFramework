local SGetChildLocationInfo = class("SGetChildLocationInfo")
SGetChildLocationInfo.TYPEID = 12609431
SGetChildLocationInfo.IN_HOME = 0
SGetChildLocationInfo.IN_YARD = 1
SGetChildLocationInfo.MOTHER_CARRY = 2
SGetChildLocationInfo.FATHER_CARRY = 3
function SGetChildLocationInfo:ctor(child_id, location)
  self.id = 12609431
  self.child_id = child_id or nil
  self.location = location or nil
end
function SGetChildLocationInfo:marshal(os)
  os:marshalInt64(self.child_id)
  os:marshalInt32(self.location)
end
function SGetChildLocationInfo:unmarshal(os)
  self.child_id = os:unmarshalInt64()
  self.location = os:unmarshalInt32()
end
function SGetChildLocationInfo:sizepolicy(size)
  return size <= 65535
end
return SGetChildLocationInfo
