local SSyncAllZhenfaInfo = class("SSyncAllZhenfaInfo")
SSyncAllZhenfaInfo.TYPEID = 12593153
function SSyncAllZhenfaInfo:ctor(ZhenfaBeanList)
  self.id = 12593153
  self.ZhenfaBeanList = ZhenfaBeanList or {}
end
function SSyncAllZhenfaInfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.ZhenfaBeanList))
  for _, v in ipairs(self.ZhenfaBeanList) do
    v:marshal(os)
  end
end
function SSyncAllZhenfaInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.zhenfa.ZhenfaBean")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.ZhenfaBeanList, v)
  end
end
function SSyncAllZhenfaInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncAllZhenfaInfo
