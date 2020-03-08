local SSynCleanlinessRes = class("SSynCleanlinessRes")
SSynCleanlinessRes.TYPEID = 12605452
function SSynCleanlinessRes:ctor(dayCleanCount, cleanliness, area)
  self.id = 12605452
  self.dayCleanCount = dayCleanCount or nil
  self.cleanliness = cleanliness or nil
  self.area = area or nil
end
function SSynCleanlinessRes:marshal(os)
  os:marshalInt32(self.dayCleanCount)
  os:marshalInt32(self.cleanliness)
  os:marshalInt32(self.area)
end
function SSynCleanlinessRes:unmarshal(os)
  self.dayCleanCount = os:unmarshalInt32()
  self.cleanliness = os:unmarshalInt32()
  self.area = os:unmarshalInt32()
end
function SSynCleanlinessRes:sizepolicy(size)
  return size <= 65535
end
return SSynCleanlinessRes
