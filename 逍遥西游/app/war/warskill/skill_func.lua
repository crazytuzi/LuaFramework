function _getTheFightIsEnd(warId)
  if warId == nil then
    return true
  end
  local result = g_WarAiInsList[warId]:GetWarResult()
  return result ~= WARRESULT_NONE
end
function _getTheWarType(warId)
  local warType = g_WarAiInsList[warId]:GetWarType()
  return warType
end
function _getFightRoleObjByPos(warId, pos)
  if warId == nil then
    printLogDebug("war_skill", "【skill tip】error  _getFightRoleObjByPos, warId 是nil")
    return nil
  end
  if pos == nil then
    printLogDebug("war_skill", "【skill tip】[warid%d] error  _getFightRoleObjByPos, pos 是nil", warId)
    return nil
  end
  local roleObj = g_WarAiInsList[warId]:getObjectByPos(pos)
  if roleObj == nil or roleObj:getProperty(PROPERTY_DEAD) ~= ROLESTATE_LIVE then
    return nil
  else
    return roleObj
  end
end
function _getFightRoleObjByPos_WithDeadHero(warId, pos)
  if warId == nil then
    printLogDebug("war_skill", "【skill tip】error  _getFightRoleObjByPos_WithDeadHero, warId 是nil")
    return nil
  end
  if pos == nil then
    printLogDebug("war_skill", "【skill tip】[warid%d] error  _getFightRoleObjByPos_WithDeadHero, pos 是nil", warId)
    return nil
  end
  local roleObj = g_WarAiInsList[warId]:getObjectByPos(pos)
  if roleObj == nil then
    return nil
  elseif roleObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE or roleObj:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD and roleObj:getType() == LOGICTYPE_HERO then
    return roleObj
  else
    return nil
  end
end
function _getFightRoleObjByPos_DeadOrLive(warId, pos)
  if warId == nil then
    printLogDebug("war_skill", "【skill tip】error  _getFightRoleObjByPos_DeadOrLive, warId 是nil")
    return nil
  end
  if pos == nil then
    printLogDebug("war_skill", "【skill tip】[warid%d] error  _getFightRoleObjByPos_DeadOrLive, pos 是nil", warId)
    return nil
  end
  local roleObj = g_WarAiInsList[warId]:getObjectByPos(pos)
  if roleObj == nil then
    return nil
  elseif roleObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE or roleObj:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD then
    return roleObj
  else
    return nil
  end
end
function _getFightRoleObjByPosOnUseDrug(warId, pos)
  if warId == nil then
    printLogDebug("war_skill", "【skill tip】error  _getFightRoleObjByPosOnUseDrug, warId 是nil")
    return nil
  end
  if pos == nil then
    printLogDebug("war_skill", "【skill tip】[warid%d] error  _getFightRoleObjByPosOnUseDrug, pos 是nil", warId)
    return nil
  end
  local roleObj = g_WarAiInsList[warId]:getObjectByPos(pos)
  if roleObj == nil or roleObj:getType() == LOGICTYPE_HERO and roleObj:getProperty(PROPERTY_DEAD) ~= ROLESTATE_LIVE and roleObj:getProperty(PROPERTY_DEAD) ~= ROLESTATE_DEAD or roleObj:getType() ~= LOGICTYPE_HERO and roleObj:getProperty(PROPERTY_DEAD) ~= ROLESTATE_LIVE then
    return nil
  else
    return roleObj
  end
end
function _getMasterPosByPetPos(pos)
  return pos - DefineRelativePetAddPos
end
function _getPetPosByMasterPos(pos)
  return pos + DefineRelativePetAddPos
end
local _getValueBySkillExp = function(skillId, skillExp, sData, roleType)
  if roleType == LOGICTYPE_PET and (skillId == 30023 or skillId == 30028 or skillId == 30033 or skillId == 30038) then
    return 3
  elseif roleType == LOGICTYPE_PET and (skillId == 30043 or skillId == 30048 or skillId == 30053) then
    return 2
  elseif type(sData) == "number" then
    return sData
  elseif type(sData) == "table" then
    for index = #sData, 1, -1 do
      local data = sData[index]
      local needExp = data[1]
      local damage = data[2]
      if skillExp >= needExp then
        return damage
      end
    end
  end
  return 0
end
local _getValueByLevel = function(skillExp, sData)
  if type(sData) == "number" then
    return sData
  elseif type(sData) == "table" then
    for index = #sData, 1, -1 do
      local data = sData[index]
      local needExp = data[1]
      local damage = data[2]
      if skillExp >= needExp then
        return damage
      end
    end
  end
  return 0
end
function _getSkillTargetNum(skillId, skillExp, roleType)
  local skillData = _getSkillData(skillId)
  if skillData == nil then
    return _getValueBySkillExp(skillId, skillExp, 1, roleType)
  else
    return _getValueBySkillExp(skillId, skillExp, skillData.targetNum, roleType)
  end
end
function _getSkillTargetNumBySkillExp(skillId, skillExp, sData, roleType)
  return _getValueBySkillExp(skillId, skillExp, sData, roleType)
end
function _getEffectOffID(effectID)
  if effectID == EFFECTTYPE_CONFUSE then
    return EFFECTTYPE_CONFUSE_OFF
  elseif effectID == EFFECTTYPE_FROZEN then
    return EFFECTTYPE_FROZEN_OFF
  elseif effectID == EFFECTTYPE_SLEEP then
    return EFFECTTYPE_SLEEP_OFF
  elseif effectID == EFFECTTYPE_POISON then
    return EFFECTTYPE_POISON_OFF
  elseif effectID == EFFECTTYPE_ADV_SPEED then
    return EFFECTTYPE_ADV_SPEED_OFF
  elseif effectID == EFFECTTYPE_ADV_DAMAGE then
    return EFFECTTYPE_ADV_DAMAGE_OFF
  elseif effectID == EFFECTTYPE_ADV_WULI then
    return EFFECTTYPE_ADV_WULI_OFF
  elseif effectID == EFFECTTYPE_ADV_RENZU then
    return EFFECTTYPE_ADV_RENZU_OFF
  elseif effectID == EFFECTTYPE_ADV_XIANZU then
    return EFFECTTYPE_ADV_XIANZU_OFF
  elseif effectID == EFFECTTYPE_ADV_MINGZHONG then
    return EFFECTTYPE_ADV_MINGZHONG_OFF
  elseif effectID == EFFECTTYPE_ADV_DEFEND then
    return EFFECTTYPE_ADV_DEFEND_OFF
  elseif effectID == EFFECTTYPE_FURY then
    return EFFECTTYPE_FURY_OFF
  elseif effectID == EFFECTTYPE_DEC_WULI then
    return EFFECTTYPE_DEC_WULI_OFF
  elseif effectID == EFFECTTYPE_DEC_RENZU then
    return EFFECTTYPE_DEC_RENZU_OFF
  elseif effectID == EFFECTTYPE_DEC_XIANZU then
    return EFFECTTYPE_DEC_XIANZU_OFF
  elseif effectID == EFFECTTYPE_DEC_ZHEN then
    return EFFECTTYPE_DEC_ZHEN_OFF
  elseif effectID == EFFECTTYPE_SHUAIRUO then
    return EFFECTTYPE_SHUAIRUO_OFF
  elseif effectID == EFFECTTYPE_YIWANG then
    return EFFECTTYPE_YIWANG_OFF
  elseif effectID == EFFECTTYPE_ADV_NIAN then
    return EFFECTTYPE_ADV_NIAN_OFF
  elseif effectID == EFFECTTYPE_DEC_SPEED then
    return EFFECTTYPE_DEC_SPEED_OFF
  elseif effectID == EFFECTTYPE_SHUNSHUITUIZHOU then
    return EFFECTTYPE_SHUNSHUITUIZHOU_OFF
  elseif effectID == EFFECTTYPE_RUHUTIANYI then
    return EFFECTTYPE_RUHUTIANYI_OFF
  elseif effectID == EFFECTTYPE_HENGYUNDUANFENG then
    return EFFECTTYPE_HENGYUNDUANFENG_OFF
  elseif effectID == EFFECTTYPE_SHUSHOUWUCE then
    return EFFECTTYPE_SHUSHOUWUCE_OFF
  elseif effectID == EFFECTTYPE_LONGZHANYUYE then
    return EFFECTTYPE_LONGZHANYUYE_OFF
  elseif effectID == EFFECTTYPE_STEALTH then
    return EFFECTTYPE_STEALTH_OFF
  elseif effectID == EFFECTTYPE_DUOHUNSUOMING then
    return EFFECTTYPE_DUOHUNSUOMING_OFF
  elseif effectID == EFFECTTYPE_WUXING then
    return EFFECTTYPE_WUXING_OFF
  elseif effectID == EFFECTTYPE_WUXING_JIN then
    return EFFECTTYPE_WUXING_JIN_OFF
  elseif effectID == EFFECTTYPE_WUXING_MU then
    return EFFECTTYPE_WUXING_MU_OFF
  elseif effectID == EFFECTTYPE_WUXING_SHUI then
    return EFFECTTYPE_WUXING_SHUI_OFF
  elseif effectID == EFFECTTYPE_WUXING_HUO then
    return EFFECTTYPE_WUXING_HUO_OFF
  elseif effectID == EFFECTTYPE_WUXING_TU then
    return EFFECTTYPE_WUXING_TU_OFF
  elseif effectID == EFFECTTYPE_TONGCHOUDIKAI then
    return EFFECTTYPE_TONGCHOUDIKAI_OFF
  elseif effectID == EFFECTTYPE_FENGMO then
    return EFFECTTYPE_FENGMO_OFF
  elseif effectID == EFFECTTYPE_SHOUHUCANGSHENG then
    return EFFECTTYPE_SHOUHUCANGSHENG_OFF
  else
    return nil
  end
end
function _getRoleIsInEffect(roleObj, checkEffList)
  if roleObj == nil then
    return false
  end
  if roleObj.getEffects == nil then
    return false
  end
  local effectList = roleObj:getEffects()
  for _, effectID in pairs(effectIDList) do
    for _, eID in pairs(checkEffList) do
      if effectID == eID then
        return true
      end
    end
  end
  return false
end
function _getEffectIsExisted(checkEffect, effectIDList)
  if effectIDList == nil then
    return false
  end
  for _, effectID in pairs(effectIDList) do
    if checkEffect == effectID then
      return true
    end
  end
  return false
end
function _checkRoleIsInState(roleObj, checkEffectID)
  if roleObj == nil then
    return false
  end
  if roleObj.getEffects == nil then
    return false
  end
  local effectList = roleObj:getEffects()
  for effectID, effectInfo in pairs(effectList) do
    local round = effectInfo[1]
    if effectID == checkEffectID and round > 0 then
      return true
    end
  end
  return false
end
function _removeRoleEffectState(roleObj, rmvEffectID)
  if roleObj == nil then
    return
  end
  local effectList = roleObj:getEffects()
  for effectID, effectInfo in pairs(effectList) do
    if effectID == rmvEffectID then
      effectList[effectID] = nil
      return
    end
  end
end
function _getRoleEffectData(roleObj, effectID)
  if roleObj == nil then
    return nil
  end
  local effectList = roleObj:getEffects()
  local d = effectList[effectID]
  if d == nil then
    return nil
  else
    return d[3]
  end
end
function _canSkillOnRole_Poison(roleObj)
  if _checkRoleIsInState(roleObj, EFFECTTYPE_FROZEN) then
    return false
  end
  return true
end
function _canSkillOnRole_Sleep(roleObj)
  if _checkRoleIsInState(roleObj, EFFECTTYPE_FROZEN) then
    return false
  end
  return true
end
function _canSkillOnRole_Confuse(roleObj)
  if _checkRoleIsInState(roleObj, EFFECTTYPE_FROZEN) then
    return false
  end
  return true
end
function _canSkillOnRole_Ice(roleObj)
  return true
end
function _canSkillOnRole_Fire(roleObj)
  if _checkRoleIsInState(roleObj, EFFECTTYPE_FROZEN) then
    return false
  end
  return true
end
function _canSkillOnRole_Fire(roleObj)
  if _checkRoleIsInState(roleObj, EFFECTTYPE_FROZEN) then
    return false
  end
  return true
end
function _canSkillOnRole_Wind(roleObj)
  if _checkRoleIsInState(roleObj, EFFECTTYPE_FROZEN) then
    return false
  end
  return true
end
function _canSkillOnRole_Thunder(roleObj)
  if _checkRoleIsInState(roleObj, EFFECTTYPE_FROZEN) then
    return false
  end
  return true
end
function _canSkillOnRole_Water(roleObj)
  if _checkRoleIsInState(roleObj, EFFECTTYPE_FROZEN) then
    return false
  end
  return true
end
function _canSkillOnRole_Pan(roleObj)
  if _checkRoleIsInState(roleObj, EFFECTTYPE_FROZEN) then
    return -1
  elseif _checkRoleIsInState(roleObj, EFFECTTYPE_SHUSHOUWUCE) then
    return -2
  end
  return true
end
function _canSkillOnRole_Attack(roleObj)
  if _checkRoleIsInState(roleObj, EFFECTTYPE_FROZEN) then
    return -1
  elseif _checkRoleIsInState(roleObj, EFFECTTYPE_SHUSHOUWUCE) then
    return -2
  end
  return true
end
function _canSkillOnRole_Speed(roleObj)
  if _checkRoleIsInState(roleObj, EFFECTTYPE_FROZEN) then
    return -1
  elseif _checkRoleIsInState(roleObj, EFFECTTYPE_SHUSHOUWUCE) then
    return -2
  end
  return true
end
function _canSkillOnRole_Zhen(roleObj)
  if _checkRoleIsInState(roleObj, EFFECTTYPE_FROZEN) then
    return false
  end
  return true
end
function _canSkillOnRole_MingLingFeiZi(roleObj)
  if _checkRoleIsInState(roleObj, EFFECTTYPE_FROZEN) then
    return false
  end
  return true
end
function _canSkillOnRole_JiXiangGuoZi(roleObj)
  if _checkRoleIsInState(roleObj, EFFECTTYPE_FROZEN) then
    return false
  end
  return true
end
function _canSkillOnRole_ShuaiRuo(roleObj)
  if _checkRoleIsInState(roleObj, EFFECTTYPE_FROZEN) then
    return false
  end
  return true
end
function _canSkillOnRole_AiHao(roleObj)
  if _checkRoleIsInState(roleObj, EFFECTTYPE_FROZEN) then
    return false
  end
  return true
end
function _canSkillOnRole_XiXue(roleObj)
  if _checkRoleIsInState(roleObj, EFFECTTYPE_FROZEN) then
    return false
  end
  return true
end
function _canSkillOnRole_YiWang(roleObj)
  if _checkRoleIsInState(roleObj, EFFECTTYPE_FROZEN) then
    return false
  end
  return true
end
function _canSkillOnRole_ShouHuCangSheng(roleObj)
  if _checkRoleIsInState(roleObj, EFFECTTYPE_FROZEN) then
    return -1
  elseif _checkRoleIsInState(roleObj, EFFECTTYPE_SHUSHOUWUCE) then
    return -2
  end
  return true
end
function _canSkillOnRole_Nian(roleObj)
  if _checkRoleIsInState(roleObj, EFFECTTYPE_FROZEN) then
    return -1
  elseif _checkRoleIsInState(roleObj, EFFECTTYPE_SHUSHOUWUCE) then
    return -2
  end
  return true
end
function _canSkillOnRole_Miss(roleObj)
  if _checkRoleIsInState(roleObj, EFFECTTYPE_FROZEN) then
    return false
  end
  return true
end
function _canSkillOnRole_NormalAttack(roleObj)
  if _checkRoleIsInState(roleObj, EFFECTTYPE_FROZEN) then
    return false
  end
  return true
end
function _canSkillOnRole_ZhaoYunMuYu(roleObj)
  if _checkRoleIsInState(roleObj, EFFECTTYPE_FROZEN) then
    return false
  end
  return true
end
function _canSkillOnRole_HuiGeHuiRi(roleObj)
  if _checkRoleIsInState(roleObj, EFFECTTYPE_FROZEN) or _checkRoleIsInState(roleObj, EFFECTTYPE_DUOHUNSUOMING) then
    return false
  end
  return true
end
function _canSkillOnRole_BuBuShengLian(roleObj)
  if _checkRoleIsInState(roleObj, EFFECTTYPE_FROZEN) then
    return false
  end
  return true
end
function _canSkillOnRole_HengYunDuanFeng(roleObj)
  if _checkRoleIsInState(roleObj, EFFECTTYPE_FROZEN) then
    return false
  end
  return true
end
function _canSkillOnRole_ShuShouWuCe(roleObj)
  if _checkRoleIsInState(roleObj, EFFECTTYPE_FROZEN) then
    return false
  end
  return true
end
function _canSkillOnRole_NianHuaYiXiao(roleObj)
  if _checkRoleIsInState(roleObj, EFFECTTYPE_FROZEN) then
    return false
  end
  return true
end
function _canSkillOnRole_MiaoBiShengHua(roleObj)
  return true
end
function _canSkillOnRole_LongZhanYuYe(roleObj)
  if _checkRoleIsInState(roleObj, EFFECTTYPE_FROZEN) then
    return false
  end
  return true
end
function _canSkillOnRole_TongChouDiKai(roleObj)
  if _checkRoleIsInState(roleObj, EFFECTTYPE_FROZEN) then
    return false
  end
  return true
end
function _RoleIsDamgeImmunity(roleObj)
  return _checkRoleIsInState(roleObj, EFFECTTYPE_TONGCHOUDIKAI) or _checkRoleIsInState(roleObj, EFFECTTYPE_MONSTER_WUDI)
end
function _getShareDamagePos(warId, roleObj, rolePos)
  if roleObj == nil then
    return nil, nil
  end
  local effectData = _getRoleEffectData(roleObj, EFFECTTYPE_SHOUHUCANGSHENG)
  if effectData == nil then
    return nil, nil
  else
    local pos = effectData.pos
    local posObj = _getFightRoleObjByPos(warId, pos)
    if posObj == nil then
      return nil, nil
    elseif _checkRoleIsInState(posObj, EFFECTTYPE_FROZEN) or _checkRoleIsInState(posObj, EFFECTTYPE_STEALTH) then
      return nil, nil
    else
      return pos, posObj
    end
  end
end
function _canSkillOnRole_FengMo(roleObj)
  if _checkRoleIsInState(roleObj, EFFECTTYPE_FROZEN) then
    return false
  end
  return true
end
function _getPosListOfAttackTeam(warId)
  local fightSeq = g_WarAiInsList[warId]:getFightPosSeq()
  local posList = {}
  for _, pos in pairs(fightSeq) do
    if pos < DefineDefendPosNumberBase then
      posList[#posList + 1] = pos
    end
  end
  return posList
end
function _getPosListOfDefendTeam(warId)
  local fightSeq = g_WarAiInsList[warId]:getFightPosSeq()
  local posList = {}
  for _, pos in pairs(fightSeq) do
    if pos >= DefineDefendPosNumberBase then
      posList[#posList + 1] = pos
    end
  end
  return posList
end
function _getPosListByPosAndTeamWithSpeedSorted(warId, team, targetType)
  if team == TEAM_ATTACK then
    if targetType == TARGETTYPE_MYSIDE then
      return _getPosListOfAttackTeam(warId)
    elseif targetType == TARGETTYPE_ENEMYSIDE then
      return _getPosListOfDefendTeam(warId)
    end
  elseif team == TEAM_DEFEND then
    if targetType == TARGETTYPE_MYSIDE then
      return _getPosListOfDefendTeam(warId)
    elseif targetType == TARGETTYPE_ENEMYSIDE then
      return _getPosListOfAttackTeam(warId)
    end
  end
  return {}
end
function _getPosListOfAttackTeamWithDeadPos(warId)
  local fightSeq = g_WarAiInsList[warId]:getFightPosSeqWithDeadPos()
  local posList = {}
  for _, pos in pairs(fightSeq) do
    if pos < DefineDefendPosNumberBase then
      posList[#posList + 1] = pos
    end
  end
  return posList
end
function _getPosListOfDefendTeamWithDeadPos(warId)
  local fightSeq = g_WarAiInsList[warId]:getFightPosSeqWithDeadPos()
  local posList = {}
  for _, pos in pairs(fightSeq) do
    if pos >= DefineDefendPosNumberBase then
      posList[#posList + 1] = pos
    end
  end
  return posList
end
function _getPosListByPosAndTeamWithSpeedSortedWithDeadPos(warId, team, targetType)
  if team == TEAM_ATTACK then
    if targetType == TARGETTYPE_MYSIDE then
      return _getPosListOfAttackTeamWithDeadPos(warId)
    elseif targetType == TARGETTYPE_ENEMYSIDE then
      return _getPosListOfDefendTeamWithDeadPos(warId)
    end
  elseif team == TEAM_DEFEND then
    if targetType == TARGETTYPE_MYSIDE then
      return _getPosListOfDefendTeamWithDeadPos(warId)
    elseif targetType == TARGETTYPE_ENEMYSIDE then
      return _getPosListOfAttackTeamWithDeadPos(warId)
    end
  end
  return {}
end
function _getPosListByTeamAndTargetType(team, targetType)
  if team == TEAM_ATTACK then
    if targetType == TARGETTYPE_MYSIDE then
      return {
        1,
        2,
        3,
        4,
        5,
        101,
        102,
        103,
        104,
        105
      }
    elseif targetType == TARGETTYPE_ENEMYSIDE then
      return {
        10001,
        10002,
        10003,
        10004,
        10005,
        10101,
        10102,
        10103,
        10104,
        10105
      }
    end
  elseif team == TEAM_DEFEND then
    if targetType == TARGETTYPE_MYSIDE then
      return {
        10001,
        10002,
        10003,
        10004,
        10005,
        10101,
        10102,
        10103,
        10104,
        10105
      }
    elseif targetType == TARGETTYPE_ENEMYSIDE then
      return {
        1,
        2,
        3,
        4,
        5,
        101,
        102,
        103,
        104,
        105
      }
    end
  end
  return {}
end
function _getPetPosListByTeamAndTargetType(team, targetType)
  if team == TEAM_ATTACK then
    if targetType == TARGETTYPE_MYSIDE then
      return {
        101,
        102,
        103,
        104,
        105
      }
    elseif targetType == TARGETTYPE_ENEMYSIDE then
      return {
        10101,
        10102,
        10103,
        10104,
        10105
      }
    end
  elseif team == TEAM_DEFEND then
    if targetType == TARGETTYPE_MYSIDE then
      return {
        10101,
        10102,
        10103,
        10104,
        10105
      }
    elseif targetType == TARGETTYPE_ENEMYSIDE then
      return {
        101,
        102,
        103,
        104,
        105
      }
    end
  end
  return {}
end
function _getAllPetPosList()
  return {
    101,
    102,
    103,
    104,
    105,
    10101,
    10102,
    10103,
    10104,
    10105
  }
end
function _getAllRolePosList()
  return {
    1,
    2,
    3,
    4,
    5,
    101,
    102,
    103,
    104,
    105,
    10001,
    10002,
    10003,
    10004,
    10005,
    10101,
    10102,
    10103,
    10104,
    10105
  }
end
function _getPetSkillSubType(skillID)
  local subType = math.floor(skillID % 10000 / 1000)
  return subType
end
function _getSkillStyle(skillID)
  local skillData = _getSkillData(skillID)
  if skillData == nil then
    return SKILLSTYLE_PASSIVE
  end
  return skillData.initiative
end
function _getSkillTargetType(skillID)
  local skillData = _getSkillData(skillID)
  if skillData == nil then
    return TARGETTYPE_ENEMYSIDE
  end
  return skillData.targetType
end
function _getIsExistedEffect(warId, pos, effectType)
  local roleObj = _getFightRoleObjByPos_WithDeadHero(warId, pos)
  if roleObj then
    local effectList = roleObj:getEffects()
    local data = effectList[effectType]
    if data == nil then
      return false
    else
      return true
    end
  else
    return false
  end
end
function _getTeamByPos(warId, pos)
  local roleObj = _getFightRoleObjByPos_WithDeadHero(warId, pos)
  if roleObj then
    return roleObj:getProperty(PROPERTY_TEAM)
  elseif pos < DefineDefendPosNumberBase then
    return TEAM_ATTACK
  else
    return TEAM_DEFEND
  end
end
local _getCertainEffectListOfPosList = function(warId, posList, certainEffectList)
  local pairs = pairs
  local resultList = {}
  for _, pos in pairs(posList) do
    local roleObj = _getFightRoleObjByPos(warId, pos)
    if roleObj then
      local effectList = roleObj:getEffects()
      local flag = false
      for effectID, effectInfo in pairs(effectList) do
        for _, eff in pairs(certainEffectList) do
          if eff == effectID then
            flag = true
            break
          end
        end
        if flag then
          break
        end
      end
      if flag then
        resultList[#resultList + 1] = pos
      end
    end
  end
  return resultList
end
function _getMyTeammateOfCertainEffect(warId, pos, certainEffectList)
  local team = _getTeamByPos(warId, uPos)
  local posList = _getPosListByPosAndTeamWithSpeedSorted(warId, team, TARGETTYPE_MYSIDE)
  for index, pos in pairs(posList) do
    if pos == uPos then
      table.remove(posList, index)
      break
    end
  end
  return _getCertainEffectListOfPosList(warId, posList, certainEffectList)
end
local _getNoEffectListOfPosList = function(warId, posList, exceptEffList)
  local pairs = pairs
  local resultList = {}
  for _, pos in pairs(posList) do
    local roleObj = _getFightRoleObjByPos(warId, pos)
    if roleObj then
      local effectList = roleObj:getEffects()
      local flag = false
      for effectID, effectInfo in pairs(effectList) do
        for _, eff in pairs(exceptEffList) do
          if eff == effectID then
            flag = true
            break
          end
        end
        if flag then
          break
        end
      end
      if not flag then
        resultList[#resultList + 1] = pos
      end
    end
  end
  return resultList
end
function _getEnemySideOfNoCertainEffect(warId, uPos, certainEffectList)
  local team = _getTeamByPos(warId, uPos)
  local posList = _getPosListByPosAndTeamWithSpeedSorted(warId, team, TARGETTYPE_ENEMYSIDE)
  return _getNoEffectListOfPosList(warId, posList, certainEffectList)
end
function _getEnemySideOfNoNegativeEffect(warId, uPos)
  return _getEnemySideOfNoCertainEffect(warId, uPos, {
    EFFECTTYPE_CONFUSE,
    EFFECTTYPE_FROZEN,
    EFFECTTYPE_SLEEP,
    EFFECTTYPE_POISON,
    EFFECTTYPE_DEC_WULI,
    EFFECTTYPE_DEC_RENZU,
    EFFECTTYPE_DEC_XIANZU,
    EFFECTTYPE_DEC_ZHEN
  })
end
function _getMySideOfNoCertainEffect(warId, uPos, certainEffectList)
  local team = _getTeamByPos(warId, uPos)
  local posList = _getPosListByPosAndTeamWithSpeedSorted(warId, team, TARGETTYPE_MYSIDE)
  return _getNoEffectListOfPosList(warId, posList, certainEffectList)
end
function _getMySideOfNoPositiveEffect(warId, uPos)
  return _getMySideOfNoCertainEffect(warId, uPos, {
    EFFECTTYPE_ADV_SPEED,
    EFFECTTYPE_ADV_DAMAGE,
    EFFECTTYPE_ADV_WULI,
    EFFECTTYPE_ADV_RENZU,
    EFFECTTYPE_ADV_XIANZU,
    EFFECTTYPE_ADV_MINGZHONG,
    EFFECTTYPE_ADV_NIAN
  })
end
function _getTeammateOfNoCertainEffect(warId, uPos, certainEffectList)
  local team = _getTeamByPos(warId, uPos)
  local posList = _getPosListByPosAndTeamWithSpeedSorted(warId, team, TARGETTYPE_MYSIDE)
  for index, pos in pairs(posList) do
    if pos == uPos then
      table.remove(posList, index)
      break
    end
  end
  return _getNoEffectListOfPosList(warId, posList, certainEffectList)
end
function _getTeammateOfNoPositiveEffect(warId, uPos)
  return _getTeammateOfNoCertainEffect(warId, uPos, {
    EFFECTTYPE_ADV_SPEED,
    EFFECTTYPE_ADV_DAMAGE,
    EFFECTTYPE_ADV_WULI,
    EFFECTTYPE_ADV_RENZU,
    EFFECTTYPE_ADV_XIANZU,
    EFFECTTYPE_ADV_MINGZHONG,
    EFFECTTYPE_ADV_NIAN
  })
end
function _isExistedPositiveEffectOfSelf(warId, uPos)
  return _getNoEffectListOfPosList(warId, {uPos}, {
    EFFECTTYPE_ADV_SPEED,
    EFFECTTYPE_ADV_DAMAGE,
    EFFECTTYPE_ADV_WULI,
    EFFECTTYPE_ADV_RENZU,
    EFFECTTYPE_ADV_XIANZU,
    EFFECTTYPE_ADV_MINGZHONG,
    EFFECTTYPE_ADV_NIAN
  })
end
function _checkUserMpOfSkill(warId, userPos, skillID)
  if skillID == SKILLTYPE_NORMALATTACK then
    return true
  elseif skillID == SKILLTYPE_DEFEND then
    return true
  elseif skillID == SKILLTYPE_BABYMONSTER or skillID == SKILLTYPE_BABYPET then
    return true
  elseif skillID == SKILLTYPE_RUNAWAY then
    return true
  else
    local userObj = _getFightRoleObjByPos_WithDeadHero(warId, userPos)
    if userObj == nil then
      printLogDebug("war_skill", "【skill tip】[warid%d] @%d 角色不存在，无法使用技能 [%d]!", warId, userPos, skillID)
      return false
    end
    local skillNeedMp = 0
    local userMp = userObj:getProperty(PROPERTY_MP)
    local objType = GetObjType(skillID)
    if objType == LOGICTYPE_NEIDANSKILL then
      local skillData = _getSkillData(skillID)
      if skillData == nil then
        printLogDebug("war_skill", "【skill tip】[warid%d] 找不到魂石技能数据，@%d 无法使用技能 [%d] !", warId, userPos, skillID)
        return false
      end
      skillNeedMp = _computeNeiDanRequireMp(skillID)
      local attr = skillData.attr
      if attr == NDATTR_MOJIE then
        if skillID == NDSKILL_QINGMIANLIAOYA then
          local loseMp, _ = _getNeiDanDamage_QingMianLiaoYa(userObj)
          skillNeedMp = skillNeedMp + loseMp
        elseif skillID == NDSKILL_XIAOLOUYEKU then
          local loseMp, _ = _getNeiDanDamage_XiaoLouYeKu(userObj)
          skillNeedMp = skillNeedMp + loseMp
        end
      end
    elseif objType == LOGICTYPE_PETSKILL then
      local petLv = userObj:getProperty(PROPERTY_ROLELEVEL)
      local petClose = userObj:getProperty(PROPERTY_CLOSEVALUE)
      local maxMp = userObj:getMaxProperty(PROPERTY_MP)
      local roleType = userObj:getType()
      skillNeedMp = _computePetSkillRequireMp(skillID, petLv, petClose, maxMp, roleType)
    elseif objType == LOGICTYPE_MARRYSKILL then
      local skillExp = userObj:getProficiency(skillID)
      skillNeedMp = _computeMarrySkillRequireMp(skillID, skillExp)
    else
      local skillExp = userObj:getProficiency(skillID)
      skillNeedMp = _computeSkillRequireMp(skillID, skillExp)
    end
    if objType ~= LOGICTYPE_NEIDANSKILL and _checkRoleIsInState(userObj, EFFECTTYPE_LONGZHANYUYE) then
      local effData = _getRoleEffectData(userObj, EFFECTTYPE_LONGZHANYUYE)
      if effData and effData.coeff then
        skillNeedMp = math.floor(skillNeedMp * (1 + effData.coeff))
      end
    end
    if userMp < skillNeedMp then
      printLogDebug("war_skill", "【skill tip】[warid%d] @%d 魔法值不够(%d<%d) 无法使用技能 [%d]", warId, userPos, userMp, skillNeedMp, skillID)
      return false
    end
    return true
  end
end
function _checkUserHpOfSkill(warId, userPos, skillID)
  if skillID == SKILLTYPE_NORMALATTACK then
    return true
  elseif skillID == SKILLTYPE_DEFEND then
    return true
  elseif skillID == SKILLTYPE_BABYMONSTER or skillID == SKILLTYPE_BABYPET then
    return true
  elseif skillID == SKILLTYPE_RUNAWAY then
    return true
  else
    local userObj = _getFightRoleObjByPos_WithDeadHero(warId, userPos)
    if userObj == nil then
      printLogDebug("war_skill", "【skill tip】[warid%d] @%d 角色不存在，无法使用技能 [%d]!", warId, userPos, skillID)
      return false
    end
    local skillNeedHp = 0
    local userHp = userObj:getProperty(PROPERTY_HP)
    local objType = GetObjType(skillID)
    if objType == LOGICTYPE_NEIDANSKILL then
      local skillData = _getSkillData(skillID)
      if skillData == nil then
        printLogDebug("war_skill", "【skill tip】[warid%d] 找不到魂石技能数据，@%d 无法使用技能 [%d] !", warId, userPos, skillID)
        return false
      end
      local attr = skillData.attr
      if attr == NDATTR_MOJIE then
        if skillID == NDSKILL_TIANMOJIETI then
          local loseHp, _ = _getNeiDanDamage_TianMoJieTi(userObj)
          skillNeedHp = skillNeedHp + loseHp
        elseif skillID == NDSKILL_FENGUANGHUAYING then
          local loseHp, _ = _getNeiDanDamage_FenGuangHuaYing(userObj)
          skillNeedHp = skillNeedHp + loseHp
        end
      end
    elseif objType == LOGICTYPE_PETSKILL then
      if skillID == PETSKILL_BINGLINCHENGXIA then
        local _, coeff, _, _ = _computePetSkill_BingLinChengXia()
        local maxHp = userObj:getMaxProperty(PROPERTY_HP)
        skillNeedHp = skillNeedHp + math.max(math.floor(maxHp * coeff), 1)
        if userHp <= skillNeedHp then
          printLogDebug("war_skill", "【skill tip】[warid%d] @%d 魔法值不够(%d<%d) 无法使用技能 [%d]", warId, userPos, userHp, skillNeedHp, skillID)
          return false
        else
          return true
        end
      end
    else
      skillNeedHp = 0
    end
    if userHp < skillNeedHp then
      printLogDebug("war_skill", "【skill tip】[warid%d] @%d 魔法值不够(%d<%d) 无法使用技能 [%d]", warId, userPos, userHp, skillNeedHp, skillID)
      return false
    end
    return true
  end
end
function _canSkillOnTarget(warId, targetPos, skillID)
  if skillID == SKILLTYPE_NORMALATTACK then
    local targetObj = _getFightRoleObjByPos(warId, targetPos)
    return targetObj ~= nil
  elseif skillID == SKILLTYPE_DEFEND then
    local targetObj = _getFightRoleObjByPos(warId, targetPos)
    return true
  elseif skillID == SKILLTYPE_BABYMONSTER or skillID == SKILLTYPE_BABYPET then
    local targetObj = _getFightRoleObjByPos(warId, targetPos)
    return true
  elseif skillID == SKILLTYPE_RUNAWAY then
    local targetObj = _getFightRoleObjByPos(warId, targetPos)
    return true
  else
    local targetObj
    if skillID == PETSKILL_HUIGEHUIRI or skillID == PETSKILL_JUEJINGFENGSHENG or skillID == PETSKILL_DUOHUNSUOMING or skillID == MARRYSKILL_QINMIWUJIAN or skillID == PETSKILL_TIESHUKAIHUA then
      targetObj = _getFightRoleObjByPos_WithDeadHero(warId, targetPos)
    else
      targetObj = _getFightRoleObjByPos(warId, targetPos)
    end
    return targetObj ~= nil
  end
end
function _isRenZuSkillAttr(skillAttr)
  return skillAttr == SKILLATTR_POISON or skillAttr == SKILLATTR_SLEEP or skillAttr == SKILLATTR_CONFUSE or skillAttr == SKILLATTR_ICE
end
function _isXianZuSkillAttr(skillAttr)
  return skillAttr == SKILLATTR_FIRE or skillAttr == SKILLATTR_WIND or skillAttr == SKILLATTR_THUNDER or skillAttr == SKILLATTR_WATER
end
function _isMoZuSkillAttr(skillAttr)
  return skillAttr == SKILLATTR_PAN or skillAttr == SKILLATTR_ATTACK or skillAttr == SKILLATTR_SPEED or skillAttr == SKILLATTR_ZHEN
end
function _addEffectOnTarget(targetObj, effectID, effectRound, effectData)
  local effectList = targetObj:getEffects()
  effectList[effectID] = {
    1,
    effectRound,
    effectData
  }
  targetObj:setEffects(effectList)
end
function _clearEffectOnTarget(targetObj, effectID)
  local effectList = targetObj:getEffects()
  effectList[effectID] = nil
  targetObj:setEffects(effectList)
end
function _clearAllEffectOnTarget(targetObj)
  targetObj:setEffects({})
end
function _getTotalKangPro(obj, skillAttr)
  local kAttr = _getKangPro(obj, skillAttr)
  local kAttrEx = _getTargetAllTempKangPro(obj, skillAttr)
  return kAttr + kAttrEx
end
function _getTotalFKangPro(obj, skillAttr)
  local fkAttr = _getFkangPro(obj, skillAttr)
  return fkAttr
end
function _getKangPro(obj, skillAttr)
  return obj:getKangPro(skillAttr)
end
function _getFkangPro(obj, skillAttr)
  return obj:getFkangPro(skillAttr)
end
function _getTargetAllTempKangPro(obj, skillAttr)
  local tempKangPro = obj:getTempKangPro(skillAttr)
  if tempKangPro == nil or tempKangPro == 0 then
    return 0
  else
    local v = 0
    for effectID, value in pairs(tempKangPro) do
      v = v + value
    end
    return v
  end
end
function _setTargetTempKangPro(obj, skillAttr, value, effectID)
  local tempKangPro = obj:getTempKangPro(skillAttr)
  if tempKangPro == nil or tempKangPro == 0 then
    tempKangPro = {}
  end
  tempKangPro[effectID] = value
  obj:setTempKangPro(skillAttr, tempKangPro)
end
function _getTargetTempKangProOfEffect(obj, skillAttr, effectID)
  local tempKangPro = obj:getTempKangPro(skillAttr)
  if tempKangPro == nil or tempKangPro == 0 then
    return 0
  end
  return tempKangPro[effectID] or 0
end
function _clearTargetTempKangPro(obj, skillAttr, effectID)
  local tempKangPro = obj:getTempKangPro(skillAttr)
  if tempKangPro == nil or tempKangPro == 0 then
    return
  end
  tempKangPro[effectID] = 0
  obj:setTempKangPro(skillAttr, tempKangPro)
end
function _getTargetTempAttr(obj, attr)
  local tempAttrPro = obj:getTempProperty(attr)
  if tempAttrPro == nil or tempAttrPro == 0 then
    return 0
  else
    local v = 0
    for effectID, value in pairs(tempAttrPro) do
      v = v + value
    end
    return v
  end
end
function _setTargetTempAttr(obj, attr, value, effectID)
  local tempAttrPro = obj:getTempProperty(attr)
  if tempAttrPro == nil or tempAttrPro == 0 then
    tempAttrPro = {}
  end
  tempAttrPro[effectID] = value
  obj:setTempProperty(attr, tempAttrPro)
end
function _getTargetTempAttrByEffect(obj, attr, effectID)
  local tempAttrPro = obj:getTempProperty(attr)
  if tempAttrPro == nil or tempAttrPro == 0 then
    return 0
  else
    return tempAttrPro[effectID] or 0
  end
end
function _clearTargetTempAttr(obj, attr, effectID)
  local tempAttrPro = obj:getTempProperty(attr)
  if tempAttrPro == nil or tempAttrPro == 0 then
    return
  end
  tempAttrPro[effectID] = 0
  obj:setTempProperty(attr, tempAttrPro)
end
function _getSkillPerformType(sID)
  if sID == SKILLTYPE_NORMALATTACK then
    pType = PERFORMETYPE_MOVE_ONEBYONE
  else
    local skillData = _getSkillData(sID) or {}
    pType = skillData.performType or PERFORMETYPE_STAND
  end
  return pType
end
function _getEffectRestRound(warId, pos, effectType)
  local roleObj = _getFightRoleObjByPos_WithDeadHero(warId, pos)
  if roleObj then
    local effectList = roleObj:getEffects()
    local data = effectList[effectType]
    if data ~= nil then
      return data[2] - data[1] + 1
    end
  end
  return 0
end
function _getTempLessenHpAndMp(roleObj)
  local effectList = roleObj:getEffects()
  if effectList[EFFECTTYPE_SHUNSHUITUIZHOU] == nil then
    return 0, 0
  end
  local effectInfo = effectList[EFFECTTYPE_SHUNSHUITUIZHOU]
  local effectData = effectInfo[3]
  local eAttr = effectData.eAttr
  if eAttr == PROPERTY_GenGu then
    return effectData.subHp, 0
  elseif eAttr == PROPERTY_Lingxing then
    return 0, effectData.subMp
  end
  return 0, 0
end
function _getCatchPetNeedHuoLi_Succeed(lTypeId, event51Flag)
  local needHl = data_getCatchPetHuoLi_Succeed(lTypeId)
  if event51Flag then
    needHl = math.floor(needHl * 0.5)
  end
  return needHl
end
function _getCatchPetNeedHuoLi_Failed(lTypeId, event51Flag)
  local needHl = data_getCatchPetHuoLi_Failed(lTypeId)
  if event51Flag then
    needHl = math.floor(needHl * 0.5)
  end
  return needHl
end
function _getWuXingKeZhiXiuZheng(userObj, targetObj, attType, wxjData)
  local kzCoeff, qkzCoeff = data_getKeZhiXiuZhengCoeff(attType)
  local kzMonsterCoeff, qkzMonsterCoeff = data_getMonsterKeZhiXiuZhengCoeff(targetObj:getType())
  local wxjin = userObj:getProperty(PROPERTY_WXJIN)
  local wxmu = userObj:getProperty(PROPERTY_WXMU)
  local wxtu = userObj:getProperty(PROPERTY_WXTU)
  local wxshui = userObj:getProperty(PROPERTY_WXSHUI)
  local wxhuo = userObj:getProperty(PROPERTY_WXHUO)
  local kewxjin = userObj:getProperty(PROPERTY_KE_WXJIN)
  local kewxmu = userObj:getProperty(PROPERTY_KE_WXMU)
  local kewxtu = userObj:getProperty(PROPERTY_KE_WXTU)
  local kewxshui = userObj:getProperty(PROPERTY_KE_WXSHUI)
  local kewxhuo = userObj:getProperty(PROPERTY_KE_WXHUO)
  local wxjin_e = targetObj:getProperty(PROPERTY_WXJIN)
  local wxmu_e = targetObj:getProperty(PROPERTY_WXMU)
  local wxtu_e = targetObj:getProperty(PROPERTY_WXTU)
  local wxshui_e = targetObj:getProperty(PROPERTY_WXSHUI)
  local wxhuo_e = targetObj:getProperty(PROPERTY_WXHUO)
  if wxjData ~= nil then
    if wxjData.wxj_jin ~= nil and wxjData.wxj_jin > 0 then
      kewxjin = kewxjin + wxjData.wxj_jin
    end
    if wxjData.wxj_mu ~= nil and 0 < wxjData.wxj_mu then
      kewxmu = kewxmu + wxjData.wxj_mu
    end
    if wxjData.wxj_tu ~= nil and 0 < wxjData.wxj_tu then
      kewxtu = kewxtu + wxjData.wxj_tu
    end
    if wxjData.wxj_shui ~= nil and 0 < wxjData.wxj_shui then
      kewxshui = kewxshui + wxjData.wxj_shui
    end
    if wxjData.wxj_huo ~= nil and 0 < wxjData.wxj_huo then
      kewxhuo = kewxhuo + wxjData.wxj_huo
    end
  end
  local coeff = kzCoeff * ((wxjin * wxmu_e + wxmu * wxtu_e + wxtu * wxshui_e + wxshui * wxhuo_e + wxhuo * wxjin_e) * kzMonsterCoeff - (wxjin * wxhuo_e + wxmu * wxjin_e + wxtu * wxmu_e + wxshui * wxtu_e + wxhuo * wxshui_e)) + qkzCoeff * qkzMonsterCoeff * (kewxjin * wxjin_e + kewxmu * wxmu_e + kewxtu * wxtu_e + kewxshui * wxshui_e + kewxhuo * wxhuo_e)
  printLogDebug("war_skill", "【war log】[warid%d] 类型<%d>的五行克制系数: %f", userObj:getWarID(), attType, coeff, kzCoeff, qkzCoeff, kzMonsterCoeff, qkzMonsterCoeff, wxjin, wxmu, wxtu, wxshui, wxhuo, kewxjin, kewxmu, kewxtu, kewxshui, kewxhuo, wxjin_e, wxmu_e, wxtu_e, wxshui_e, wxhuo_e)
  return coeff
end
