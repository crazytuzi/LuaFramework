local OctetsStream = require("netio.OctetsStream")
local ModelInfo = class("ModelInfo")
ModelInfo.WEAPON = 1
ModelInfo.WING = 2
ModelInfo.WING_COLOR_ID = 3
ModelInfo.FABAO = 4
ModelInfo.QILING_LEVEL = 5
ModelInfo.SCALE_RATE = 6
ModelInfo.HAIR_COLOR_ID = 7
ModelInfo.CLOTH_COLOR_ID = 8
ModelInfo.PET_SHIPIN = 9
ModelInfo.AIRCRAFT = 10
ModelInfo.OUTLOOK_ID = 11
ModelInfo.COLOR_ID = 12
ModelInfo.EXTERIOR_ID = 13
ModelInfo.FASHION_DRESS_ID = 14
ModelInfo.WEAPON_EFFECT_ID = 15
ModelInfo.QILING_EFFECT_LEVEL = 16
ModelInfo.PET_STAGE_LEVEL = 17
ModelInfo.EXPRESS_PLAY_ACTION = 18
ModelInfo.MOUNTS_ID = 19
ModelInfo.MOUNTS_COLOR_ID = 20
ModelInfo.MOUNTS_RANK = 21
ModelInfo.PET_EXTERIOR_ID = 22
ModelInfo.PET_EXTERIOR_COLOR_ID = 23
ModelInfo.MAGIC_MARK = 24
ModelInfo.CHILDREN_PHASE = 25
ModelInfo.CHILDREN_GENDER = 26
ModelInfo.CHILDREN_FASHION = 27
ModelInfo.CHILDREN_MODEL_ID = 28
ModelInfo.CHILDREN_WEAPON_ID = 29
ModelInfo.FABAO_LINGQI = 30
ModelInfo.WUSHI_ID = 31
ModelInfo.GENDER = 32
ModelInfo.OCCUPATION = 33
ModelInfo.MORAL_VALUE = 34
ModelInfo.CHANGE_MODEL_CARD_CFGID = 35
ModelInfo.CHANGE_MODEL_CARD_LEVEL = 36
ModelInfo.CHANGE_MODEL_CARD_MINI = 37
ModelInfo.AIRCRAFT_COLOR_ID = 38
ModelInfo.PET_MARK_CFG_ID = 39
function ModelInfo:ctor(modelid, name, extraMap)
  self.modelid = modelid or nil
  self.name = name or nil
  self.extraMap = extraMap or {}
end
function ModelInfo:marshal(os)
  os:marshalInt32(self.modelid)
  os:marshalString(self.name)
  local _size_ = 0
  for _, _ in pairs(self.extraMap) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.extraMap) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function ModelInfo:unmarshal(os)
  self.modelid = os:unmarshalInt32()
  self.name = os:unmarshalString()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.extraMap[k] = v
  end
end
return ModelInfo
