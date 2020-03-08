local SSyncNewGangPurpose = class("SSyncNewGangPurpose")
SSyncNewGangPurpose.TYPEID = 12589854
function SSyncNewGangPurpose:ctor(purpose)
  self.id = 12589854
  self.purpose = purpose or nil
end
function SSyncNewGangPurpose:marshal(os)
  os:marshalString(self.purpose)
end
function SSyncNewGangPurpose:unmarshal(os)
  self.purpose = os:unmarshalString()
end
function SSyncNewGangPurpose:sizepolicy(size)
  return size <= 65535
end
return SSyncNewGangPurpose
