local CLongjingUnMountReq = class("CLongjingUnMountReq")
CLongjingUnMountReq.TYPEID = 12595978
function CLongjingUnMountReq:ctor(fabaoType, pos)
  self.id = 12595978
  self.fabaoType = fabaoType or nil
  self.pos = pos or nil
end
function CLongjingUnMountReq:marshal(os)
  os:marshalInt32(self.fabaoType)
  os:marshalInt32(self.pos)
end
function CLongjingUnMountReq:unmarshal(os)
  self.fabaoType = os:unmarshalInt32()
  self.pos = os:unmarshalInt32()
end
function CLongjingUnMountReq:sizepolicy(size)
  return size <= 65535
end
return CLongjingUnMountReq
