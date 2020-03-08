local SConditionTimeOutRes = class("SConditionTimeOutRes")
SConditionTimeOutRes.TYPEID = 12601444
function SConditionTimeOutRes:ctor(subid, index)
  self.id = 12601444
  self.subid = subid or nil
  self.index = index or nil
end
function SConditionTimeOutRes:marshal(os)
  os:marshalInt32(self.subid)
  os:marshalInt32(self.index)
end
function SConditionTimeOutRes:unmarshal(os)
  self.subid = os:unmarshalInt32()
  self.index = os:unmarshalInt32()
end
function SConditionTimeOutRes:sizepolicy(size)
  return size <= 65535
end
return SConditionTimeOutRes
