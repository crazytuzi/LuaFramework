local Lplus = require("Lplus")
local PartnerProterty = Lplus.Class("PartnerProterty")
local def = PartnerProterty.define
local PartnerInterface = require("Main.partner.PartnerInterface")
local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
def.static("table", "number", "=>", PartnerProterty).New = function(partnerCfg, level)
  local instance = PartnerProterty()
  instance:Init(partnerCfg, level)
  return instance
end
def.field("table")._partnerCfg = nil
def.field("table")._partnerPropertyCfg = nil
def.field("number")._level = 0
PartnerProterty.PropertyFunctionMap = 0
PartnerProterty.LV2toLV1Change = 0
def.method("table", "number").Init = function(self, partnerCfg, level)
  self._partnerCfg = partnerCfg
  self._level = level
  self._partnerPropertyCfg = PartnerInterface.GetLevelToPropertyCfg(partnerCfg.level2propertyId, level)
  if PartnerProterty.LV2toLV1Change == 0 then
    PartnerProterty.LV2toLV1Change = {}
    local entries = DynamicData.GetTable(CFG_PATH.DATA_PARTNER_PARTNER2PROPERTYCHANGE_CFG)
    local count = DynamicDataTable.GetRecordsCount(entries)
    DynamicDataTable.FastGetRecordBegin(entries)
    for i = 0, count - 1 do
      local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
      local cfg = {}
      cfg.LV1Property = entry:GetIntValue("LV1Property")
      cfg.LV2Property = entry:GetIntValue("LV2Property")
      cfg.effectValue = entry:GetFloatValue("effectValue")
      if cfg.effectValue ~= 0 then
        local lv1tovalues = PartnerProterty.LV2toLV1Change[cfg.LV2Property]
        if lv1tovalues == nil then
          lv1tovalues = {}
          PartnerProterty.LV2toLV1Change[cfg.LV2Property] = lv1tovalues
        end
        local lv1tovalue = lv1tovalues[cfg.LV1Property]
        if lv1tovalue == nil then
          lv1tovalue = {}
          lv1tovalue.LV1Property = cfg.LV1Property
          lv1tovalue.effectValue = cfg.effectValue
          lv1tovalues[cfg.LV1Property] = lv1tovalue
        end
      end
    end
    DynamicDataTable.FastGetRecordEnd(entries)
  end
  if PartnerProterty.PropertyFunctionMap == 0 then
    PartnerProterty.PropertyFunctionMap = {}
    PartnerProterty.PropertyFunctionMap[PropertyType.MAX_HP] = PartnerProterty.get_MAX_HP
    PartnerProterty.PropertyFunctionMap[PropertyType.CUR_HP] = PartnerProterty.get_CUR_HP
    PartnerProterty.PropertyFunctionMap[PropertyType.MAX_MP] = PartnerProterty.get_MAX_MP
    PartnerProterty.PropertyFunctionMap[PropertyType.CUR_MP] = PartnerProterty.get_CUR_MP
    PartnerProterty.PropertyFunctionMap[PropertyType.MAX_ANGER] = PartnerProterty.get_MAX_ANGER
    PartnerProterty.PropertyFunctionMap[PropertyType.CUR_ANGER] = PartnerProterty.get_CUR_ANGER
    PartnerProterty.PropertyFunctionMap[PropertyType.PHYATK] = PartnerProterty.get_PHYATK
    PartnerProterty.PropertyFunctionMap[PropertyType.PHYDEF] = PartnerProterty.get_PHYDEF
    PartnerProterty.PropertyFunctionMap[PropertyType.MAGATK] = PartnerProterty.get_MAGATK
    PartnerProterty.PropertyFunctionMap[PropertyType.MAGDEF] = PartnerProterty.get_MAGDEF
    PartnerProterty.PropertyFunctionMap[PropertyType.PHY_CRT_RATE] = PartnerProterty.get_PHY_CRT_RATE
    PartnerProterty.PropertyFunctionMap[PropertyType.MAG_CRT_RATE] = PartnerProterty.get_MAG_CRT_RATE
    PartnerProterty.PropertyFunctionMap[PropertyType.HEAL_CRT_RATE] = PartnerProterty.get_HEAL_CRT_RATE
    PartnerProterty.PropertyFunctionMap[PropertyType.PHY_CRT_VALUE] = PartnerProterty.get_PHY_CRT_VALUE
    PartnerProterty.PropertyFunctionMap[PropertyType.MAG_CRT_VALUE] = PartnerProterty.get_MAG_CRT_VALUE
    PartnerProterty.PropertyFunctionMap[PropertyType.SEAL_HIT] = PartnerProterty.get_SEAL_HIT
    PartnerProterty.PropertyFunctionMap[PropertyType.SEAL_RESIST] = PartnerProterty.get_SEAL_RESIST
    PartnerProterty.PropertyFunctionMap[PropertyType.PHY_HIT_LEVEL] = PartnerProterty.get_PHY_HIT_LEVEL
    PartnerProterty.PropertyFunctionMap[PropertyType.PHY_DODGE_LEVEL] = PartnerProterty.get_PHY_DODGE_LEVEL
    PartnerProterty.PropertyFunctionMap[PropertyType.MAG_HIT_LEVEL] = PartnerProterty.get_MAG_HIT_LEVEL
    PartnerProterty.PropertyFunctionMap[PropertyType.MAG_DODGE_LEVEL] = PartnerProterty.get_MAG_DODGE_LEVEL
    PartnerProterty.PropertyFunctionMap[PropertyType.PHY_FIGHT_BACK_RATE] = PartnerProterty.get_PHY_FIGHT_BACK_RATE
    PartnerProterty.PropertyFunctionMap[PropertyType.MAG_FIGHT_BACK_RATE] = PartnerProterty.get_MAG_FIGHT_BACK_RATE
    PartnerProterty.PropertyFunctionMap[PropertyType.SPEED] = PartnerProterty.get_SPEED
    PartnerProterty.PropertyFunctionMap[PropertyType.STR] = PartnerProterty.get_STR
    PartnerProterty.PropertyFunctionMap[PropertyType.DEX] = PartnerProterty.get_DEX
    PartnerProterty.PropertyFunctionMap[PropertyType.SPR] = PartnerProterty.get_SPR
    PartnerProterty.PropertyFunctionMap[PropertyType.CON] = PartnerProterty.get_CON
    PartnerProterty.PropertyFunctionMap[PropertyType.STA] = PartnerProterty.get_STA
    PartnerProterty.PropertyFunctionMap[PropertyType.MAX_HP_ADD_PERCENT] = PartnerProterty.get_MAX_HP_ADD_PERCENT
    PartnerProterty.PropertyFunctionMap[PropertyType.MAX_MP_ADD_PERCENT] = PartnerProterty.get_MAX_MP_ADD_PERCENT
    PartnerProterty.PropertyFunctionMap[PropertyType.MAX_ANGER_ADD_PERCENT] = PartnerProterty.get_MAX_ANGER_ADD_PERCENT
    PartnerProterty.PropertyFunctionMap[PropertyType.PHYATK_ADD_PERCENT] = PartnerProterty.get_PHYATK_ADD_PERCENT
    PartnerProterty.PropertyFunctionMap[PropertyType.PHYDEF_ADD_PERCENT] = PartnerProterty.get_PHYDEF_ADD_PERCENT
    PartnerProterty.PropertyFunctionMap[PropertyType.MAGATK_ADD_PERCENT] = PartnerProterty.get_MAGATK_ADD_PERCENT
    PartnerProterty.PropertyFunctionMap[PropertyType.MAGDEF_ADD_PERCENT] = PartnerProterty.get_MAGDEF_ADD_PERCENT
    PartnerProterty.PropertyFunctionMap[PropertyType.PHY_CRT_VALUE_ADD_PERCENT] = PartnerProterty.get_PHY_CRT_VALUE_ADD_PERCENT
    PartnerProterty.PropertyFunctionMap[PropertyType.MAG_CRT_VALUE_ADD_PERCENT] = PartnerProterty.get_MAG_CRT_VALUE_ADD_PERCENT
    PartnerProterty.PropertyFunctionMap[PropertyType.SEAL_HIT_ADD_PERCENT] = PartnerProterty.get_SEAL_HIT_ADD_PERCENT
    PartnerProterty.PropertyFunctionMap[PropertyType.SEAL_RESIST_ADD_PERCENT] = PartnerProterty.get_SEAL_RESIST_ADD_PERCENT
    PartnerProterty.PropertyFunctionMap[PropertyType.PHY_HIT_LEVEL_ADD_PERCENT] = PartnerProterty.get_PHY_HIT_LEVEL_ADD_PERCENT
    PartnerProterty.PropertyFunctionMap[PropertyType.PHY_DODGE_LEVEL_ADD_PERCENT] = PartnerProterty.get_PHY_DODGE_LEVEL_ADD_PERCENT
    PartnerProterty.PropertyFunctionMap[PropertyType.MAG_HIT_LEVEL_ADD_PERCENT] = PartnerProterty.get_MAG_HIT_LEVEL_ADD_PERCENT
    PartnerProterty.PropertyFunctionMap[PropertyType.MAG_DODGE_LEVEL_ADD_PERCENT] = PartnerProterty.get_MAG_DODGE_LEVEL_ADD_PERCENT
    PartnerProterty.PropertyFunctionMap[PropertyType.PHY_FIGHT_BACK_RATE_ADD_PERCENT] = PartnerProterty.get_PHY_FIGHT_BACK_RATE_ADD_PERCENT
    PartnerProterty.PropertyFunctionMap[PropertyType.MAG_FIGHT_BACK_RATE_ADD_PERCENT] = PartnerProterty.get_MAG_FIGHT_BACK_RATE_ADD_PERCENT
    PartnerProterty.PropertyFunctionMap[PropertyType.SPEED_ADD_PERCENT] = PartnerProterty.get_SPEED_ADD_PERCENT
    PartnerProterty.PropertyFunctionMap[PropertyType.ATK_APT] = PartnerProterty.get_ATK_APT
    PartnerProterty.PropertyFunctionMap[PropertyType.DEF_APT] = PartnerProterty.get_DEF_APT
    PartnerProterty.PropertyFunctionMap[PropertyType.MAG_APT] = PartnerProterty.get_MAG_APT
    PartnerProterty.PropertyFunctionMap[PropertyType.TILI_APT] = PartnerProterty.get_TILI_APT
    PartnerProterty.PropertyFunctionMap[PropertyType.SPEED_APT] = PartnerProterty.get_SPEED_APT
    PartnerProterty.PropertyFunctionMap[PropertyType.GROW] = PartnerProterty.get_GROW
    PartnerProterty.PropertyFunctionMap[PropertyType.LIFE] = PartnerProterty.get_LIFE
    PartnerProterty.PropertyFunctionMap[PropertyType.ADD_DAMAGE_RATE] = PartnerProterty.get_ADD_DAMAGE_RATE
    PartnerProterty.PropertyFunctionMap[PropertyType.ADD_BE_HIT_DAMAGE_RATE] = PartnerProterty.get_ADD_BE_HIT_DAMAGE_RATE
    PartnerProterty.PropertyFunctionMap[PropertyType.PHY_DAMAGE_RATE] = PartnerProterty.get_PHY_DAMAGE_RATE
    PartnerProterty.PropertyFunctionMap[PropertyType.MAG_DAMAGE_RATE] = PartnerProterty.get_MAG_DAMAGE_RATE
    PartnerProterty.PropertyFunctionMap[PropertyType.PHY_BE_DAMAGE_RATE] = PartnerProterty.get_PHY_BE_DAMAGE_RATE
    PartnerProterty.PropertyFunctionMap[PropertyType.MAG_BE_DAMAGE_RATE] = PartnerProterty.get_MAG_BE_DAMAGE_RATE
    PartnerProterty.PropertyFunctionMap[PropertyType.ADD_DEF_RATE] = PartnerProterty.get_ADD_DEF_RATE
    PartnerProterty.PropertyFunctionMap[PropertyType.ADD_EXP_RATE] = PartnerProterty.get_ADD_EXP_RATE
    PartnerProterty.PropertyFunctionMap[PropertyType.SEAL_HIT_RATE] = PartnerProterty.get_SEAL_HIT_RATE
    PartnerProterty.PropertyFunctionMap[PropertyType.SEAL_BE_HIT_RATE] = PartnerProterty.get_SEAL_BE_HIT_RATE
    PartnerProterty.PropertyFunctionMap[PropertyType.PHY_ATK_HIT_RATE] = PartnerProterty.get_PHY_ATK_HIT_RATE
    PartnerProterty.PropertyFunctionMap[PropertyType.PHY_ATK_BE_HIT_RATE] = PartnerProterty.get_PHY_ATK_BE_HIT_RATE
    PartnerProterty.PropertyFunctionMap[PropertyType.MAG_ATK_HIT_RATE] = PartnerProterty.get_MAG_ATK_HIT_RATE
    PartnerProterty.PropertyFunctionMap[PropertyType.MAG_ATK_BE_HIT_RATE] = PartnerProterty.get_MAG_ATK_BE_HIT_RATE
    PartnerProterty.PropertyFunctionMap[PropertyType.BE_HEAL_EFFECT_VALUE] = PartnerProterty.get_BE_HEAL_EFFECT_VALUE
    PartnerProterty.PropertyFunctionMap[PropertyType.BE_HEAL_EFFECT_RATE] = PartnerProterty.get_BE_HEAL_EFFECT_RATE
    PartnerProterty.PropertyFunctionMap[PropertyType.ESCAPE_RATE] = PartnerProterty.get_ESCAPE_RATE
    PartnerProterty.PropertyFunctionMap[PropertyType.CATCH_PET_RATE] = PartnerProterty.get_CATCH_PET_RATE
    PartnerProterty.PropertyFunctionMap[PropertyType.PHY_DAMAGE_WAVE_LOW] = PartnerProterty.get_PHY_DAMAGE_WAVE_LOW
    PartnerProterty.PropertyFunctionMap[PropertyType.PHY_DAMAGE_WAVE_HIGH] = PartnerProterty.get_PHY_DAMAGE_WAVE_HIGH
    PartnerProterty.PropertyFunctionMap[PropertyType.MAG_DAMAGE_WAVE_LOW] = PartnerProterty.get_MAG_DAMAGE_WAVE_LOW
    PartnerProterty.PropertyFunctionMap[PropertyType.MAG_DAMAGE_WAVE_HIGH] = PartnerProterty.get_MAG_DAMAGE_WAVE_HIGH
    PartnerProterty.PropertyFunctionMap[PropertyType.HEAL_EFFECT_VALUE] = PartnerProterty.get_HEAL_EFFECT_VALUE
    PartnerProterty.PropertyFunctionMap[PropertyType.HEAL_EFFECT_RATE] = PartnerProterty.get_HEAL_EFFECT_RATE
    PartnerProterty.PropertyFunctionMap[PropertyType.PHY_FIGHT_BACK_DAMAGE_RATE] = PartnerProterty.get_PHY_FIGHT_BACK_DAMAGE_RATE
    PartnerProterty.PropertyFunctionMap[PropertyType.MAG_FIGHT_BACK_DAMAGE_RATE] = PartnerProterty.get_MAG_FIGHT_BACK_DAMAGE_RATE
    PartnerProterty.PropertyFunctionMap[PropertyType.VIGOR] = PartnerProterty.get_VIGOR
    PartnerProterty.PropertyFunctionMap[PropertyType.PHY_CRIT_LEVEL] = PartnerProterty.get_PHY_CRIT_LEVEL
    PartnerProterty.PropertyFunctionMap[PropertyType.MAG_CRT_LEVEL] = PartnerProterty.get_MAG_CRT_LEVEL
    PartnerProterty.PropertyFunctionMap[PropertyType.PHY_CRT_DEF_LEVEL] = PartnerProterty.get_PHY_CRT_DEF_LEVEL
    PartnerProterty.PropertyFunctionMap[PropertyType.MAG_CRT_DEF_LEVEL] = PartnerProterty.get_MAG_CRT_DEF_LEVEL
    PartnerProterty.PropertyFunctionMap[PropertyType.ENERGY] = PartnerProterty.get_ENERGY
  end
end
def.static(PartnerProterty, "number", "number", "=>", "number").add_LV2toLV1Change = function(self, propertyType, ret)
  local lv2tolv1 = PartnerProterty.LV2toLV1Change[propertyType]
  if lv2tolv1 ~= nil then
    for lv1, lv1tovalue in pairs(lv2tolv1) do
      local fn = PartnerProterty.PropertyFunctionMap[lv1tovalue.LV1Property]
      if fn ~= nil then
        ret = ret + fn(self) * lv1tovalue.effectValue
      end
    end
  end
  return ret
end
def.static(PartnerProterty, "=>", "number").get_MAX_HP = function(self)
  local ret = self._partnerCfg.bornMaxHP + self._partnerPropertyCfg.addMaxHpPerLevel
  ret = PartnerProterty.add_LV2toLV1Change(self, PropertyType.MAX_HP, ret)
  return ret
end
def.static(PartnerProterty, "=>", "number").get_CUR_HP = function(self)
end
def.static(PartnerProterty, "=>", "number").get_MAX_MP = function(self)
  local ret = self._partnerCfg.bornMaxMp + self._partnerPropertyCfg.addMaxMpPerLevel
  ret = PartnerProterty.add_LV2toLV1Change(self, PropertyType.MAX_MP, ret)
  return ret
end
def.static(PartnerProterty, "=>", "number").get_CUR_MP = function(self)
end
def.static(PartnerProterty, "=>", "number").get_MAX_ANGER = function(self)
end
def.static(PartnerProterty, "=>", "number").get_CUR_ANGER = function(self)
end
def.static(PartnerProterty, "=>", "number").get_PHYATK = function(self)
  local ret = self._partnerCfg.bornPhyAtk + self._partnerPropertyCfg.addPhyAtkPerLevel
  ret = PartnerProterty.add_LV2toLV1Change(self, PropertyType.PHYATK, ret)
  return ret
end
def.static(PartnerProterty, "=>", "number").get_PHYDEF = function(self)
  local ret = self._partnerCfg.bornPhyDef + self._partnerPropertyCfg.addPhyDefPerLevel
  ret = PartnerProterty.add_LV2toLV1Change(self, PropertyType.PHYDEF, ret)
  return ret
end
def.static(PartnerProterty, "=>", "number").get_MAGATK = function(self)
  local ret = self._partnerCfg.bornMagAtk + self._partnerPropertyCfg.addMagAtkPerLevel
  ret = PartnerProterty.add_LV2toLV1Change(self, PropertyType.MAGATK, ret)
  return ret
end
def.static(PartnerProterty, "=>", "number").get_MAGDEF = function(self)
  local ret = self._partnerCfg.bornMagDef + self._partnerPropertyCfg.addMagDefPerLevel
  ret = PartnerProterty.add_LV2toLV1Change(self, PropertyType.MAGDEF, ret)
  return ret
end
def.static(PartnerProterty, "=>", "number").get_PHY_CRT_RATE = function(self)
  local ret = self._partnerCfg.bornPhyCrtRate + self._partnerPropertyCfg.addPhyCrtRatePerLevel
  ret = PartnerProterty.add_LV2toLV1Change(self, PropertyType.PHY_CRT_RATE, ret)
  return ret
end
def.static(PartnerProterty, "=>", "number").get_MAG_CRT_RATE = function(self)
  local ret = self._partnerCfg.bornMagCrtRate + self._partnerPropertyCfg.addMagCrtRatePerLevel
  ret = PartnerProterty.add_LV2toLV1Change(self, PropertyType.MAG_CRT_RATE, ret)
  return ret
end
def.static(PartnerProterty, "=>", "number").get_HEAL_CRT_RATE = function(self)
end
def.static(PartnerProterty, "=>", "number").get_PHY_CRT_VALUE = function(self)
  local ret = self._partnerCfg.bornPhyCrtValue + self._partnerPropertyCfg.addPhyCrtValuePerLevel
  ret = PartnerProterty.add_LV2toLV1Change(self, PropertyType.PHY_CRT_VALUE, ret)
  return ret
end
def.static(PartnerProterty, "=>", "number").get_MAG_CRT_VALUE = function(self)
  local ret = self._partnerCfg.bornMagCrtValue + self._partnerPropertyCfg.addMagCrtValuePerLevel
  ret = PartnerProterty.add_LV2toLV1Change(self, PropertyType.PHY_CRT_VALUE, ret)
  return ret
end
def.static(PartnerProterty, "=>", "number").get_SEAL_HIT = function(self)
  local ret = self._partnerCfg.bornSealHitLevel + self._partnerPropertyCfg.addSealHitLevelPerLevel
  ret = PartnerProterty.add_LV2toLV1Change(self, PropertyType.SEAL_HIT, ret)
  return ret
end
def.static(PartnerProterty, "=>", "number").get_SEAL_RESIST = function(self)
  local ret = self._partnerCfg.bornSealResLevel + self._partnerPropertyCfg.addSealResLevelPerLevel
  ret = PartnerProterty.add_LV2toLV1Change(self, PropertyType.SEAL_RESIST, ret)
  return ret
end
def.static(PartnerProterty, "=>", "number").get_PHY_HIT_LEVEL = function(self)
  local ret = self._partnerCfg.bornPhyHitLevel + self._partnerPropertyCfg.addPhyHitLevelPerLevel
  ret = PartnerProterty.add_LV2toLV1Change(self, PropertyType.PHY_HIT_LEVEL, ret)
  return ret
end
def.static(PartnerProterty, "=>", "number").get_PHY_DODGE_LEVEL = function(self)
  local ret = self._partnerCfg.bornPhyDodgeLevel + self._partnerPropertyCfg.addPhyDodgeLevelPerLevel
  ret = PartnerProterty.add_LV2toLV1Change(self, PropertyType.PHY_DODGE_LEVEL, ret)
  return ret
end
def.static(PartnerProterty, "=>", "number").get_MAG_HIT_LEVEL = function(self)
  local ret = self._partnerCfg.bornMagHitLevel + self._partnerPropertyCfg.addMagHitLevelPerLevel
  ret = PartnerProterty.add_LV2toLV1Change(self, PropertyType.MAG_HIT_LEVEL, ret)
  return ret
end
def.static(PartnerProterty, "=>", "number").get_MAG_DODGE_LEVEL = function(self)
  local ret = self._partnerCfg.bornMagDodogeLevel
  ret = PartnerProterty.add_LV2toLV1Change(self, PropertyType.MAG_DODGE_LEVEL, ret)
  return ret
end
def.static(PartnerProterty, "=>", "number").get_PHY_FIGHT_BACK_RATE = function(self)
end
def.static(PartnerProterty, "=>", "number").get_MAG_FIGHT_BACK_RATE = function(self)
end
def.static(PartnerProterty, "=>", "number").get_SPEED = function(self)
  local ret = self._partnerCfg.bornSpeed + self._partnerPropertyCfg.addSpeedPerLevelPerLevel
  ret = PartnerProterty.add_LV2toLV1Change(self, PropertyType.SPEED, ret)
  return ret
end
def.static(PartnerProterty, "=>", "number").get_STR = function(self)
  local ret = self._partnerCfg.bornStr + self._level * self._partnerCfg.addStrPerLevel
  ret = PartnerProterty.add_LV2toLV1Change(self, PropertyType.STR, ret)
  return ret
end
def.static(PartnerProterty, "=>", "number").get_DEX = function(self)
  local ret = self._partnerCfg.bornDex + self._level * self._partnerCfg.addDexPerLevel
  ret = PartnerProterty.add_LV2toLV1Change(self, PropertyType.DEX, ret)
  return ret
end
def.static(PartnerProterty, "=>", "number").get_SPR = function(self)
  local ret = self._partnerCfg.bornSpr + self._level * self._partnerCfg.addSprPerLevel
  ret = PartnerProterty.add_LV2toLV1Change(self, PropertyType.SPR, ret)
  return ret
end
def.static(PartnerProterty, "=>", "number").get_CON = function(self)
  local ret = self._partnerCfg.bornCon + self._level * self._partnerCfg.addConPerLevel
  ret = PartnerProterty.add_LV2toLV1Change(self, PropertyType.CON, ret)
  return ret
end
def.static(PartnerProterty, "=>", "number").get_STA = function(self)
  local ret = self._partnerCfg.bornSta + self._level * self._partnerCfg.addStaPerLevel
  ret = PartnerProterty.add_LV2toLV1Change(self, PropertyType.STA, ret)
  return ret
end
def.static(PartnerProterty, "=>", "number").get_MAX_HP_ADD_PERCENT = function(self)
end
def.static(PartnerProterty, "=>", "number").get_MAX_MP_ADD_PERCENT = function(self)
end
def.static(PartnerProterty, "=>", "number").get_MAX_ANGER_ADD_PERCENT = function(self)
end
def.static(PartnerProterty, "=>", "number").get_PHYATK_ADD_PERCENT = function(self)
end
def.static(PartnerProterty, "=>", "number").get_PHYDEF_ADD_PERCENT = function(self)
end
def.static(PartnerProterty, "=>", "number").get_MAGATK_ADD_PERCENT = function(self)
end
def.static(PartnerProterty, "=>", "number").get_MAGDEF_ADD_PERCENT = function(self)
end
def.static(PartnerProterty, "=>", "number").get_PHY_CRT_VALUE_ADD_PERCENT = function(self)
end
def.static(PartnerProterty, "=>", "number").get_MAG_CRT_VALUE_ADD_PERCENT = function(self)
end
def.static(PartnerProterty, "=>", "number").get_SEAL_HIT_ADD_PERCENT = function(self)
end
def.static(PartnerProterty, "=>", "number").get_SEAL_RESIST_ADD_PERCENT = function(self)
end
def.static(PartnerProterty, "=>", "number").get_PHY_HIT_LEVEL_ADD_PERCENT = function(self)
end
def.static(PartnerProterty, "=>", "number").get_PHY_DODGE_LEVEL_ADD_PERCENT = function(self)
end
def.static(PartnerProterty, "=>", "number").get_MAG_HIT_LEVEL_ADD_PERCENT = function(self)
end
def.static(PartnerProterty, "=>", "number").get_MAG_DODGE_LEVEL_ADD_PERCENT = function(self)
end
def.static(PartnerProterty, "=>", "number").get_PHY_FIGHT_BACK_RATE_ADD_PERCENT = function(self)
end
def.static(PartnerProterty, "=>", "number").get_MAG_FIGHT_BACK_RATE_ADD_PERCENT = function(self)
end
def.static(PartnerProterty, "=>", "number").get_SPEED_ADD_PERCENT = function(self)
end
def.static(PartnerProterty, "=>", "number").get_ATK_APT = function(self)
end
def.static(PartnerProterty, "=>", "number").get_DEF_APT = function(self)
end
def.static(PartnerProterty, "=>", "number").get_MAG_APT = function(self)
end
def.static(PartnerProterty, "=>", "number").get_TILI_APT = function(self)
end
def.static(PartnerProterty, "=>", "number").get_SPEED_APT = function(self)
end
def.static(PartnerProterty, "=>", "number").get_GROW = function(self)
end
def.static(PartnerProterty, "=>", "number").get_LIFE = function(self)
end
def.static(PartnerProterty, "=>", "number").get_ADD_DAMAGE_RATE = function(self)
end
def.static(PartnerProterty, "=>", "number").get_ADD_BE_HIT_DAMAGE_RATE = function(self)
end
def.static(PartnerProterty, "=>", "number").get_PHY_DAMAGE_RATE = function(self)
end
def.static(PartnerProterty, "=>", "number").get_MAG_DAMAGE_RATE = function(self)
end
def.static(PartnerProterty, "=>", "number").get_PHY_BE_DAMAGE_RATE = function(self)
end
def.static(PartnerProterty, "=>", "number").get_MAG_BE_DAMAGE_RATE = function(self)
end
def.static(PartnerProterty, "=>", "number").get_ADD_DEF_RATE = function(self)
end
def.static(PartnerProterty, "=>", "number").get_ADD_EXP_RATE = function(self)
end
def.static(PartnerProterty, "=>", "number").get_SEAL_HIT_RATE = function(self)
end
def.static(PartnerProterty, "=>", "number").get_SEAL_BE_HIT_RATE = function(self)
end
def.static(PartnerProterty, "=>", "number").get_PHY_ATK_HIT_RATE = function(self)
end
def.static(PartnerProterty, "=>", "number").get_PHY_ATK_BE_HIT_RATE = function(self)
end
def.static(PartnerProterty, "=>", "number").get_MAG_ATK_HIT_RATE = function(self)
end
def.static(PartnerProterty, "=>", "number").get_MAG_ATK_BE_HIT_RATE = function(self)
end
def.static(PartnerProterty, "=>", "number").get_BE_HEAL_EFFECT_VALUE = function(self)
end
def.static(PartnerProterty, "=>", "number").get_BE_HEAL_EFFECT_RATE = function(self)
end
def.static(PartnerProterty, "=>", "number").get_ESCAPE_RATE = function(self)
end
def.static(PartnerProterty, "=>", "number").get_CATCH_PET_RATE = function(self)
end
def.static(PartnerProterty, "=>", "number").get_PHY_DAMAGE_WAVE_LOW = function(self)
end
def.static(PartnerProterty, "=>", "number").get_PHY_DAMAGE_WAVE_HIGH = function(self)
end
def.static(PartnerProterty, "=>", "number").get_MAG_DAMAGE_WAVE_LOW = function(self)
end
def.static(PartnerProterty, "=>", "number").get_MAG_DAMAGE_WAVE_HIGH = function(self)
end
def.static(PartnerProterty, "=>", "number").get_HEAL_EFFECT_VALUE = function(self)
end
def.static(PartnerProterty, "=>", "number").get_HEAL_EFFECT_RATE = function(self)
end
def.static(PartnerProterty, "=>", "number").get_PHY_FIGHT_BACK_DAMAGE_RATE = function(self)
end
def.static(PartnerProterty, "=>", "number").get_MAG_FIGHT_BACK_DAMAGE_RATE = function(self)
end
def.static(PartnerProterty, "=>", "number").get_VIGOR = function(self)
end
def.static(PartnerProterty, "=>", "number").get_PHY_CRIT_LEVEL = function(self)
  local ret = self._partnerCfg.phyCrtLevel + self._partnerPropertyCfg.addPhyCrtLevelPerLevel
  warn("----1111111get_PHY_CRIT_LEVEL:", ret, self._partnerCfg.phyCrtLevel, self._partnerPropertyCfg.addPhyCrtLevelPerLevel)
  ret = PartnerProterty.add_LV2toLV1Change(self, PropertyType.PHY_CRIT_LEVEL, ret)
  warn("----22222get_PHY_CRIT_LEVEL:", ret)
  return ret
end
def.static(PartnerProterty, "=>", "number").get_MAG_CRT_LEVEL = function(self)
  local ret = self._partnerCfg.magCrtLevel + self._partnerPropertyCfg.addMagCrtLevelPerLevel
  ret = PartnerProterty.add_LV2toLV1Change(self, PropertyType.MAG_CRT_LEVEL, ret)
  return ret
end
def.static(PartnerProterty, "=>", "number").get_PHY_CRT_DEF_LEVEL = function(self)
end
def.static(PartnerProterty, "=>", "number").get_MAG_CRT_DEF_LEVEL = function(self)
end
def.static(PartnerProterty, "=>", "number").get_ENERGY = function(self)
end
PartnerProterty.Commit()
return PartnerProterty
