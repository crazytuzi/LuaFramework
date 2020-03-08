local SSynInstanceInfo = class("SSynInstanceInfo")
SSynInstanceInfo.TYPEID = 12591367
function SSynInstanceInfo:ctor(teamInstances)
  self.id = 12591367
  self.teamInstances = teamInstances or {}
end
function SSynInstanceInfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.teamInstances))
  for _, v in ipairs(self.teamInstances) do
    v:marshal(os)
  end
end
function SSynInstanceInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.instance.TeamInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.teamInstances, v)
  end
end
function SSynInstanceInfo:sizepolicy(size)
  return size <= 65535
end
return SSynInstanceInfo
