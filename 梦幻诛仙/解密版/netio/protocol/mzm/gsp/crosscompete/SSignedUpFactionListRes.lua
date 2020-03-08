local SSignedUpFactionListRes = class("SSignedUpFactionListRes")
SSignedUpFactionListRes.TYPEID = 12616732
function SSignedUpFactionListRes:ctor(factions)
  self.id = 12616732
  self.factions = factions or {}
end
function SSignedUpFactionListRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.factions))
  for _, v in ipairs(self.factions) do
    v:marshal(os)
  end
end
function SSignedUpFactionListRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.crosscompete.SignedUpFaction")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.factions, v)
  end
end
function SSignedUpFactionListRes:sizepolicy(size)
  return size <= 65535
end
return SSignedUpFactionListRes
