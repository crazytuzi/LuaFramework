local SSyncActivityCompensates = class("SSyncActivityCompensates")
SSyncActivityCompensates.TYPEID = 12627460
function SSyncActivityCompensates:ctor(compensates)
  self.id = 12627460
  self.compensates = compensates or {}
end
function SSyncActivityCompensates:marshal(os)
  os:marshalCompactUInt32(table.getn(self.compensates))
  for _, v in ipairs(self.compensates) do
    v:marshal(os)
  end
end
function SSyncActivityCompensates:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.activitycompensate.ActivityCompensate")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.compensates, v)
  end
end
function SSyncActivityCompensates:sizepolicy(size)
  return size <= 65535
end
return SSyncActivityCompensates
