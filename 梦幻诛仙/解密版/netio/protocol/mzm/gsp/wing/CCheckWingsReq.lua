local CCheckWingsReq = class("CCheckWingsReq")
CCheckWingsReq.TYPEID = 12596542
function CCheckWingsReq:ctor(roleId, cfgId)
  self.id = 12596542
  self.roleId = roleId or nil
  self.cfgId = cfgId or nil
end
function CCheckWingsReq:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalInt32(self.cfgId)
end
function CCheckWingsReq:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.cfgId = os:unmarshalInt32()
end
function CCheckWingsReq:sizepolicy(size)
  return size <= 65535
end
return CCheckWingsReq
