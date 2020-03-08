local CLongjingUpLevelReq = class("CLongjingUpLevelReq")
CLongjingUpLevelReq.TYPEID = 12596017
function CLongjingUpLevelReq:ctor(fabaoType, pos)
  self.id = 12596017
  self.fabaoType = fabaoType or nil
  self.pos = pos or nil
end
function CLongjingUpLevelReq:marshal(os)
  os:marshalInt32(self.fabaoType)
  os:marshalInt32(self.pos)
end
function CLongjingUpLevelReq:unmarshal(os)
  self.fabaoType = os:unmarshalInt32()
  self.pos = os:unmarshalInt32()
end
function CLongjingUpLevelReq:sizepolicy(size)
  return size <= 65535
end
return CLongjingUpLevelReq
