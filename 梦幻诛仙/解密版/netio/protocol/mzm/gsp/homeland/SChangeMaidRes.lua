local SChangeMaidRes = class("SChangeMaidRes")
SChangeMaidRes.TYPEID = 12605476
function SChangeMaidRes:ctor(maidUuid)
  self.id = 12605476
  self.maidUuid = maidUuid or nil
end
function SChangeMaidRes:marshal(os)
  os:marshalInt64(self.maidUuid)
end
function SChangeMaidRes:unmarshal(os)
  self.maidUuid = os:unmarshalInt64()
end
function SChangeMaidRes:sizepolicy(size)
  return size <= 65535
end
return SChangeMaidRes
