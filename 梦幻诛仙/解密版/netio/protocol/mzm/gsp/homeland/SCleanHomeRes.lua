local SCleanHomeRes = class("SCleanHomeRes")
SCleanHomeRes.TYPEID = 12605487
function SCleanHomeRes:ctor(dayCleanCount, addCleanliness, area)
  self.id = 12605487
  self.dayCleanCount = dayCleanCount or nil
  self.addCleanliness = addCleanliness or nil
  self.area = area or nil
end
function SCleanHomeRes:marshal(os)
  os:marshalInt32(self.dayCleanCount)
  os:marshalInt32(self.addCleanliness)
  os:marshalInt32(self.area)
end
function SCleanHomeRes:unmarshal(os)
  self.dayCleanCount = os:unmarshalInt32()
  self.addCleanliness = os:unmarshalInt32()
  self.area = os:unmarshalInt32()
end
function SCleanHomeRes:sizepolicy(size)
  return size <= 65535
end
return SCleanHomeRes
