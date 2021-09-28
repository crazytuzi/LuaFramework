function _getXianZu_ExtraDamageSuccess(roleObj, skillAttr)
  if roleObj == nil then
    return 0, 0
  end
  if skillAttr == SKILLATTR_FIRE then
    return roleObj:getProperty(PROPERTY_MAGICKUANGBAO_HUO_RATE), roleObj:getProperty(PROPERTY_MAGICKUANGBAO_HUO)
  elseif skillAttr == SKILLATTR_WIND then
    return roleObj:getProperty(PROPERTY_MAGICKUANGBAO_FENG_RATE), roleObj:getProperty(PROPERTY_MAGICKUANGBAO_FENG)
  elseif skillAttr == SKILLATTR_THUNDER then
    return roleObj:getProperty(PROPERTY_MAGICKUANGBAO_LEI_RATE), roleObj:getProperty(PROPERTY_MAGICKUANGBAO_LEI)
  elseif skillAttr == SKILLATTR_WATER then
    return roleObj:getProperty(PROPERTY_MAGICKUANGBAO_SHUI_RATE), roleObj:getProperty(PROPERTY_MAGICKUANGBAO_SHUI)
  elseif skillAttr == SKILLATTR_AIHAO then
    return roleObj:getProperty(PROPERTY_MAGICKUANGBAO_AIHAO_RATE), roleObj:getProperty(PROPERTY_MAGICKUANGBAO_AIHAO)
  elseif skillAttr == SKILLATTR_XIXUE then
    return roleObj:getProperty(PROPERTY_MAGICKUANGBAO_XIXUE_RATE), roleObj:getProperty(PROPERTY_MAGICKUANGBAO_XIXUE)
  end
  return 0, 0
end
function _getXianZu_DoubleHitSuccess(roleObj)
  if roleObj == nil then
    return 0, 0
  end
  return roleObj:getProperty(PROPERTY_NEIDAN_MHSN_EFFECTRATE), roleObj:getProperty(PROPERTY_NEIDAN_MHSN_EFFECT)
end
function _getXianZu_ExtraFkAttrSuccess(roleObj)
  if roleObj == nil then
    return 0, 0
  end
  return roleObj:getProperty(PROPERTY_NEIDAN_KTPD_EFFECTRATE), roleObj:getProperty(PROPERTY_NEIDAN_KTPD_EFFECT)
end
function _getGeShanDaNiuSuccess(roleObj)
  if roleObj == nil then
    return 0, 0
  end
  return roleObj:getProperty(PROPERTY_NEIDAN_GSDN_EFFECTRATE), roleObj:getProperty(PROPERTY_NEIDAN_GSDN_EFFECT)
end
function _getWuLi_ExtraPoisonSkillDamageSuccess(roleObj)
  if roleObj == nil then
    return 0, 0
  end
  return roleObj:getProperty(PROPERTY_PASSIVE_USEMAGIC_DU_RATE), roleObj:getProperty(PROPERTY_PASSIVE_USEMAGIC_DU)
end
function _getWuLi_ExtraZhenSkillDamageSuccess(roleObj)
  if roleObj == nil then
    return 0, 0
  end
  return roleObj:getProperty(PROPERTY_PASSIVE_USEMAGIC_ZHEN_RATE), roleObj:getProperty(PROPERTY_PASSIVE_USEMAGIC_ZHEN)
end
function _getWuLi_ExtraSpeedSkillSuccess(roleObj)
  if roleObj == nil then
    return 0, 0
  end
  return roleObj:getProperty(PROPERTY_PASSIVE_USEMAGIC_SU_RATE), roleObj:getProperty(PROPERTY_PASSIVE_USEMAGIC_SU)
end
function _getWuLi_ExtraPanSkillSuccess(roleObj)
  if roleObj == nil then
    return 0, 0
  end
  return roleObj:getProperty(PROPERTY_PASSIVE_USEMAGIC_FANG_RATE), roleObj:getProperty(PROPERTY_PASSIVE_USEMAGIC_FANG)
end
function _getWuLi_ExtraAttackSkillSuccess(roleObj)
  if roleObj == nil then
    return 0, 0
  end
  return roleObj:getProperty(PROPERTY_PASSIVE_USEMAGIC_GONG_RATE), roleObj:getProperty(PROPERTY_PASSIVE_USEMAGIC_GONG)
end
function _getWuLi_ExtraFireSkillDamageSuccess(roleObj)
  if roleObj == nil then
    return 0, 0
  end
  return roleObj:getProperty(PROPERTY_PASSIVE_USEMAGIC_HUO_RATE), roleObj:getProperty(PROPERTY_PASSIVE_USEMAGIC_HUO)
end
function _getWuLi_ExtraWindSkillDamageSuccess(roleObj)
  if roleObj == nil then
    return 0, 0
  end
  return roleObj:getProperty(PROPERTY_PASSIVE_USEMAGIC_FENG_RATE), roleObj:getProperty(PROPERTY_PASSIVE_USEMAGIC_FENG)
end
function _getWuLi_ExtraThunderSkillDamageSuccess(roleObj)
  if roleObj == nil then
    return 0, 0
  end
  return roleObj:getProperty(PROPERTY_PASSIVE_USEMAGIC_LEI_RATE), roleObj:getProperty(PROPERTY_PASSIVE_USEMAGIC_LEI)
end
function _getWuLi_ExtraWaterSkillDamageSuccess(roleObj)
  if roleObj == nil then
    return 0, 0
  end
  return roleObj:getProperty(PROPERTY_PASSIVE_USEMAGIC_SHUI_RATE), roleObj:getProperty(PROPERTY_PASSIVE_USEMAGIC_SHUI)
end
function _getNeiDan_HaoRanZhengQiSuccess(roleObj)
  if roleObj == nil then
    return 0, 0
  end
  return roleObj:getProperty(PROPERTY_NEIDAN_HRZQ_EFFECTRATE), roleObj:getProperty(PROPERTY_NEIDAN_HRZQ_EFFECT)
end
function _getNeiDan_WanFoChaoZongSuccess(roleObj)
  if roleObj == nil then
    return 0, 0
  end
  return roleObj:getProperty(PROPERTY_NEIDAN_WFCZ_EFFECTRATE), roleObj:getProperty(PROPERTY_NEIDAN_WFCZ_EFFECT)
end
function _getNormalSkill_ExtraSuccessRate(roleObj, skillAttr)
  local extra_rate = 0
  local pro = SKILLATTR_TO_STRENGTHEN_MAGIC_RATE[skillAttr]
  if pro ~= nil then
    extra_rate = roleObj:getProperty(pro)
  end
  return extra_rate
end
function _getNormalSkill_ExtraDamageCoeff(roleObj, skillAttr)
  local extra_coeff = 0
  local pro = SKILLATTR_TO_STRENGTHEN_MAGIC[skillAttr]
  local pro_2 = SKILLATTR_TO_STRENGTHEN_MAGIC_RATE[skillAttr]
  if pro ~= nil then
    extra_coeff = roleObj:getProperty(pro)
  end
  if pro_2 ~= nil then
    extra_coeff = extra_coeff + roleObj:getProperty(pro_2)
  end
  return extra_coeff
end
function _getNormalSkill_ExtraDamageValue(roleObj, skillAttr)
  local extra_value = 0
  local pro = SKILLATTR_TO_STRENGTHEN_MAGIC_VALUE[skillAttr]
  if pro ~= nil then
    extra_value = roleObj:getProperty(pro)
  end
  return extra_value
end
function _getNormalSkill_WeakenDamage(roleObj, skillAttr)
  local weaken_damage = 0
  local pro = SKILLATTR_TO_WEAKEN_MAGIC[skillAttr]
  if pro ~= nil then
    weaken_damage = roleObj:getProperty(pro)
  end
  return weaken_damage
end
