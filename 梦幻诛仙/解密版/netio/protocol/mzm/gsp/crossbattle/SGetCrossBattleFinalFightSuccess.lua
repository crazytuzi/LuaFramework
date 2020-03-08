local SGetCrossBattleFinalFightSuccess = class("SGetCrossBattleFinalFightSuccess")
SGetCrossBattleFinalFightSuccess.TYPEID = 12617056
function SGetCrossBattleFinalFightSuccess:ctor(final_fight_corps_map, final_stage_fight_info_map, final_stage)
  self.id = 12617056
  self.final_fight_corps_map = final_fight_corps_map or {}
  self.final_stage_fight_info_map = final_stage_fight_info_map or {}
  self.final_stage = final_stage or nil
end
function SGetCrossBattleFinalFightSuccess:marshal(os)
  do
    local _size_ = 0
    for _, _ in pairs(self.final_fight_corps_map) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.final_fight_corps_map) do
      os:marshalInt64(k)
      v:marshal(os)
    end
  end
  do
    local _size_ = 0
    for _, _ in pairs(self.final_stage_fight_info_map) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.final_stage_fight_info_map) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  os:marshalInt32(self.final_stage)
end
function SGetCrossBattleFinalFightSuccess:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local BeanClazz = require("netio.protocol.mzm.gsp.crossbattle.CorpsInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.final_fight_corps_map[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.crossbattle.KnockOutStageFightInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.final_stage_fight_info_map[k] = v
  end
  self.final_stage = os:unmarshalInt32()
end
function SGetCrossBattleFinalFightSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetCrossBattleFinalFightSuccess
