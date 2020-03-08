local CObserveFightReq = class("CObserveFightReq")
CObserveFightReq.TYPEID = 12594179
function CObserveFightReq:ctor(roleid)
  self.id = 12594179
  self.roleid = roleid or nil
end
function CObserveFightReq:marshal(os)
  os:marshalInt64(self.roleid)
end
function CObserveFightReq:unmarshal(os)
  self.roleid = os:unmarshalInt64()
end
function CObserveFightReq:sizepolicy(size)
  return size <= 65535
end
return CObserveFightReq
