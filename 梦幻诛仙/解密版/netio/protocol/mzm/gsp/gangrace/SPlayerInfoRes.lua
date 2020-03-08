local SPlayerInfoRes = class("SPlayerInfoRes")
SPlayerInfoRes.TYPEID = 12602120
function SPlayerInfoRes:ctor(playerInfos)
  self.id = 12602120
  self.playerInfos = playerInfos or {}
end
function SPlayerInfoRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.playerInfos))
  for _, v in ipairs(self.playerInfos) do
    v:marshal(os)
  end
end
function SPlayerInfoRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.gangrace.PlayerInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.playerInfos, v)
  end
end
function SPlayerInfoRes:sizepolicy(size)
  return size <= 65535
end
return SPlayerInfoRes
