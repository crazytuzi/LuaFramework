local SGetCrossBattleSelectionFightSuccess = class("SGetCrossBattleSelectionFightSuccess")
SGetCrossBattleSelectionFightSuccess.TYPEID = 12616995
function SGetCrossBattleSelectionFightSuccess:ctor(selection_fight_corps_map, selection_stage_fight_info_map, selection_stage)
  self.id = 12616995
  self.selection_fight_corps_map = selection_fight_corps_map or {}
  self.selection_stage_fight_info_map = selection_stage_fight_info_map or {}
  self.selection_stage = selection_stage or nil
end
function SGetCrossBattleSelectionFightSuccess:marshal(os)
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
  do
    local _size_ = 0
    for _, _ in pairs(self.selection_stage_fight_info_map) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.selection_stage_fight_info_map) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  os:marshalInt32(self.selection_stage)
end
function SGetCrossBattleSelectionFightSuccess:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local BeanClazz = require("netio.protocol.mzm.gsp.crossbattle.CorpsInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.selection_fight_corps_map[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.crossbattle.KnockOutStageFightInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.selection_stage_fight_info_map[k] = v
  end
  self.selection_stage = os:unmarshalInt32()
end
function SGetCrossBattleSelectionFightSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetCrossBattleSelectionFightSuccess
