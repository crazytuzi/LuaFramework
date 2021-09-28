function _computeSkillRequireMp(skillID, skillExp)
  if skillID == SKILLTYPE_NORMALATTACK then
    return 0
  elseif skillID == SKILLTYPE_BABYMONSTER or skillID == SKILLTYPE_BABYPET then
    return 0
  elseif skillID == SKILLTYPE_DEFEND then
    return 0
  elseif skillID == SKILLTYPE_RUNAWAY then
    return 0
  end
  local skillData = data_Skill[skillID]
  if skillData == nil then
    print(string.format("【_computeSkillRequireMp error】技能数据异常，无法计算技能魔法消耗: [%d]", skillID))
    return 0
  end
  if skillID == SKILL_SHOUHUCANGSHENG or skillID == SKILL_YIHUAJIEYU or skillID == SKILL_KAISHANLIESHI or skillID == SKILL_JIZHINUMU then
    return skillData.mp or 0
  end
  if skillExp == nil then
    skillExp = 1
  end
  local mp = math.floor(skillData.mp * (skillExp ^ 0.3 * 50 / 100 + 1))
  return math.max(mp, 0)
end
function _computeSkillSuccess(skillID, kAttr, fkAttr, skillExp, ssv)
  local skillData = data_Skill[skillID]
  if skillData == nil then
    print(string.format("【_computeSkillSuccess error】技能数据异常，无法计算技能成功率: [%d]", skillID))
    return 0
  end
  local skillAttr = skillData.attr
  local s
  if skillAttr == SKILLATTR_POISON or skillAttr == SKILLATTR_SLEEP or skillAttr == SKILLATTR_CONFUSE or skillAttr == SKILLATTR_ICE or skillAttr == SKILLATTR_YIWANG then
    ssv = ssv or 1
    local success = skillData.success * ssv
    s = success * (skillExp ^ 0.3 * 4 / 100 + 1) - kAttr + fkAttr
  else
    s = skillData.success
  end
  return math.max(s, 0)
end
local _computeSkillRound_Poison = function(skillData, skillExp, kAttr, fkAttr)
  kAttr = kAttr or 0
  fkAttr = fkAttr or 0
  local round = 1
  if skillData.step <= 3 then
    round = skillData.round * (skillExp ^ 0.3 * 8 / 100 + 1)
  else
    round = skillData.round * (skillExp ^ 0.3 * 7 / 100 + 1)
  end
  local roundMin = skillData.round
  local roundMax = math.max(math.floor(round), roundMin)
  round = math.floor(round * (1 - kAttr / 2 + fkAttr))
  if roundMin > round then
    round = roundMin
  elseif roundMax < round then
    round = roundMax
  end
  return round
end
local _computeSkillRound_Sleep = function(skillData, skillExp, kAttr, fkAttr)
  kAttr = kAttr or 0
  fkAttr = fkAttr or 0
  local round = 1
  if skillData.step <= 3 then
    round = skillData.round * (skillExp ^ 0.3 * 8 / 100 + 1)
  else
    round = skillData.round * (skillExp ^ 0.3 * 7 / 100 + 1)
  end
  local roundMin = skillData.round
  local roundMax = math.max(math.floor(round), roundMin)
  round = math.floor(round * (1 - kAttr / 2 + fkAttr))
  if roundMin > round then
    round = roundMin
  elseif roundMax < round then
    round = roundMax
  end
  return round
end
local _computeSkillRound_Confuse = function(skillData, skillExp, kAttr, fkAttr)
  kAttr = kAttr or 0
  fkAttr = fkAttr or 0
  local round = 1
  if skillData.step <= 3 then
    round = skillData.round * (skillExp ^ 0.3 * 6 / 100 + 1)
  else
    round = skillData.round * (skillExp ^ 0.3 * 5 / 100 + 1)
  end
  local roundMin = skillData.round
  local roundMax = math.max(math.floor(round), roundMin)
  round = math.floor(round * (1 - kAttr / 2 + fkAttr))
  if roundMin > round then
    round = roundMin
  elseif roundMax < round then
    round = roundMax
  end
  return round
end
local _computeSkillRound_Ice = function(skillData, skillExp, kAttr, fkAttr)
  kAttr = kAttr or 0
  fkAttr = fkAttr or 0
  local round = 1
  if skillData.step <= 3 then
    round = skillData.round * (skillExp ^ 0.3 * 8 / 100 + 1)
  else
    round = skillData.round * (skillExp ^ 0.3 * 7 / 100 + 1)
  end
  local roundMin = skillData.round
  local roundMax = math.max(math.floor(round), roundMin)
  round = math.floor(round * (1 - kAttr / 2 + fkAttr))
  if roundMin > round then
    round = roundMin
  elseif roundMax < round then
    round = roundMax
  end
  return round
end
local _computeSkillRound_Pan = function(skillData, skillExp)
  local round = 1
  if skillData.step <= 3 then
    round = math.floor(skillData.round * (skillExp ^ 0.35 * 7 / 100 + 1))
  else
    round = math.floor(skillData.round * (skillExp ^ 0.35 * 5 / 100 + 1))
  end
  return math.max(round, 1)
end
local _computeSkillRound_Attack = function(skillData, skillExp)
  local round = 1
  if skillData.step <= 3 then
    round = math.floor(skillData.round * (skillExp ^ 0.35 * 7 / 100 + 1))
  else
    round = math.floor(skillData.round * (skillExp ^ 0.35 * 5 / 100 + 1))
  end
  return math.max(round, 1)
end
local _computeSkillRound_Speed = function(skillData, skillExp)
  local round = 1
  if skillData.step <= 3 then
    round = math.floor(skillData.round * (skillExp ^ 0.35 * 7 / 100 + 1))
  else
    round = math.floor(skillData.round * (skillExp ^ 0.35 * 5 / 100 + 1))
  end
  return math.max(round, 1)
end
local _computeSkillRound_MingLingFeiZi = function(skillData, skillExp)
  local round = math.floor(skillData.round)
  return math.max(round, 1)
end
local _computeSkillRound_JiXiangGuoZi = function(skillData, skillExp)
  local round = math.floor(skillData.round)
  return math.max(round, 1)
end
local _computeSkillRound_ShouHuCangSheng = function(skillData, skillExp)
  local round = math.floor(skillData.round)
  return math.max(round, 1)
end
local _computeSkillRound_ShuaiRuo = function(skillData, skillExp)
  local round = math.floor(skillData.round)
  return math.max(round, 1)
end
local _computeSkillRound_YiWang = function(skillData, skillExp, kAttr, fkAttr)
  kAttr = kAttr or 0
  fkAttr = fkAttr or 0
  local round = skillData.round * (skillExp ^ 0.3 * 8 / 100 + 1)
  local roundMin = skillData.round
  local roundMax = math.max(math.floor(round), roundMin)
  round = math.floor(round * (1 - kAttr / 2 + fkAttr))
  if roundMin > round then
    round = roundMin
  elseif roundMax < round then
    round = roundMax
  end
  return round
end
local _computeSkillRound_Nian = function(skillData, skillExp)
  local round = math.floor(skillData.round)
  return math.max(round, 1)
end
function _computeSkillRound(skillID, skillExp, kAttr, fkAttr)
  local skillData = data_Skill[skillID]
  if skillData == nil then
    print(string.format("【_computeSkillRound error】技能数据异常，无法计算技能回合数: [%d]", skillID))
    return 1
  end
  kAttr = kAttr or 0
  fkAttr = fkAttr or 0
  local skillAttr = skillData.attr
  if skillAttr == SKILLATTR_POISON then
    return _computeSkillRound_Poison(skillData, skillExp, kAttr, fkAttr)
  elseif skillAttr == SKILLATTR_SLEEP then
    return _computeSkillRound_Sleep(skillData, skillExp, kAttr, fkAttr)
  elseif skillAttr == SKILLATTR_CONFUSE then
    return _computeSkillRound_Confuse(skillData, skillExp, kAttr, fkAttr)
  elseif skillAttr == SKILLATTR_ICE then
    return _computeSkillRound_Ice(skillData, skillExp, kAttr, fkAttr)
  elseif skillAttr == SKILLATTR_PAN then
    return _computeSkillRound_Pan(skillData, skillExp)
  elseif skillAttr == SKILLATTR_ATTACK then
    return _computeSkillRound_Attack(skillData, skillExp)
  elseif skillAttr == SKILLATTR_SPEED then
    return _computeSkillRound_Speed(skillData, skillExp)
  elseif skillAttr == SKILLATTR_MINGLINGFEIZI then
    return _computeSkillRound_MingLingFeiZi(skillData, skillExp)
  elseif skillAttr == SKILLATTR_JIXIANGGUOZI then
    return _computeSkillRound_JiXiangGuoZi(skillData, skillExp)
  elseif skillAttr == SKILLATTR_SHOUHUCANGSHENG then
    return _computeSkillRound_ShouHuCangSheng(skillData, skillExp)
  elseif skillAttr == SKILLATTR_SHUAIRUO then
    return _computeSkillRound_ShuaiRuo(skillData, skillExp)
  elseif skillAttr == SKILLATTR_YIWANG then
    return _computeSkillRound_YiWang(skillData, skillExp, kAttr, fkAttr)
  elseif skillAttr == SKILLATTR_NIAN then
    return _computeSkillRound_Nian(skillData, skillExp)
  else
    return 1
  end
end
function _computeSkillDamage_Poison_FirstRound(skillID, skillExp, pLevel, ssv)
  local skillData = data_Skill[skillID]
  if skillData == nil then
    return 1
  end
  ssv = ssv or 1
  local power = skillData.power * ssv
  local damage = power * ((100000 + skillExp) / 100000)
  return damage
end
function _computeSkillDamage_Poison(skillID, kAttr, fkAttr, skillExp, sRound, pLevel, maxHp, ssv, extraCoeff, weakCeoff, damageWeak)
  local skillData = data_Skill[skillID]
  if skillData == nil then
    return 1
  end
  sRound = sRound or 1
  ssv = ssv or 1
  extraCoeff = extraCoeff or 0
  weakCeoff = weakCeoff or 0
  damageWeak = damageWeak or 0
  local power = skillData.power * ssv
  local damageBase = maxHp * power * ((100000 + skillExp) / 100000) * 0.75 ^ (sRound - 1)
  local damageMaxBase = 7000 * (1 + power) * (1 + math.floor(skillExp / 1000) * 0.01 + pLevel * 0.001)
  local damage = (damageBase - damageWeak) * (1 - kAttr + fkAttr) * (1 + extraCoeff)
  local damageMax = (damageMaxBase - damageWeak) * (1 - kAttr + fkAttr) * (1 + extraCoeff)
  damage = math.min(damage, damageMax)
  damage = math.floor(damage)
  damage = math.max(damage, 1)
  return damage
end
function _computeSkillDamage_Confuse(skillID, kAttr, fkAttr, skillExp, pLevel, ssv, extraCoeff, weakCeoff, damageWeak)
  local skillData = data_Skill[skillID]
  if skillData == nil then
    return 1
  end
  ssv = ssv or 1
  extraCoeff = extraCoeff or 0
  weakCeoff = weakCeoff or 0
  damageWeak = damageWeak or 0
  local power = skillData.power * ssv
  local damageBase = power * pLevel ^ 0.45 * (skillExp ^ 0.4 * 2.8853998118144273 / 100 + 1)
  local damage = (damageBase - damageWeak) * (1 - kAttr + fkAttr) * (1 + extraCoeff)
  damage = math.floor(damage)
  damage = math.max(damage, 1)
  return damage
end
function _computeSkillDamage_XianZu(skillID, kAttr, fkAttr, skillExp, pLevel, ssv, extraCoeff, weakCeoff, damageWeak)
  local skillData = data_Skill[skillID]
  if skillData == nil then
    return 1
  end
  ssv = ssv or 1
  extraCoeff = extraCoeff or 0
  weakCeoff = weakCeoff or 0
  damageWeak = damageWeak or 0
  local damageBase = 0
  local power = skillData.power * ssv
  if 1 >= skillData.step then
    damageBase = power * pLevel * 0.9 * (skillExp ^ 0.4 * 2.8853998118144273 / 100 + 1)
  elseif skillData.step == 2 then
    damageBase = power * pLevel * 1 * (skillExp ^ 0.4 * 2.8853998118144273 / 100 + 1)
  elseif skillData.step == 3 then
    damageBase = power * pLevel * 0.95 * (skillExp ^ 0.4 * 2.8853998118144273 / 100 + 1)
  elseif skillData.step == 4 then
    damageBase = power * pLevel * 1.05 * (skillExp ^ 0.4 * 2.8853998118144273 / 100 + 1)
  else
    damageBase = power * pLevel * 1 * (skillExp ^ 0.4 * 2.51188643150958 / 100 + 1)
  end
  local damage = (damageBase - damageWeak) * (1 - kAttr + fkAttr) * (1 + extraCoeff) * (1 - weakCeoff)
  damage = math.floor(damage)
  damage = math.max(damage, 1)
  return damage
end
function _computeSkillDamage_Zhen(skillID, kAttr, fkAttr, skillExp, pLevel, hp, mp, ssv, extraCoeff, weakCeoff, damageWeak)
  local skillData = data_Skill[skillID]
  if skillData == nil then
    return 1, 1
  end
  ssv = ssv or 1
  extraCoeff = extraCoeff or 0
  weakCeoff = weakCeoff or 0
  damageWeak = damageWeak or 0
  local k_hp = (skillData.power[1] or 0) * ssv
  local k_mp = (skillData.power[2] or 0) * ssv
  local damageHPBase = pLevel ^ 0.3333333333333333 * 100 + hp * k_hp * (skillExp ^ 0.35 * 2 / 100 + 1)
  local damageMpBase = pLevel ^ 0.3333333333333333 * 100 + mp * k_mp * (skillExp ^ 0.35 * 2 / 100 + 1)
  local damageHP = (damageHPBase - damageWeak) * (1 - kAttr + fkAttr) * (1 + extraCoeff)
  local damageMp = (damageMpBase - damageWeak) * (1 - kAttr + fkAttr) * (1 + extraCoeff)
  damageHP = math.floor(damageHP)
  damageHP = math.max(damageHP, 1)
  damageMp = math.floor(damageMp)
  damageMp = math.max(damageMp, 1)
  return damageHP, damageMp
end
function _computeSkillDamage_Zhen_Detail(skillID, skillExp, pLevel, ssv)
  local skillData = data_Skill[skillID]
  if skillData == nil then
    return 0, 0, 0, 0
  end
  ssv = ssv or 1
  local k_hp = (skillData.power[1] or 0) * ssv
  local k_mp = (skillData.power[2] or 0) * ssv
  return math.floor(pLevel ^ 0.3333333333333333 * 100), k_hp * (skillExp ^ 0.35 * 2 / 100 + 1), math.floor(pLevel ^ 0.3333333333333333 * 100), k_mp * (skillExp ^ 0.35 * 2 / 100 + 1)
end
function _computeSkillDamage_AiHao(skillID, kAttr, fkAttr, skillExp, pLevel, ssv, extraCoeff, weakCeoff, damageWeak, deadNum)
  local skillData = data_Skill[skillID]
  if skillData == nil then
    return 1
  end
  ssv = ssv or 1
  extraCoeff = extraCoeff or 0
  weakCeoff = weakCeoff or 0
  damageWeak = damageWeak or 0
  local power = skillData.power or {}
  local coeff = (power[1] or 0) * ssv
  local coeff_2 = 1
  if deadNum <= 0 then
    coeff_2 = power[2] or 1
  elseif deadNum == 1 then
    coeff_2 = power[3] or 1
  elseif deadNum == 2 then
    coeff_2 = power[4] or 1
  elseif deadNum == 3 then
    coeff_2 = power[5] or 1
  else
    coeff_2 = power[6] or 1
  end
  local damageBase = coeff * pLevel * (skillExp ^ 0.4 * 2.8853998118144273 / 100 + 1) * coeff_2
  local damage = (damageBase - damageWeak) * (1 - kAttr + fkAttr) * (1 + extraCoeff) * (1 - weakCeoff)
  damage = math.floor(damage)
  damage = math.max(damage, 1)
  return damage
end
function _computeSkillDamage_XiXue(skillID, damageWeak, damageAdd, skillExp, pLevel, ssv, weakCeoff)
  local skillData = data_Skill[skillID]
  if skillData == nil then
    return 1
  end
  ssv = ssv or 1
  weakCeoff = weakCeoff or 0
  damageWeak = damageWeak or 0
  damageAdd = damageAdd or 0
  local power = skillData.power or {}
  local coeff = (power[1] or 0) * ssv
  damageBase = coeff * pLevel * (skillExp ^ 0.4 * 2.8853998118144273 / 100 + 1)
  local damage = (damageBase + damageAdd - damageWeak) * (1 - weakCeoff)
  damage = math.floor(damage)
  damage = math.max(damage, 1)
  return damage
end
function _computeSkillDamage_XiXueAddHp(skillID, damage, extraCeoff)
  local skillData = data_Skill[skillID]
  if skillData == nil then
    return 0
  end
  extraCeoff = extraCeoff or 0
  local power = skillData.power or {}
  local baseCoeff = power[2] or 0
  local addHp = damage * (baseCoeff + 2 * extraCeoff)
  addHp = math.floor(addHp)
  addHp = math.max(addHp, 1)
  return addHp
end
function _computeSkillDamage_XiXueAddHp_BaseCoeff(skillID)
  local skillData = data_Skill[skillID]
  if skillData == nil then
    return 0
  end
  local power = skillData.power or {}
  local baseCoeff = power[2] or 0
  return baseCoeff
end
function _computeSkillDamage_YiWang(skillID)
  local skillData = data_Skill[skillID]
  if skillData == nil then
    return 0
  end
  local power = skillData.power or 0
  return power
end
function _computeSkillEffect_Pan(skillID, skillExp, ssv)
  local skillData = data_Skill[skillID]
  if skillData == nil then
    return 0, 0, 0
  end
  local wlKang, xzKang, rzKang = 0, 0, 0
  ssv = ssv or 1
  local k_wl = (skillData.power[1] or 0) * ssv
  local k_xz = (skillData.power[2] or 0) * ssv
  local k_rz = (skillData.power[3] or 0) * ssv
  wlKang = k_wl * (skillExp ^ 0.35 * 2 / 100 + 1)
  xzKang = k_xz * (skillExp ^ 0.35 * 2 / 100 + 1)
  rzKang = k_rz * (skillExp ^ 0.35 * 2 / 100 + 1)
  return math.max(wlKang, 0), math.max(xzKang, 0), math.max(rzKang, 0)
end
function _computeSkillEffect_Attack(skillID, skillExp, ssv)
  local skillData = data_Skill[skillID]
  if skillData == nil then
    return 0, 0
  end
  local ap, mz = 0, 0
  ssv = ssv or 1
  local k_ap = (skillData.power[1] or 0) * ssv
  local k_mz = (skillData.power[2] or 0) * ssv
  ap = k_ap * (skillExp ^ 0.35 * 5 / 100 + 1)
  mz = k_mz * (skillExp ^ 0.35 * 5 / 100 + 1)
  return math.max(ap, 0), math.max(mz, 0)
end
function _computeSkillEffect_Speed(skillID, skillExp, ssv)
  local skillData = data_Skill[skillID]
  if skillData == nil then
    return 0
  end
  local sp = 0
  ssv = ssv or 1
  local power = skillData.power * ssv
  sp = power * (skillExp ^ 0.3 * 2 / 100 + 1)
  return math.max(sp, 0)
end
function _computeSkillEffect_MingLingFeiZi(skillID, ssv)
  local skillData = data_Skill[skillID]
  if skillData == nil then
    return 0, 0, 0
  end
  ssv = ssv or 1
  local k_wl = (skillData.power[1] or 0) * ssv
  local k_xz = (skillData.power[2] or 0) * ssv
  local k_rz = (skillData.power[3] or 0) * ssv
  return -math.max(k_wl, 0), -math.max(k_xz, 0), -math.max(k_rz, 0)
end
function _computeSkillEffect_JiXiangGuoZi(skillID, ssv)
  local skillData = data_Skill[skillID]
  if skillData == nil then
    return 0
  end
  ssv = ssv or 1
  local power = skillData.power or {}
  local k_zs = (power[1] or 0) * ssv
  local k_yw = (power[2] or 0) * ssv
  local k_ah = (power[3] or 0) * ssv
  local k_xx = (power[4] or 0) * ssv
  return -math.max(k_zs, 0), -math.max(k_yw, 0), -math.max(k_ah, 0), -math.max(k_xx, 0)
end
function _computeSkillEffect_ShuaiRuo(skillID, skillExp, ssv)
  local skillData = data_Skill[skillID]
  if skillData == nil then
    return 0, 0, 0
  end
  ssv = ssv or 1
  local power = skillData.power or {}
  local coeff = skillExp ^ 0.35 * 2 / 100 + 1
  local k_zhen = (power[1] or 0) * ssv
  k_zhen = -math.max(k_zhen * coeff, 0)
  local k_yw = (power[2] or 0) * ssv
  k_yw = -math.max(k_yw * coeff, 0)
  local k_ah = (power[3] or 0) * ssv
  k_ah = -math.max(k_ah * coeff, 0)
  local k_xx = (power[4] or 0) * ssv
  k_xx = -math.max(math.floor(k_xx * coeff), 0)
  return k_zhen, k_yw, k_ah, k_xx
end
function _computeSkillEffect_ShouHuCangSheng(skillID)
  local skillData = data_Skill[skillID]
  if skillData == nil then
    return 0.7, 0.25, 5
  end
  local power = skillData.power
  return power[1], power[2], math.floor(power[3])
end
function _computeSkillEffect_Nian(skillID)
  local skillData = data_Skill[skillID]
  if skillData == nil then
    return 0, 0, 0
  end
  local power = skillData.power or {}
  return power[1] or 0, power[2] or 0, power[3] or 0
end
function _computeSkillEffect_GuYingZiLian(skillID)
  local skillData = data_Skill[skillID]
  if skillData == nil then
    return 0.6
  end
  local power = skillData.power or 0.6
  return power
end
function _computeSkillEffect_YiHuaJieYu(skillID)
  local skillData = data_Skill[skillID]
  if skillData == nil then
    return 0
  end
  local power = skillData.power or 0
  return power
end
