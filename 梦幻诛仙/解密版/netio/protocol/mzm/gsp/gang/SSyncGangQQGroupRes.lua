local SSyncGangQQGroupRes = class("SSyncGangQQGroupRes")
SSyncGangQQGroupRes.TYPEID = 12589948
function SSyncGangQQGroupRes:ctor(groupOpenId)
  self.id = 12589948
  self.groupOpenId = groupOpenId or nil
end
function SSyncGangQQGroupRes:marshal(os)
  os:marshalString(self.groupOpenId)
end
function SSyncGangQQGroupRes:unmarshal(os)
  self.groupOpenId = os:unmarshalString()
end
function SSyncGangQQGroupRes:sizepolicy(size)
  return size <= 65535
end
return SSyncGangQQGroupRes
