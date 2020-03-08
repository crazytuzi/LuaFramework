local SSynGroupKickInfo = class("SSynGroupKickInfo")
SSynGroupKickInfo.TYPEID = 12605220
function SSynGroupKickInfo:ctor(group_kick_infos)
  self.id = 12605220
  self.group_kick_infos = group_kick_infos or {}
end
function SSynGroupKickInfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.group_kick_infos))
  for _, v in ipairs(self.group_kick_infos) do
    v:marshal(os)
  end
end
function SSynGroupKickInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.group.GroupKickInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.group_kick_infos, v)
  end
end
function SSynGroupKickInfo:sizepolicy(size)
  return size <= 65535
end
return SSynGroupKickInfo
