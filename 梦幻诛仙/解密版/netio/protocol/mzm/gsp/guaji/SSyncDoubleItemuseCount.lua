local SSyncDoubleItemuseCount = class("SSyncDoubleItemuseCount")
SSyncDoubleItemuseCount.TYPEID = 12591111
function SSyncDoubleItemuseCount:ctor(daycanusecount, weekcanusecount)
  self.id = 12591111
  self.daycanusecount = daycanusecount or nil
  self.weekcanusecount = weekcanusecount or nil
end
function SSyncDoubleItemuseCount:marshal(os)
  os:marshalInt32(self.daycanusecount)
  os:marshalInt32(self.weekcanusecount)
end
function SSyncDoubleItemuseCount:unmarshal(os)
  self.daycanusecount = os:unmarshalInt32()
  self.weekcanusecount = os:unmarshalInt32()
end
function SSyncDoubleItemuseCount:sizepolicy(size)
  return size <= 32
end
return SSyncDoubleItemuseCount
