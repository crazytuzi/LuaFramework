local SGetCrossBattleTopThreeInfo = class("SGetCrossBattleTopThreeInfo")
SGetCrossBattleTopThreeInfo.TYPEID = 12617088
function SGetCrossBattleTopThreeInfo:ctor(session, champion_corps, second_place_corps, third_place_corps)
  self.id = 12617088
  self.session = session or nil
  self.champion_corps = champion_corps or {}
  self.second_place_corps = second_place_corps or {}
  self.third_place_corps = third_place_corps or {}
end
function SGetCrossBattleTopThreeInfo:marshal(os)
  os:marshalInt32(self.session)
  os:marshalCompactUInt32(table.getn(self.champion_corps))
  for _, v in ipairs(self.champion_corps) do
    v:marshal(os)
  end
  os:marshalCompactUInt32(table.getn(self.second_place_corps))
  for _, v in ipairs(self.second_place_corps) do
    v:marshal(os)
  end
  os:marshalCompactUInt32(table.getn(self.third_place_corps))
  for _, v in ipairs(self.third_place_corps) do
    v:marshal(os)
  end
end
function SGetCrossBattleTopThreeInfo:unmarshal(os)
  self.session = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.crossbattle.CorpsInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.champion_corps, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.crossbattle.CorpsInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.second_place_corps, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.crossbattle.CorpsInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.third_place_corps, v)
  end
end
function SGetCrossBattleTopThreeInfo:sizepolicy(size)
  return size <= 65535
end
return SGetCrossBattleTopThreeInfo
