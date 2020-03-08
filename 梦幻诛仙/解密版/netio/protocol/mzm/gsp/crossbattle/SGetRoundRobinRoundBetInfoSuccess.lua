local SGetRoundRobinRoundBetInfoSuccess = class("SGetRoundRobinRoundBetInfoSuccess")
SGetRoundRobinRoundBetInfoSuccess.TYPEID = 12617037
function SGetRoundRobinRoundBetInfoSuccess:ctor(activity_cfg_id, round_index, stage, fight_bet_infos)
  self.id = 12617037
  self.activity_cfg_id = activity_cfg_id or nil
  self.round_index = round_index or nil
  self.stage = stage or nil
  self.fight_bet_infos = fight_bet_infos or {}
end
function SGetRoundRobinRoundBetInfoSuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.round_index)
  os:marshalInt32(self.stage)
  os:marshalCompactUInt32(table.getn(self.fight_bet_infos))
  for _, v in ipairs(self.fight_bet_infos) do
    v:marshal(os)
  end
end
function SGetRoundRobinRoundBetInfoSuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.round_index = os:unmarshalInt32()
  self.stage = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.crossbattle.RoundRobinFightBetInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.fight_bet_infos, v)
  end
end
function SGetRoundRobinRoundBetInfoSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetRoundRobinRoundBetInfoSuccess
