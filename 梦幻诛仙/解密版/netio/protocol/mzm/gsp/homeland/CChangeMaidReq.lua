local CChangeMaidReq = class("CChangeMaidReq")
CChangeMaidReq.TYPEID = 12605472
function CChangeMaidReq:ctor(maidUuid)
  self.id = 12605472
  self.maidUuid = maidUuid or nil
end
function CChangeMaidReq:marshal(os)
  os:marshalInt64(self.maidUuid)
end
function CChangeMaidReq:unmarshal(os)
  self.maidUuid = os:unmarshalInt64()
end
function CChangeMaidReq:sizepolicy(size)
  return size <= 65535
end
return CChangeMaidReq
