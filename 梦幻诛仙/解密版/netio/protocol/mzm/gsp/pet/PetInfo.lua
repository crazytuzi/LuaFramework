local OctetsStream = require("netio.OctetsStream")
local ModelInfo = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
local PetAptInfo = require("netio.protocol.mzm.gsp.pet.PetAptInfo")
local PetInfo = class("PetInfo")
PetInfo.PET_TYPE_WILD = 0
PetInfo.PET_TYPE_BAOBAO = 1
PetInfo.PET_TYPE_BIANYI = 2
PetInfo.PET_TYPE_SHENSHOU = 3
PetInfo.PET_TYPE_MOSHOU = 4
PetInfo.EQUIP_HELMET = 0
PetInfo.EQUIP_NECKLACE = 1
PetInfo.EQUIP_AMULET = 2
function PetInfo:ctor(petId, typeId, petName, petType, petLevel, life, yaoli, grow, exp, model, hp, maxHp, mp, maxMp, phyAtk, phyDef, magAtk, magDef, speed, bindedState, isDecorated, rememberSkillId, petApt, skillIdList, equipMap, basePropMap, autoAddPropPref, isAutoAddFlagOpen, potentialPoint, isCanResetProp, marketbuytime, stageLevel, extraModelCfgId, soulMap, petMarkCfgId, petMarkLevel, own_extra_model_cfg_ids)
  self.petId = petId or nil
  self.typeId = typeId or nil
  self.petName = petName or nil
  self.petType = petType or nil
  self.petLevel = petLevel or nil
  self.life = life or nil
  self.yaoli = yaoli or nil
  self.grow = grow or nil
  self.exp = exp or nil
  self.model = model or ModelInfo.new()
  self.hp = hp or nil
  self.maxHp = maxHp or nil
  self.mp = mp or nil
  self.maxMp = maxMp or nil
  self.phyAtk = phyAtk or nil
  self.phyDef = phyDef or nil
  self.magAtk = magAtk or nil
  self.magDef = magDef or nil
  self.speed = speed or nil
  self.bindedState = bindedState or nil
  self.isDecorated = isDecorated or nil
  self.rememberSkillId = rememberSkillId or nil
  self.petApt = petApt or PetAptInfo.new()
  self.skillIdList = skillIdList or {}
  self.equipMap = equipMap or {}
  self.basePropMap = basePropMap or {}
  self.autoAddPropPref = autoAddPropPref or {}
  self.isAutoAddFlagOpen = isAutoAddFlagOpen or nil
  self.potentialPoint = potentialPoint or nil
  self.isCanResetProp = isCanResetProp or nil
  self.marketbuytime = marketbuytime or nil
  self.stageLevel = stageLevel or nil
  self.extraModelCfgId = extraModelCfgId or nil
  self.soulMap = soulMap or {}
  self.petMarkCfgId = petMarkCfgId or nil
  self.petMarkLevel = petMarkLevel or nil
  self.own_extra_model_cfg_ids = own_extra_model_cfg_ids or {}
end
function PetInfo:marshal(os)
  os:marshalInt64(self.petId)
  os:marshalInt32(self.typeId)
  os:marshalString(self.petName)
  os:marshalInt32(self.petType)
  os:marshalInt32(self.petLevel)
  os:marshalInt32(self.life)
  os:marshalInt32(self.yaoli)
  os:marshalFloat(self.grow)
  os:marshalInt32(self.exp)
  self.model:marshal(os)
  os:marshalInt32(self.hp)
  os:marshalInt32(self.maxHp)
  os:marshalInt32(self.mp)
  os:marshalInt32(self.maxMp)
  os:marshalInt32(self.phyAtk)
  os:marshalInt32(self.phyDef)
  os:marshalInt32(self.magAtk)
  os:marshalInt32(self.magDef)
  os:marshalInt32(self.speed)
  os:marshalInt32(self.bindedState)
  os:marshalInt32(self.isDecorated)
  os:marshalInt32(self.rememberSkillId)
  self.petApt:marshal(os)
  os:marshalCompactUInt32(table.getn(self.skillIdList))
  for _, v in ipairs(self.skillIdList) do
    os:marshalInt32(v)
  end
  do
    local _size_ = 0
    for _, _ in pairs(self.equipMap) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.equipMap) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  do
    local _size_ = 0
    for _, _ in pairs(self.basePropMap) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.basePropMap) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  do
    local _size_ = 0
    for _, _ in pairs(self.autoAddPropPref) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.autoAddPropPref) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  os:marshalInt32(self.isAutoAddFlagOpen)
  os:marshalInt32(self.potentialPoint)
  os:marshalInt32(self.isCanResetProp)
  os:marshalInt64(self.marketbuytime)
  os:marshalInt32(self.stageLevel)
  os:marshalInt32(self.extraModelCfgId)
  do
    local _size_ = 0
    for _, _ in pairs(self.soulMap) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.soulMap) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  os:marshalInt32(self.petMarkCfgId)
  os:marshalInt32(self.petMarkLevel)
  os:marshalCompactUInt32(table.getn(self.own_extra_model_cfg_ids))
  for _, v in ipairs(self.own_extra_model_cfg_ids) do
    os:marshalInt32(v)
  end
end
function PetInfo:unmarshal(os)
  self.petId = os:unmarshalInt64()
  self.typeId = os:unmarshalInt32()
  self.petName = os:unmarshalString()
  self.petType = os:unmarshalInt32()
  self.petLevel = os:unmarshalInt32()
  self.life = os:unmarshalInt32()
  self.yaoli = os:unmarshalInt32()
  self.grow = os:unmarshalFloat()
  self.exp = os:unmarshalInt32()
  self.model = ModelInfo.new()
  self.model:unmarshal(os)
  self.hp = os:unmarshalInt32()
  self.maxHp = os:unmarshalInt32()
  self.mp = os:unmarshalInt32()
  self.maxMp = os:unmarshalInt32()
  self.phyAtk = os:unmarshalInt32()
  self.phyDef = os:unmarshalInt32()
  self.magAtk = os:unmarshalInt32()
  self.magDef = os:unmarshalInt32()
  self.speed = os:unmarshalInt32()
  self.bindedState = os:unmarshalInt32()
  self.isDecorated = os:unmarshalInt32()
  self.rememberSkillId = os:unmarshalInt32()
  self.petApt = PetAptInfo.new()
  self.petApt:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.skillIdList, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.item.ItemInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.equipMap[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.basePropMap[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.autoAddPropPref[k] = v
  end
  self.isAutoAddFlagOpen = os:unmarshalInt32()
  self.potentialPoint = os:unmarshalInt32()
  self.isCanResetProp = os:unmarshalInt32()
  self.marketbuytime = os:unmarshalInt64()
  self.stageLevel = os:unmarshalInt32()
  self.extraModelCfgId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.pet.PetSoulInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.soulMap[k] = v
  end
  self.petMarkCfgId = os:unmarshalInt32()
  self.petMarkLevel = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.own_extra_model_cfg_ids, v)
  end
end
return PetInfo
