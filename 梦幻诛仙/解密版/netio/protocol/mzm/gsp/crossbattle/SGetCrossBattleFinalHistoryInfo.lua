local SGetCrossBattleFinalHistoryInfo = class("SGetCrossBattleFinalHistoryInfo")
SGetCrossBattleFinalHistoryInfo.TYPEID = 12617090
function SGetCrossBattleFinalHistoryInfo:ctor(session, final_fight_corps_map, final_stage_fight_info_map)
  self.id = 12617090
  self.session = session or nil
  self.final_fight_corps_map = final_fight_corps_map or {}
  self.final_stage_fight_info_map = final_stage_fight_info_map or {}
end
function SGetCrossBattleFinalHistoryInfo:marshal(os)
  os:marshalInt32(self.session)
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
function SGetCrossBattleFinalHistoryInfo:unmarshal(os)
  self.session = os:unmarshalInt32()
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
end
function SGetCrossBattleFinalHistoryInfo:sizepolicy(size)
  return size <= 65535
end
return SGetCrossBattleFinalHistoryInfo
