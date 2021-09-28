local _checkDamage = function(damage)
  return math.max(math.floor(damage), 1)
end
function _computeMarrySkillRequireMp(skillId, skillExp)
  local skillData = _getSkillData(skillId) or {}
  local mpbase = skillData.mpbase or 0
  return math.floor(mpbase * (skillExp ^ 0.3 * 50 / 100 + 1))
end
function _computeMarrySkill_QinMiWuJian(roleLv, skillExp)
  local skillData = _getSkillData(MARRYSKILL_QINMIWUJIAN) or {}
  local param = skillData.calparam or {}
  local cdRound = skillData.cd or 1
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local addHp = _checkDamage(a * b * roleLv ^ c + skillExp)
  local addMp = _checkDamage(a * b * roleLv ^ c + skillExp)
  return addHp, addMp, cdRound
end
function _computeMarrySkill_TongChouDiKai(roleLv, skillExp)
  local skillData = _getSkillData(MARRYSKILL_TONGCHOUDIKAI) or {}
  local param = skillData.calparam or {}
  local cdRound = skillData.cd or 1
  local round = param[1]
  local a = param[2] or 0
  local b = param[3] or 0
  local c = param[4] or 1
  local d = param[5] or 0
  local e = param[6] or 1
  local f = param[7] or 0
  local pro = a + b * (roleLv / c + d * (skillExp / e) ^ f)
  return pro, round, cdRound
end
function _computeMarrySkill_QingShenSiHai(roleLv, skillExp)
  local skillData = _getSkillData(MARYYSKILL_QINGSHENSIHAI) or {}
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 1
  local d = param[4] or 0
  local e = param[5] or 1
  local f = param[6] or 0
  local pro = a + b * (roleLv / c + d * (skillExp / e) ^ f)
  return pro
end
