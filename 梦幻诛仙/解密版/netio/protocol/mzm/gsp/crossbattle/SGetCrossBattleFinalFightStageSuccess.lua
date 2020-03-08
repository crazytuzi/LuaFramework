local KnockOutStageFightInfo = require("netio.protocol.mzm.gsp.crossbattle.KnockOutStageFightInfo")
local SGetCrossBattleFinalFightStageSuccess = class("SGetCrossBattleFinalFightStageSuccess")
SGetCrossBattleFinalFightStageSuccess.TYPEID = 12617054
function SGetCrossBattleFinalFightStageSuccess:ctor(fight_zone_id, final_stage, final_fight_corps_map, final_stage_fight_info)
  self.id = 12617054
  self.fight_zone_id = fight_zone_id or nil
  self.final_stage = final_stage or nil
  self.final_fight_corps_map = final_fight_corps_map or {}
  self.final_stage_fight_info = final_stage_fight_info or KnockOutStageFightInfo.new()
end
function SGetCrossBattleFinalFightStageSuccess:marshal(os)
  os:marshalInt32(self.fight_zone_id)
  os:marshalInt32(self.final_stage)
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
  self.final_stage_fight_info:marshal(os)
end
function SGetCrossBattleFinalFightStageSuccess:unmarshal(os)
  self.fight_zone_id = os:unmarshalInt32()
  self.final_stage = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local BeanClazz = require("netio.protocol.mzm.gsp.crossbattle.CorpsInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.final_fight_corps_map[k] = v
  end
  self.final_stage_fight_info = KnockOutStageFightInfo.new()
  self.final_stage_fight_info:unmarshal(os)
end
function SGetCrossBattleFinalFightStageSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetCrossBattleFinalFightStageSuccess
