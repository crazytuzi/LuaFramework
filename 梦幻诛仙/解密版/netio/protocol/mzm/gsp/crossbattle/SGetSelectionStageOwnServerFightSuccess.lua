local KnockOutStageFightInfo = require("netio.protocol.mzm.gsp.crossbattle.KnockOutStageFightInfo")
local SGetSelectionStageOwnServerFightSuccess = class("SGetSelectionStageOwnServerFightSuccess")
SGetSelectionStageOwnServerFightSuccess.TYPEID = 12617079
function SGetSelectionStageOwnServerFightSuccess:ctor(selection_stage, selection_fight_corps_map, selection_stage_fight_info)
  self.id = 12617079
  self.selection_stage = selection_stage or nil
  self.selection_fight_corps_map = selection_fight_corps_map or {}
  self.selection_stage_fight_info = selection_stage_fight_info or KnockOutStageFightInfo.new()
end
function SGetSelectionStageOwnServerFightSuccess:marshal(os)
  os:marshalInt32(self.selection_stage)
  do
    local _size_ = 0
    for _, _ in pairs(self.selection_fight_corps_map) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.selection_fight_corps_map) do
      os:marshalInt64(k)
      v:marshal(os)
    end
  end
  self.selection_stage_fight_info:marshal(os)
end
function SGetSelectionStageOwnServerFightSuccess:unmarshal(os)
  self.selection_stage = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local BeanClazz = require("netio.protocol.mzm.gsp.crossbattle.CorpsInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.selection_fight_corps_map[k] = v
  end
  self.selection_stage_fight_info = KnockOutStageFightInfo.new()
  self.selection_stage_fight_info:unmarshal(os)
end
function SGetSelectionStageOwnServerFightSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetSelectionStageOwnServerFightSuccess
