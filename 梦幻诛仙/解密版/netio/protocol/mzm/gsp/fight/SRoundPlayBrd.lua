local SRoundPlayBrd = class("SRoundPlayBrd")
SRoundPlayBrd.TYPEID = 12594185
function SRoundPlayBrd:ctor(fight_uuid, playlist)
  self.id = 12594185
  self.fight_uuid = fight_uuid or nil
  self.playlist = playlist or {}
end
function SRoundPlayBrd:marshal(os)
  os:marshalInt64(self.fight_uuid)
  os:marshalCompactUInt32(table.getn(self.playlist))
  for _, v in ipairs(self.playlist) do
    v:marshal(os)
  end
end
function SRoundPlayBrd:unmarshal(os)
  self.fight_uuid = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.fight.Play")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.playlist, v)
  end
end
function SRoundPlayBrd:sizepolicy(size)
  return size <= 65535
end
return SRoundPlayBrd
