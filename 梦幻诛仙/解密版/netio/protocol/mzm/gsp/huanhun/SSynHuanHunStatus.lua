local SSynHuanHunStatus = class("SSynHuanHunStatus")
SSynHuanHunStatus.TYPEID = 12584460
function SSynHuanHunStatus:ctor(status)
  self.id = 12584460
  self.status = status or nil
end
function SSynHuanHunStatus:marshal(os)
  os:marshalInt32(self.status)
end
function SSynHuanHunStatus:unmarshal(os)
  self.status = os:unmarshalInt32()
end
function SSynHuanHunStatus:sizepolicy(size)
  return size <= 65535
end
return SSynHuanHunStatus
