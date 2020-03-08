local SGetMonsterLocationRes = class("SGetMonsterLocationRes")
SGetMonsterLocationRes.TYPEID = 12590881
function SGetMonsterLocationRes:ctor(monsterList)
  self.id = 12590881
  self.monsterList = monsterList or {}
end
function SGetMonsterLocationRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.monsterList))
  for _, v in ipairs(self.monsterList) do
    v:marshal(os)
  end
end
function SGetMonsterLocationRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.map.MonsterLocation")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.monsterList, v)
  end
end
function SGetMonsterLocationRes:sizepolicy(size)
  return size <= 65535
end
return SGetMonsterLocationRes
