local OctetsStream = require("netio.OctetsStream")
local AccessWayInfoList = class("AccessWayInfoList")
function AccessWayInfoList:ctor(accessWays)
  self.accessWays = accessWays or {}
end
function AccessWayInfoList:marshal(os)
  os:marshalCompactUInt32(table.getn(self.accessWays))
  for _, v in ipairs(self.accessWays) do
    v:marshal(os)
  end
end
function AccessWayInfoList:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.item.AccessWayInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.accessWays, v)
  end
end
return AccessWayInfoList
