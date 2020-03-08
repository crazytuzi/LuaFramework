local SAddVigorRes = class("SAddVigorRes")
SAddVigorRes.TYPEID = 12605474
function SAddVigorRes:ctor(addVigorNum, dayRestoreVigorCount)
  self.id = 12605474
  self.addVigorNum = addVigorNum or nil
  self.dayRestoreVigorCount = dayRestoreVigorCount or nil
end
function SAddVigorRes:marshal(os)
  os:marshalInt32(self.addVigorNum)
  os:marshalInt32(self.dayRestoreVigorCount)
end
function SAddVigorRes:unmarshal(os)
  self.addVigorNum = os:unmarshalInt32()
  self.dayRestoreVigorCount = os:unmarshalInt32()
end
function SAddVigorRes:sizepolicy(size)
  return size <= 65535
end
return SAddVigorRes
