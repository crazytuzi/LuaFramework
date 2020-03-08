local SGetChuShiApprenticeSuccess = class("SGetChuShiApprenticeSuccess")
SGetChuShiApprenticeSuccess.TYPEID = 12601612
function SGetChuShiApprenticeSuccess:ctor(chuShiApprenticeListInfo)
  self.id = 12601612
  self.chuShiApprenticeListInfo = chuShiApprenticeListInfo or {}
end
function SGetChuShiApprenticeSuccess:marshal(os)
  os:marshalCompactUInt32(table.getn(self.chuShiApprenticeListInfo))
  for _, v in ipairs(self.chuShiApprenticeListInfo) do
    v:marshal(os)
  end
end
function SGetChuShiApprenticeSuccess:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.shitu.ShiTuRoleInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.chuShiApprenticeListInfo, v)
  end
end
function SGetChuShiApprenticeSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetChuShiApprenticeSuccess
