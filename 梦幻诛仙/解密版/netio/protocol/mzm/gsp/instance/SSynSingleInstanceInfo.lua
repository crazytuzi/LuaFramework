local SSynSingleInstanceInfo = class("SSynSingleInstanceInfo")
SSynSingleInstanceInfo.TYPEID = 12591386
function SSynSingleInstanceInfo:ctor(singleInstanceInfo, singleFailTime)
  self.id = 12591386
  self.singleInstanceInfo = singleInstanceInfo or {}
  self.singleFailTime = singleFailTime or nil
end
function SSynSingleInstanceInfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.singleInstanceInfo))
  for _, v in ipairs(self.singleInstanceInfo) do
    v:marshal(os)
  end
  os:marshalInt32(self.singleFailTime)
end
function SSynSingleInstanceInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.instance.SingleInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.singleInstanceInfo, v)
  end
  self.singleFailTime = os:unmarshalInt32()
end
function SSynSingleInstanceInfo:sizepolicy(size)
  return size <= 65535
end
return SSynSingleInstanceInfo
