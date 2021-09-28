function _getNeiDanCoeff(petObj, ndSkillID)
  if petObj == nil then
    return 0
  end
  local ndpro = NEIDAN_SKILL_TO_PRO_TABLE[ndSkillID]
  if ndpro == nil then
    return 0
  end
  local ndCoeff = petObj:getProperty(ndpro)
  return ndCoeff
end
function _getNeiDanDamage_TianMoJieTi_DisPlay(petObj)
  if petObj == nil then
    return 0, 0
  end
  local ndCoeff = _getNeiDanCoeff(petObj, NDSKILL_TIANMOJIETI)
  local petLv = petObj:getProperty(PROPERTY_ROLELEVEL)
  local petMaxMp = petObj:getMaxProperty(PROPERTY_MP)
  local myLoseRate = math.min((1 + ndCoeff) / 100, 0.99)
  local eLoseRate = (0.2 + 0.15 * petLv ^ 2 / (petMaxMp + 1)) * myLoseRate
  return myLoseRate, eLoseRate
end
function _getNeiDanDamage_FenGuangHuaYing_DisPlay(petObj)
  if petObj == nil then
    return 0, 0
  end
  local ndCoeff = _getNeiDanCoeff(petObj, NDSKILL_FENGUANGHUAYING)
  local petLv = petObj:getProperty(PROPERTY_ROLELEVEL)
  local petMaxMp = petObj:getMaxProperty(PROPERTY_MP)
  local myLoseRate = math.min((1 + ndCoeff) / 100, 0.99)
  local eLoseRate = (0.2 + 0.15 * petLv ^ 2 / (petMaxMp + 1)) * myLoseRate
  return myLoseRate, eLoseRate
end
function _getNeiDanDamage_QingMianLiaoYa_DisPlay(petObj)
  if petObj == nil then
    return 0, 0
  end
  local ndCoeff = _getNeiDanCoeff(petObj, NDSKILL_QINGMIANLIAOYA)
  local myLoseRate = math.min((1 + ndCoeff) / 100, 0.99)
  local eLoseRate = 0.7 * myLoseRate
  return myLoseRate, eLoseRate
end
function _getNeiDanDamage_XiaoLouYeKu_DisPlay(petObj)
  if petObj == nil then
    return 0, 0
  end
  local ndCoeff = _getNeiDanCoeff(petObj, NDSKILL_XIAOLOUYEKU)
  local myLoseRate = math.min((1 + ndCoeff) / 100, 0.99)
  local eLoseRate = 0.3 * myLoseRate
  return myLoseRate, eLoseRate
end
function _getNeiDanDamage_TianMoJieTi(petObj)
  if petObj == nil then
    return 0, 0
  end
  local ndCoeff = _getNeiDanCoeff(petObj, NDSKILL_TIANMOJIETI)
  local params = {}
  params.petLv = petObj:getProperty(PROPERTY_ROLELEVEL)
  params.petHp = petObj:getProperty(PROPERTY_HP)
  params.petMaxMp = petObj:getMaxProperty(PROPERTY_MP)
  return _computeNeiDanDamage_TianMoJieTi(ndCoeff, params)
end
function _getNeiDanDamage_FenGuangHuaYing(petObj)
  if petObj == nil then
    return 0, 0
  end
  local ndCoeff = _getNeiDanCoeff(petObj, NDSKILL_FENGUANGHUAYING)
  local params = {}
  params.petLv = petObj:getProperty(PROPERTY_ROLELEVEL)
  params.petHp = petObj:getProperty(PROPERTY_HP)
  params.petMaxMp = petObj:getMaxProperty(PROPERTY_MP)
  return _computeNeiDanDamage_FenGuangHuaYing(ndCoeff, params)
end
function _getNeiDanDamage_QingMianLiaoYa(petObj)
  if petObj == nil then
    return 0, 0
  end
  local ndCoeff = _getNeiDanCoeff(petObj, NDSKILL_QINGMIANLIAOYA)
  local params = {}
  params.petMp = petObj:getProperty(PROPERTY_MP)
  return _computeNeiDanDamage_QingMianLiaoYa(ndCoeff, params)
end
function _getNeiDanDamage_XiaoLouYeKu(petObj)
  if petObj == nil then
    return 0, 0
  end
  local ndCoeff = _getNeiDanCoeff(petObj, NDSKILL_XIAOLOUYEKU)
  local params = {}
  params.petMp = petObj:getProperty(PROPERTY_MP)
  return _computeNeiDanDamage_XiaoLouYeKu(ndCoeff, params)
end
function _getNeiDanDamage_QingMianLiaoYa_ByNDEffectAndCurMp(ndEffect, curMp)
  local ndCoeff = ndEffect
  local params = {}
  params.petMp = curMp
  return _computeNeiDanDamage_QingMianLiaoYa(ndCoeff, params)
end
function _getNeiDanDamage_XiaoLouYeKu_ByNDEffectAndCurMp(ndEffect, curMp)
  local ndCoeff = ndEffect
  local params = {}
  params.petMp = curMp
  return _computeNeiDanDamage_XiaoLouYeKu(ndCoeff, params)
end
function _getNeiDanDamage_ChengFengPoLang(petObj, kAttr, fkAttr, ishow, extraCoeff, weakCeoff, damageWeak)
  if petObj == nil then
    return 0
  end
  local neidanObj = petObj:GetNeidanObj(ITEM_DEF_NEIDAN_CFPL)
  if neidanObj == nil then
    return 0
  end
  local params = {}
  params.petZhuan = petObj:getProperty(PROPERTY_ZHUANSHENG)
  params.petLv = petObj:getProperty(PROPERTY_ROLELEVEL)
  params.petMaxMp = petObj:getMaxProperty(PROPERTY_MP)
  params.ndLv = neidanObj:getProperty(ITEM_PRO_LV)
  params.ndZhuan = neidanObj:getProperty(ITEM_PRO_NEIDAN_ZS)
  params.kang = kAttr
  params.fkang = fkAttr
  params.extraCoeff = extraCoeff
  params.weakCeoff = weakCeoff
  params.damageWeak = damageWeak
  params.ishow = ishow
  local ndCoeff = _getNeiDanCoeff(petObj, NDSKILL_CHENGFENGPOLANG)
  return _computeNeiDanDamage_XiuLuo(ndCoeff, params)
end
function _getNeiDanDamage_PiLiLiuXing(petObj, kAttr, fkAttr, ishow, extraCoeff, weakCeoff, damageWeak)
  if petObj == nil then
    return 0
  end
  local neidanObj = petObj:GetNeidanObj(ITEM_DEF_NEIDAN_PLLX)
  if neidanObj == nil then
    return 0
  end
  local params = {}
  params.petZhuan = petObj:getProperty(PROPERTY_ZHUANSHENG)
  params.petLv = petObj:getProperty(PROPERTY_ROLELEVEL)
  params.petMaxMp = petObj:getMaxProperty(PROPERTY_MP)
  params.ndLv = neidanObj:getProperty(ITEM_PRO_LV)
  params.ndZhuan = neidanObj:getProperty(ITEM_PRO_NEIDAN_ZS)
  params.kang = kAttr
  params.fkang = fkAttr
  params.extraCoeff = extraCoeff
  params.weakCeoff = weakCeoff
  params.damageWeak = damageWeak
  params.ishow = ishow
  local ndCoeff = _getNeiDanCoeff(petObj, NDSKILL_PILILIUXING)
  return _computeNeiDanDamage_XiuLuo(ndCoeff, params)
end
function _getNeiDanDamage_DaHaiWuLiang(petObj, kAttr, fkAttr, ishow, extraCoeff, weakCeoff, damageWeak)
  if petObj == nil then
    return 0
  end
  local neidanObj = petObj:GetNeidanObj(ITEM_DEF_NEIDAN_DHWL)
  if neidanObj == nil then
    return 0
  end
  local params = {}
  params.petZhuan = petObj:getProperty(PROPERTY_ZHUANSHENG)
  params.petLv = petObj:getProperty(PROPERTY_ROLELEVEL)
  params.petMaxMp = petObj:getMaxProperty(PROPERTY_MP)
  params.ndLv = neidanObj:getProperty(ITEM_PRO_LV)
  params.ndZhuan = neidanObj:getProperty(ITEM_PRO_NEIDAN_ZS)
  params.kang = kAttr
  params.fkang = fkAttr
  params.extraCoeff = extraCoeff
  params.weakCeoff = weakCeoff
  params.damageWeak = damageWeak
  params.ishow = ishow
  local ndCoeff = _getNeiDanCoeff(petObj, NDSKILL_DAHAIWULIANG)
  return _computeNeiDanDamage_XiuLuo(ndCoeff, params)
end
function _getNeiDanDamage_ZhuRongQuHuo(petObj, kAttr, fkAttr, ishow, extraCoeff, weakCeoff, damageWeak)
  if petObj == nil then
    return 0
  end
  local neidanObj = petObj:GetNeidanObj(ITEM_DEF_NEIDAN_ZRQH)
  if neidanObj == nil then
    return 0
  end
  local params = {}
  params.petZhuan = petObj:getProperty(PROPERTY_ZHUANSHENG)
  params.petLv = petObj:getProperty(PROPERTY_ROLELEVEL)
  params.petMaxMp = petObj:getMaxProperty(PROPERTY_MP)
  params.ndLv = neidanObj:getProperty(ITEM_PRO_LV)
  params.ndZhuan = neidanObj:getProperty(ITEM_PRO_NEIDAN_ZS)
  params.kang = kAttr
  params.fkang = fkAttr
  params.extraCoeff = extraCoeff
  params.weakCeoff = weakCeoff
  params.damageWeak = damageWeak
  params.ishow = ishow
  local ndCoeff = _getNeiDanCoeff(petObj, NDSKILL_ZHURONGQUHUO)
  return _computeNeiDanDamage_XiuLuo(ndCoeff, params)
end
function _getNeiDanDamage_HaoRanZhengQi(rate, targetMaxMp)
  return _computeNeiDanDamage_HaoRanZhengQi(rate, targetMaxMp)
end
function _getNeiDanSuccess(skillID)
  return _computeNeiDanSuccess(skillID)
end
