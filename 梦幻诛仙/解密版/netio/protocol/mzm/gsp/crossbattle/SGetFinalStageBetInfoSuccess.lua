local KnockOutStageFightInfo = require("netio.protocol.mzm.gsp.crossbattle.KnockOutStageFightInfo")
local SGetFinalStageBetInfoSuccess = class("SGetFinalStageBetInfoSuccess")
SGetFinalStageBetInfoSuccess.TYPEID = 12617071
function SGetFinalStageBetInfoSuccess:ctor(activity_cfg_id, stage, corps_infos, fight_infos, fight_bet_infos)
  self.id = 12617071
  self.activity_cfg_id = activity_cfg_id or nil
  self.stage = stage or nil
  self.corps_infos = corps_infos or {}
  self.fight_infos = fight_infos or KnockOutStageFightInfo.new()
  self.fight_bet_infos = fight_bet_infos or {}
end
function SGetFinalStageBetInfoSuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.stage)
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
function SGetFinalStageBetInfoSuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.stage = os:unmarshalInt32()
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
function SGetFinalStageBetInfoSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetFinalStageBetInfoSuccess
