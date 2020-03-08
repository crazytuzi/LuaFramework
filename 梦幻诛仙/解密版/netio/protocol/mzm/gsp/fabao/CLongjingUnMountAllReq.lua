local CLongjingUnMountAllReq = class("CLongjingUnMountAllReq")
CLongjingUnMountAllReq.TYPEID = 12596011
function CLongjingUnMountAllReq:ctor(fabaoType)
  self.id = 12596011
  self.fabaoType = fabaoType or nil
end
function CLongjingUnMountAllReq:marshal(os)
  os:marshalInt32(self.fabaoType)
end
function CLongjingUnMountAllReq:unmarshal(os)
  self.fabaoType = os:unmarshalInt32()
end
function CLongjingUnMountAllReq:sizepolicy(size)
  return size <= 65535
end
return CLongjingUnMountAllReq
