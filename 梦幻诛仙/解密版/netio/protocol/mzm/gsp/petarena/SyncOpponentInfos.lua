local SyncOpponentInfos = class("SyncOpponentInfos")
SyncOpponentInfos.TYPEID = 12628235
function SyncOpponentInfos:ctor(opponent_infos, serial)
  self.id = 12628235
  self.opponent_infos = opponent_infos or {}
  self.serial = serial or nil
end
function SyncOpponentInfos:marshal(os)
  os:marshalCompactUInt32(table.getn(self.opponent_infos))
  for _, v in ipairs(self.opponent_infos) do
    v:marshal(os)
  end
  os:marshalInt32(self.serial)
end
function SyncOpponentInfos:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.petarena.OpponentInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.opponent_infos, v)
  end
  self.serial = os:unmarshalInt32()
end
function SyncOpponentInfos:sizepolicy(size)
  return size <= 65535
end
return SyncOpponentInfos
