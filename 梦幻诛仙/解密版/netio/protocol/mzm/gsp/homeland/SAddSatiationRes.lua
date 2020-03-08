local SAddSatiationRes = class("SAddSatiationRes")
SAddSatiationRes.TYPEID = 12605446
function SAddSatiationRes:ctor(addSatiationNum, dayRestoreSatiationCount)
  self.id = 12605446
  self.addSatiationNum = addSatiationNum or nil
  self.dayRestoreSatiationCount = dayRestoreSatiationCount or nil
end
function SAddSatiationRes:marshal(os)
  os:marshalInt32(self.addSatiationNum)
  os:marshalInt32(self.dayRestoreSatiationCount)
end
function SAddSatiationRes:unmarshal(os)
  self.addSatiationNum = os:unmarshalInt32()
  self.dayRestoreSatiationCount = os:unmarshalInt32()
end
function SAddSatiationRes:sizepolicy(size)
  return size <= 65535
end
return SAddSatiationRes
