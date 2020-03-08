local KnockOutStageFightInfo = require("netio.protocol.mzm.gsp.crossbattle.KnockOutStageFightInfo")
local SGetSelectionStageBetInfoSuccess = class("SGetSelectionStageBetInfoSuccess")
SGetSelectionStageBetInfoSuccess.TYPEID = 12617043
function SGetSelectionStageBetInfoSuccess:ctor(activity_cfg_id, fight_zone_id, selection_stage, corps_infos, fight_infos, fight_bet_infos)
  self.id = 12617043
  self.activity_cfg_id = activity_cfg_id or nil
  self.fight_zone_id = fight_zone_id or nil
  self.selection_stage = selection_stage or nil
  self.corps_infos = corps_infos or {}
  self.fight_infos = fight_infos or KnockOutStageFightInfo.new()
  self.fight_bet_infos = fight_bet_infos or {}
end
function SGetSelectionStageBetInfoSuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.fight_zone_id)
  os:marshalInt32(self.selection_stage)
  do
    local _size_ = 0
    for _, _ in pairs(self.corps_infos) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.corps_infos) do
      os:marshalInt64(k)
      v:marshal(os)
    end
  end
  self.fight_infos:marshal(os)
  os:marshalCompactUInt32(table.getn(self.fight_bet_infos))
  for _, v in ipairs(self.fight_bet_infos) do
    v:marshal(os)
  end
end
function SGetSelectionStageBetInfoSuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.fight_zone_id = os:unmarshalInt32()
  self.selection_stage = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local BeanClazz = require("netio.protocol.mzm.gsp.crossbattle.CorpsInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.corps_infos[k] = v
  end
  self.fight_infos = KnockOutStageFightInfo.new()
  self.fight_infos:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.crossbattle.KnockoutFightBetInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.fight_bet_infos, v)
  end
end
function SGetSelectionStageBetInfoSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetSelectionStageBetInfoSuccess
