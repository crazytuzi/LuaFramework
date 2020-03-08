local SSyncBaoShiDuInfo = class("SSyncBaoShiDuInfo")
SSyncBaoShiDuInfo.TYPEID = 12585989
function SSyncBaoShiDuInfo:ctor(baoshudu)
  self.id = 12585989
  self.baoshudu = baoshudu or nil
end
function SSyncBaoShiDuInfo:marshal(os)
  os:marshalInt32(self.baoshudu)
end
function SSyncBaoShiDuInfo:unmarshal(os)
  self.baoshudu = os:unmarshalInt32()
end
function SSyncBaoShiDuInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncBaoShiDuInfo
