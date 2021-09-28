function _computeNeiDanCoefficient(ndType, petZhuan, petLv, fam, ndLv, ndZhuan, ssv)
  local skillID = NEIDAN_ITEM_TO_SKILL_TABLE[ndType]
  if skillID == nil then
    return 0
  end
  local skillData = data_Skill[skillID]
  if skillData == nil then
    print(string.format("【_computeNeiDanCoefficient error】魂石数据异常，无法计算魂石计算系数: [%d]", skillID))
    return 0
  end
  ndZhuan = math.min(petZhuan, ndZhuan)
  ndLv = math.min(petLv, ndLv)
  ssv = ssv or 1
  local xz_k = skillData.power * ssv
  local result = xz_k * (ndZhuan * 0.25 + 1) * ((ndLv * petLv) ^ 0.5 * 0.1 + fam ^ 0.16666666666666666 * ndLv / (100 + ndZhuan * 20))
  return result
end
function _computeNeiDanRequireMp(skillID)
  local skillData = data_Skill[skillID]
  if skillData == nil then
    print(string.format("【_computeNeiDanRequireMp error】魂石数据异常，无法计算魂石魔法消耗: [%d]", skillID))
    return 0
  end
  return skillData.mp
end
function _computeNeiDanSuccess(skillID)
  local skillData = data_Skill[skillID]
  if skillData == nil then
    print(string.format("【_computeNeiDanSuccess error】魂石数据异常，无法计算魂石成功率: [%d]", skillID))
    return 0
  end
  return skillData.success
end
function _computeNeiDanDamage_TianMoJieTi(coeff, params)
  local loseRate = math.min((1 + coeff) / 100, 0.99)
  local loseHp = loseRate * params.petHp
  loseHp = math.max(loseHp, 1)
  local damageHp = (0.2 + 0.15 * params.petLv ^ 2 / (params.petMaxMp + 1)) * loseHp
  damageHp = math.max(damageHp, 1)
  return math.floor(loseHp), math.floor(damageHp)
end
function _computeNeiDanDamage_FenGuangHuaYing(coeff, params)
  local loseRate = math.min((1 + coeff) / 100, 0.99)
  local loseHp = loseRate * params.petHp
  loseHp = math.max(loseHp, 1)
  local damageMp = (0.2 + 0.15 * params.petLv ^ 2 / (params.petMaxMp + 1)) * loseHp
  damageMp = math.max(damageMp, 1)
  return math.floor(loseHp), math.floor(damageMp)
end
function _computeNeiDanDamage_QingMianLiaoYa(coeff, params)
  local loseRate = math.min((1 + coeff) / 100, 0.99)
  local loseMp = loseRate * params.petMp
  loseMp = math.max(loseMp, 1)
  local damageHp = 0.7 * loseMp
  damageHp = math.max(damageHp, 1)
  return math.floor(loseMp), math.floor(damageHp)
end
function _computeNeiDanDamage_XiaoLouYeKu(coeff, params)
  local loseRate = math.min((1 + coeff) / 100, 0.99)
  local loseMp = loseRate * params.petMp
  loseMp = math.max(loseMp, 1)
  local damageMp = 0.3 * loseMp
  damageMp = math.max(damageMp, 1)
  return math.floor(loseMp), math.floor(damageMp)
end
function _computeNeiDanPro_ChengFengPoLang(coeff)
  local ex = coeff / 100
  if coeff == 0 then
    ex = 0
  end
  if false and ex > 0 then
    ex = 1
  end
  return math.max(ex, 0)
end
function _computeNeiDanPro_PiLiLiuXing(coeff)
  local ex = coeff / 100
  if coeff == 0 then
    ex = 0
  end
  if false and ex > 0 then
    return 1
  end
  return math.max(ex, 0)
end
function _computeNeiDanPro_DaHaiWuLiang(coeff)
  local ex = coeff / 100
  if coeff == 0 then
    ex = 0
  end
  if false and ex > 0 then
    ex = 1
  end
  return math.max(ex, 0)
end
function _computeNeiDanPro_ZhuRongQuHuo(coeff)
  local ex = coeff / 100
  if coeff == 0 then
    ex = 0
  end
  if false and ex > 0 then
    return 1
  end
  return math.max(ex, 0)
end
function _computeNeiDanDamage_XiuLuo(coeff, params)
  local ndZhuan = math.min(params.ndZhuan, params.petZhuan)
  local ndLv = math.min(params.ndLv, params.petLv)
  local dhp = 9.7 * (params.petLv * ndLv) ^ 0.5 * (1 + 0.1 * ndZhuan)
  local rd_DHP = 1
  if dhp >= 1 then
    if params.ishow == true then
      rd_DHP = (1 + math.floor(dhp * 10) / 10) / 2
    else
      rd_DHP = math.random(10, math.floor(dhp * 10)) / 10
    end
  end
  local kAttr = params.kang or 0
  local fkAttr = params.fkang or 0
  local extraCoeff = params.extraCoeff or 0
  local weakCeoff = params.weakCeoff or 0
  local damageWeak = params.damageWeak or 0
  local damageHpBase = 0.25 * (params.petMaxMp / 100) ^ 1.6 + rd_DHP
  local damageHp = (damageHpBase - damageWeak) * (1 - kAttr + fkAttr) * (1 + extraCoeff) * (1 - weakCeoff)
  damageHp = math.floor(damageHp)
  return math.max(damageHp, 1)
end
function _computeNeiDanPro_HongYanBaiFa(coeff)
  local ex = math.max(coeff / 100, 0)
  if false and ex > 0 then
    ex = 1
  end
  return ex, ex
end
function _computeNeiDanPro_MeiHuaSanNong(coeff)
  local ex = math.max(coeff / 100, 0)
  local dbHitTimes = math.min(math.floor(coeff + 1), 5)
  if false and ex > 0 then
    ex = 1
  end
  return ex, dbHitTimes
end
function _computeNeiDanPro_KaiTianPiDi(coeff)
  local ex = math.max(coeff / 100, 0)
  if false and ex > 0 then
    ex = 1
  end
  return ex, ex
end
function _computeNeiDanPro_WanFoChaoZong(coeff)
  local ex = math.max(coeff / 100, 0)
  if false and ex > 0 then
    ex = 1
  end
  return ex, ex
end
function _computeNeiPro_HaoRanZhengQi(coeff, petLv, petMaxMp)
  local ex = math.max(coeff / 100, 0)
  local rate = coeff / 100 + 0.2 * petLv ^ 2 / (petMaxMp + 1)
  rate = math.max(rate, 0)
  if coeff == 0 then
    ex = 0
  end
  if false and ex > 0 then
    ex = 1
  end
  return ex, rate
end
function _computeNeiDanDamage_HaoRanZhengQi(ex, enemyMaxMp)
  local damageHp = math.min(enemyMaxMp, 100000) * ex
  damageHp = checkint(damageHp)
  return math.max(damageHp, 1)
end
function _computeNeiDanPro_AnDuChenCang(coeff)
  local ex = math.max(coeff / 100, 0)
  if false and ex > 0 then
    ex = 1
  end
  return ex, ex
end
function _computeNeiDanPro_JieLiDaLi(coeff)
  local ex = math.max(coeff / 100, 0)
  local times
  if coeff < 1 then
    times = 1
  else
    times = math.min(math.floor(coeff), 15)
  end
  if false and ex > 0 then
    ex = 1
  end
  return ex, times
end
function _computeNeiDanPro_LingBoWeiBu(coeff)
  local ex = coeff / 100
  if coeff == 0 then
    ex = 0
  end
  return math.max(ex, 0)
end
function _computeNeiDanDamage_GeShanDaNiu(coeff, petLv, petMaxMp)
  local ex = math.max(coeff / 100, 0)
  local rate = coeff / 100 + 0.2 * petLv ^ 2 / (petMaxMp + 1)
  rate = math.max(rate, 0)
  if coeff == 0 then
    ex = 0
  end
  if false and ex > 0 then
    ex = 1
  end
  return ex, rate
end
