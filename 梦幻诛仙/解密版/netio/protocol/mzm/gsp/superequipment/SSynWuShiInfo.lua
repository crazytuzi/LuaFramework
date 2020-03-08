local SSynWuShiInfo = class("SSynWuShiInfo")
SSynWuShiInfo.TYPEID = 12618777
function SSynWuShiInfo:ctor(wuShiInfos)
  self.id = 12618777
  self.wuShiInfos = wuShiInfos or {}
end
function SSynWuShiInfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.wuShiInfos))
  for _, v in ipairs(self.wuShiInfos) do
    v:marshal(os)
  end
end
function SSynWuShiInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.superequipment.WuShiInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.wuShiInfos, v)
  end
end
function SSynWuShiInfo:sizepolicy(size)
  return size <= 65535
end
return SSynWuShiInfo
