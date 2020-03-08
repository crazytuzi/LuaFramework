local SUpdateCrossBattleSelectionProcessInfo = class("SUpdateCrossBattleSelectionProcessInfo")
SUpdateCrossBattleSelectionProcessInfo.TYPEID = 12616992
function SUpdateCrossBattleSelectionProcessInfo:ctor(fight_type, process_infos)
  self.id = 12616992
  self.fight_type = fight_type or nil
  self.process_infos = process_infos or {}
end
function SUpdateCrossBattleSelectionProcessInfo:marshal(os)
  os:marshalInt32(self.fight_type)
  os:marshalCompactUInt32(table.getn(self.process_infos))
  for _, v in ipairs(self.process_infos) do
    v:marshal(os)
  end
end
function SUpdateCrossBattleSelectionProcessInfo:unmarshal(os)
  self.fight_type = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.crossbattle.CrossBattleSelectionProcessInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.process_infos, v)
  end
end
function SUpdateCrossBattleSelectionProcessInfo:sizepolicy(size)
  return size <= 65535
end
return SUpdateCrossBattleSelectionProcessInfo
