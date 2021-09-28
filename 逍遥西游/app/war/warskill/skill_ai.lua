local _onNewFormatFightSequence = function(warId, formatFightSeq)
  AISetSeqData(warId, formatFightSeq)
end
local _formatNormalSeqOfTarget = function(seqType, objPos, objHp, objMp, damageHp, damageMp, effectID, effList, objMaxHp, objMaxMp)
  local seq = {}
  seq.seqType = seqType
  seq.objPos = objPos
  seq.objHp = objHp
  seq.objMp = objMp
  seq.objMaxHp = objMaxHp
  seq.objMaxMp = objMaxMp
  seq.damageHp = damageHp
  seq.damageMp = damageMp
  seq.effectID = effectID
  seq.effList = effList
  return seq
end
local function _formatAndSendNormalBaseInfoSeqOfTarget(warId, objPos, objHp, objMp, objMaxHp, objMaxMp)
  local seq = {}
  seq.seqType = SEQTYPE_BASEHPMP
  seq.objPos = objPos
  seq.objHp = objHp
  seq.objMp = objMp
  seq.objMaxHp = objMaxHp
  seq.objMaxMp = objMaxMp
  _onNewFormatFightSequence(warId, seq)
end
local function _formatAndSendProtectSeqOfTarget(warId, protectPos, objPos, protectSkillId)
  local seq = {}
  seq.seqType = SEQTYPE_PROTECT
  seq.pPos = protectPos
  seq.objPos = objPos
  seq.pSkill = protectSkillId
  _onNewFormatFightSequence(warId, seq)
end
local function _formatAndSendBackToPosSeqOfTarget(warId, pos)
  local seq = {}
  seq.seqType = SEQTYPE_BACKTOPOS
  seq.pos = pos
  _onNewFormatFightSequence(warId, seq)
end
local function _formatAndSendCancelStealthSeq(warId, pos)
  local seq = {}
  seq.seqType = SEQTYPE_EFFECT_OFF
  seq.objPos = pos
  seq.effectList = {EFFECTTYPE_STEALTH_OFF}
  _onNewFormatFightSequence(warId, seq)
end
local _formatSubNormalSeqOfTarget = function(attPos, objPos, objHp, objMp, damageHp, damageMp, attEffectList, objEffectList, skillID, attMp, ndSkillId_att, ndSkillId_def, petSkill_att, petSkill_def, attHp)
  local seq = {}
  seq.attPos = attPos
  seq.objPos = objPos
  seq.objHp = objHp
  seq.objMp = objMp
  seq.damageHp = damageHp
  seq.damageMp = damageMp
  seq.attEffectList = attEffectList
  seq.objEffectList = objEffectList
  seq.skillID = skillID
  seq.attMp = attMp
  seq.attHp = attHp
  if ndSkillId_att ~= nil and #ndSkillId_att > 0 then
    seq.attND = ndSkillId_att
  end
  if ndSkillId_def ~= nil and #ndSkillId_def > 0 then
    seq.defND = ndSkillId_def
  end
  if petSkill_att ~= nil and petSkill_att ~= 0 then
    seq.attPetSkill = petSkill_att
  end
  if petSkill_def ~= nil and petSkill_def ~= 0 then
    seq.defPetSkill = petSkill_def
  end
  return seq
end
local _formatSubNormalSeqOfTarget_PetSkillAddHpMp = function(attPos, objPos, objHp, objMp, addHp, addMp, petSkill_att, petSkill_def, fuhuo, effList, skillID, attMp, attEffList, aniFlag)
  local seq = {}
  seq.stype = SUBSEQTYPE_ADDHPMP
  seq.attPos = attPos
  seq.objPos = objPos
  seq.objHp = objHp
  seq.objMp = objMp
  seq.addHp = addHp
  seq.addMp = addMp
  seq.fuhuo = fuhuo
  seq.skillID = skillID
  seq.attMp = attMp
  seq.objEffectList = effList
  seq.attEffectList = attEffList
  seq.aniFlag = aniFlag
  if petSkill_att ~= nil and petSkill_att ~= 0 then
    seq.attPetSkill = petSkill_att
  end
  if petSkill_def ~= nil and petSkill_def ~= 0 then
    seq.defPetSkill = petSkill_def
  end
  return seq
end
local _formatSubNormalSeqOfTarget_PetSkillDamageHpMp = function(attPos, objPos, objHp, objMp, subHp, subMp, petSkill_att, petSkill_def, effList)
  local seq = {}
  seq.stype = SUBSEQTYPE_SUBHPMP
  seq.attPos = attPos
  seq.objPos = objPos
  seq.objHp = objHp
  seq.objMp = objMp
  seq.subHp = subHp
  seq.subMp = subMp
  seq.objEffectList = effList
  if petSkill_att ~= nil and petSkill_att ~= 0 then
    seq.attPetSkill = petSkill_att
  end
  if petSkill_def ~= nil and petSkill_def ~= 0 then
    seq.defPetSkill = petSkill_def
  end
  return seq
end
local _formatSubNormalSeqOfTarget_PetSkillHpMpBase = function(attPos, objPos, objHp, objMp, maxHp, maxMp, petSkill_att, petSkill_def)
  local seq = {}
  seq.stype = SUBSEQTYPE_BASEHPMP
  seq.attPos = attPos
  seq.objPos = objPos
  seq.objHp = objHp
  seq.objMp = objMp
  seq.objMaxHp = maxHp
  seq.objMaxMp = maxMp
  if petSkill_att ~= nil and petSkill_att ~= 0 then
    seq.attPetSkill = petSkill_att
  end
  if petSkill_def ~= nil and petSkill_def ~= 0 then
    seq.defPetSkill = petSkill_def
  end
  return seq
end
local function _formatAndSendInstantAddHpMpSeq(warId, userPos, hp, mp, addHp, addMp, pSkill, petPos, fuhuo, effList, stype, aniFlag, sparam)
  local fFightSeq = {}
  fFightSeq.seqType = SEQTYPE_INSTANT_HPMP
  fFightSeq.userPos = userPos
  fFightSeq.hp = hp
  fFightSeq.addhp = addHp
  fFightSeq.mp = mp
  fFightSeq.addmp = addMp
  fFightSeq.pSkill = pSkill
  fFightSeq.petPos = petPos
  fFightSeq.fuhuo = fuhuo
  fFightSeq.stype = stype
  fFightSeq.objEffectList = effList
  fFightSeq.ani = aniFlag
  fFightSeq.sparam = sparam
  _onNewFormatFightSequence(warId, fFightSeq)
end
local function _formatAndSendInstantDamageHpMpSeq(warId, userPos, hp, mp, subHp, subMp, pSkill, petPos, effList, stype, maxhp, maxmp)
  local fFightSeq = {}
  fFightSeq.seqType = SEQTYPE_INSTANT_HPMP
  fFightSeq.userPos = userPos
  fFightSeq.hp = hp
  fFightSeq.subhp = subHp
  fFightSeq.mp = mp
  fFightSeq.submp = subMp
  fFightSeq.maxhp = maxhp
  fFightSeq.maxmp = maxmp
  fFightSeq.pSkill = pSkill
  fFightSeq.petPos = petPos
  fFightSeq.stype = stype
  fFightSeq.objEffectList = effList
  _onNewFormatFightSequence(warId, fFightSeq)
end
local _formatSubNormalSeqOfTarget_MonsterTxAddHpMp = function(attPos, objPos, objHp, objMp, addHp, addMp)
  local seq = {}
  seq.attPos = attPos
  seq.objPos = objPos
  seq.objHp = objHp
  seq.objMp = objMp
  seq.addHp = addHp
  seq.addMp = addMp
  return seq
end
local _formatWordTipSequence = function(warId, playerId, tipID, skillId, pos)
  local formatFightSeq = {}
  formatFightSeq.seqType = SEQTYPE_USERWORDTIP
  formatFightSeq.pid = playerId
  formatFightSeq.tipID = tipID
  formatFightSeq.skill = skillId
  formatFightSeq.pos = pos
  return formatFightSeq
end
local function _formatAndSendWordTipSequence(warId, playerId, tipID, skillId, pos)
  local formatFightSeq = _formatWordTipSequence(warId, playerId, tipID, skillId, pos)
  _onNewFormatFightSequence(warId, formatFightSeq)
end
local function _formatAndSendReliveSequence(warId, pos, hp, mp, maxhp, maxmp, pskillId)
  local formatFightSeq = {}
  formatFightSeq.seqType = SEQTYPE_RELIVE
  formatFightSeq.pos = pos
  formatFightSeq.hp = hp
  formatFightSeq.mp = mp
  formatFightSeq.maxhp = maxhp
  formatFightSeq.maxmp = maxmp
  formatFightSeq.pskill = pskillId
  _onNewFormatFightSequence(warId, formatFightSeq)
end
local function _formatAndSendMakeOtherReliveSequence(warId, pos, objPos, hp, mp, maxhp, maxmp, txId)
  local formatFightSeq = {}
  formatFightSeq.seqType = SEQTYPE_MAKEOTEHRRELIVE
  formatFightSeq.pos = pos
  formatFightSeq.objPos = objPos
  formatFightSeq.hp = hp
  formatFightSeq.mp = mp
  formatFightSeq.maxhp = maxhp
  formatFightSeq.maxmp = maxmp
  formatFightSeq.txId = txId
  _onNewFormatFightSequence(warId, formatFightSeq)
end
local function _formatAndSendLeaveBattleSeq(warId, pos, stype, sparam)
  local seq = {}
  seq.seqType = SEQTYPE_LEAVEBATTLE
  seq.pos = pos
  seq.stype = stype
  seq.sparam = sparam
  _onNewFormatFightSequence(warId, seq)
end
local function _formatAndSendTakeAwayeq(warId, pos, pskillId, objPos)
  local seq = {}
  seq.seqType = SEQTYPE_TAKEAWARY
  seq.pos = pos
  seq.pskill = pskillId
  seq.objPos = objPos
  _onNewFormatFightSequence(warId, seq)
end
local function _formatAndSendCatchPetSeq(warId, pos, petPos, poshp, posmp, playerID, success)
  local seq = {}
  seq.seqType = SEQTYPE_CATCHPET
  seq.pos = pos
  seq.petPos = petPos
  seq.hp = poshp
  seq.mp = posmp
  seq.pid = playerID
  seq.success = success
  _onNewFormatFightSequence(warId, seq)
end
function _formatAndSendAddSceneAni(warId, subType, param)
  local seq = {}
  seq.seqType = SEQTYPE_ADDSCENEANI
  seq.subType = subType
  seq.param = param
  _onNewFormatFightSequence(warId, seq)
end
function _formatAndSendDelSceneAni(warId, subType, param)
  local seq = {}
  seq.seqType = SEQTYPE_DELSCENEANI
  seq.subType = subType
  seq.param = param
  _onNewFormatFightSequence(warId, seq)
end
function _formatAddPosAni(warId, pos, skillId, petPos, pSkill)
  local seq = {}
  seq.seqType = SEQTYPE_ADDPOSANI
  seq.pos = pos
  seq.skill = skillId
  seq.petPos = petPos
  seq.pSkill = pSkill
  return seq
end
function _formatAndSendAddPosAni(warId, pos, skillId, petPos, pSkill)
  local seq = _formatAddPosAni(warId, pos, skillId, petPos, pSkill)
  _onNewFormatFightSequence(warId, seq)
end
function _formatAndSendShowHpMpFlag(warId, team, flag)
  local seq = {}
  seq.seqType = SEQTYPE_SHOWENEMYHPMP
  seq.team = team
  seq.flag = flag
  _onNewFormatFightSequence(warId, seq)
end
local _canAffectOnPro = function(pro)
  if pro <= 0 then
    return false
  elseif pro >= 1 then
    return true
  else
    local k = 1000000
    local rdNumber = math.random(1, k)
    return rdNumber <= pro * k
  end
end
local _checkDamage = function(damage)
  return math.max(math.floor(damage), 1)
end
local _callBack = function(callback)
  if callback then
    callback()
  end
end
function _setRoleIsDeadInWar(warId, warRound, rolePos, roleObj, objEffList, forceClearAllBuff)
  local jrtx = roleObj:getTempProperty(PROPERTY_JIRENTIANXIANG) or 0
  if jrtx > 0 and warRound > 3 then
    local maxHpMpChanged = false
    local effectList = roleObj:getEffects()
    for effectID, effectInfo in pairs(effectList) do
      local effectData = effectInfo[3]
      local effectOffID = _getEffectOffID(effectID)
      objEffList[#objEffList + 1] = effectOffID
      maxHpMpChanged = _checkDurativeEffectOnRole_Off(warId, rolePos, roleObj, effectID, effectOffID, effectData, false) or maxHpMpChanged
    end
    roleObj:setEffects({})
    roleObj:setTempProperty(PROPERTY_JIRENTIANXIANG, 0)
    objEffList[#objEffList + 1] = EFFECTTYPE_JIRENTIANXIANG
    return jrtx, maxHpMpChanged
  else
    if roleObj:getType() == LOGICTYPE_MONSTER then
      local team = roleObj:getProperty(PROPERTY_TEAM)
      local posList = _getPosListByTeamAndTargetType(team, TARGETTYPE_MYSIDE)
      if roleObj:IsBossMonster() then
        if roleObj:PossessMonsterTeXing(MONSTER_TX_12) then
          local effPosList = {}
          for _, pos in pairs(posList) do
            local monsterObj = _getFightRoleObjByPos(warId, pos)
            if monsterObj and monsterObj:getType() == LOGICTYPE_MONSTER and not monsterObj:IsBossMonster() then
              effPosList[#effPosList + 1] = pos
            end
          end
          if #effPosList > 0 then
            objEffList[#objEffList + 1] = {
              seqType = SEQTYPE_MONSTER_TX,
              stype = MONSTER_TX_12,
              effPos = rolePos
            }
            return 10, false
          end
        end
      elseif roleObj:PossessMonsterTeXing(MONSTER_TX_13) then
        local effPosList = {}
        for _, pos in pairs(posList) do
          local monsterObj = _getFightRoleObjByPos(warId, pos)
          if monsterObj and monsterObj:getType() == LOGICTYPE_MONSTER and monsterObj:IsBossMonster() then
            effPosList[#effPosList + 1] = pos
          end
        end
        if #effPosList > 0 then
          objEffList[#objEffList + 1] = {
            seqType = SEQTYPE_MONSTER_TX,
            stype = MONSTER_TX_13,
            effPos = rolePos
          }
          return 10, false
        end
      end
    end
    local maxHpMpChanged = false
    local effectList = roleObj:getEffects()
    local restEffect = {}
    for effectID, effectInfo in pairs(effectList) do
      if EFFECTBUFF_DEAD_KEEP[effectID] == nil or roleObj:getType() ~= LOGICTYPE_HERO or forceClearAllBuff == true then
        local effectData = effectInfo[3]
        local effectOffID = _getEffectOffID(effectID)
        objEffList[#objEffList + 1] = effectOffID
        maxHpMpChanged = _checkDurativeEffectOnRole_Off(warId, pos, roleObj, effectID, effectOffID, effectData, false) or maxHpMpChanged
      else
        restEffect[effectID] = effectInfo
      end
    end
    roleObj:setEffects(restEffect)
    roleObj:setProperty(PROPERTY_DEAD, ROLESTATE_DEAD)
    print_SkillLog_RoleIsDead(warId, rolePos)
    return 0, maxHpMpChanged
  end
end
function _checkDefenceEffectStateBeforeRound(warId, pos, isDefence)
  if isDefence then
    _defendOnTarget(warId, pos, 2)
  else
  end
end
function _checkWhenUseSkillOfWar(warId, warRound, pos, posSkill)
  local roleObj = _getFightRoleObjByPos(warId, pos)
  if roleObj == nil then
    print_SkillLog_RoleIsNotExist(warId, pos)
    return true
  end
  local warAiObj = g_WarAiInsList[warId]
  if warAiObj == nil then
    return true
  end
  local warType = _getTheWarType(warId)
  local isPvpWar = IsPVPWarType(warType)
  local team = roleObj:getProperty(PROPERTY_TEAM)
  local xr_or_yh = false
  if isPvpWar and roleObj:getTempProperty(PROPERTY_HUAWUMARK) == 1 then
    local hwFlag = false
    if team == TEAM_ATTACK then
      local flag = warAiObj:WarAiGetDefendFirstUseMagicSkillHuaWu()
      if flag == true then
        _formatAndSendWordTipSequence(warId, roleObj:getPlayerId(), SUBSEQTYPE_HUAWU, posSkill, pos)
        _formatAndSendAddPosAni(warId, pos, PETSKILL_HUAWU)
        warAiObj:WarAiSetDefendFirstUseMagicSkillHuaWu(false)
        hwFlag = true
      end
    else
      local flag = warAiObj:WarAiGetAttackFirstUseMagicSkillHuaWu()
      if flag == true then
        _formatAndSendWordTipSequence(warId, roleObj:getPlayerId(), SUBSEQTYPE_HUAWU, posSkill, pos)
        _formatAndSendAddPosAni(warId, pos, PETSKILL_HUAWU)
        warAiObj:WarAiSetAttackFirstUseMagicSkillHuaWu(false)
        hwFlag = true
      end
    end
    if hwFlag then
      local posList = _getPosListByTeamAndTargetType(team, TARGETTYPE_MYSIDE)
      for _, pos in pairs(posList) do
        local roleObj = _getFightRoleObjByPos_WithDeadHero(warId, pos)
        if roleObj then
          roleObj:setTempProperty(PROPERTY_HUAWUMARK, 0)
        end
      end
      local petPosList = _getPetPosListByTeamAndTargetType(team, TARGETTYPE_ENEMYSIDE)
      for _, petPos in pairs(petPosList) do
        local petObj = _getFightRoleObjByPos(warId, petPos)
        if petObj then
          petObj:setTempProperty(PROPERTY_HUAWU, 1)
        end
      end
      return false
    end
  end
  if isPvpWar then
    local damageHp = 0
    if team == TEAM_ATTACK then
      local xrDHp = warAiObj:WarAiGetDefendFirstUseMagicSkillHpHurt()
      if xrDHp > 0 then
        damageHp = xrDHp
        warAiObj:WarAiSetDefendFirstUseMagicSkillHpHurt(-1)
      end
    else
      local xrDHp = warAiObj:WarAiGetAttackFirstUseMagicSkillHpHurt()
      if xrDHp > 0 then
        damageHp = xrDHp
        warAiObj:WarAiSetAttackFirstUseMagicSkillHpHurt(-1)
      end
    end
    if damageHp > 0 then
      if roleObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
        local effList = {}
        local hp = roleObj:getProperty(PROPERTY_HP)
        local mp = roleObj:getProperty(PROPERTY_MP)
        if not _RoleIsDamgeImmunity(roleObj) then
          hp = hp - damageHp
          local maxHpMpChanged = false
          if hp <= 0 then
            hp = 0
            hp, maxHpMpChanged = _setRoleIsDeadInWar(warId, warRound, pos, roleObj, effList)
          end
          roleObj:setProperty(PROPERTY_HP, hp)
          if roleObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and _checkRoleIsInState(roleObj, EFFECTTYPE_SLEEP) then
            _removeRoleEffectState(roleObj, EFFECTTYPE_SLEEP)
            effList[#effList + 1] = EFFECTTYPE_SLEEP_OFF
          end
          if maxHpMpChanged == true then
            local maxHp = roleObj:getMaxProperty(PROPERTY_HP)
            local maxMp = roleObj:getMaxProperty(PROPERTY_MP)
            _formatAndSendInstantDamageHpMpSeq(warId, pos, hp, mp, damageHp, 0, nil, nil, effList, SUBSEQTYPE_XUANREN, maxHp, maxMp)
          else
            _formatAndSendInstantDamageHpMpSeq(warId, pos, hp, mp, damageHp, 0, nil, nil, effList, SUBSEQTYPE_XUANREN)
          end
        else
          _formatAndSendInstantDamageHpMpSeq(warId, pos, hp, mp, 0, 0, nil, nil, {EFFECTTYPE_IMMUNITY_DAMAGE}, SUBSEQTYPE_XUANREN)
        end
      elseif team == TEAM_ATTACK then
        _formatAndSendDelSceneAni(warId, SUBSEQTYPE_XUANREN, TEAM_DEFEND)
      else
        _formatAndSendDelSceneAni(warId, SUBSEQTYPE_XUANREN, TEAM_ATTACK)
      end
      xr_or_yh = true
    end
    if roleObj:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD then
      return false
    end
  end
  if isPvpWar then
    local damageMp = 0
    if team == TEAM_ATTACK then
      local xrDHp = warAiObj:WarAiGetDefendFirstUseMagicSkillMpHurt()
      if xrDHp > 0 then
        damageMp = xrDHp
        warAiObj:WarAiSetDefendFirstUseMagicSkillMpHurt(-1)
      end
    else
      local xrDHp = warAiObj:WarAiGetAttackFirstUseMagicSkillMpHurt()
      if xrDHp > 0 then
        damageMp = xrDHp
        warAiObj:WarAiSetAttackFirstUseMagicSkillMpHurt(-1)
      end
    end
    if damageMp > 0 then
      if roleObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
        local hp = roleObj:getProperty(PROPERTY_HP)
        local mp = roleObj:getProperty(PROPERTY_MP)
        if not _RoleIsDamgeImmunity(roleObj) then
          mp = mp - damageMp
          if mp < 0 then
            mp = 0
          end
          roleObj:setProperty(PROPERTY_MP, mp)
          local effList = {}
          if roleObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and _checkRoleIsInState(roleObj, EFFECTTYPE_SLEEP) then
            _removeRoleEffectState(roleObj, EFFECTTYPE_SLEEP)
            effList[#effList + 1] = EFFECTTYPE_SLEEP_OFF
          end
          _formatAndSendInstantDamageHpMpSeq(warId, pos, hp, mp, 0, damageMp, nil, nil, effList, SUBSEQTYPE_YIHUAN)
        else
          _formatAndSendInstantDamageHpMpSeq(warId, pos, hp, mp, 0, 0, nil, nil, {EFFECTTYPE_IMMUNITY_DAMAGE}, SUBSEQTYPE_YIHUAN)
        end
      elseif team == TEAM_ATTACK then
        _formatAndSendDelSceneAni(warId, SUBSEQTYPE_YIHUAN, TEAM_DEFEND)
      else
        _formatAndSendDelSceneAni(warId, SUBSEQTYPE_YIHUAN, TEAM_ATTACK)
      end
      xr_or_yh = true
    end
    if roleObj:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD then
      return false
    end
  end
  if isPvpWar and not xr_or_yh then
    if roleObj:getType() == LOGICTYPE_HERO then
      local sgqxPosList = {}
      local allPetPosList = _getAllPetPosList()
      for _, petPos in pairs(allPetPosList) do
        local petObj = _getFightRoleObjByPos(warId, petPos)
        if petObj and petObj:getType() == LOGICTYPE_PET and petObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
          local damageHp, sgqxSkillId = petObj:GetPetSkillShuangGuanQiXia()
          if damageHp > 0 then
            sgqxPosList[#sgqxPosList + 1] = {
              petPos,
              petObj,
              damageHp,
              sgqxSkillId
            }
          end
        end
      end
      if #sgqxPosList > 0 then
        local selInfo = sgqxPosList[math.random(1, #sgqxPosList)]
        local petPos, petObj, damageHp, sgqxSkillId = unpack(selInfo, 1, 4)
        local roleHp = roleObj:getProperty(PROPERTY_HP)
        local roleMp = roleObj:getProperty(PROPERTY_MP)
        _checkIsThieveSkill(petObj, sgqxSkillId)
        if damageHp < roleHp then
          if not _RoleIsDamgeImmunity(roleObj) then
            roleHp = roleHp - damageHp
            roleObj:setProperty(PROPERTY_HP, roleHp)
            local effList = {}
            if _checkRoleIsInState(roleObj, EFFECTTYPE_SLEEP) then
              _removeRoleEffectState(roleObj, EFFECTTYPE_SLEEP)
              effList[#effList + 1] = EFFECTTYPE_SLEEP_OFF
            end
            _formatAndSendInstantDamageHpMpSeq(warId, pos, roleHp, roleMp, damageHp, 0, sgqxSkillId, petPos, effList)
          else
            _formatAndSendInstantDamageHpMpSeq(warId, pos, roleHp, roleMp, 0, 0, sgqxSkillId, petPos, {EFFECTTYPE_IMMUNITY_DAMAGE})
          end
        else
          _LackHpWhenSkill(warId, pos, roleObj, posSkill)
          return false
        end
      end
    end
    if roleObj:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD then
      return false
    end
  end
  if roleObj:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD then
    return false
  end
  return true
end
function _checkAllShenBingXianQiBeforeRound(warId, pos)
  local roleObj = _getFightRoleObjByPos(warId, pos)
  if roleObj == nil then
    print_SkillLog_RoleIsNotExist(warId, pos)
    return
  end
  print_SkillLog_UpdateAllStateBeforeRound(warId, pos)
  local hp = roleObj:getProperty(PROPERTY_HP)
  local maxHp = roleObj:getMaxProperty(PROPERTY_HP)
  if hp < maxHp then
    local recoverHp = roleObj:getProperty(PROPERTY_HFQX)
    if recoverHp > 0 then
      hp = math.min(hp + recoverHp, maxHp)
      roleObj:setProperty(PROPERTY_HP, hp)
      local mp = roleObj:getProperty(PROPERTY_MP)
      _formatAndSendInstantAddHpMpSeq(warId, pos, hp, mp, recoverHp, 0, nil, nil, nil, nil, SUBSEQTYPE_BEFOREROUND, 0)
    end
  end
  local mp = roleObj:getProperty(PROPERTY_MP)
  local maxMp = roleObj:getMaxProperty(PROPERTY_MP)
  if mp < maxMp then
    local recoverMp = roleObj:getProperty(PROPERTY_HFFL)
    if recoverMp > 0 then
      mp = math.min(mp + recoverMp, maxMp)
      roleObj:setProperty(PROPERTY_MP, mp)
      local hp = roleObj:getProperty(PROPERTY_HP)
      _formatAndSendInstantAddHpMpSeq(warId, pos, hp, mp, 0, recoverMp, nil, nil, nil, nil, SUBSEQTYPE_BEFOREROUND, 0)
    end
  end
end
function _checkAllPetSkillBeforeRound(warId, pos)
  local petObj = _getFightRoleObjByPos(warId, pos)
  if petObj == nil then
    print_SkillLog_RoleIsNotExist(warId, pos)
    return
  end
  print_SkillLog_UpdateAllStateBeforeRound(warId, pos)
  local coeff, skillId = petObj:GetPetSkillZhongCheng()
  if coeff > 0 and not _checkRoleIsInState(petObj, EFFECTTYPE_FROZEN) then
    local masterPos = _getMasterPosByPetPos(pos)
    local masterObj = _getFightRoleObjByPos(warId, masterPos)
    if masterObj and masterObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
      local hp = masterObj:getProperty(PROPERTY_HP)
      local maxHp = masterObj:getMaxProperty(PROPERTY_HP)
      if hp < maxHp then
        local mp = masterObj:getProperty(PROPERTY_MP)
        local recoverHp = _checkDamage(maxHp * coeff)
        if recoverHp > 0 then
          hp = math.min(hp + recoverHp, maxHp)
          masterObj:setProperty(PROPERTY_HP, hp)
          _formatAndSendInstantAddHpMpSeq(warId, masterPos, hp, mp, recoverHp, 0, nil, nil, nil, nil, SUBSEQTYPE_BEFOREROUND)
        end
      end
    end
  end
  local pro, less, coeff, skillId = petObj:GetPetSkillDaYi()
  if _canAffectOnPro(pro) and not _checkRoleIsInState(petObj, EFFECTTYPE_FROZEN) then
    local team = petObj:getProperty(PROPERTY_TEAM)
    local posList = _getPosListByTeamAndTargetType(team, TARGETTYPE_MYSIDE)
    local selectList = {}
    for _, tPos in pairs(posList) do
      if tPos ~= pos then
        local tObj = _getFightRoleObjByPos_WithDeadHero(warId, tPos)
        if tObj then
          local tMp = tObj:getProperty(PROPERTY_MP)
          local tMaxMp = tObj:getMaxProperty(PROPERTY_MP)
          if tMaxMp > 0 and less > tMp / tMaxMp then
            selectList[#selectList + 1] = {tPos, tObj}
          end
        end
      end
    end
    if #selectList > 0 then
      local selectData = selectList[math.random(1, #selectList)]
      local sPos, sObj = selectData[1], selectData[2]
      local tMp = sObj:getProperty(PROPERTY_MP)
      local hp = sObj:getProperty(PROPERTY_HP)
      local tMaxMp = sObj:getMaxProperty(PROPERTY_MP)
      local addMp = _checkDamage(tMaxMp * coeff)
      tMp = math.min(tMp + addMp, tMaxMp)
      sObj:setProperty(PROPERTY_MP, tMp)
      _formatAndSendInstantAddHpMpSeq(warId, sPos, hp, tMp, 0, addMp, nil, nil, nil, nil, SUBSEQTYPE_BEFOREROUND)
    end
  end
  local pro, less, coeff, skillId = petObj:GetPetSkillZiYi()
  if _canAffectOnPro(pro) and not _checkRoleIsInState(petObj, EFFECTTYPE_FROZEN) then
    local hp = petObj:getProperty(PROPERTY_HP)
    local maxHp = petObj:getMaxProperty(PROPERTY_HP)
    if hp < maxHp and hp > 0 and less > hp / maxHp then
      local recoverHp = _checkDamage(maxHp * coeff)
      if recoverHp > 0 then
        hp = math.min(hp + recoverHp, maxHp)
        petObj:setProperty(PROPERTY_HP, hp)
        local mp = petObj:getProperty(PROPERTY_MP)
        _formatAndSendInstantAddHpMpSeq(warId, pos, hp, mp, recoverHp, 0, nil, nil, nil, nil, SUBSEQTYPE_BEFOREROUND)
      end
    end
  end
  if _checkRoleIsInState(petObj, EFFECTTYPE_CONFUSE) and not _checkRoleIsInState(petObj, EFFECTTYPE_FROZEN) then
    local pro, skillId = petObj:GetPetSkillQingMingShu()
    if _canAffectOnPro(pro) then
      local fFightSeq = {
        seqType = SEQTYPE_EFFECT_OFF,
        objPos = pos,
        effectList = {},
        pSkill = skillId,
        skill = skillId
      }
      local effectOffID = _getEffectOffID(EFFECTTYPE_CONFUSE)
      if effectOffID ~= nil then
        local effList = fFightSeq.effectList
        effList[#effList + 1] = effectOffID
      end
      _checkDurativeEffectOnRole_Off(warId, pos, petObj, EFFECTTYPE_CONFUSE, effectOffID)
      _onNewFormatFightSequence(warId, fFightSeq)
    end
  end
  if _checkRoleIsInState(petObj, EFFECTTYPE_FROZEN) then
    local pro, skillId = petObj:GetPetSkillTuoKunShu()
    if _canAffectOnPro(pro) then
      local fFightSeq = {
        seqType = SEQTYPE_EFFECT_OFF,
        objPos = pos,
        effectList = {},
        pSkill = skillId,
        skill = skillId
      }
      local effectOffID = _getEffectOffID(EFFECTTYPE_FROZEN)
      if effectOffID ~= nil then
        local effList = fFightSeq.effectList
        effList[#effList + 1] = effectOffID
      end
      _checkDurativeEffectOnRole_Off(warId, pos, petObj, EFFECTTYPE_FROZEN, effectOffID)
      _onNewFormatFightSequence(warId, fFightSeq)
    end
  end
  if _checkRoleIsInState(petObj, EFFECTTYPE_YIWANG) and not _checkRoleIsInState(petObj, EFFECTTYPE_FROZEN) then
    local pro, skillId = petObj:GetPetSkillNingShenShu()
    if _canAffectOnPro(pro) then
      local fFightSeq = {
        seqType = SEQTYPE_EFFECT_OFF,
        objPos = pos,
        effectList = {},
        pSkill = skillId,
        skill = skillId
      }
      local effectOffID = _getEffectOffID(EFFECTTYPE_YIWANG)
      if effectOffID ~= nil then
        local effList = fFightSeq.effectList
        effList[#effList + 1] = effectOffID
      end
      _checkDurativeEffectOnRole_Off(warId, pos, petObj, EFFECTTYPE_YIWANG, effectOffID)
      _onNewFormatFightSequence(warId, fFightSeq)
    end
  end
  if not _checkRoleIsInState(petObj, EFFECTTYPE_FROZEN) then
    local pro, coeff, skillId = petObj:GetPetSkillFuShang()
    if _canAffectOnPro(pro) then
      local team = petObj:getProperty(PROPERTY_TEAM)
      local posList = _getPosListByTeamAndTargetType(team, TARGETTYPE_MYSIDE)
      local selectList = {}
      for _, tPos in pairs(posList) do
        local tObj = _getFightRoleObjByPos_WithDeadHero(warId, tPos)
        if tObj and tObj:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD then
          selectList[#selectList + 1] = {tPos, tObj}
        end
      end
      if #selectList > 0 then
        local temp = selectList[math.random(1, #selectList)]
        local sPos, sObj = temp[1], temp[2]
        local hp = sObj:getProperty(PROPERTY_HP)
        local mp = sObj:getProperty(PROPERTY_MP)
        if not _checkRoleIsInState(sObj, EFFECTTYPE_DUOHUNSUOMING) then
          local maxHp = sObj:getMaxProperty(PROPERTY_HP)
          local recoverHp = _checkDamage(maxHp * coeff)
          hp = math.min(hp + recoverHp, maxHp)
          sObj:setProperty(PROPERTY_HP, hp)
          sObj:setProperty(PROPERTY_DEAD, ROLESTATE_LIVE)
          _formatAndSendInstantAddHpMpSeq(warId, sPos, hp, mp, recoverHp, 0, skillId, pos, 1, nil, SUBSEQTYPE_BEFOREROUND)
        else
          _formatAndSendInstantAddHpMpSeq(warId, sPos, hp, mp, 0, 0, skillId, pos, nil, {EFFECTTYPE_INVALID}, SUBSEQTYPE_BEFOREROUND)
        end
      end
    end
  end
  if 0 < petObj:getBDProficiency(SKILL_GUYINGZILIAN) then
    local totalNum = 0
    local effectNum = 0
    local team = petObj:getProperty(PROPERTY_TEAM)
    local posList = _getPosListByTeamAndTargetType(team, TARGETTYPE_MYSIDE)
    for _, tPos in pairs(posList) do
      local tObj = _getFightRoleObjByPos_DeadOrLive(warId, tPos)
      if tObj then
        totalNum = totalNum + 1
        if tObj:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD then
          effectNum = effectNum + 1
        else
          local underControlBuff = false
          local currAllEffectList = tObj:getEffects()
          for eID, eInfo in pairs(currAllEffectList) do
            if EFFECTBUFF_GUYINGZILIAN_CONTROLBUFF[eID] ~= nil then
              underControlBuff = true
              break
            end
          end
          if underControlBuff then
            effectNum = effectNum + 1
          end
        end
      end
    end
    if totalNum > 0 then
      local activePro = _computeSkillEffect_GuYingZiLian(SKILL_GUYINGZILIAN)
      if activePro <= effectNum / totalNum then
        local fFightSeq = {
          seqType = SEQTYPE_EFFECT_OFF,
          objPos = pos,
          effectList = {},
          pSkill = SKILL_GUYINGZILIAN,
          skill = SKILL_GUYINGZILIAN
        }
        local currAllEffectList = petObj:getEffects()
        local effList = fFightSeq.effectList
        for eID, eInfo in pairs(currAllEffectList) do
          if EFFECTBUFF_GUYINGZILIAN_CONTROLBUFF[eID] ~= nil then
            local eOffID = _getEffectOffID(eID)
            local eData = eInfo[3]
            if eOffID ~= nil then
              _checkDurativeEffectOnRole_Off(warId, pos, petObj, eID, eOffID, eData)
              effList[#effList + 1] = eOffID
            end
          end
        end
        if #effList > 0 then
          _onNewFormatFightSequence(warId, fFightSeq)
        end
      end
    end
  end
end
function _checkAllPetSkillDamageBeforeRound(warId, warRound, pos, param)
  local roleObj = _getFightRoleObjByPos(warId, pos)
  if roleObj == nil then
    print_SkillLog_RoleIsNotExist(warId, pos)
    return
  end
  print_SkillLog_UpdateAllStateBeforeRound(warId, pos)
  local warType = _getTheWarType(warId)
  local isPvpWar = IsPVPWarType(warType)
  if isPvpWar then
    local damage, skillId = roleObj:GetPetSkillTaoMing()
    if damage > 0 and not _checkRoleIsInState(roleObj, EFFECTTYPE_FROZEN) and not _checkRoleIsInState(roleObj, EFFECTTYPE_STEALTH) and param.taoming == nil then
      local allPetPosList = _getAllPetPosList()
      for _, petPos in pairs(allPetPosList) do
        local petObj = _getFightRoleObjByPos(warId, petPos)
        if petObj and petObj:getType() == LOGICTYPE_PET and petObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and not _checkRoleIsInState(petObj, EFFECTTYPE_STEALTH) then
          local masterPos = _getMasterPosByPetPos(petPos)
          local masterObj = _getFightRoleObjByPos_WithDeadHero(warId, masterPos)
          if masterObj then
            local masterHp = masterObj:getProperty(PROPERTY_HP)
            local masterMp = masterObj:getProperty(PROPERTY_MP)
            local wxCoeff = _getWuXingKeZhiXiuZheng(roleObj, masterObj, WUXING_CHONGWU)
            local damageMaster = _checkDamage(damage * (1 + wxCoeff))
            if masterHp > damageMaster and not _checkRoleIsInState(masterObj, EFFECTTYPE_FROZEN) and not _checkRoleIsInState(masterObj, EFFECTTYPE_STEALTH) then
              if not _RoleIsDamgeImmunity(masterObj) then
                masterHp = masterHp - damageMaster
                masterObj:setProperty(PROPERTY_HP, masterHp)
                local effList = {}
                if masterObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and _checkRoleIsInState(masterObj, EFFECTTYPE_SLEEP) then
                  _removeRoleEffectState(masterObj, EFFECTTYPE_SLEEP)
                  effList[#effList + 1] = EFFECTTYPE_SLEEP_OFF
                end
                _formatAndSendInstantDamageHpMpSeq(warId, masterPos, masterHp, masterMp, damageMaster, 0, skillId, pos, effList, SUBSEQTYPE_BEFOREROUND)
              else
                _formatAndSendInstantDamageHpMpSeq(warId, masterPos, masterHp, masterMp, 0, 0, skillId, pos, {EFFECTTYPE_IMMUNITY_DAMAGE}, SUBSEQTYPE_BEFOREROUND)
              end
              skillId = nil
            elseif not _checkRoleIsInState(petObj, EFFECTTYPE_FROZEN) and not _checkRoleIsInState(petObj, EFFECTTYPE_STEALTH) then
              local petHp = petObj:getProperty(PROPERTY_HP)
              local petMp = petObj:getProperty(PROPERTY_MP)
              local effList = {}
              local wxCoeff = _getWuXingKeZhiXiuZheng(roleObj, petObj, WUXING_CHONGWU)
              local damagePet = _checkDamage(damage * (1 + wxCoeff))
              petHp = petHp - damagePet
              local maxHpMpChanged = false
              if petHp <= 0 then
                petHp = 0
                petHp, maxHpMpChanged = _setRoleIsDeadInWar(warId, warRound, petPos, petObj, effList)
              end
              petObj:setProperty(PROPERTY_HP, petHp)
              if petHp > 0 and petObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and _checkRoleIsInState(petObj, EFFECTTYPE_SLEEP) then
                _removeRoleEffectState(petObj, EFFECTTYPE_SLEEP)
                effList[#effList + 1] = EFFECTTYPE_SLEEP_OFF
              end
              if maxHpMpChanged == true then
                local maxHp = petObj:getMaxProperty(PROPERTY_HP)
                local maxMp = petObj:getMaxProperty(PROPERTY_MP)
                _formatAndSendInstantDamageHpMpSeq(warId, petPos, petHp, petMp, damagePet, 0, skillId, pos, effList, SUBSEQTYPE_BEFOREROUND, maxHp, maxMp)
              else
                _formatAndSendInstantDamageHpMpSeq(warId, petPos, petHp, petMp, damagePet, 0, skillId, pos, effList, SUBSEQTYPE_BEFOREROUND)
              end
              skillId = nil
            elseif not _checkRoleIsInState(petObj, EFFECTTYPE_STEALTH) then
              local petHp = petObj:getProperty(PROPERTY_HP)
              local petMp = petObj:getProperty(PROPERTY_MP)
              _formatAndSendInstantDamageHpMpSeq(warId, petPos, petHp, petMp, 0, 0, skillId, pos, {EFFECTTYPE_IMMUNITY}, SUBSEQTYPE_BEFOREROUND)
              skillId = nil
            end
          end
        end
      end
      param.taoming = 1
    end
  end
end
function _checkOtherSkillBeforeRound(warId, warRound, pos)
  local roleObj = _getFightRoleObjByPos(warId, pos)
  if roleObj == nil then
    print_SkillLog_RoleIsNotExist(warId, pos)
    return
  end
  if not _checkRoleIsInState(roleObj, EFFECTTYPE_FROZEN) and not _checkRoleIsInState(roleObj, EFFECTTYPE_STEALTH) then
    local pro, coeff, round, skillId = roleObj:GetPetSkillZhiNanErTui()
    if pro > 0 then
      local hp = roleObj:getProperty(PROPERTY_HP)
      local maxhp = roleObj:getMaxProperty(PROPERTY_HP)
      if hp < maxhp * coeff and _canAffectOnPro(pro) then
        _addEffectOnTarget(roleObj, EFFECTTYPE_STEALTH, round + 1)
        local fFightSeq = {}
        fFightSeq.seqType = SEQTYPE_STEALTH_BEFOREROUND
        fFightSeq.pos = pos
        fFightSeq.skill = skillId
        _onNewFormatFightSequence(warId, fFightSeq)
      end
    end
  end
end
function _checkMonsterTeXingBeforeRound(warId, warRound, pos)
  local roleObj = _getFightRoleObjByPos(warId, pos)
  if roleObj == nil then
    print_SkillLog_RoleIsNotExist(warId, pos)
    return
  end
  if roleObj:getType() ~= LOGICTYPE_MONSTER then
    printLogDebug("war_skill", "【war log】[warid%d]角色 @%d 不是怪物，不检查怪物特性", warId, pos)
    return
  end
  if roleObj:IsBossMonster() and roleObj:PossessMonsterTeXing(MONSTER_TX_4) and not _checkRoleIsInState(roleObj, EFFECTTYPE_FROZEN) then
    printLogDebug("war_skill", "【war log】[warid%d]boss @%d 准备对小怪进行加血", warId, pos)
    local tableData = data_MonsterTeXing[MONSTER_TX_4] or {}
    tableData = tableData.calparam or {}
    local targetNum = tableData[1] or 3
    local hpCoeff = tableData[2] or 0.5
    local addCoeff = tableData[3] or 0.25
    local team = roleObj:getProperty(PROPERTY_TEAM)
    local posList = _getPosListByTeamAndTargetType(team, TARGETTYPE_MYSIDE)
    local effList = {}
    for _, p in pairs(posList) do
      local monterObj = _getFightRoleObjByPos(warId, p)
      if monterObj and monterObj:getType() == LOGICTYPE_MONSTER and not monterObj:IsBossMonster() and not _checkRoleIsInState(monterObj, EFFECTTYPE_FROZEN) then
        local hp = monterObj:getProperty(PROPERTY_HP)
        local maxHp = monterObj:getMaxProperty(PROPERTY_HP)
        if hp < maxHp * hpCoeff then
          effList[#effList + 1] = {p, monterObj}
        end
      end
    end
    if #effList > 0 then
      local formatFightSeq = {
        seqType = SEQTYPE_MONSTER_TX,
        txType = MONSTER_TX_4,
        userPos = pos,
        targetInfo = {}
      }
      local tInfo = formatFightSeq.targetInfo
      for i = 1, targetNum do
        local selIdx = math.random(1, #effList)
        local effData = table.remove(effList, selIdx)
        local effPos, monterObj = effData[1], effData[2]
        local hp = monterObj:getProperty(PROPERTY_HP)
        local mp = monterObj:getProperty(PROPERTY_MP)
        local maxHp = monterObj:getMaxProperty(PROPERTY_HP)
        local addHp = math.floor(maxHp * addCoeff)
        hp = hp + addHp
        if maxHp < hp then
          hp = maxHp
        end
        monterObj:setProperty(PROPERTY_HP, hp)
        tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_MonsterTxAddHpMp(pos, effPos, hp, mp, addHp, 0)
        printLogDebug("war_skill", "【war log】[warid%d]boss @%d 给小怪加血 @%d (%d,%d)", warId, pos, effPos, hp, addHp)
        if #effList <= 0 then
          break
        end
      end
      if #tInfo > 0 then
        _onNewFormatFightSequence(warId, formatFightSeq)
      end
    else
      printLogDebug("war_skill", "【war log】[warid%d]boss @%d 找不到需要加血的小怪", warId, pos)
    end
  end
  if not roleObj:IsBossMonster() and roleObj:PossessMonsterTeXing(MONSTER_TX_5) and not _checkRoleIsInState(roleObj, EFFECTTYPE_FROZEN) then
    printLogDebug("war_skill", "【war log】[warid%d]小怪 @%d 准备对biss进行加血", warId, pos)
    local tableData = data_MonsterTeXing[MONSTER_TX_5] or {}
    tableData = tableData.calparam or {}
    local hpCoeff = tableData[1] or 0.5
    local addCoeff = tableData[2] or 0.1
    local team = roleObj:getProperty(PROPERTY_TEAM)
    local posList = _getPosListByTeamAndTargetType(team, TARGETTYPE_MYSIDE)
    local effList = {}
    for _, p in pairs(posList) do
      local monterObj = _getFightRoleObjByPos(warId, p)
      if monterObj and monterObj:getType() == LOGICTYPE_MONSTER and monterObj:IsBossMonster() and not _checkRoleIsInState(monterObj, EFFECTTYPE_FROZEN) then
        local hp = monterObj:getProperty(PROPERTY_HP)
        local maxHp = monterObj:getMaxProperty(PROPERTY_HP)
        if hp < maxHp * hpCoeff then
          effList[#effList + 1] = {p, monterObj}
        end
      end
    end
    if #effList > 0 then
      local formatFightSeq = {
        seqType = SEQTYPE_MONSTER_TX,
        txType = MONSTER_TX_5,
        userPos = pos,
        targetInfo = {}
      }
      local tInfo = formatFightSeq.targetInfo
      local selIdx = math.random(1, #effList)
      local effData = table.remove(effList, selIdx)
      local effPos, monterObj = effData[1], effData[2]
      local hp = monterObj:getProperty(PROPERTY_HP)
      local mp = monterObj:getProperty(PROPERTY_MP)
      local maxHp = monterObj:getMaxProperty(PROPERTY_HP)
      local addHp = math.floor(maxHp * addCoeff)
      hp = hp + addHp
      if maxHp < hp then
        hp = maxHp
      end
      monterObj:setProperty(PROPERTY_HP, hp)
      tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_MonsterTxAddHpMp(pos, effPos, hp, mp, addHp, 0)
      printLogDebug("war_skill", "【war log】[warid%d]小怪 @%d 给boss加血 @%d (%d,%d)", warId, pos, effPos, hp, addHp)
      if #tInfo > 0 then
        _onNewFormatFightSequence(warId, formatFightSeq)
      end
    else
      printLogDebug("war_skill", "【war log】[warid%d]小怪 @%d 找不到需要加血的boss", warId, pos)
    end
  end
  if roleObj:PossessMonsterTeXing(MONSTER_TX_8) and not _checkRoleIsInState(roleObj, EFFECTTYPE_FROZEN) then
    local team = roleObj:getProperty(PROPERTY_TEAM)
    local posList = _getPosListByTeamAndTargetType(team, TARGETTYPE_MYSIDE)
    for _, p in pairs(posList) do
      local monsterObj = _getFightRoleObjByPos_DeadOrLive(warId, p)
      if monsterObj and monsterObj:getType() == LOGICTYPE_MONSTER and monsterObj:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD and monsterObj:PossessMonsterTeXing(MONSTER_TX_8) then
        local maxHp = monsterObj:getMaxProperty(PROPERTY_HP)
        local maxMp = monsterObj:getMaxProperty(PROPERTY_MP)
        monsterObj:setProperty(PROPERTY_HP, maxHp)
        monsterObj:setProperty(PROPERTY_MP, maxMp)
        monsterObj:setProperty(PROPERTY_DEAD, ROLESTATE_LIVE)
        _formatAndSendMakeOtherReliveSequence(warId, pos, p, maxHp, maxMp, maxHp, maxMp, MONSTER_TX_8)
      end
    end
  end
end
function _checkAllEffectStateBeforeRound(warId, warRound, pos)
  local roleObj = _getFightRoleObjByPos_WithDeadHero(warId, pos)
  if roleObj == nil then
    print_SkillLog_RoleIsNotExist(warId, pos)
    return
  end
  print_SkillLog_UpdateAllStateBeforeRound(warId, pos)
  local effList = roleObj:getEffects()
  local formatFightSeq = {
    seqType = SEQTYPE_EFFECT_OFF,
    objPos = pos,
    effectList = {}
  }
  local effectList = formatFightSeq.effectList
  local newEffectList = {}
  local rmvsleep = false
  local clearAllEffect = false
  for effectID, effectInfo in pairs(effList) do
    local effRound = effectInfo[1]
    local effRoundMax = effectInfo[2]
    local effectData = effectInfo[3]
    effRound = effRound + 1
    if effRoundMax >= effRound then
      newEffectList[effectID] = {
        effRound,
        effRoundMax,
        effectData
      }
      local rs, cae = _checkDurativeEffectOnRole(warId, warRound, pos, roleObj, effectID, effRound, effectData)
      rmvsleep = rmvsleep or rs
      clearAllEffect = clearAllEffect or cae
      if clearAllEffect then
        break
      end
    else
      printLogDebug("skill_ai", "回合前刷新buff时出现异常，buff不应该在回合前结束", pos, effectID)
      local effectOffID = _getEffectOffID(effectID)
      if effectOffID ~= nil then
        effectList[#effectList + 1] = effectOffID
      end
      _checkDurativeEffectOnRole_Off(warId, pos, roleObj, effectID, effectOffID, effectData)
    end
  end
  if newEffectList[EFFECTTYPE_SLEEP] ~= nil and rmvsleep and roleObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
    newEffectList[EFFECTTYPE_SLEEP] = nil
    effectList[#effectList + 1] = EFFECTTYPE_SLEEP_OFF
  end
  if clearAllEffect then
    roleObj:setEffects({})
  else
    roleObj:setEffects(newEffectList)
  end
  local caLimit = roleObj:getProperty(PROPERTY_PWLFJTIMES) + 1
  roleObj:setTempProperty(PROPERTY_PWLFJTIMES, caLimit)
  if roleObj:getType() == LOGICTYPE_PET then
    roleObj:setTempProperty(PROPERTY_PROTECTTIMES, DEFINE_PETSKILL_PROTECT_MAXTIMES)
  end
  if #effectList > 0 then
    _onNewFormatFightSequence(warId, formatFightSeq)
    for effectID, effectInfo in pairs(newEffectList) do
      local effRound = effectInfo[1]
      local tempData = data_Effect[effectID] or {}
      print_SkillLog_UpdateAllStateInfo(warId, pos, tempData.name or "未知效果", effRound)
    end
  end
end
function _checkDurativeEffectOnRole(warId, warRound, pos, roleObj, effectID, effRound, effectData)
  local formatFightSeq, shareSeq
  local rmvsleep = false
  local clearAllEffect = false
  if effectID == EFFECTTYPE_POISON then
    local roleHp = roleObj:getProperty(PROPERTY_HP)
    local roleMp = roleObj:getProperty(PROPERTY_MP)
    if not _RoleIsDamgeImmunity(roleObj) then
      local kAttr = _getTotalKangPro(roleObj, SKILLATTR_POISON)
      local maxHp = roleObj:getMaxProperty(PROPERTY_HP)
      local extraCoeff = effectData.extraCoeff or 0
      local skillWeakCeoff = effectData.skillWeakCeoff or 0
      local wxCoeff = effectData.wxCoeff or 0
      local damageWeak = _getNormalSkill_WeakenDamage(roleObj, SKILLATTR_POISON)
      local damage = _computeSkillDamage_Poison(effectData.skillID, kAttr, effectData.fkAttr, effectData.skillExp, effRound, effectData.pLevel, maxHp, effectData.ssv, extraCoeff, skillWeakCeoff, damageWeak)
      damage = _checkDamage(damage * (1 + wxCoeff))
      local effList = {}
      local maxHpMpChanged = false
      if damage > 0 then
        local sharePos, shareObj = _getShareDamagePos(warId, roleObj, pos)
        if shareObj ~= nil then
          local sk_1, sk_2, _ = _computeSkillEffect_ShouHuCangSheng(SKILL_SHOUHUCANGSHENG)
          local shareDamage = _checkDamage(damage * sk_2)
          damage = _checkDamage(damage * sk_1)
          effList[#effList + 1] = EFFECTTYPE_SHAREDAMAGE
          local shareHp = shareObj:getProperty(PROPERTY_HP)
          local shareMp = shareObj:getProperty(PROPERTY_MP)
          local shareEffList = {EFFECTTYPE_NOSKILLANI}
          if not _RoleIsDamgeImmunity(shareObj) then
            local maxHpMpChanged_Share = false
            shareHp = math.max(shareHp - shareDamage)
            if shareHp <= 0 then
              shareHp, maxHpMpChanged_Share = _setRoleIsDeadInWar(warId, warRound, sharePos, shareObj, shareEffList)
            end
            shareObj:setProperty(PROPERTY_HP, shareHp)
            if shareObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and _checkRoleIsInState(shareObj, EFFECTTYPE_SLEEP) then
              _removeRoleEffectState(shareObj, EFFECTTYPE_SLEEP)
              shareEffList[#shareEffList + 1] = EFFECTTYPE_SLEEP_OFF
            end
            if maxHpMpChanged_Share then
              local shareMaxHp = shareObj:getMaxProperty(PROPERTY_HP)
              local shareMaxMp = shareObj:getMaxProperty(PROPERTY_MP)
              shareSeq = _formatNormalSeqOfTarget(SEQTYPE_DURATIVE_EFFECT, sharePos, shareHp, shareMp, shareDamage, 0, EFFECTTYPE_NONE, shareEffList, shareMaxHp, shareMaxMp)
            else
              shareSeq = _formatNormalSeqOfTarget(SEQTYPE_DURATIVE_EFFECT, sharePos, shareHp, shareMp, shareDamage, 0, EFFECTTYPE_NONE, shareEffList)
            end
          else
            shareEffList[#shareEffList + 1] = EFFECTTYPE_IMMUNITY_DAMAGE
            shareSeq = _formatNormalSeqOfTarget(SEQTYPE_DURATIVE_EFFECT, sharePos, shareHp, shareMp, 0, 0, EFFECTTYPE_NONE, shareEffList)
          end
        end
      end
      roleHp = roleHp - damage
      print_SkillLog_PoisonDamage(warId, pos, damage)
      if roleHp <= 0 then
        roleHp = 0
        roleHp, maxHpMpChanged = _setRoleIsDeadInWar(warId, warRound, pos, roleObj, effList)
        if _getEffectIsExisted(EFFECTTYPE_JIRENTIANXIANG, effList) then
          clearAllEffect = true
        end
        if roleObj:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD then
          clearAllEffect = true
        end
      end
      roleObj:setProperty(PROPERTY_HP, roleHp)
      if maxHpMpChanged == true then
        local roleMaxHp = roleObj:getMaxProperty(PROPERTY_HP)
        local roleMaxMp = roleObj:getMaxProperty(PROPERTY_MP)
        formatFightSeq = _formatNormalSeqOfTarget(SEQTYPE_DURATIVE_EFFECT, pos, roleHp, roleMp, damage, 0, effectID, effList, roleMaxHp, roleMaxMp)
      else
        formatFightSeq = _formatNormalSeqOfTarget(SEQTYPE_DURATIVE_EFFECT, pos, roleHp, roleMp, damage, 0, effectID, effList)
      end
      rmvsleep = true
    else
      formatFightSeq = _formatNormalSeqOfTarget(SEQTYPE_DURATIVE_EFFECT, pos, roleHp, roleMp, 0, 0, effectID, {EFFECTTYPE_IMMUNITY_DAMAGE})
    end
  end
  if formatFightSeq ~= nil then
    _onNewFormatFightSequence(warId, formatFightSeq)
  end
  if shareSeq ~= nil then
    _onNewFormatFightSequence(warId, shareSeq)
  end
  return rmvsleep, clearAllEffect
end
function _checkAllEffectStateAfterRound(warId, pos)
  local roleObj = _getFightRoleObjByPos_WithDeadHero(warId, pos)
  if roleObj == nil then
    print_SkillLog_RoleIsNotExist(warId, pos)
    return
  end
  local effList = roleObj:getEffects()
  local formatFightSeq = {
    seqType = SEQTYPE_EFFECT_OFF,
    objPos = pos,
    effectList = {}
  }
  local effectList = formatFightSeq.effectList
  local newEffectList = {}
  for effectID, effectInfo in pairs(effList) do
    local effRound = effectInfo[1]
    local effRoundMax = effectInfo[2]
    local effectData = effectInfo[3]
    if effRoundMax >= effRound + 1 then
      newEffectList[effectID] = {
        effRound,
        effRoundMax,
        effectData
      }
    else
      local effectOffID = _getEffectOffID(effectID)
      if effectOffID ~= nil then
        effectList[#effectList + 1] = effectOffID
      end
      _checkDurativeEffectOnRole_Off(warId, pos, roleObj, effectID, effectOffID, effectData)
    end
  end
  roleObj:setEffects(newEffectList)
  if #effectList > 0 then
    _onNewFormatFightSequence(warId, formatFightSeq)
    for effectID, effectInfo in pairs(newEffectList) do
      local effRound = effectInfo[1]
      local tempData = data_Effect[effectID] or {}
      print_SkillLog_UpdateAllStateInfo(warId, pos, tempData.name or "未知效果", effRound)
    end
  end
end
function _checkDurativeEffectOnRole_Off(warId, pos, roleObj, effectID, effectOffID, effectData, isFormatSeq)
  local maxHpMpChanged = false
  _clearEffectOnTarget(roleObj, effectID)
  if effectOffID == EFFECTTYPE_ADV_SPEED_OFF then
    _clearTargetTempAttr(roleObj, PROPERTY_SP, EFFECTTYPE_ADV_SPEED)
  elseif effectOffID == EFFECTTYPE_ADV_DAMAGE_OFF then
    _clearTargetTempAttr(roleObj, PROPERTY_AP, EFFECTTYPE_ADV_DAMAGE)
  elseif effectOffID == EFFECTTYPE_ADV_WULI_OFF then
    _clearTargetTempKangPro(roleObj, SKILLATTR_WULI, EFFECTTYPE_ADV_WULI)
  elseif effectOffID == EFFECTTYPE_ADV_RENZU_OFF then
    _clearTargetTempKangPro(roleObj, SKILLATTR_POISON, EFFECTTYPE_ADV_RENZU)
    _clearTargetTempKangPro(roleObj, SKILLATTR_SLEEP, EFFECTTYPE_ADV_RENZU)
    _clearTargetTempKangPro(roleObj, SKILLATTR_CONFUSE, EFFECTTYPE_ADV_RENZU)
    _clearTargetTempKangPro(roleObj, SKILLATTR_ICE, EFFECTTYPE_ADV_RENZU)
  elseif effectOffID == EFFECTTYPE_ADV_XIANZU_OFF then
    _clearTargetTempKangPro(roleObj, SKILLATTR_FIRE, EFFECTTYPE_ADV_XIANZU)
    _clearTargetTempKangPro(roleObj, SKILLATTR_WIND, EFFECTTYPE_ADV_XIANZU)
    _clearTargetTempKangPro(roleObj, SKILLATTR_THUNDER, EFFECTTYPE_ADV_XIANZU)
    _clearTargetTempKangPro(roleObj, SKILLATTR_WATER, EFFECTTYPE_ADV_XIANZU)
  elseif effectOffID == EFFECTTYPE_ADV_MINGZHONG_OFF then
    _clearTargetTempAttr(roleObj, PROPERTY_PACC, EFFECTTYPE_ADV_MINGZHONG)
  elseif effectOffID == EFFECTTYPE_ADV_DEFEND_OFF then
    roleObj:setTempProperty(PROPERTY_PWLFYXS, 0)
  elseif effectOffID == EFFECTTYPE_DEC_WULI_OFF then
    _clearTargetTempKangPro(roleObj, SKILLATTR_WULI, EFFECTTYPE_DEC_WULI)
  elseif effectOffID == EFFECTTYPE_DEC_RENZU_OFF then
    _clearTargetTempKangPro(roleObj, SKILLATTR_POISON, EFFECTTYPE_DEC_RENZU)
    _clearTargetTempKangPro(roleObj, SKILLATTR_SLEEP, EFFECTTYPE_DEC_RENZU)
    _clearTargetTempKangPro(roleObj, SKILLATTR_CONFUSE, EFFECTTYPE_DEC_RENZU)
    _clearTargetTempKangPro(roleObj, SKILLATTR_ICE, EFFECTTYPE_DEC_RENZU)
  elseif effectOffID == EFFECTTYPE_DEC_XIANZU_OFF then
    _clearTargetTempKangPro(roleObj, SKILLATTR_FIRE, EFFECTTYPE_DEC_XIANZU)
    _clearTargetTempKangPro(roleObj, SKILLATTR_WIND, EFFECTTYPE_DEC_XIANZU)
    _clearTargetTempKangPro(roleObj, SKILLATTR_THUNDER, EFFECTTYPE_DEC_XIANZU)
    _clearTargetTempKangPro(roleObj, SKILLATTR_WATER, EFFECTTYPE_DEC_XIANZU)
  elseif effectOffID == EFFECTTYPE_DEC_ZHEN_OFF then
    _clearTargetTempKangPro(roleObj, SKILLATTR_ZHEN, EFFECTTYPE_DEC_ZHEN)
    _clearTargetTempKangPro(roleObj, SKILLATTR_YIWANG, EFFECTTYPE_DEC_ZHEN)
    _clearTargetTempKangPro(roleObj, SKILLATTR_AIHAO, EFFECTTYPE_DEC_ZHEN)
    _clearTargetTempKangPro(roleObj, SKILLATTR_XIXUE, EFFECTTYPE_DEC_ZHEN)
  elseif effectOffID == EFFECTTYPE_SHUAIRUO_OFF then
    _clearTargetTempKangPro(roleObj, SKILLATTR_ZHEN, EFFECTTYPE_SHUAIRUO)
    _clearTargetTempKangPro(roleObj, SKILLATTR_YIWANG, EFFECTTYPE_SHUAIRUO)
    _clearTargetTempKangPro(roleObj, SKILLATTR_AIHAO, EFFECTTYPE_SHUAIRUO)
    _clearTargetTempKangPro(roleObj, SKILLATTR_XIXUE, EFFECTTYPE_SHUAIRUO)
  elseif effectOffID == EFFECTTYPE_YIWANG_OFF then
    roleObj:setTempProperty(PROPERTY_YIWANGSKILL, 0)
  elseif effectOffID == EFFECTTYPE_ADV_NIAN_OFF then
    _clearTargetTempAttr(roleObj, PROPERTY_PKUANGBAO, EFFECTTYPE_ADV_NIAN)
    _clearTargetTempAttr(roleObj, PROPERTY_PACC, EFFECTTYPE_ADV_NIAN)
    _clearTargetTempAttr(roleObj, PROPERTY_PCRIT, EFFECTTYPE_ADV_NIAN)
  elseif effectOffID == EFFECTTYPE_DEC_SPEED_OFF then
    _clearTargetTempAttr(roleObj, PROPERTY_SP, EFFECTTYPE_DEC_SPEED)
  elseif effectOffID == EFFECTTYPE_SHUNSHUITUIZHOU_OFF then
    local eAttr = effectData.eAttr
    if eAttr == PROPERTY_GenGu then
      local gg = effectData.gg
      local subHp = effectData.subHp
      roleObj:setProperty(PROPERTY_GenGu, gg)
      local newMaxHp = CalculateRoleHP(roleObj)
      roleObj:setMaxProperty(PROPERTY_HP, newMaxHp)
      if subHp > 0 then
        local hp = roleObj:getProperty(PROPERTY_HP)
        hp = hp + subHp
        if newMaxHp < hp then
          hp = newMaxHp
        end
        roleObj:setProperty(PROPERTY_HP, hp)
      end
      if isFormatSeq ~= false then
        local hp = roleObj:getProperty(PROPERTY_HP)
        local mp = roleObj:getProperty(PROPERTY_MP)
        local maxhp = roleObj:getMaxProperty(PROPERTY_HP)
        local maxmp = roleObj:getMaxProperty(PROPERTY_MP)
        _formatAndSendNormalBaseInfoSeqOfTarget(warId, pos, hp, mp, maxhp, maxmp)
      end
      maxHpMpChanged = true
    elseif eAttr == PROPERTY_Lingxing then
      local lx = effectData.lx
      local subMp = effectData.subMp
      roleObj:setProperty(PROPERTY_Lingxing, lx)
      local newMaxMp = CalculateRoleMP(roleObj)
      roleObj:setMaxProperty(PROPERTY_MP, newMaxMp)
      if subMp > 0 then
        local mp = roleObj:getProperty(PROPERTY_MP)
        mp = mp + subMp
        if newMaxMp < mp then
          mp = newMaxMp
        end
        roleObj:setProperty(PROPERTY_MP, mp)
      end
      if isFormatSeq ~= false then
        local hp = roleObj:getProperty(PROPERTY_HP)
        local mp = roleObj:getProperty(PROPERTY_MP)
        local maxhp = roleObj:getMaxProperty(PROPERTY_HP)
        local maxmp = roleObj:getMaxProperty(PROPERTY_MP)
        _formatAndSendNormalBaseInfoSeqOfTarget(warId, pos, hp, mp, maxhp, maxmp)
      end
      maxHpMpChanged = true
    elseif eAttr == PROPERTY_LiLiang then
      local ll = effectData.ll
      roleObj:setProperty(PROPERTY_LiLiang, ll)
      local newAp = CalculateRoleAP(roleObj)
      roleObj:setProperty(PROPERTY_AP, newAp)
    elseif eAttr == PROPERTY_MinJie then
      local mj = effectData.mj
      roleObj:setProperty(PROPERTY_MinJie, mj)
      local newSp = CalculateRoleSP(roleObj)
      roleObj:setProperty(PROPERTY_SP, newSp)
    end
  elseif effectOffID == EFFECTTYPE_RUHUTIANYI_OFF then
    _clearTargetTempKangPro(roleObj, SKILLATTR_WULI, EFFECTTYPE_RUHUTIANYI)
    _clearTargetTempKangPro(roleObj, SKILLATTR_POISON, EFFECTTYPE_RUHUTIANYI)
    _clearTargetTempKangPro(roleObj, SKILLATTR_SLEEP, EFFECTTYPE_RUHUTIANYI)
    _clearTargetTempKangPro(roleObj, SKILLATTR_CONFUSE, EFFECTTYPE_RUHUTIANYI)
    _clearTargetTempKangPro(roleObj, SKILLATTR_ICE, EFFECTTYPE_RUHUTIANYI)
    _clearTargetTempKangPro(roleObj, SKILLATTR_FIRE, EFFECTTYPE_RUHUTIANYI)
    _clearTargetTempKangPro(roleObj, SKILLATTR_WIND, EFFECTTYPE_RUHUTIANYI)
    _clearTargetTempKangPro(roleObj, SKILLATTR_THUNDER, EFFECTTYPE_RUHUTIANYI)
    _clearTargetTempKangPro(roleObj, SKILLATTR_WATER, EFFECTTYPE_RUHUTIANYI)
  elseif effectOffID == EFFECTTYPE_WUXING_OFF then
    for _, proName in pairs({
      PROPERTY_WXJIN,
      PROPERTY_WXMU,
      PROPERTY_WXSHUI,
      PROPERTY_WXHUO,
      PROPERTY_WXTU
    }) do
      local v = effectData[proName]
      if v ~= nil then
        roleObj:setProperty(proName, v)
      end
    end
  end
  local tempData = data_Effect[effectID] or {}
  print_SkillLog_StateRemoved(warId, pos, tempData.name or "未知效果")
  return maxHpMpChanged
end
function _checkAllEffectStateBeforeRoundCompleted(warId)
  local formatFightSeq = {}
  formatFightSeq.seqType = SEQTYPE_FRESHFINISHBEFOREROUND
  _onNewFormatFightSequence(warId, formatFightSeq)
end
function _checkPetSkillsAfterRound(warId, warType, warRound)
  local allPetPosList = _getAllPetPosList()
  for _, petPos in pairs(allPetPosList) do
    local petObj = _getFightRoleObjByPos(warId, petPos)
    if petObj and petObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
      local hpCoeff, mpCoeff, skillId = petObj:GetPetSkillZuoNiaoShouSan()
      if hpCoeff > 0 or mpCoeff > 0 then
        local masterPos = _getMasterPosByPetPos(petPos)
        local masterObj = _getFightRoleObjByPos_WithDeadHero(warId, masterPos)
        if masterObj and masterObj:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD then
          local team = petObj:getProperty(PROPERTY_TEAM)
          local petPosList = _getPosListByTeamAndTargetType(team, TARGETTYPE_MYSIDE)
          local onlyFlag = true
          for _, p in pairs(petPosList) do
            if p ~= petPos then
              local tmpObj = _getFightRoleObjByPos(warId, p)
              if tmpObj and tmpObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and tmpObj:getType() == LOGICTYPE_PET then
                onlyFlag = false
              end
            end
          end
          if onlyFlag then
            _checkCancelStealth(warId, petPos, petObj)
            local posList = _getPosListByTeamAndTargetType(team, TARGETTYPE_MYSIDE)
            for _, rolePos in pairs(posList) do
              local roleObj = _getFightRoleObjByPos_WithDeadHero(warId, rolePos)
              if roleObj and roleObj:getType() == LOGICTYPE_HERO then
                local roleHp = roleObj:getProperty(PROPERTY_HP)
                local roleMp = roleObj:getProperty(PROPERTY_MP)
                local roleMaxHp = roleObj:getMaxProperty(PROPERTY_HP)
                local roleMaxMp = roleObj:getMaxProperty(PROPERTY_MP)
                local addHp, addMp = 0, 0
                local fuhuo, effList
                if not _checkRoleIsInState(roleObj, EFFECTTYPE_DUOHUNSUOMING) then
                  if hpCoeff > 0 then
                    addHp = _checkDamage(roleMaxHp * hpCoeff)
                    roleHp = math.min(roleMaxHp, roleHp + addHp)
                    roleObj:setProperty(PROPERTY_HP, roleHp)
                    if roleObj:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD then
                      roleObj:setProperty(PROPERTY_DEAD, ROLESTATE_LIVE)
                      fuhuo = 1
                    end
                  end
                  if mpCoeff > 0 then
                    addMp = _checkDamage(roleMaxMp * mpCoeff)
                    roleMp = math.min(roleMaxMp, roleMp + addMp)
                    roleObj:setProperty(PROPERTY_MP, roleMp)
                  end
                else
                  effList = {EFFECTTYPE_INVALID}
                end
                _formatAndSendInstantAddHpMpSeq(warId, rolePos, roleHp, roleMp, addHp, addMp, skillId, petPos, fuhuo, effList)
                skillId = nil
              end
            end
            _checkIsThieveSkill(petObj, PETSKILL_ZUONIAOSHOUSAN)
            local effectList = {}
            local petHp, maxHpMpChanged = _setRoleIsDeadInWar(warId, warRound, petPos, petObj, effectList, true)
            petObj:setProperty(PROPERTY_HP, petHp)
            if petHp > 0 then
              local petMp = petObj:getProperty(PROPERTY_MP)
              local petMaxHp = petObj:getMaxProperty(PROPERTY_HP)
              local petMaxMp = petObj:getMaxProperty(PROPERTY_MP)
              _formatAndSendInstantDamageHpMpSeq(warId, petPos, petHp, petMp, nil, nil, nil, nil, effectList, SUBSEQTYPE_SEQSPACE_PREEND_2, petMaxHp, petMaxMp)
            else
              _formatAndSendLeaveBattleSeq(warId, petPos, SUBSEQTYPE_SEQSPACE_PREEND_2)
            end
          end
        end
      end
    end
  end
end
function _checkWhenWarBegin(warId, warType)
  local isPvpWar = IsPVPWarType(warType)
  local ftSeq = {}
  if isPvpWar then
    local pairs = pairs
    local allPetPosList = _getAllPetPosList()
    for _, pos in pairs(allPetPosList) do
      local newObj = _getFightRoleObjByPos(warId, pos)
      if newObj and newObj:getType() == LOGICTYPE_PET then
        local yyhySkill = newObj:GetPetSkillYiYaHuanYa()
        if yyhySkill ~= nil and yyhySkill ~= 0 then
          local times = newObj:getTempProperty(PROPERTY_YIYAHUANYA)
          if times == 0 then
            local thieveSkills = {}
            local team = newObj:getProperty(PROPERTY_TEAM)
            local petList = _getPetPosListByTeamAndTargetType(team, TARGETTYPE_ENEMYSIDE)
            for _, petPos in pairs(petList) do
              local petObj = _getFightRoleObjByPos(warId, petPos)
              if petObj and petObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and petObj:getType() == LOGICTYPE_PET then
                local pskillList = petObj:getAllCanThievedPetSkills()
                for _, sId in pairs(pskillList) do
                  local subType = _getPetSkillSubType(sId)
                  if subType == PETSKILL_SUBTYPE_SUPREME and not newObj:hasLearnPetSkill(sId) and sId ~= PETSKILL_YIYAHUANYA then
                    thieveSkills[#thieveSkills + 1] = {petPos, sId}
                  end
                end
              end
            end
            if #thieveSkills > 0 then
              local selData = thieveSkills[math.random(1, #thieveSkills)]
              local petPos, skillId = unpack(selData, 1, 2)
              newObj:setThieveSkill(skillId)
              newObj:setTempProperty(PROPERTY_YIYAHUANYA, times + 1)
              ftSeq[#ftSeq + 1] = _formatWordTipSequence(warId, newObj:getPlayerId(), SUBSEQTYPE_THIEVESKILL, skillId, pos)
              ftSeq[#ftSeq + 1] = _formatAddPosAni(warId, petPos, yyhySkill, pos, yyhySkill)
            end
          end
        end
      end
    end
  end
  if #ftSeq <= 0 then
    return nil
  else
    return ftSeq
  end
end
function _checkWhenPetEnter(warId, warRound, pos, param)
  local newObj = _getFightRoleObjByPos(warId, pos)
  if newObj == nil then
    return
  end
  local warType = _getTheWarType(warId)
  local isPvpWar = IsPVPWarType(warType)
  local team = newObj:getProperty(PROPERTY_TEAM)
  param = param or {}
  if isPvpWar and param.sf ~= 1 then
    local yyhySkill = newObj:GetPetSkillYiYaHuanYa()
    if yyhySkill ~= nil and yyhySkill ~= 0 then
      local pairs = pairs
      local times = newObj:getTempProperty(PROPERTY_YIYAHUANYA)
      if times == 0 then
        local thieveSkills = {}
        local petList = _getPetPosListByTeamAndTargetType(team, TARGETTYPE_ENEMYSIDE)
        for _, petPos in pairs(petList) do
          local petObj = _getFightRoleObjByPos(warId, petPos)
          if petObj and petObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and petObj:getType() == LOGICTYPE_PET then
            local pskillList = petObj:getAllCanThievedPetSkills()
            for _, sId in pairs(pskillList) do
              local subType = _getPetSkillSubType(sId)
              if subType == PETSKILL_SUBTYPE_SUPREME and not newObj:hasLearnPetSkill(sId) and sId ~= PETSKILL_YIYAHUANYA then
                thieveSkills[#thieveSkills + 1] = {petPos, sId}
              end
            end
          end
        end
        if #thieveSkills > 0 then
          local selData = thieveSkills[math.random(1, #thieveSkills)]
          local petPos, skillId = unpack(selData, 1, 2)
          newObj:setThieveSkill(skillId)
          newObj:setTempProperty(PROPERTY_YIYAHUANYA, times + 1)
          _formatAndSendWordTipSequence(warId, newObj:getPlayerId(), SUBSEQTYPE_THIEVESKILL, skillId, pos)
          _formatAndSendAddPosAni(warId, petPos, yyhySkill, pos, yyhySkill)
        end
      end
    end
  end
  if isPvpWar then
    local mcqhSkill = newObj:GetPetSkillMingChaQiuHao()
    if mcqhSkill then
      _formatAndSendShowHpMpFlag(warId, team, 1)
    end
  end
  if isPvpWar and param.sf ~= 1 and _checkXuanRenFlagOfTeam(warId, team) ~= nil then
    _formatAndSendAddSceneAni(warId, SUBSEQTYPE_XUANREN, team)
  end
  if isPvpWar and param.sf ~= 1 and _checkYiHuanFlagOfTeam(warId, team) ~= nil then
    _formatAndSendAddSceneAni(warId, SUBSEQTYPE_YIHUAN, team)
  end
  if isPvpWar then
    _checkHuaWuFlagOfTeam(warId, newObj, team)
  end
  if isPvpWar and param.sf ~= 1 then
    local proHp, proMp, petSkillId = newObj:GetPetSkillXianFengDaoGu()
    if proHp > 0 or proMp > 0 then
      local posList = _getPosListByTeamAndTargetType(team, TARGETTYPE_MYSIDE)
      local posMin
      for _, thePos in pairs(posList) do
        if thePos ~= pos then
          local posObj = _getFightRoleObjByPos_WithDeadHero(warId, thePos)
          if posObj then
            local posObjHp = posObj:getProperty(PROPERTY_HP)
            local posObjMaxHp = posObj:getMaxProperty(PROPERTY_HP)
            if posObjMaxHp > 0 and posObjHp < posObjMaxHp then
              local hpPro = posObjHp / posObjMaxHp
              if posMin == nil then
                posMin = {
                  thePos,
                  posObj,
                  hpPro
                }
              elseif hpPro < posMin[3] then
                posMin = {
                  thePos,
                  posObj,
                  hpPro
                }
              end
            end
          end
        end
      end
      if posMin ~= nil then
        local effPos, effObj = posMin[1], posMin[2]
        local objHp = effObj:getProperty(PROPERTY_HP)
        local objMp = effObj:getProperty(PROPERTY_MP)
        if _checkRoleIsInState(effObj, EFFECTTYPE_FROZEN) then
          _formatAndSendInstantAddHpMpSeq(warId, effPos, objHp, objMp, 0, 0, petSkillId, pos, nil, {EFFECTTYPE_IMMUNITY}, SUBSEQTYPE_PETENTER)
        elseif _checkRoleIsInState(effObj, EFFECTTYPE_DUOHUNSUOMING) then
          _formatAndSendInstantAddHpMpSeq(warId, effPos, objHp, objMp, 0, 0, petSkillId, pos, nil, {EFFECTTYPE_INVALID}, SUBSEQTYPE_PETENTER)
        else
          local objMaxHp = effObj:getMaxProperty(PROPERTY_HP)
          local objMaxMp = effObj:getMaxProperty(PROPERTY_MP)
          local addHp, addMp = 0, 0
          local fuhuo
          if proHp > 0 then
            addHp = _checkDamage(proHp * objMaxHp)
            objHp = math.min(objHp + addHp, objMaxHp)
            effObj:setProperty(PROPERTY_HP, objHp)
            if effObj:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD then
              effObj:setProperty(PROPERTY_DEAD, ROLESTATE_LIVE)
              fuhuo = 1
            end
          end
          if proMp > 0 then
            addMp = _checkDamage(proMp * objMaxMp)
            objMp = math.min(objMp + addMp, objMaxMp)
            effObj:setProperty(PROPERTY_MP, objMp)
          end
          _formatAndSendInstantAddHpMpSeq(warId, effPos, objHp, objMp, addHp, addMp, petSkillId, pos, fuhuo, nil, SUBSEQTYPE_PETENTER)
        end
      end
    end
  end
  local proHp, proMp, petSkillId = newObj:GetPetSkillMiaoShouRenXin()
  if isPvpWar and param.sf ~= 1 and (proHp > 0 or proMp > 0) then
    local posList = _getPosListByTeamAndTargetType(team, TARGETTYPE_MYSIDE)
    local posMin
    for _, thePos in pairs(posList) do
      if thePos ~= pos then
        local posObj = _getFightRoleObjByPos_WithDeadHero(warId, thePos)
        if posObj then
          local posObjMp = posObj:getProperty(PROPERTY_MP)
          local posObjMaxMp = posObj:getMaxProperty(PROPERTY_MP)
          if posObjMaxMp > 0 and posObjMp < posObjMaxMp then
            local mpPro = posObjMp / posObjMaxMp
            if posMin == nil then
              posMin = {
                thePos,
                posObj,
                mpPro
              }
            elseif mpPro < posMin[3] then
              posMin = {
                thePos,
                posObj,
                mpPro
              }
            end
          end
        end
      end
    end
    if posMin ~= nil then
      local effPos, effObj = posMin[1], posMin[2]
      local objHp = effObj:getProperty(PROPERTY_HP)
      local objMp = effObj:getProperty(PROPERTY_MP)
      if _checkRoleIsInState(effObj, EFFECTTYPE_FROZEN) then
        _formatAndSendInstantAddHpMpSeq(warId, effPos, objHp, objMp, 0, 0, petSkillId, pos, nil, {EFFECTTYPE_IMMUNITY}, SUBSEQTYPE_PETENTER)
      elseif _checkRoleIsInState(effObj, EFFECTTYPE_DUOHUNSUOMING) then
        _formatAndSendInstantAddHpMpSeq(warId, effPos, objHp, objMp, 0, 0, petSkillId, pos, nil, {EFFECTTYPE_INVALID}, SUBSEQTYPE_PETENTER)
      else
        local objMaxHp = effObj:getMaxProperty(PROPERTY_HP)
        local objMaxMp = effObj:getMaxProperty(PROPERTY_MP)
        local addHp, addMp = 0, 0
        local fuhuo
        if proHp > 0 then
          addHp = _checkDamage(proHp * objMaxHp)
          objHp = math.min(objHp + addHp, objMaxHp)
          effObj:setProperty(PROPERTY_HP, objHp)
          if effObj:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD then
            effObj:setProperty(PROPERTY_DEAD, ROLESTATE_LIVE)
            fuhuo = 1
          end
        end
        if proMp > 0 then
          addMp = _checkDamage(proMp * objMaxMp)
          objMp = math.min(objMp + addMp, objMaxMp)
          effObj:setProperty(PROPERTY_MP, objMp)
        end
        _formatAndSendInstantAddHpMpSeq(warId, effPos, objHp, objMp, addHp, addMp, petSkillId, pos, fuhuo, nil, SUBSEQTYPE_PETENTER)
      end
    end
  end
  if isPvpWar and param.sf ~= 1 then
    local masterPos = _getMasterPosByPetPos(pos)
    local masterObj = _getFightRoleObjByPos(warId, masterPos)
    if masterObj and masterObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
      local maxDamageSel
      local enemyPetList = _getPetPosListByTeamAndTargetType(team, TARGETTYPE_ENEMYSIDE)
      for _, petPos in pairs(enemyPetList) do
        local enemyPet = _getFightRoleObjByPos(warId, petPos)
        if enemyPet and enemyPet:getType() == LOGICTYPE_PET and not _checkRoleIsInState(enemyPet, EFFECTTYPE_FROZEN) and not _checkRoleIsInState(enemyPet, EFFECTTYPE_STEALTH) then
          local pro, damage, petSkillId = enemyPet:GetPetSkillRenLaiFeng()
          if _canAffectOnPro(pro) then
            local wxCoeff = _getWuXingKeZhiXiuZheng(enemyPet, masterObj, WUXING_CHONGWU)
            damage = _checkDamage(damage * (1 + wxCoeff))
            if maxDamageSel == nil or damage > maxDamageSel[1] then
              maxDamageSel = {
                damage,
                petSkillId,
                petPos
              }
            end
          end
        end
      end
      if maxDamageSel ~= nil then
        local damageSel, petSkillIdSel, petPosSel = maxDamageSel[1], maxDamageSel[2], maxDamageSel[3]
        local objHp = masterObj:getProperty(PROPERTY_HP)
        local objMp = masterObj:getProperty(PROPERTY_MP)
        if not _RoleIsDamgeImmunity(masterObj) then
          local effList = {}
          objHp = objHp - damageSel
          local maxHpMpChanged = false
          if objHp <= 0 then
            objHp = 0
            objHp, maxHpMpChanged = _setRoleIsDeadInWar(warId, warRound, masterPos, masterObj, effList)
          end
          masterObj:setProperty(PROPERTY_HP, objHp)
          if maxHpMpChanged == true then
            local objMaxHp = masterObj:getMaxProperty(PROPERTY_HP)
            local objMaxMp = masterObj:getMaxProperty(PROPERTY_MP)
            _formatAndSendInstantDamageHpMpSeq(warId, masterPos, objHp, objMp, damageSel, 0, petSkillIdSel, petPosSel, effList, SUBSEQTYPE_PETENTER, objMaxHp, objMaxMp)
          else
            _formatAndSendInstantDamageHpMpSeq(warId, masterPos, objHp, objMp, damageSel, 0, petSkillIdSel, petPosSel, effList, SUBSEQTYPE_PETENTER)
          end
        else
          _formatAndSendInstantDamageHpMpSeq(warId, masterPos, objHp, objMp, 0, 0, petSkillIdSel, petPosSel, {EFFECTTYPE_IMMUNITY_DAMAGE}, SUBSEQTYPE_PETENTER)
        end
      end
    end
  end
  local rhtyRound, effSkillId, rhtySkillId = newObj:GetPetSkillRuHuTianYi()
  if rhtyRound > 0 then
    local formatFightSeq = {
      seqType = SEQTYPE_ADDBUFF,
      userPos = pos,
      pskill = rhtySkillId,
      tInfo = {}
    }
    local targetInfo = formatFightSeq.tInfo
    local masterPos = _getMasterPosByPetPos(pos)
    local ssv = newObj:getProperty(PROPERTY_STARSKILLVALUE)
    local wlKang, xzKang, rzKang = _computeSkillEffect_Pan(effSkillId, 1, ssv)
    if param.sf == 1 then
      rhtyRound = rhtyRound + 1
    end
    for _, effPos in pairs({pos, masterPos}) do
      local effObj = _getFightRoleObjByPos(warId, effPos)
      if effObj and effObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and _canSkillOnRole_Pan(effObj) then
        _setTargetTempKangPro(effObj, SKILLATTR_WULI, wlKang, EFFECTTYPE_RUHUTIANYI)
        _setTargetTempKangPro(effObj, SKILLATTR_POISON, rzKang, EFFECTTYPE_RUHUTIANYI)
        _setTargetTempKangPro(effObj, SKILLATTR_SLEEP, rzKang, EFFECTTYPE_RUHUTIANYI)
        _setTargetTempKangPro(effObj, SKILLATTR_CONFUSE, rzKang, EFFECTTYPE_RUHUTIANYI)
        _setTargetTempKangPro(effObj, SKILLATTR_ICE, rzKang, EFFECTTYPE_RUHUTIANYI)
        _setTargetTempKangPro(effObj, SKILLATTR_FIRE, xzKang, EFFECTTYPE_RUHUTIANYI)
        _setTargetTempKangPro(effObj, SKILLATTR_WIND, xzKang, EFFECTTYPE_RUHUTIANYI)
        _setTargetTempKangPro(effObj, SKILLATTR_THUNDER, xzKang, EFFECTTYPE_RUHUTIANYI)
        _setTargetTempKangPro(effObj, SKILLATTR_WATER, xzKang, EFFECTTYPE_RUHUTIANYI)
        _addEffectOnTarget(effObj, EFFECTTYPE_RUHUTIANYI, rhtyRound)
        targetInfo[#targetInfo + 1] = {
          effPos = effPos,
          effID = EFFECTTYPE_RUHUTIANYI,
          effSkill = effSkillId
        }
      end
    end
    if #targetInfo > 0 then
      _onNewFormatFightSequence(warId, formatFightSeq)
    end
  end
  local dtbhSkill = newObj:GetPetSkillDangTouBangHe()
  if param.sf ~= 1 and dtbhSkill ~= 0 and dtbhSkill ~= nil then
    local pairs = pairs
    local tempSkillId = dtbhSkill
    local allFightSeq = {}
    local posList = _getPetPosListByTeamAndTargetType(team, TARGETTYPE_MYSIDE)
    for _, rolePos in pairs(posList) do
      local petObj = _getFightRoleObjByPos(warId, rolePos)
      if petObj and petObj:getType() == LOGICTYPE_PET and petObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
        local currAllEffectList = petObj:getEffects()
        local objEffectList = {}
        for eID, eInfo in pairs(currAllEffectList) do
          if EFFECTBUFF_DANGTOUBANGHE_CLEAR[eID] ~= nil then
            local eOffID = _getEffectOffID(eID)
            local eData = eInfo[3]
            if eOffID ~= nil then
              _checkDurativeEffectOnRole_Off(warId, rolePos, petObj, eID, eOffID, eData)
              objEffectList[#objEffectList + 1] = eOffID
            end
          end
        end
        if #objEffectList > 0 then
          local seq = {
            seqType = SEQTYPE_EFFECT_OFF,
            objPos = rolePos,
            effectList = objEffectList,
            petPos = pos,
            pSkill = dtbhSkill,
            skill = tempSkillId
          }
          if dtbhSkill ~= nil then
            _checkIsThieveSkill(newObj, dtbhSkill)
          end
          dtbhSkill = nil
          allFightSeq[#allFightSeq + 1] = seq
        end
      end
    end
    if #allFightSeq > 0 then
      for index, seq in ipairs(allFightSeq) do
        if index >= #allFightSeq then
          seq.stype = SUBSEQTYPE_ENDDELAY_1S
        else
          seq.stype = SUBSEQTYPE_NO_DELAY
        end
        _onNewFormatFightSequence(warId, seq)
      end
    end
  end
  local thyxSkill = newObj:GetPetSkillTanHuaYiXian()
  if param.sf ~= 1 and thyxSkill ~= nil and thyxSkill ~= 0 then
    local posList = _getPosListByPosAndTeamWithSpeedSorted(warId, team, TARGETTYPE_MYSIDE)
    for _, rolePos in pairs(posList) do
      local petObj = _getFightRoleObjByPos(warId, rolePos)
      if petObj and petObj:getType() == LOGICTYPE_PET and petObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
        local currAllEffectList = petObj:getEffects()
        local objEffectList = {}
        for eID, eInfo in pairs(currAllEffectList) do
          if EFFECTBUFF_DANGTOUBANGHE_CLEAR[eID] ~= nil then
            local eOffID = _getEffectOffID(eID)
            local eData = eInfo[3]
            if eOffID ~= nil then
              _checkDurativeEffectOnRole_Off(warId, rolePos, petObj, eID, eOffID, eData)
              objEffectList[#objEffectList + 1] = eOffID
            end
          end
        end
        if #objEffectList > 0 then
          local seq = {
            seqType = SEQTYPE_EFFECT_OFF,
            objPos = rolePos,
            effectList = objEffectList,
            petPos = pos,
            pSkill = thyxSkill,
            skill = thyxSkill,
            stype = SUBSEQTYPE_ENDDELAY_1S
          }
          _onNewFormatFightSequence(warId, seq)
          break
        end
      end
    end
  end
  _checkInitPetSkill_YingJiChangKong(warId, warRound, newObj, false)
  local hp, _ = newObj:GetPetSkillJiRenTianXiang()
  if hp > 0 then
    newObj:setTempProperty(PROPERTY_JIRENTIANXIANG, hp)
  end
  local _, _, startRound = _computePetSkill_JueJingFengSheng()
  _setPetSkillCDRound(newObj, PETSKILL_JUEJINGFENGSHENG, startRound)
  local _, _, _, startRound = _computePetSkill_TieShuKaiHua()
  _setPetSkillCDRound(newObj, PETSKILL_TIESHUKAIHUA, startRound)
  local startRound = _computePetSkill_ChunHuiDaDi()
  _setPetSkillCDRound(newObj, PETSKILL_CHUNHUIDADI, startRound)
  local _, startRound = _computePetSkill_HuiChunMiaoShou()
  _setPetSkillCDRound(newObj, PETSKILL_HUICHUNMIAOSHOU, startRound)
end
function _checkInitPetSkill_YingJiChangKong(warId, warRound, petObj, reset)
  local round, targetNum, coeff, llRequire, petSkillId = petObj:GetPetSkillYingJiChangKong()
  if targetNum > 0 and coeff > 0 then
    if reset then
      round = round + 1
    end
    petObj:setTempProperty(PROPERTY_YINGJICHANGKONG, {
      warRound + round,
      targetNum,
      coeff,
      llRequire,
      petSkillId
    })
  end
end
function _checkWhenPetLeave(warId, pos, leavePetObj)
  if leavePetObj == nil or leavePetObj:getType() ~= LOGICTYPE_PET then
    return
  end
  local warType = _getTheWarType(warId)
  local isPvpWar = IsPVPWarType(warType)
  local team = leavePetObj:getProperty(PROPERTY_TEAM)
  local ceoff, petSkillId = leavePetObj:GetPetSkillYiChan()
  if ceoff > 0 then
    local leaveMp = leavePetObj:getProperty(PROPERTY_MP)
    if leaveMp > 0 then
      local posList = _getPosListByTeamAndTargetType(team, TARGETTYPE_MYSIDE)
      local posMin
      for _, rolePos in pairs(posList) do
        if pos ~= rolePos then
          local posObj = _getFightRoleObjByPos_WithDeadHero(warId, rolePos)
          if posObj and posObj:getType() == LOGICTYPE_HERO then
            local posObjMp = posObj:getProperty(PROPERTY_MP)
            local posObjMaxMp = posObj:getMaxProperty(PROPERTY_MP)
            if posObjMaxMp > 0 and posObjMp < posObjMaxMp then
              if posMin == nil then
                posMin = {
                  rolePos,
                  posObj,
                  posObjMp
                }
              elseif posObjMp < posMin[3] then
                posMin = {
                  rolePos,
                  posObj,
                  posObjMp
                }
              end
            end
          end
        end
      end
      if posMin ~= nil then
        local effPos, effObj = posMin[1], posMin[2]
        local objHp = effObj:getProperty(PROPERTY_HP)
        local objMp = effObj:getProperty(PROPERTY_MP)
        local objMaxMp = effObj:getMaxProperty(PROPERTY_MP)
        local addMp = leaveMp * ceoff
        objMp = math.min(objMp + addMp, objMaxMp)
        effObj:setProperty(PROPERTY_MP, objMp)
        _formatAndSendInstantAddHpMpSeq(warId, effPos, objHp, objMp, 0, addMp, petSkillId, pos, nil, nil, SUBSEQTYPE_ENDDELAY_1S, nil, pos)
      end
    end
  end
  local jsSkill = leavePetObj:GetPetSkillJiangSi()
  if jsSkill ~= 0 and jsSkill ~= nil then
    local pairs = pairs
    local posList = _getPetPosListByTeamAndTargetType(team, TARGETTYPE_MYSIDE)
    local jsSeqList = {}
    local skillId = jsSkill
    for _, rolePos in pairs(posList) do
      local petObj = _getFightRoleObjByPos(warId, rolePos)
      if petObj and petObj:getType() == LOGICTYPE_PET and petObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
        local currAllEffectList = petObj:getEffects()
        local objEffectList = {}
        for eID, eInfo in pairs(currAllEffectList) do
          if EFFECTBUFF_JIANGSI_CLEAR[eID] ~= nil then
            local eOffID = _getEffectOffID(eID)
            local eData = eInfo[3]
            if eOffID ~= nil then
              _checkDurativeEffectOnRole_Off(warId, rolePos, petObj, eID, eOffID, eData)
              objEffectList[#objEffectList + 1] = eOffID
            end
          end
        end
        if #objEffectList > 0 then
          local seq = {
            seqType = SEQTYPE_EFFECT_OFF,
            objPos = rolePos,
            effectList = objEffectList,
            petPos = pos,
            pSkill = jsSkill,
            skill = skillId
          }
          if jsSkill ~= nil then
            _checkIsThieveSkill(leavePetObj, jsSkill)
          end
          jsSkill = nil
          jsSeqList[#jsSeqList + 1] = seq
        end
      end
    end
    if #jsSeqList > 0 then
      for index, seq in ipairs(jsSeqList) do
        if index >= #jsSeqList then
          seq.stype = SUBSEQTYPE_ENDDELAY_1S
        else
          seq.stype = SUBSEQTYPE_NO_DELAY
        end
        _onNewFormatFightSequence(warId, seq)
      end
    end
  end
  if isPvpWar then
    local mcqhSkill = leavePetObj:GetPetSkillMingChaQiuHao()
    if mcqhSkill then
      _checkIsThieveSkill(leavePetObj, mcqhSkill)
      local showFlag = false
      local petPosList = _getPetPosListByTeamAndTargetType(team, TARGETTYPE_MYSIDE)
      for _, petPos in pairs(petPosList) do
        if petPos ~= pos then
          local petObj = _getFightRoleObjByPos(warId, petPos)
          if petObj and petObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and petObj:getType() == LOGICTYPE_PET and petObj:GetPetSkillMingChaQiuHao() then
            showFlag = true
            break
          end
        end
      end
      if not showFlag then
        _formatAndSendShowHpMpFlag(warId, team, 0)
      end
    end
  end
  if isPvpWar then
    local pro, ssqySkill = leavePetObj:GetPetShunShouQianYang()
    if pro > 0 and _canAffectOnPro(pro) then
      local samePetList = {}
      local userType = leavePetObj:getTypeId()
      local petPosList = _getPetPosListByTeamAndTargetType(team, TARGETTYPE_ENEMYSIDE)
      for _, petPos in pairs(petPosList) do
        if petPos ~= pos then
          local petObj = _getFightRoleObjByPos(warId, petPos)
          if petObj and petObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and petObj:getType() == LOGICTYPE_PET and not _checkRoleIsInState(petObj, EFFECTTYPE_FROZEN) and not _checkRoleIsInState(petObj, EFFECTTYPE_STEALTH) and petObj:getTypeId() == userType then
            samePetList[#samePetList + 1] = {petPos, petObj}
          end
        end
      end
      if #samePetList > 0 then
        local d = samePetList[math.random(1, #samePetList)]
        local petPos, petObj = d[1], d[2]
        _formatAndSendTakeAwayeq(warId, pos, ssqySkill, petPos)
        petObj:setProperty(PROPERTY_HP, 0)
        petObj:setProperty(PROPERTY_DEAD, ROLESTATE_DEAD)
      end
    end
  end
  local dzqkSkill = leavePetObj:GetPetSkillDaoZhuanQianKun()
  if dzqkSkill ~= nil and dzqkSkill ~= 0 then
    local posList = _getPosListByPosAndTeamWithSpeedSorted(warId, team, TARGETTYPE_MYSIDE)
    for _, rolePos in pairs(posList) do
      local petObj = _getFightRoleObjByPos(warId, rolePos)
      if petObj and petObj:getType() == LOGICTYPE_PET and petObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
        local currAllEffectList = petObj:getEffects()
        local objEffectList = {}
        for eID, eInfo in pairs(currAllEffectList) do
          if EFFECTBUFF_JIANGSI_CLEAR[eID] ~= nil then
            local eOffID = _getEffectOffID(eID)
            local eData = eInfo[3]
            if eOffID ~= nil then
              _checkDurativeEffectOnRole_Off(warId, rolePos, petObj, eID, eOffID, eData)
              objEffectList[#objEffectList + 1] = eOffID
            end
          end
        end
        if #objEffectList > 0 then
          local seq = {
            seqType = SEQTYPE_EFFECT_OFF,
            objPos = rolePos,
            effectList = objEffectList,
            petPos = pos,
            pSkill = dzqkSkill,
            skill = dzqkSkill,
            stype = SUBSEQTYPE_ENDDELAY_1S
          }
          _onNewFormatFightSequence(warId, seq)
          break
        end
      end
    end
  end
  if 0 < leavePetObj:getProficiency(SKILL_SHOUHUCANGSHENG) then
    local pairs = pairs
    local team = leavePetObj:getProperty(PROPERTY_TEAM)
    local posList = _getPosListByTeamAndTargetType(team, TARGETTYPE_MYSIDE)
    for _, effPos in pairs(posList) do
      if effPos ~= pos then
        local effObj = _getFightRoleObjByPos(warId, effPos)
        if effObj and effObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
          local effData = _getRoleEffectData(effObj, EFFECTTYPE_SHOUHUCANGSHENG)
          if effData ~= nil and effData.pos == pos then
            local eHp = effObj:getProperty(PROPERTY_HP)
            local eMp = effObj:getProperty(PROPERTY_MP)
            _clearEffectOnTarget(effObj, EFFECTTYPE_SHOUHUCANGSHENG)
            local fFightSeq = {
              seqType = SEQTYPE_EFFECT_OFF,
              objPos = effPos,
              effectList = {EFFECTTYPE_SHOUHUCANGSHENG_OFF}
            }
            _onNewFormatFightSequence(warId, fFightSeq)
          end
        end
      end
    end
  end
end
function _checkReliveWhenRoleIsDead(warId, pos, roleObj)
  if roleObj == nil or roleObj:getProperty(PROPERTY_DEAD) ~= ROLESTATE_DEAD then
    return
  end
  local reliveTimes = roleObj:getTempProperty(PROPERTY_RELIVETIMES) or 0
  if reliveTimes > 0 then
    local npPro, npSkill = roleObj:GetPetSkillNiePan()
    if _canAffectOnPro(npPro) and not _checkRoleIsInState(roleObj, EFFECTTYPE_DUOHUNSUOMING) then
      roleObj:setTempProperty(PROPERTY_RELIVETIMES, reliveTimes - 1)
      local maxHp = roleObj:getMaxProperty(PROPERTY_HP)
      local maxMp = roleObj:getMaxProperty(PROPERTY_MP)
      roleObj:setProperty(PROPERTY_HP, maxHp)
      roleObj:setProperty(PROPERTY_MP, maxMp)
      roleObj:setProperty(PROPERTY_DEAD, ROLESTATE_LIVE)
      _formatAndSendReliveSequence(warId, pos, maxHp, maxMp, maxHp, maxMp, npSkill)
    end
  end
end
function _checkWhenRoleIsDead(warId, pos, roleObj)
  if roleObj == nil or roleObj:getProperty(PROPERTY_DEAD) ~= ROLESTATE_DEAD then
    return
  end
  if roleObj:getType() == LOGICTYPE_PET then
    local pairs = pairs
    local team = roleObj:getProperty(PROPERTY_TEAM)
    local petPosList = _getPosListByTeamAndTargetType(team, TARGETTYPE_MYSIDE)
    for _, petPos in pairs(petPosList) do
      if petPos ~= pos then
        local pObj = _getFightRoleObjByPos(warId, petPos)
        if pObj and pObj:getType() == LOGICTYPE_PET and pObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
          local kangAdd, skillId = pObj:GetPetSkillLiuAnHuaMing()
          if kangAdd > 0 then
            for _, skillAttr in pairs({
              SKILLATTR_ICE,
              SKILLATTR_SLEEP,
              SKILLATTR_CONFUSE,
              SKILLATTR_YIWANG
            }) do
              local kangCur = _getTargetTempKangProOfEffect(pObj, skillAttr, EFFECTTYPE_LIUANHUAMING)
              kangCur = math.min(kangCur + kangAdd, 0.2)
              _setTargetTempKangPro(pObj, skillAttr, kangCur, EFFECTTYPE_LIUANHUAMING)
            end
          end
          local kangAdd, skillId = pObj:GetPetSkillFuLuShuangQuan()
          if kangAdd > 0 then
            for _, skillAttr in pairs({
              SKILLATTR_FIRE,
              SKILLATTR_WIND,
              SKILLATTR_THUNDER,
              SKILLATTR_WATER
            }) do
              local kangCur = _getTargetTempKangProOfEffect(pObj, skillAttr, EFFECTTYPE_FULUSHUANGQUAN)
              kangCur = math.min(kangCur + kangAdd, 0.2)
              _setTargetTempKangPro(pObj, skillAttr, kangCur, EFFECTTYPE_FULUSHUANGQUAN)
            end
          end
        end
      end
    end
  end
end
function _useSkillOnTarget(warId, warRound, userPos, selectPos, skillID, exPara)
  local userObj = _getFightRoleObjByPos(warId, userPos)
  if userObj and _checkSkillIsYiWang(userObj, skillID) then
    _formatAndSendWordTipSequence(warId, userObj:getPlayerId(), SUBSEQTYPE_YIWANGSKILL, skillID, userPos)
    return
  end
  if skillID == SKILLTYPE_NORMALATTACK then
    return _normalAttackOnTarget(warId, warRound, userPos, selectPos)
  elseif skillID == SKILLTYPE_BABYMONSTER or skillID == SKILLTYPE_BABYPET then
    return
  elseif skillID == SKILLTYPE_DEFEND then
    return _defendOnTarget(warId, userPos, 1)
  elseif skillID == SKILLTYPE_RUNAWAY then
    return _escapeWar(warId, userPos, exPara)
  else
    local logicType = GetObjType(skillID)
    if logicType == LOGICTYPE_NEIDANSKILL then
      return _useNeiDanSkillOnTarget(warId, warRound, userPos, selectPos, skillID)
    elseif logicType == LOGICTYPE_PETSKILL then
      return _usePetSkillOnTarget(warId, warRound, userPos, selectPos, skillID)
    elseif logicType == LOGICTYPE_MARRYSKILL then
      return _useMarrySkillOnTarget(warId, warRound, userPos, selectPos, skillID)
    elseif skillID == SKILL_SHOUHUCANGSHENG then
      return _usePetSkillOnTarget(warId, warRound, userPos, selectPos, skillID)
    elseif skillID == SKILL_YIHUAJIEYU then
      return _usePetSkillOnTarget(warId, warRound, userPos, selectPos, skillID)
    else
      return _useNormalSkillOnTarget(warId, warRound, userPos, selectPos, skillID)
    end
  end
end
function _ExecNormalAttackWhenSkill(warId, userPos, userObj, skillID)
  _formatAndSendWordTipSequence(warId, userObj:getPlayerId(), SUBSEQTYPE_EXECNORMALATTACK, skillID, userPos)
end
function _SkillFormatAndSendTipSequence(warId, userPos, userObj, skillID, tipsID)
  _formatAndSendWordTipSequence(warId, userObj:getPlayerId(), tipsID, skillID, userPos)
end
function _LackManaWhenSkill(warId, userPos, userObj, skillID)
  if userObj:getType() == LOGICTYPE_HERO then
    _formatAndSendWordTipSequence(warId, userObj:getPlayerId(), SUBSEQTYPE_LACKMANA, skillID, userPos)
  elseif userObj:getType() == LOGICTYPE_PET then
    _formatAndSendWordTipSequence(warId, userObj:getPlayerId(), SUBSEQTYPE_PETLACKMANA, skillID, userPos)
  end
  _formatTipSequence(warId, userPos, SKILLTIP_LACKMANA_WHENSKILL)
end
function _LackHpWhenSkill(warId, userPos, userObj, skillID)
  if userObj:getType() == LOGICTYPE_HERO then
    _formatAndSendWordTipSequence(warId, userObj:getPlayerId(), SUBSEQTYPE_LACKHP, skillID, userPos)
  elseif userObj:getType() == LOGICTYPE_PET then
    _formatAndSendWordTipSequence(warId, userObj:getPlayerId(), SUBSEQTYPE_PETLACKHP, skillID, userPos)
  end
  _formatTipSequence(warId, userPos, SKILLTIP_LACKHP_WHENSKILL)
end
function _NoTargetWhenSkill(warId, userPos, userObj, skillID)
  if userObj:getType() == LOGICTYPE_HERO then
    _formatAndSendWordTipSequence(warId, userObj:getPlayerId(), SUBSEQTYPE_NOTARGET, skillID, userPos)
  elseif userObj:getType() == LOGICTYPE_PET then
    _formatAndSendWordTipSequence(warId, userObj:getPlayerId(), SUBSEQTYPE_NOTARGET, skillID, userPos)
  end
end
function _LackGenGuWhenSkill(warId, userPos, userObj, skillID)
  if userObj:getType() == LOGICTYPE_HERO then
    _formatAndSendWordTipSequence(warId, userObj:getPlayerId(), SUBSEQTYPE_LACKGENGU, skillID, userPos)
  elseif userObj:getType() == LOGICTYPE_PET then
    _formatAndSendWordTipSequence(warId, userObj:getPlayerId(), SUBSEQTYPE_PETLACKGENGU, skillID, userPos)
  end
  _formatTipSequence(warId, userPos, SKILLTIP_LACKGG_WHENSKILL)
end
function _LackLingXingWhenSkill(warId, userPos, userObj, skillID)
  if userObj:getType() == LOGICTYPE_HERO then
    _formatAndSendWordTipSequence(warId, userObj:getPlayerId(), SUBSEQTYPE_LACKLINGXING, skillID, userPos)
  elseif userObj:getType() == LOGICTYPE_PET then
    _formatAndSendWordTipSequence(warId, userObj:getPlayerId(), SUBSEQTYPE_PETLACKLINGXING, skillID, userPos)
  end
  _formatTipSequence(warId, userPos, SKILLTIP_LACKLX_WHENSKILL)
end
function _LackMinJieWhenSkill(warId, userPos, userObj, skillID)
  if userObj:getType() == LOGICTYPE_HERO then
    _formatAndSendWordTipSequence(warId, userObj:getPlayerId(), SUBSEQTYPE_LACKMINJIE, skillID, userPos)
  elseif userObj:getType() == LOGICTYPE_PET then
    _formatAndSendWordTipSequence(warId, userObj:getPlayerId(), SUBSEQTYPE_PETLACKMINJIE, skillID, userPos)
  end
  _formatTipSequence(warId, userPos, SKILLTIP_LACKMJ_WHENSKILL)
end
function _LackLiLiangWhenSkill(warId, userPos, userObj, skillID)
  if userObj:getType() == LOGICTYPE_HERO then
    _formatAndSendWordTipSequence(warId, userObj:getPlayerId(), SUBSEQTYPE_LACKLILIANG, skillID, userPos)
  elseif userObj:getType() == LOGICTYPE_PET then
    _formatAndSendWordTipSequence(warId, userObj:getPlayerId(), SUBSEQTYPE_PETLACKLILIANG, skillID, userPos)
  end
  _formatTipSequence(warId, userPos, SKILLTIP_LACKLL_WHENSKILL)
end
function _LackWuXingJinWhenSkill(warId, userPos, userObj, skillID)
  if userObj:getType() == LOGICTYPE_HERO then
    _formatAndSendWordTipSequence(warId, userObj:getPlayerId(), SUBSEQTYPE_LACK_WXJIN, skillID, userPos)
  elseif userObj:getType() == LOGICTYPE_PET then
    _formatAndSendWordTipSequence(warId, userObj:getPlayerId(), SUBSEQTYPE_PETLACK_WXJIN, skillID, userPos)
  end
  _formatTipSequence(warId, userPos, SKILLTIP_LACKWXJIN_WHENSKILL)
end
function _LackWuXingMuWhenSkill(warId, userPos, userObj, skillID)
  if userObj:getType() == LOGICTYPE_HERO then
    _formatAndSendWordTipSequence(warId, userObj:getPlayerId(), SUBSEQTYPE_LACK_WXMU, skillID, userPos)
  elseif userObj:getType() == LOGICTYPE_PET then
    _formatAndSendWordTipSequence(warId, userObj:getPlayerId(), SUBSEQTYPE_PETLACK_WXMU, skillID, userPos)
  end
  _formatTipSequence(warId, userPos, SKILLTIP_LACKWXMU_WHENSKILL)
end
function _LackWuXingShuiWhenSkill(warId, userPos, userObj, skillID)
  if userObj:getType() == LOGICTYPE_HERO then
    _formatAndSendWordTipSequence(warId, userObj:getPlayerId(), SUBSEQTYPE_LACK_WXSHUI, skillID, userPos)
  elseif userObj:getType() == LOGICTYPE_PET then
    _formatAndSendWordTipSequence(warId, userObj:getPlayerId(), SUBSEQTYPE_PETLACK_WXSHUI, skillID, userPos)
  end
  _formatTipSequence(warId, userPos, SKILLTIP_LACKWXSHUI_WHENSKILL)
end
function _LackWuXingHuoWhenSkill(warId, userPos, userObj, skillID)
  if userObj:getType() == LOGICTYPE_HERO then
    _formatAndSendWordTipSequence(warId, userObj:getPlayerId(), SUBSEQTYPE_LACK_WXHUO, skillID, userPos)
  elseif userObj:getType() == LOGICTYPE_PET then
    _formatAndSendWordTipSequence(warId, userObj:getPlayerId(), SUBSEQTYPE_PETLACK_WXHUO, skillID, userPos)
  end
  _formatTipSequence(warId, userPos, SKILLTIP_LACKWXHUO_WHENSKILL)
end
function _LackWuXingTuWhenSkill(warId, userPos, userObj, skillID)
  if userObj:getType() == LOGICTYPE_HERO then
    _formatAndSendWordTipSequence(warId, userObj:getPlayerId(), SUBSEQTYPE_LACK_WXTU, skillID, userPos)
  elseif userObj:getType() == LOGICTYPE_PET then
    _formatAndSendWordTipSequence(warId, userObj:getPlayerId(), SUBSEQTYPE_PETLACK_WXTU, skillID, userPos)
  end
  _formatTipSequence(warId, userPos, SKILLTIP_LACKWXTU_WHENSKILL)
end
function _LackHuoLiWhenSkill(warId, userPos, playerId, skillID)
  _formatAndSendWordTipSequence(warId, playerId, SUBSEQTYPE_LACKHUOLI, skillID, userPos)
  _formatTipSequence(warId, userPos, SKILLTIP_LACKLL_HUOLI)
end
function _LackPetNumWhenSkill(warId, userPos, playerId, skillID)
  _formatAndSendWordTipSequence(warId, playerId, SUBSEQTYPE_LACKPETNUM, skillID, userPos)
end
function _SkillIsCDWhenSkill(warId, userPos, userObj, skillID)
  _formatAndSendWordTipSequence(warId, userObj:getPlayerId(), SUBSEQTYPE_CDWHENSKILL, skillID, userPos)
end
function _OnceSkillHaveUsedWhenSkill(warId, userPos, userObj, skillID)
  _formatAndSendWordTipSequence(warId, userObj:getPlayerId(), SUBSEQTYPE_ONCESKILLHAVEUSED, skillID, userPos)
end
function _CanNotUseWhenSkillInCurRound(warId, userPos, userObj, skillID)
  _formatAndSendWordTipSequence(warId, userObj:getPlayerId(), SUBSEQTYPE_CANNNOTUSECURROUND, skillID, userPos)
end
function _setTipsCanNotUseYiWangSkill(warId, userPos, userObj, skillID)
  _formatAndSendWordTipSequence(warId, userObj:getPlayerId(), SUBSEQTYPE_YIWANGSKILL, skillID, userPos)
end
function _setTipsCanNotUseSkillOnDeadRole(warId, userPos, userObj, skillID)
  _formatAndSendWordTipSequence(warId, userObj:getPlayerId(), SUBSEQTYPE_TARGETISDEAD, skillID, userPos)
end
function _setTipsCanNotUseSkillInAutoState(warId, userPos, userObj, skillID)
  _formatAndSendWordTipSequence(warId, userObj:getPlayerId(), SUBSEQTYPE_CANNOTAUTOSKILL, skillID, userPos)
end
function _CanNotUseWhenSkillInPVE(warId, userPos, userObj, skillID)
  _formatAndSendWordTipSequence(warId, userObj:getPlayerId(), SUBSEQTYPE_CANNNOTUSEPVE, skillID, userPos)
end
function _checkCancelStealth(warId, userPos, userObj)
  if userObj and _checkRoleIsInState(userObj, EFFECTTYPE_STEALTH) then
    _checkDurativeEffectOnRole_Off(warId, userPos, userObj, EFFECTTYPE_STEALTH, EFFECTTYPE_STEALTH_OFF)
    _formatAndSendCancelStealthSeq(warId, userPos)
  end
end
function _checkIsThieveSkill(userObj, skillId)
  if userObj and userObj:checkIsThieveSkill(skillId) then
    userObj:resetThieveSkill(skillId)
  end
end
local _addHpSortFunc = function(a, b)
  if a == nil or b == nil then
    return false
  end
  return b < a
end
local _roleHpSortFunc = function(a, b)
  if a == nil or b == nil then
    return false
  end
  local obj_a = a[1]
  local obj_b = b[1]
  local hp_a = obj_a:getProperty(PROPERTY_HP)
  local hp_b = obj_b:getProperty(PROPERTY_HP)
  local maxhp_a = math.max(obj_a:getMaxProperty(PROPERTY_HP), 1)
  local maxhp_b = math.max(obj_b:getMaxProperty(PROPERTY_HP), 1)
  local pro_a = hp_a / maxhp_a
  local pro_b = hp_b / maxhp_b
  if pro_a ~= pro_b then
    return pro_a < pro_b
  else
    local spIdx_a = obj_a.__speedIdx
    local spIdx_b = obj_b.__speedIdx
    if spIdx_a ~= spIdx_b then
      return spIdx_a < spIdx_b
    else
      local id_a = obj_a:getObjId()
      local id_b = obj_b:getObjId()
      return id_a < id_b
    end
  end
end
function _useNormalSkillOnTarget(warId, warRound, userPos, selectPos, skillID, callback)
  local skillData = _getSkillData(skillID)
  if skillData == nil then
    print_SkillLog_SkillDataError(warId, userPos, selectPos, skillID)
    _callBack(callback)
    return
  end
  local userObj = _getFightRoleObjByPos(warId, userPos)
  if userObj == nil then
    print_SkillLog_RoleIsNotExist(warId, userPos)
    _callBack(callback)
    return
  end
  print_SkillLog_UseSkill(warId, userPos, selectPos, skillData.name)
  local userHp = userObj:getProperty(PROPERTY_HP)
  local userMp = userObj:getProperty(PROPERTY_MP)
  local skillExp = userObj:getProficiency(skillID)
  local team = userObj:getProperty(PROPERTY_TEAM)
  local mainTargetObj = _getFightRoleObjByPos_WithDeadHero(warId, selectPos)
  if mainTargetObj == nil then
    return
  end
  local selectTeam = mainTargetObj:getProperty(PROPERTY_TEAM)
  local targetPosList = _getSkillAllTargets(warId, userPos, userObj, skillID, skillExp, skillData, selectPos, selectTeam)
  if targetPosList == nil or #targetPosList <= 0 then
    print_SkillLog_NoRightTarget(warId, userPos, selectPos)
    _callBack(callback)
    return
  end
  local skillNeedMp = _getNormalSkillRequireMp(userObj, skillID, skillExp)
  if userMp < skillNeedMp then
    _LackManaWhenSkill(warId, userPos, userObj, skillID)
    print_SkillLog_LackMp(warId, userMp, skillNeedMp)
    _callBack(callback)
    return
  end
  _checkCancelStealth(warId, userPos, userObj)
  local checkFlag = _checkWhenUseSkillOfWar(warId, warRound, userPos, skillID)
  if checkFlag == false then
    return
  end
  userHp = userObj:getProperty(PROPERTY_HP)
  userMp = userObj:getProperty(PROPERTY_MP)
  if skillNeedMp > userMp then
    _LackManaWhenSkill(warId, userPos, userObj, skillID)
    print_SkillLog_LackMp(warId, userMp, skillNeedMp)
    _callBack(callback)
    return
  end
  userMp = userMp - skillNeedMp
  userObj:setProperty(PROPERTY_MP, userMp)
  local skillAttr = skillData.attr
  local canwxj = false
  local hpCoeff = 0.15
  local wxjData = {}
  local userHp_send
  if (skillAttr == SKILLATTR_POISON or skillAttr == SKILLATTR_CONFUSE or skillAttr == SKILLATTR_FIRE or skillAttr == SKILLATTR_WIND or skillAttr == SKILLATTR_THUNDER or skillAttr == SKILLATTR_WATER or skillAttr == SKILLATTR_ZHEN or skillAttr == SKILLATTR_AIHAO or skillAttr == SKILLATTR_XIXUE) and userHp * hpCoeff >= 1 then
    local wxjFlag = false
    if 0 < userObj:getProperty(PROPERTY_WINE_KE_WXJIN) then
      wxjData.wxj_jin = userObj:getProperty(PROPERTY_WINE_KE_WXJIN)
      wxjFlag = true
    end
    if 0 < userObj:getProperty(PROPERTY_WINE_KE_WXMU) then
      wxjData.wxj_mu = userObj:getProperty(PROPERTY_WINE_KE_WXMU)
      wxjFlag = true
    end
    if 0 < userObj:getProperty(PROPERTY_WINE_KE_WXTU) then
      wxjData.wxj_tu = userObj:getProperty(PROPERTY_WINE_KE_WXTU)
      wxjFlag = true
    end
    if 0 < userObj:getProperty(PROPERTY_WINE_KE_WXSHUI) then
      wxjData.wxj_shui = userObj:getProperty(PROPERTY_WINE_KE_WXSHUI)
      wxjFlag = true
    end
    if 0 < userObj:getProperty(PROPERTY_WINE_KE_WXHUO) then
      wxjData.wxj_huo = userObj:getProperty(PROPERTY_WINE_KE_WXHUO)
      wxjFlag = true
    end
    if wxjFlag == true then
      local lostHp = math.floor(userHp * hpCoeff)
      userHp = math.max(userHp - lostHp, 1)
      userObj:setProperty(PROPERTY_HP, userHp)
      userHp_send = userHp
    end
  end
  local formatFightSeq = {
    seqType = SEQTYPE_USESKILL,
    userPos = userPos,
    targetInfo = {}
  }
  local tInfo = formatFightSeq.targetInfo
  local performType = _getSkillPerformType(skillID)
  local fkAttr = _getTotalFKangPro(userObj, skillAttr)
  local qh_ExtraCoeff = _getNormalSkill_ExtraDamageCoeff(userObj, skillAttr)
  local qh_ExtraValue = _getNormalSkill_ExtraDamageValue(userObj, skillAttr)
  local skillWeakCeoff = userObj:getProperty(PROPERTY_SKILLCOEFF)
  local kb_ExtraCoeff = 0
  local kb_Flag = true
  local maxHitTimes = 1
  local dbHitTimes = 0
  local xz_extraFkAttr = 0
  local isPet = userObj:getType() == LOGICTYPE_PET
  local ndSkillId_att
  if skillAttr == SKILLATTR_FIRE or skillAttr == SKILLATTR_WIND or skillAttr == SKILLATTR_THUNDER or skillAttr == SKILLATTR_WATER then
    local tx_10_Flag = false
    kb_ExtraCoeff, tx_10_Flag = _checkXianZu_ExtraDamageCoeff(warId, userObj, skillAttr)
    if tx_10_Flag then
      formatFightSeq.txId = MONSTER_TX_10
    end
    if not isPet or kb_ExtraCoeff <= 0 then
      dbHitTimes = _checkXianZu_DoubleHit(userObj)
    end
    if not isPet or kb_ExtraCoeff <= 0 and dbHitTimes <= 0 then
      xz_extraFkAttr = _checkXianZu_ExtraFkAttr(userObj)
      fkAttr = fkAttr + xz_extraFkAttr
    end
    if isPet then
      if kb_ExtraCoeff > 0 then
        ndSkillId_att = {NDSKILL_HONGYANBAIFA}
      elseif dbHitTimes > 0 then
        ndSkillId_att = {NDSKILL_MEIHUASANNONG}
        kb_Flag = false
      elseif xz_extraFkAttr > 0 then
        ndSkillId_att = {NDSKILL_KAITIANPIDI}
        kb_Flag = false
      end
    end
  elseif skillAttr == SKILLATTR_AIHAO or skillAttr == SKILLATTR_XIXUE then
    kb_ExtraCoeff, _ = _checkXianZu_ExtraDamageCoeff(warId, userObj, skillAttr)
  end
  maxHitTimes = maxHitTimes + dbHitTimes
  local pairs = pairs
  for nHit = 1, maxHitTimes do
    local isFirstTarget = true
    local xixueList = {}
    local damageInfoList = {}
    for tIndex, targetPos in pairs(targetPosList) do
      local targetObj = _getFightRoleObjByPos(warId, targetPos)
      if targetObj and targetObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
        if tIndex > 1 and kb_Flag then
          kb_ExtraCoeff, _ = _checkXianZu_ExtraDamageCoeff(warId, userObj, skillAttr)
        end
        local targetHp = targetObj:getProperty(PROPERTY_HP)
        local targetMp = targetObj:getProperty(PROPERTY_MP)
        local kAttr = _getTotalKangPro(targetObj, skillAttr)
        local attEffectList = {}
        local objEffectList = {}
        local damageHp = 0
        local damageMp = 0
        local maxHpMpChanged = false
        local skillSuccess = false
        if _useSkillSuccess(userObj, skillID, kAttr, fkAttr, skillExp) then
          print_SkillLog_UseSkillSucceed(warId, userPos, targetPos, skillData.name)
          local weaken_damage = _getNormalSkill_WeakenDamage(targetObj, skillAttr)
          if skillAttr == SKILLATTR_POISON then
            if _canSkillOnRole_Poison(targetObj) then
              local pLevel = userObj:getProperty(PROPERTY_ROLELEVEL)
              local maxHp = targetObj:getMaxProperty(PROPERTY_HP)
              local ssv = userObj:getProperty(PROPERTY_STARSKILLVALUE)
              damageHp = _computeSkillDamage_Poison(skillID, kAttr, fkAttr, skillExp, 1, pLevel, maxHp, ssv, qh_ExtraCoeff, skillWeakCeoff, weaken_damage)
              local wxCoeff = _getWuXingKeZhiXiuZheng(userObj, targetObj, WUXING_RENFA, wxjData)
              damageHp = _checkDamage(damageHp * (1 + wxCoeff))
              local skillRound = _computeSkillRound(skillID, skillExp, kAttr, fkAttr)
              local effectData = {}
              effectData.skillID = skillID
              effectData.fkAttr = fkAttr
              effectData.skillExp = skillExp
              effectData.pLevel = pLevel
              effectData.ssv = ssv
              effectData.extraCoeff = qh_ExtraCoeff
              effectData.skillWeakCeoff = skillWeakCeoff
              effectData.wxCoeff = wxCoeff
              _addEffectOnTarget(targetObj, EFFECTTYPE_POISON, skillRound, effectData)
              objEffectList = {EFFECTTYPE_POISON}
              print_SkillLog_AddEffect(warId, userPos, targetPos, EFFECTTYPE_POISON, skillRound)
              skillSuccess = true
            else
              objEffectList = {EFFECTTYPE_IMMUNITY}
            end
          elseif skillAttr == SKILLATTR_SLEEP then
            if _canSkillOnRole_Sleep(targetObj) then
              local skillRound = _computeSkillRound(skillID, skillExp, kAttr, fkAttr)
              _addEffectOnTarget(targetObj, EFFECTTYPE_SLEEP, skillRound)
              objEffectList = {EFFECTTYPE_SLEEP}
              if _checkRoleIsInState(targetObj, EFFECTTYPE_CONFUSE) then
                local eOffID = _getEffectOffID(EFFECTTYPE_CONFUSE)
                if eOffID ~= nil then
                  objEffectList[#objEffectList + 1] = eOffID
                end
                _clearEffectOnTarget(targetObj, EFFECTTYPE_CONFUSE)
              end
              print_SkillLog_AddEffect(warId, userPos, targetPos, EFFECTTYPE_SLEEP, skillRound)
              skillSuccess = true
            else
              objEffectList = {EFFECTTYPE_IMMUNITY}
            end
          elseif skillAttr == SKILLATTR_CONFUSE then
            if _canSkillOnRole_Confuse(targetObj) then
              local skillRound = _computeSkillRound(skillID, skillExp, kAttr, fkAttr)
              _addEffectOnTarget(targetObj, EFFECTTYPE_CONFUSE, skillRound, CONFUSETYPE_HERO)
              objEffectList = {EFFECTTYPE_CONFUSE}
              if _checkRoleIsInState(targetObj, EFFECTTYPE_SLEEP) then
                local eOffID = _getEffectOffID(EFFECTTYPE_SLEEP)
                if eOffID ~= nil then
                  objEffectList[#objEffectList + 1] = eOffID
                end
                _clearEffectOnTarget(targetObj, EFFECTTYPE_SLEEP)
              end
              print_SkillLog_AddEffect(warId, userPos, targetPos, EFFECTTYPE_CONFUSE, skillRound)
              local pLevel = userObj:getProperty(PROPERTY_ROLELEVEL)
              local ssv = userObj:getProperty(PROPERTY_STARSKILLVALUE)
              damageHp = _computeSkillDamage_Confuse(skillID, kAttr, fkAttr, skillExp, pLevel, ssv, qh_ExtraCoeff, skillWeakCeoff, weaken_damage)
              local wxCoeff = _getWuXingKeZhiXiuZheng(userObj, targetObj, WUXING_RENFA, wxjData)
              damageHp = _checkDamage(damageHp * (1 + wxCoeff))
              skillSuccess = true
            else
              objEffectList = {EFFECTTYPE_IMMUNITY}
            end
          elseif skillAttr == SKILLATTR_ICE then
            if _canSkillOnRole_Ice(targetObj) then
              local currAllEffectList = targetObj:getEffects()
              local newEffects = {}
              for eID, eData in pairs(currAllEffectList) do
                if EFFECTBUFF_FROZEN_CLEAR[eID] ~= nil then
                  local eOffID = _getEffectOffID(eID)
                  if eOffID ~= nil then
                    maxHpMpChanged = _checkDurativeEffectOnRole_Off(warId, targetPos, targetObj, eID, eOffID, eData, false) or maxHpMpChanged
                    objEffectList[#objEffectList + 1] = eOffID
                  end
                else
                  newEffects[eID] = eData
                end
              end
              targetObj:setEffects(newEffects)
              local skillRound = _computeSkillRound(skillID, skillExp, kAttr, fkAttr)
              _addEffectOnTarget(targetObj, EFFECTTYPE_FROZEN, skillRound, FROZENTYPE_HERO)
              objEffectList[#objEffectList + 1] = EFFECTTYPE_FROZEN
              print_SkillLog_AddEffect(warId, userPos, targetPos, EFFECTTYPE_FROZEN, skillRound)
              skillSuccess = true
            else
              objEffectList = {EFFECTTYPE_IMMUNITY}
            end
          elseif skillAttr == SKILLATTR_FIRE then
            if _canSkillOnRole_Fire(targetObj) then
              local pLevel = userObj:getProperty(PROPERTY_ROLELEVEL)
              local ssv = userObj:getProperty(PROPERTY_STARSKILLVALUE)
              damageHp = _computeSkillDamage_XianZu(skillID, kAttr, fkAttr, skillExp, pLevel, ssv, qh_ExtraCoeff, skillWeakCeoff, weaken_damage)
              local wxCoeff = _getWuXingKeZhiXiuZheng(userObj, targetObj, WUXING_XIANFA, wxjData)
              damageHp = damageHp * (1 + wxCoeff)
              damageHp = _checkDamage(damageHp * (1 + kb_ExtraCoeff))
              if kb_ExtraCoeff > 0 then
                attEffectList = {EFFECTTYPE_FURY}
              end
              skillSuccess = true
            else
              objEffectList = {EFFECTTYPE_IMMUNITY}
            end
          elseif skillAttr == SKILLATTR_WIND then
            if _canSkillOnRole_Wind(targetObj) then
              local pLevel = userObj:getProperty(PROPERTY_ROLELEVEL)
              local ssv = userObj:getProperty(PROPERTY_STARSKILLVALUE)
              damageHp = _computeSkillDamage_XianZu(skillID, kAttr, fkAttr, skillExp, pLevel, ssv, qh_ExtraCoeff, skillWeakCeoff, weaken_damage)
              local wxCoeff = _getWuXingKeZhiXiuZheng(userObj, targetObj, WUXING_XIANFA, wxjData)
              damageHp = damageHp * (1 + wxCoeff)
              damageHp = _checkDamage(damageHp * (1 + kb_ExtraCoeff))
              if kb_ExtraCoeff > 0 then
                attEffectList = {EFFECTTYPE_FURY}
              end
              skillSuccess = true
            else
              objEffectList = {EFFECTTYPE_IMMUNITY}
            end
          elseif skillAttr == SKILLATTR_THUNDER then
            if _canSkillOnRole_Thunder(targetObj) then
              local pLevel = userObj:getProperty(PROPERTY_ROLELEVEL)
              local ssv = userObj:getProperty(PROPERTY_STARSKILLVALUE)
              damageHp = _computeSkillDamage_XianZu(skillID, kAttr, fkAttr, skillExp, pLevel, ssv, qh_ExtraCoeff, skillWeakCeoff, weaken_damage)
              local wxCoeff = _getWuXingKeZhiXiuZheng(userObj, targetObj, WUXING_XIANFA, wxjData)
              damageHp = damageHp * (1 + wxCoeff)
              damageHp = _checkDamage(damageHp * (1 + kb_ExtraCoeff))
              if kb_ExtraCoeff > 0 then
                attEffectList = {EFFECTTYPE_FURY}
              end
              skillSuccess = true
            else
              objEffectList = {EFFECTTYPE_IMMUNITY}
            end
          elseif skillAttr == SKILLATTR_WATER then
            if _canSkillOnRole_Water(targetObj) then
              local pLevel = userObj:getProperty(PROPERTY_ROLELEVEL)
              local ssv = userObj:getProperty(PROPERTY_STARSKILLVALUE)
              damageHp = _computeSkillDamage_XianZu(skillID, kAttr, fkAttr, skillExp, pLevel, ssv, qh_ExtraCoeff, skillWeakCeoff, weaken_damage)
              local wxCoeff = _getWuXingKeZhiXiuZheng(userObj, targetObj, WUXING_XIANFA, wxjData)
              damageHp = damageHp * (1 + wxCoeff)
              damageHp = _checkDamage(damageHp * (1 + kb_ExtraCoeff))
              if kb_ExtraCoeff > 0 then
                attEffectList = {EFFECTTYPE_FURY}
              end
              skillSuccess = true
            else
              objEffectList = {EFFECTTYPE_IMMUNITY}
            end
          elseif skillAttr == SKILLATTR_PAN then
            local _checkFlag = _canSkillOnRole_Pan(targetObj)
            if _checkFlag == true then
              local ssv = userObj:getProperty(PROPERTY_STARSKILLVALUE)
              local wlKang, xzKang, rzKang = _computeSkillEffect_Pan(skillID, skillExp, ssv)
              wlKang = wlKang + qh_ExtraCoeff
              xzKang = xzKang + qh_ExtraCoeff
              rzKang = rzKang + qh_ExtraCoeff
              _setTargetTempKangPro(targetObj, SKILLATTR_WULI, wlKang, EFFECTTYPE_ADV_WULI)
              _setTargetTempKangPro(targetObj, SKILLATTR_POISON, rzKang, EFFECTTYPE_ADV_RENZU)
              _setTargetTempKangPro(targetObj, SKILLATTR_SLEEP, rzKang, EFFECTTYPE_ADV_RENZU)
              _setTargetTempKangPro(targetObj, SKILLATTR_CONFUSE, rzKang, EFFECTTYPE_ADV_RENZU)
              _setTargetTempKangPro(targetObj, SKILLATTR_ICE, rzKang, EFFECTTYPE_ADV_RENZU)
              _setTargetTempKangPro(targetObj, SKILLATTR_FIRE, xzKang, EFFECTTYPE_ADV_XIANZU)
              _setTargetTempKangPro(targetObj, SKILLATTR_WIND, xzKang, EFFECTTYPE_ADV_XIANZU)
              _setTargetTempKangPro(targetObj, SKILLATTR_THUNDER, xzKang, EFFECTTYPE_ADV_XIANZU)
              _setTargetTempKangPro(targetObj, SKILLATTR_WATER, xzKang, EFFECTTYPE_ADV_XIANZU)
              local skillRound = _computeSkillRound(skillID, skillExp, kAttr, fkAttr)
              _addEffectOnTarget(targetObj, EFFECTTYPE_ADV_WULI, skillRound)
              _addEffectOnTarget(targetObj, EFFECTTYPE_ADV_RENZU, skillRound)
              _addEffectOnTarget(targetObj, EFFECTTYPE_ADV_XIANZU, skillRound)
              objEffectList = {
                EFFECTTYPE_ADV_WULI,
                EFFECTTYPE_ADV_RENZU,
                EFFECTTYPE_ADV_XIANZU
              }
              print_SkillLog_AddEffect(warId, userPos, targetPos, EFFECTTYPE_ADV_WULI, skillRound)
              print_SkillLog_AddEffect(warId, userPos, targetPos, EFFECTTYPE_ADV_RENZU, skillRound)
              print_SkillLog_AddEffect(warId, userPos, targetPos, EFFECTTYPE_ADV_XIANZU, skillRound)
              skillSuccess = true
            elseif _checkFlag == -1 then
              objEffectList = {EFFECTTYPE_IMMUNITY}
            elseif _checkFlag == -2 then
              objEffectList = {EFFECTTYPE_INVALID}
            end
          elseif skillAttr == SKILLATTR_ATTACK then
            local _checkFlag = _canSkillOnRole_Attack(targetObj)
            if _checkFlag == true then
              local ssv = userObj:getProperty(PROPERTY_STARSKILLVALUE)
              local ap, mz = _computeSkillEffect_Attack(skillID, skillExp, ssv)
              ap = ap + qh_ExtraCoeff
              mz = mz + qh_ExtraCoeff
              _setTargetTempAttr(targetObj, PROPERTY_AP, ap, EFFECTTYPE_ADV_DAMAGE)
              _setTargetTempAttr(targetObj, PROPERTY_PACC, mz, EFFECTTYPE_ADV_MINGZHONG)
              local skillRound = _computeSkillRound(skillID, skillExp, kAttr, fkAttr)
              _addEffectOnTarget(targetObj, EFFECTTYPE_ADV_DAMAGE, skillRound)
              _addEffectOnTarget(targetObj, EFFECTTYPE_ADV_MINGZHONG, skillRound)
              objEffectList = {EFFECTTYPE_ADV_DAMAGE, EFFECTTYPE_ADV_MINGZHONG}
              print_SkillLog_AddEffect(warId, userPos, targetPos, EFFECTTYPE_ADV_DAMAGE, skillRound)
              print_SkillLog_AddEffect(warId, userPos, targetPos, EFFECTTYPE_ADV_MINGZHONG, skillRound)
              skillSuccess = true
            elseif _checkFlag == -1 then
              objEffectList = {EFFECTTYPE_IMMUNITY}
            elseif _checkFlag == -2 then
              objEffectList = {EFFECTTYPE_INVALID}
            end
          elseif skillAttr == SKILLATTR_SPEED then
            local _checkFlag = _canSkillOnRole_Speed(targetObj)
            if _checkFlag == true then
              local ssv = userObj:getProperty(PROPERTY_STARSKILLVALUE)
              local sp = _computeSkillEffect_Speed(skillID, skillExp, ssv)
              sp = sp + qh_ExtraCoeff
              _setTargetTempAttr(targetObj, PROPERTY_SP, sp, EFFECTTYPE_ADV_SPEED)
              local skillRound = _computeSkillRound(skillID, skillExp, kAttr, fkAttr)
              _addEffectOnTarget(targetObj, EFFECTTYPE_ADV_SPEED, skillRound)
              objEffectList = {EFFECTTYPE_ADV_SPEED}
              print_SkillLog_AddEffect(warId, userPos, targetPos, EFFECTTYPE_ADV_SPEED, skillRound)
              skillSuccess = true
            elseif _checkFlag == -1 then
              objEffectList = {EFFECTTYPE_IMMUNITY}
            elseif _checkFlag == -2 then
              objEffectList = {EFFECTTYPE_INVALID}
            end
          elseif skillAttr == SKILLATTR_ZHEN then
            if _canSkillOnRole_Zhen(targetObj) then
              local pLevel = userObj:getProperty(PROPERTY_ROLELEVEL)
              local ssv = userObj:getProperty(PROPERTY_STARSKILLVALUE)
              damageHp, damageMp = _computeSkillDamage_Zhen(skillID, kAttr, fkAttr, skillExp, pLevel, targetHp, targetMp, ssv, qh_ExtraCoeff, skillWeakCeoff, weaken_damage)
              local wxCoeff = _getWuXingKeZhiXiuZheng(userObj, targetObj, WUXING_MOFA, wxjData)
              damageHp = _checkDamage(damageHp * (1 + wxCoeff))
              damageMp = _checkDamage(damageMp * (1 + wxCoeff))
              local damageHpMax = _checkDamage(targetHp * 0.5 + 500)
              if damageHp > damageHpMax then
                damageHp = damageHpMax
              end
              skillSuccess = true
            else
              objEffectList = {EFFECTTYPE_IMMUNITY}
            end
          elseif skillAttr == SKILLATTR_MINGLINGFEIZI then
            if _canSkillOnRole_MingLingFeiZi(targetObj) then
              local ssv = userObj:getProperty(PROPERTY_STARSKILLVALUE)
              local k_wl, k_xz, k_rz = _computeSkillEffect_MingLingFeiZi(skillID, ssv)
              _setTargetTempKangPro(targetObj, SKILLATTR_WULI, k_wl, EFFECTTYPE_DEC_WULI)
              _setTargetTempKangPro(targetObj, SKILLATTR_POISON, k_rz, EFFECTTYPE_DEC_RENZU)
              _setTargetTempKangPro(targetObj, SKILLATTR_SLEEP, k_rz, EFFECTTYPE_DEC_RENZU)
              _setTargetTempKangPro(targetObj, SKILLATTR_CONFUSE, k_rz, EFFECTTYPE_DEC_RENZU)
              _setTargetTempKangPro(targetObj, SKILLATTR_ICE, k_rz, EFFECTTYPE_DEC_RENZU)
              _setTargetTempKangPro(targetObj, SKILLATTR_FIRE, k_xz, EFFECTTYPE_DEC_XIANZU)
              _setTargetTempKangPro(targetObj, SKILLATTR_WIND, k_xz, EFFECTTYPE_DEC_XIANZU)
              _setTargetTempKangPro(targetObj, SKILLATTR_THUNDER, k_xz, EFFECTTYPE_DEC_XIANZU)
              _setTargetTempKangPro(targetObj, SKILLATTR_WATER, k_xz, EFFECTTYPE_DEC_XIANZU)
              local skillRound = _computeSkillRound(skillID, skillExp, kAttr, fkAttr)
              _addEffectOnTarget(targetObj, EFFECTTYPE_DEC_WULI, skillRound)
              _addEffectOnTarget(targetObj, EFFECTTYPE_DEC_RENZU, skillRound)
              _addEffectOnTarget(targetObj, EFFECTTYPE_DEC_XIANZU, skillRound)
              objEffectList = {
                EFFECTTYPE_DEC_WULI,
                EFFECTTYPE_DEC_RENZU,
                EFFECTTYPE_DEC_XIANZU
              }
              print_SkillLog_AddEffect(warId, userPos, targetPos, EFFECTTYPE_DEC_WULI, skillRound)
              print_SkillLog_AddEffect(warId, userPos, targetPos, EFFECTTYPE_DEC_RENZU, skillRound)
              print_SkillLog_AddEffect(warId, userPos, targetPos, EFFECTTYPE_DEC_XIANZU, skillRound)
              skillSuccess = true
            else
              objEffectList = {EFFECTTYPE_IMMUNITY}
            end
          elseif skillAttr == SKILLATTR_JIXIANGGUOZI then
            if _canSkillOnRole_JiXiangGuoZi(targetObj) then
              local ssv = userObj:getProperty(PROPERTY_STARSKILLVALUE)
              local k_zs, k_yw, k_ah, k_xx = _computeSkillEffect_JiXiangGuoZi(skillID, ssv)
              _setTargetTempKangPro(targetObj, SKILLATTR_ZHEN, k_zs, EFFECTTYPE_DEC_ZHEN)
              _setTargetTempKangPro(targetObj, SKILLATTR_YIWANG, k_yw, EFFECTTYPE_DEC_ZHEN)
              _setTargetTempKangPro(targetObj, SKILLATTR_AIHAO, k_ah, EFFECTTYPE_DEC_ZHEN)
              _setTargetTempKangPro(targetObj, SKILLATTR_XIXUE, k_xx, EFFECTTYPE_DEC_ZHEN)
              local skillRound = _computeSkillRound(skillID, skillExp, kAttr, fkAttr)
              _addEffectOnTarget(targetObj, EFFECTTYPE_DEC_ZHEN, skillRound)
              objEffectList = {EFFECTTYPE_DEC_ZHEN}
              print_SkillLog_AddEffect(warId, userPos, targetPos, EFFECTTYPE_DEC_ZHEN, skillRound)
              skillSuccess = true
            else
              objEffectList = {EFFECTTYPE_IMMUNITY}
            end
          elseif skillAttr == SKILLATTR_SHUAIRUO then
            if _canSkillOnRole_ShuaiRuo(targetObj) then
              local ssv = userObj:getProperty(PROPERTY_STARSKILLVALUE)
              local k_zhen, k_yw, k_ah, k_xx = _computeSkillEffect_ShuaiRuo(skillID, skillExp, ssv)
              k_zhen = k_zhen - qh_ExtraCoeff
              k_yw = k_yw - qh_ExtraCoeff
              k_ah = k_ah - qh_ExtraCoeff
              k_xx = math.ceil(k_xx * (1 + qh_ExtraCoeff))
              _setTargetTempKangPro(targetObj, SKILLATTR_ZHEN, k_zhen, EFFECTTYPE_SHUAIRUO)
              _setTargetTempKangPro(targetObj, SKILLATTR_YIWANG, k_yw, EFFECTTYPE_SHUAIRUO)
              _setTargetTempKangPro(targetObj, SKILLATTR_AIHAO, k_ah, EFFECTTYPE_SHUAIRUO)
              _setTargetTempKangPro(targetObj, SKILLATTR_XIXUE, k_xx, EFFECTTYPE_SHUAIRUO)
              local skillRound = _computeSkillRound(skillID, skillExp, kAttr, fkAttr)
              _addEffectOnTarget(targetObj, EFFECTTYPE_SHUAIRUO, skillRound)
              objEffectList = {EFFECTTYPE_SHUAIRUO}
              print_SkillLog_AddEffect(warId, userPos, targetPos, EFFECTTYPE_SHUAIRUO, skillRound)
              skillSuccess = true
            else
              objEffectList = {EFFECTTYPE_IMMUNITY}
            end
          elseif skillAttr == SKILLATTR_AIHAO then
            if _canSkillOnRole_AiHao(targetObj) then
              local pLevel = userObj:getProperty(PROPERTY_ROLELEVEL)
              local ssv = userObj:getProperty(PROPERTY_STARSKILLVALUE)
              local deadNum = _getDeadTeamMateHeroAmount(warId, team)
              damageHp = _computeSkillDamage_AiHao(skillID, kAttr, fkAttr, skillExp, pLevel, ssv, qh_ExtraCoeff, skillWeakCeoff, weaken_damage, deadNum)
              local wxCoeff = _getWuXingKeZhiXiuZheng(userObj, targetObj, WUXING_AIHAO, wxjData)
              damageHp = damageHp * (1 + wxCoeff)
              damageHp = _checkDamage(damageHp * (1 + kb_ExtraCoeff))
              if kb_ExtraCoeff > 0 then
                attEffectList = {EFFECTTYPE_FURY}
              end
              skillSuccess = true
            else
              objEffectList = {EFFECTTYPE_IMMUNITY}
            end
          elseif skillAttr == SKILLATTR_XIXUE then
            if _canSkillOnRole_XiXue(targetObj) then
              local pLevel = userObj:getProperty(PROPERTY_ROLELEVEL)
              local ssv = userObj:getProperty(PROPERTY_STARSKILLVALUE)
              damageHp = _computeSkillDamage_XiXue(skillID, kAttr, qh_ExtraValue, skillExp, pLevel, ssv, skillWeakCeoff)
              local wxCoeff = _getWuXingKeZhiXiuZheng(userObj, targetObj, WUXING_XIXUE, wxjData)
              damageHp = damageHp * (1 + wxCoeff)
              damageHp = _checkDamage(damageHp * (1 + kb_ExtraCoeff))
              if kb_ExtraCoeff > 0 then
                attEffectList = {EFFECTTYPE_FURY}
              end
              skillSuccess = true
            else
              objEffectList = {EFFECTTYPE_IMMUNITY}
            end
          elseif skillAttr == SKILLATTR_YIWANG then
            if _canSkillOnRole_YiWang(targetObj) then
              local skillRound = _computeSkillRound(skillID, skillExp, kAttr, fkAttr)
              _addEffectOnTarget(targetObj, EFFECTTYPE_YIWANG, skillRound)
              objEffectList = {EFFECTTYPE_YIWANG}
              local ywPro = _computeSkillDamage_YiWang(skillID)
              local ysList = {SKILLTYPE_USEDRUG}
              for sId, p in pairs(targetObj:getSkills()) do
                if p > 0 then
                  local logicType = GetObjType(sId)
                  if logicType ~= LOGICTYPE_MARRYSKILL and _canAffectOnPro(ywPro) then
                    ysList[#ysList + 1] = sId
                  end
                end
              end
              targetObj:setTempProperty(PROPERTY_YIWANGSKILL, ysList)
            else
              objEffectList = {EFFECTTYPE_IMMUNITY}
            end
          elseif skillAttr == SKILLATTR_NIAN then
            local _checkFlag = _canSkillOnRole_Nian(targetObj)
            if _checkFlag == true then
              local adv_kb, adv_mz, adv_zm = _computeSkillEffect_Nian(skillID)
              _setTargetTempAttr(targetObj, PROPERTY_PKUANGBAO, adv_kb, EFFECTTYPE_ADV_NIAN)
              _setTargetTempAttr(targetObj, PROPERTY_PACC, adv_mz, EFFECTTYPE_ADV_NIAN)
              _setTargetTempAttr(targetObj, PROPERTY_PCRIT, adv_zm, EFFECTTYPE_ADV_NIAN)
              local skillRound = _computeSkillRound(skillID, skillExp, kAttr, fkAttr)
              _addEffectOnTarget(targetObj, EFFECTTYPE_ADV_NIAN, skillRound)
              objEffectList = {EFFECTTYPE_ADV_NIAN}
              print_SkillLog_AddEffect(warId, userPos, targetPos, EFFECTTYPE_ADV_NIAN, skillRound)
              skillSuccess = true
            elseif _checkFlag == -1 then
              objEffectList = {EFFECTTYPE_IMMUNITY}
            elseif _checkFlag == -2 then
              objEffectList = {EFFECTTYPE_INVALID}
            end
          end
        else
          if skillAttr == SKILLATTR_CONFUSE or skillAttr == SKILLATTR_SLEEP or skillAttr == SKILLATTR_ICE or skillAttr == SKILLATTR_YIWANG then
            objEffectList = {EFFECTTYPE_IMMUNITY}
          elseif _checkRoleIsInState(targetObj, EFFECTTYPE_SLEEP) or _checkRoleIsInState(targetObj, EFFECTTYPE_FROZEN) then
            objEffectList = {EFFECTTYPE_IMMUNITY}
          else
            objEffectList = {EFFECTTYPE_MISS}
          end
          print_SkillLog_Miss(warId, targetPos)
        end
        if maxHitTimes > 1 then
          if nHit > 1 then
            if damageHp > 0 then
              damageHp = _checkDamage(damageHp / nHit)
            end
            if damageMp > 0 then
              damageMp = _checkDamage(damageMp / nHit)
            end
            if isFirstTarget then
              attEffectList[#attEffectList + 1] = EFFECTTYPE_DOUBLEHIT
            end
          elseif isFirstTarget then
            attEffectList[#attEffectList + 1] = EFFECTTYPE_DOUBLEHIT_COME
          end
        end
        if (damageHp > 0 or damageMp > 0) and _RoleIsDamgeImmunity(targetObj) then
          damageHp = 0
          damageMp = 0
          objEffectList[#objEffectList + 1] = EFFECTTYPE_IMMUNITY_DAMAGE
        end
        local shareSeq = {}
        if damageHp > 0 then
          local sharePos, shareObj = _getShareDamagePos(warId, targetObj, targetPos)
          if shareObj ~= nil then
            local sk_1, sk_2, _ = _computeSkillEffect_ShouHuCangSheng(SKILL_SHOUHUCANGSHENG)
            local shareDamage = _checkDamage(damageHp * sk_2)
            damageHp = _checkDamage(damageHp * sk_1)
            objEffectList[#objEffectList + 1] = EFFECTTYPE_SHAREDAMAGE
            local shareHp = shareObj:getProperty(PROPERTY_HP)
            local shareMp = shareObj:getProperty(PROPERTY_MP)
            local shareEffList = {EFFECTTYPE_NOSKILLANI}
            if not _RoleIsDamgeImmunity(shareObj) then
              local maxHpMpChanged_Share = false
              shareHp = math.max(shareHp - shareDamage)
              if shareHp <= 0 then
                shareHp, maxHpMpChanged_Share = _setRoleIsDeadInWar(warId, warRound, sharePos, shareObj, shareEffList)
              end
              shareObj:setProperty(PROPERTY_HP, shareHp)
              if shareObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and _checkRoleIsInState(shareObj, EFFECTTYPE_SLEEP) then
                _removeRoleEffectState(shareObj, EFFECTTYPE_SLEEP)
                shareEffList[#shareEffList + 1] = EFFECTTYPE_SLEEP_OFF
              end
              shareSeq[#shareSeq + 1] = _formatSubNormalSeqOfTarget(userPos, sharePos, shareHp, shareMp, shareDamage, 0, {}, shareEffList)
              if maxHpMpChanged_Share then
                local shareMaxHp = shareObj:getMaxProperty(PROPERTY_HP)
                local shareMaxMp = shareObj:getMaxProperty(PROPERTY_MP)
                shareSeq[#shareSeq + 1] = _formatSubNormalSeqOfTarget_PetSkillHpMpBase(userPos, sharePos, shareHp, shareMp, shareMaxHp, shareMaxMp)
              end
            else
              shareEffList[#shareEffList + 1] = EFFECTTYPE_IMMUNITY_DAMAGE
              shareSeq[#shareSeq + 1] = _formatSubNormalSeqOfTarget(userPos, sharePos, shareHp, shareMp, 0, 0, {}, shareEffList)
            end
          end
        end
        print_SkillLog_DamageHpAndMp(warId, userPos, targetPos, damageHp, damageMp)
        targetHp = math.max(targetHp - damageHp, 0)
        targetMp = math.max(targetMp - damageMp, 0)
        if damageHp > 0 and skillAttr == SKILLATTR_XIXUE then
          local extraCeoff = userObj:getProperty(PROPERTY_ADD_XIXUEHUIXUE)
          local addHp = _computeSkillDamage_XiXueAddHp(skillID, damageHp, extraCeoff)
          xixueList[#xixueList + 1] = addHp
        end
        if targetHp <= 0 then
          local maxHpMpChanged_dead = false
          targetHp, maxHpMpChanged_dead = _setRoleIsDeadInWar(warId, warRound, targetPos, targetObj, objEffectList)
          maxHpMpChanged = maxHpMpChanged or maxHpMpChanged_dead
        end
        targetObj:setProperty(PROPERTY_HP, targetHp)
        targetObj:setProperty(PROPERTY_MP, targetMp)
        if targetObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and _checkRoleIsInState(targetObj, EFFECTTYPE_SLEEP) and skillSuccess and (damageHp > 0 and skillAttr ~= SKILLATTR_CONFUSE or skillAttr == SKILLATTR_ICE) then
          _removeRoleEffectState(targetObj, EFFECTTYPE_SLEEP)
          objEffectList[#objEffectList + 1] = EFFECTTYPE_SLEEP_OFF
        end
        if isFirstTarget then
          userMp = userObj:getProperty(PROPERTY_MP)
          if nHit == 1 then
            tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, damageHp, damageMp, attEffectList, objEffectList, skillID, userMp, ndSkillId_att, nil, nil, nil, userHp_send)
          else
            tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, damageHp, damageMp, attEffectList, objEffectList, skillID, userMp, nil, nil, nil, nil, userHp_send)
          end
        else
          tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, damageHp, damageMp, attEffectList, objEffectList)
        end
        if maxHpMpChanged == true then
          local tMaxHp = targetObj:getMaxProperty(PROPERTY_HP)
          local tMaxMp = targetObj:getMaxProperty(PROPERTY_MP)
          tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillHpMpBase(userPos, targetPos, targetHp, targetMp, tMaxHp, tMaxMp)
        end
        if #shareSeq > 0 then
          for _, sSeq in pairs(shareSeq) do
            tInfo[#tInfo + 1] = sSeq
          end
        end
        damageInfoList[#damageInfoList + 1] = {
          targetPos,
          targetObj,
          damageHp
        }
        isFirstTarget = false
      end
      if userObj:getProperty(PROPERTY_DEAD) ~= ROLESTATE_LIVE then
        break
      end
    end
    if skillAttr == SKILLATTR_XIXUE and #xixueList > 0 then
      table.sort(xixueList, _addHpSortFunc)
      local addPosList = _getPosListByPosAndTeamWithSpeedSortedWithDeadPos(warId, team, TARGETTYPE_MYSIDE)
      local addPosObjList = {}
      for idx, addPos in pairs(addPosList) do
        local addPosObj = _getFightRoleObjByPos_WithDeadHero(warId, addPos)
        if addPosObj then
          local posHp = addPosObj:getProperty(PROPERTY_HP)
          local posMaxHp = addPosObj:getMaxProperty(PROPERTY_HP)
          if posHp < posMaxHp then
            addPosObjList[#addPosObjList + 1] = {addPosObj, addPos}
            addPosObj.__speedIdx = idx
          end
        end
      end
      table.sort(addPosObjList, _roleHpSortFunc)
      for idx, addHp in pairs(xixueList) do
        local addPosData = addPosObjList[idx]
        if addPosData ~= nil then
          local addPosObj, addPos = addPosData[1], addPosData[2]
          local posHp = addPosObj:getProperty(PROPERTY_HP)
          local posMp = addPosObj:getProperty(PROPERTY_MP)
          if _checkRoleIsInState(addPosObj, EFFECTTYPE_DUOHUNSUOMING) then
            tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillAddHpMp(userPos, addPos, posHp, posMp, 0, 0, nil, nil, nil, {EFFECTTYPE_INVALID}, nil, nil, nil, 0)
          else
            local posMaxHp = addPosObj:getMaxProperty(PROPERTY_HP)
            posHp = posHp + addHp
            if posMaxHp < posHp then
              posHp = posMaxHp
            end
            addPosObj:setProperty(PROPERTY_HP, posHp)
            local fuhuo
            if addPosObj:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD then
              addPosObj:setProperty(PROPERTY_DEAD, ROLESTATE_LIVE)
              fuhuo = 1
            end
            tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillAddHpMp(userPos, addPos, posHp, posMp, addHp, 0, nil, nil, fuhuo, nil, nil, nil, nil, 0)
          end
        else
          break
        end
      end
      for _, addPosData in pairs(addPosObjList) do
        local addPosObj = addPosData[1]
        addPosObj.__speedIdx = nil
      end
    end
    for _, damageInfo in pairs(damageInfoList) do
      local targetPos, targetObj, damageHp = damageInfo[1], damageInfo[2], damageInfo[3]
      if targetObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and userObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and (_isXianZuSkillAttr(skillAttr) or skillAttr == SKILLATTR_AIHAO or skillAttr == SKILLATTR_XIXUE) and damageHp > 0 then
        local ftHp = 0
        local ftPro = targetObj:getProperty(PROPERTY_FTPRO)
        local eList = {EFFECTTYPE_REVERBERATE}
        local eObjList = {}
        if _canAffectOnPro(ftPro) then
          local ftLv = targetObj:getProperty(PROPERTY_FTLV)
          local ftLv_k = userObj:getProperty(PROPERTY_PKFTLV)
          ftLv = ftLv - ftLv_k
          if ftLv < MIN_FTLV_NUM then
            ftLv = MIN_FTLV_NUM
          elseif ftLv > MAX_FTLV_NUM then
            ftLv = MAX_FTLV_NUM
          end
          ftHp = _checkDamage(damageHp * ftLv)
        end
        local nd_wfcz
        local eList_Extra = {}
        local ftHp_Extra = _getNeiDan_WanFoChaoZong_Reverberate(userObj, targetObj, eList_Extra, damageHp)
        if ftHp_Extra > 0 then
          ftHp = ftHp + ftHp_Extra
          eList = eList_Extra
          nd_wfcz = {NDSKILL_WANFOCHAOZONG}
        end
        local ftWeak = userObj:getProperty(PROPERTY_DEL_ZHEN)
        if ftHp > 0 then
          ftHp = _checkDamage(ftHp - ftWeak)
        end
        if ftHp > 0 then
          local ftMp = 0
          local jgbrCoeff, jgbrSkill = targetObj:GetPetSkillJingGuanBaiRi()
          if jgbrCoeff > 0 then
            ftMp = _checkDamage(ftHp * jgbrCoeff)
            eList[#eList + 1] = EFFECTTYPE_JINGGUANBAIRI
          end
          if _RoleIsDamgeImmunity(userObj) then
            ftHp = 0
            ftMp = 0
            eObjList = {EFFECTTYPE_IMMUNITY_DAMAGE}
          end
          local tHp = userObj:getProperty(PROPERTY_HP)
          local tMp = userObj:getProperty(PROPERTY_MP)
          tHp = math.max(tHp - ftHp, 0)
          tMp = math.max(tMp - ftMp, 0)
          local maxHpMpChanged_ft = false
          if tHp <= 0 then
            tHp, maxHpMpChanged_ft = _setRoleIsDeadInWar(warId, warRound, userPos, userObj, eObjList)
          end
          userObj:setProperty(PROPERTY_HP, tHp)
          userObj:setProperty(PROPERTY_MP, tMp)
          tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(targetPos, userPos, tHp, tMp, ftHp, ftMp, eList, eObjList, nil, nil, nd_wfcz)
          if maxHpMpChanged_ft == true then
            local tMaxHp = userObj:getMaxProperty(PROPERTY_HP)
            local tMaxMp = userObj:getMaxProperty(PROPERTY_MP)
            tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillHpMpBase(targetPos, userPos, tHp, tMp, tMaxHp, tMaxMp)
          end
        end
      end
    end
    if nHit == 1 then
      _checkBaoFuSkillWhenUseSkill(warId, warRound, userPos, userObj, tInfo)
      _checkHuiYuanSkillWhenUseSkill(warId, userPos, userObj, tInfo)
    end
    if userObj:getProperty(PROPERTY_DEAD) ~= ROLESTATE_LIVE then
      break
    end
  end
  _onNewFormatFightSequence(warId, formatFightSeq)
  _callBack(callback)
end
function _getNormalSkillRequireMp(userObj, skillID, skillExp)
  local skillNeedMp = _computeSkillRequireMp(skillID, skillExp)
  if _checkRoleIsInState(userObj, EFFECTTYPE_LONGZHANYUYE) then
    local effData = _getRoleEffectData(userObj, EFFECTTYPE_LONGZHANYUYE)
    if effData and effData.coeff then
      skillNeedMp = math.floor(skillNeedMp * (1 + effData.coeff))
    end
  end
  return skillNeedMp
end
function _useSkillSuccess(userObj, skillID, kAttr, fkAttr, skillExp)
  local success = _computeSkillSuccess(skillID, kAttr, fkAttr, skillExp)
  printLogDebug("skill_ai", "【war log】[warid%d] 普通技能使用成功率%d技能%d,kAttr%s,fkAttr%s", userObj:getWarID(), success, skillID, kAttr, fkAttr)
  local skillData = _getSkillData(skillID)
  if skillData then
    local skillAttr = skillData.attr
    success = success + _getNormalSkill_ExtraSuccessRate(userObj, skillAttr)
  end
  return _canAffectOnPro(success)
end
function _getDeadTeamMateHeroAmount(warId, team)
  local amount = 0
  local posList = _getPosListByTeamAndTargetType(team, TARGETTYPE_MYSIDE)
  for _, pos in pairs(posList) do
    local posObj = _getFightRoleObjByPos_WithDeadHero(warId, pos)
    if posObj and posObj:getType() == LOGICTYPE_HERO and posObj:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD then
      amount = amount + 1
    end
  end
  return amount
end
function _getSkillAllTargets(warId, userPos, userObj, skillID, skillExp, skillData, selectPos, team, targetTypePram)
  local targetNum = _getSkillTargetNumBySkillExp(skillID, skillExp, skillData.targetNum, userObj:getType())
  if skillData.attr == SKILLATTR_AIHAO then
    local deadNum = _getDeadTeamMateHeroAmount(warId, userObj:getProperty(PROPERTY_TEAM))
    if deadNum >= 4 then
      targetNum = targetNum + 1
    end
  end
  if selectPos == nil or targetNum <= 0 then
    print_SkillLog_SelectPosError(warId, selectPos, targetNum, skillData.name)
    return nil
  end
  if not _canSkillOnTarget(warId, selectPos, skillID) then
    print_SkillLog_CanNotUseSkill(warId, selectPos, skillData.name)
    return nil
  end
  local stealthIsOk = false
  local skillAttr = skillData.attr
  local skillTargetType = skillData.targetType
  if skillTargetType == TARGETTYPE_MYSIDE or skillTargetType == TARGETTYPE_TEAMMATE or skillTargetType == TARGETTYPE_SELF or skillTargetType == TARGETTYPE_MYSIDEPET or skillTargetType == TARGETTYPE_MYSIDEDEAD then
    stealthIsOk = true
  end
  return _getSkillAllTargetsOfNum(warId, userPos, userObj, skillID, selectPos, targetNum, team, TARGETTYPE_MYSIDE, skillAttr, targetTypePram, stealthIsOk)
end
function _getSkillAllTargetsOfNum(warId, userPos, userObj, skillID, selectPos, targetNum, team, targetType, skillAttr, targetTypePram, stealthIsOk)
  stealthIsOk = stealthIsOk or false
  local targetList = {}
  local selectObj = _getFightRoleObjByPos_WithDeadHero(warId, selectPos)
  if selectObj and (not _checkRoleIsInState(selectObj, EFFECTTYPE_STEALTH) or selectPos == userPos or stealthIsOk) then
    targetList[#targetList + 1] = selectPos
    targetNum = targetNum - 1
  end
  if targetNum <= 0 then
    return targetList
  end
  local function _apSortFunc(a, b)
    if a == nil or b == nil then
      return false
    end
    local role_a = _getFightRoleObjByPos(warId, a)
    local role_b = _getFightRoleObjByPos(warId, b)
    if role_a == nil and role_b ~= nil then
      return false
    elseif role_a ~= nil and role_b == nil then
      return true
    elseif role_a ~= nil and role_b ~= nil then
      local ap_a = role_a:getProperty(PROPERTY_AP)
      local ap_b = role_b:getProperty(PROPERTY_AP)
      local ex_a = _getTargetTempAttr(role_a, PROPERTY_AP)
      local ex_b = _getTargetTempAttr(role_b, PROPERTY_AP)
      return ap_a * (1 + ex_a) > ap_b * (1 + ex_b)
    else
      return a < b
    end
  end
  local pList = {}
  local pList_bak = {}
  local posList = _getPosListByPosAndTeamWithSpeedSorted(warId, team, targetType)
  if skillAttr == SKILLATTR_ATTACK or skillAttr == SKILLATTR_NIAN then
    table.sort(posList, _apSortFunc)
  end
  for index, p in pairs(posList) do
    if p ~= selectPos and _canSkillOnTarget(warId, p, skillID) then
      local tObj = _getFightRoleObjByPos(warId, p)
      if tObj and tObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and (not _checkRoleIsInState(tObj, EFFECTTYPE_STEALTH) or p == userPos or stealthIsOk) and (targetTypePram == nil or targetTypePram[tObj:getType()] ~= nil) then
        if _checkRoleIsInState(tObj, EFFECTTYPE_FROZEN) then
          pList_bak[#pList_bak + 1] = p
        else
          pList[#pList + 1] = p
        end
      end
    end
  end
  for _, pos in ipairs(pList) do
    if targetNum > 0 then
      targetList[#targetList + 1] = pos
      targetNum = targetNum - 1
    else
      break
    end
  end
  if targetNum > 0 then
    for _, pos in ipairs(pList_bak) do
      if targetNum > 0 then
        targetList[#targetList + 1] = pos
        targetNum = targetNum - 1
      else
        break
      end
    end
  end
  return targetList
end
function _checkXianZu_ExtraDamageCoeff(warId, userObj, skillAttr)
  if userObj:getType() == LOGICTYPE_MONSTER and userObj:PossessMonsterTeXing(MONSTER_TX_10) then
    local team = userObj:getProperty(PROPERTY_TEAM)
    local posList = _getPosListByTeamAndTargetType(team, TARGETTYPE_MYSIDE)
    local cnt = 0
    for _, pos in pairs(posList) do
      local roleObj = _getFightRoleObjByPos(warId, pos)
      if roleObj and roleObj:getType() == LOGICTYPE_MONSTER and not roleObj:IsBossMonster() then
        cnt = cnt + 1
      end
    end
    local tableData = data_MonsterTeXing[MONSTER_TX_10] or {}
    local calparam = tableData.calparam or {}
    local totalNum = calparam[1] or 1
    local damageCoeff = calparam[2] or 1
    if cnt <= totalNum then
      return damageCoeff, true
    end
  end
  local success, coeff = _getXianZu_ExtraDamageSuccess(userObj, skillAttr)
  if _canAffectOnPro(success) then
    return coeff, false
  else
    return 0, false
  end
end
function _checkXianZu_DoubleHit(userObj)
  local success, hitTimes = _getXianZu_DoubleHitSuccess(userObj)
  if _canAffectOnPro(success) then
    return hitTimes
  else
    return 0
  end
end
function _checkXianZu_ExtraFkAttr(userObj)
  local success, fkAttr = _getXianZu_ExtraFkAttrSuccess(userObj)
  if _canAffectOnPro(success) then
    return fkAttr
  else
    return 0
  end
end
function _normalAttackOnTarget(warId, warRound, userPos, targetPos, callback, attParamOfFirstAttack)
  local userObj = _getFightRoleObjByPos(warId, userPos)
  if userObj == nil then
    print_SkillLog_RoleIsNotExist(warId, userPos)
    _callBack(callback)
    return
  end
  targetPos = _checkSelectTarget(warId, userPos, targetPos, false, true)
  if targetPos == nil then
    _callBack(callback)
    return
  end
  local targetObj = _getFightRoleObjByPos(warId, targetPos)
  if targetObj == nil then
    print_SkillLog_TargetRoleIsNotExist(warId, targetPos)
    _callBack(callback)
    return
  end
  if userPos == targetPos then
    return
  end
  local protectObj
  local protectPos = g_WarAiInsList[warId]:GetProtectDataPos(targetPos)
  if protectPos == targetPos then
    protectPos = nil
  end
  local isPet = userObj:getType() == LOGICTYPE_PET
  local isHunLuan = _checkRoleIsInState(userObj, EFFECTTYPE_CONFUSE)
  local isSBAttack = false
  local userTeam = userObj:getProperty(PROPERTY_TEAM)
  local targetTeam = targetObj:getProperty(PROPERTY_TEAM)
  if userTeam == targetTeam and not isHunLuan then
    isSBAttack = true
  end
  local userHp = userObj:getProperty(PROPERTY_HP)
  local userMp = userObj:getProperty(PROPERTY_MP)
  local targetHp = targetObj:getProperty(PROPERTY_HP)
  local targetMp = targetObj:getProperty(PROPERTY_MP)
  local formatFightSeq = {
    seqType = SEQTYPE_NORMALATTACK,
    userPos = userPos,
    targetInfo = {}
  }
  local tInfo = formatFightSeq.targetInfo
  print_SkillLog_NormalAttack(warId, userPos, targetPos)
  local pursuitFlag = false
  local yjckFlag = false
  local allLiveObjBeforeAttack = {}
  local pursuitPro, _ = userObj:GetPetSkillFenHuaFuLiu()
  if _canAffectOnPro(pursuitPro) and not isSBAttack then
    pursuitFlag = true
    local allPosList = _getAllRolePosList()
    for _, tempPos in pairs(allPosList) do
      local liveObj = _getFightRoleObjByPos(warId, tempPos)
      if liveObj then
        allLiveObjBeforeAttack[#allLiveObjBeforeAttack + 1] = liveObj
      end
    end
  end
  _checkCancelStealth(warId, userPos, userObj)
  if not _canSkillOnRole_NormalAttack(targetObj) then
    tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, 0, 0, {}, {EFFECTTYPE_IMMUNITY})
    print_SkillLog_NormalAttackInvalid(warId, userPos, targetPos)
  elseif _RoleIsDamgeImmunity(targetObj) then
    tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, 0, 0, {}, {EFFECTTYPE_IMMUNITY_DAMAGE})
    print_SkillLog_NormalAttackInvalid(warId, userPos, targetPos)
  elseif not _checkMiss(userObj, targetObj) or _checkRoleIsInState(targetObj, EFFECTTYPE_SLEEP) then
    local maxHitTimes = 1
    if _checkDoubleHit(userObj, targetObj) then
      maxHitTimes = maxHitTimes + userObj:getProperty(PROPERTY_PLJTIMES) + 1
    end
    for nHit = 1, maxHitTimes do
      if nHit == 1 then
        local protectSkillId
        if protectPos == nil and targetObj:getType() == LOGICTYPE_HERO then
          local tPetPos = _getPetPosByMasterPos(targetPos)
          local tPetObj = _getFightRoleObjByPos(warId, tPetPos)
          if tPetObj and tPetObj:getType() == LOGICTYPE_PET and not isSBAttack then
            local protectPro, protectSkill = tPetObj:GetPetSkillZhongBuBiWei()
            if _canAffectOnPro(protectPro) and not _checkRoleIsInState(tPetObj, EFFECTTYPE_FROZEN) and not _checkRoleIsInState(tPetObj, EFFECTTYPE_CONFUSE) and not _checkRoleIsInState(tPetObj, EFFECTTYPE_FENGMO) and not _checkRoleIsInState(tPetObj, EFFECTTYPE_SLEEP) then
              local protectTimes = tPetObj:getTempProperty(PROPERTY_PROTECTTIMES) or 0
              if protectTimes > 0 then
                protectSkillId = protectSkill
                protectPos = tPetPos
                tPetObj:setTempProperty(PROPERTY_PROTECTTIMES, protectTimes - 1)
              end
            end
          end
        end
        if protectPos ~= nil then
          protectObj = _getFightRoleObjByPos(warId, protectPos)
          if protectObj ~= nil then
            _checkCancelStealth(warId, protectPos, protectObj)
            _formatAndSendProtectSeqOfTarget(warId, protectPos, targetPos, protectSkillId)
          end
        end
      end
      local damageHp = 0
      local damageParam = {}
      if attParamOfFirstAttack ~= nil and nHit == 1 then
        damageParam = attParamOfFirstAttack
      end
      local attEffectList = {}
      local objEffectList = {}
      local protectDamageHp = 0
      if isSBAttack then
        damageHp = 1
        protectDamageHp = 1
      elseif protectObj then
        damageParam.dk = 0.3
        damageHp, attEffectList, objEffectList, userSeq, damageParam = _getFinalWuliDamage(userObj, targetObj, userPos, nHit, maxHitTimes, true, true, damageParam)
        local damageParamTemp = DeepCopyTable(damageParam)
        damageParamTemp.dk = 0.7
        local damageHpTemp, _, _, _, _ = _getFinalWuliDamage(userObj, protectObj, userPos, nHit, maxHitTimes, true, false, damageParamTemp)
        protectDamageHp = damageHpTemp
      else
        damageHp, attEffectList, objEffectList, userSeq, damageParam = _getFinalWuliDamage(userObj, targetObj, userPos, nHit, maxHitTimes, true, true, damageParam)
      end
      if maxHitTimes > 1 then
        if nHit > 1 then
          attEffectList[#attEffectList + 1] = EFFECTTYPE_DOUBLEHIT
        else
          attEffectList[#attEffectList + 1] = EFFECTTYPE_DOUBLEHIT_COME
        end
      end
      local maxHpMpChanged = false
      local shareSeq
      targetHp, damageHp, maxHpMpChanged, shareSeq = _realWuliDamageOnTarget(warId, warRound, targetPos, targetObj, damageHp, objEffectList, userPos, userObj, true)
      if targetObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and damageHp > 0 and _checkRoleIsInState(targetObj, EFFECTTYPE_SLEEP) then
        _removeRoleEffectState(targetObj, EFFECTTYPE_SLEEP)
        objEffectList[#objEffectList + 1] = EFFECTTYPE_SLEEP_OFF
      end
      tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, damageHp, 0, attEffectList, objEffectList)
      print_SkillLog_DamageHp(warId, userPos, targetPos, damageHp)
      if maxHpMpChanged == true then
        local tMaxHp = targetObj:getMaxProperty(PROPERTY_HP)
        local tMaxMp = targetObj:getMaxProperty(PROPERTY_MP)
        tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillHpMpBase(userPos, targetPos, targetHp, targetMp, tMaxHp, tMaxMp)
      end
      if shareSeq ~= nil then
        for _, sSeq in pairs(shareSeq) do
          tInfo[#tInfo + 1] = sSeq
        end
      end
      if protectObj ~= nil and protectObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
        local protectEffectList = {}
        local maxHpMpChanged_protect = false
        local protectHp, protectDHp, maxHpMpChanged_protect, shareSeq_protect = _realWuliDamageOnTarget(warId, warRound, protectPos, protectObj, protectDamageHp, protectEffectList, userPos, userObj, true)
        local protectMp = protectObj:getProperty(PROPERTY_MP)
        tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, protectPos, protectHp, protectMp, protectDHp, 0, nil, protectEffectList)
        if maxHpMpChanged_protect == true then
          local pMaxHp = protectObj:getMaxProperty(PROPERTY_HP)
          local pMaxMp = protectObj:getMaxProperty(PROPERTY_MP)
          tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillHpMpBase(userPos, protectPos, protectHp, protectMp, pMaxHp, pMaxMp)
        end
        if shareSeq_protect ~= nil then
          for _, sSeq in pairs(shareSeq_protect) do
            tInfo[#tInfo + 1] = sSeq
          end
        end
      end
      if userSeq ~= nil then
        tInfo[#tInfo + 1] = userSeq
      end
      local flag_gsdn = _checkNeiDan_GeShanDaNiu_OnTarget(warId, warRound, userPos, userObj, targetPos, tInfo, damageHp, protectPos)
      local yjckData = userObj:getTempProperty(PROPERTY_YINGJICHANGKONG)
      if yjckData ~= 0 and yjckData ~= nil then
        local yjckRound, yjckNum, yjckCoeff, llRequire, yjckSkill = unpack(yjckData, 1, 5)
        local userLiLiang = userObj:getProperty(PROPERTY_LiLiang)
        if yjckNum > 0 and yjckCoeff > 0 and (llRequire <= userLiLiang or userObj:getType() == LOGICTYPE_MONSTER) and warRound >= yjckRound and not _checkRoleIsInState(targetObj, EFFECTTYPE_FROZEN) then
          local fenlieList = _getNormalAttackExtraTarget(warId, userPos, targetPos, targetTeam, yjckNum, protectPos)
          for _, feiliePos in pairs(fenlieList) do
            fenlieObj = _getFightRoleObjByPos(warId, feiliePos)
            if fenlieObj and fenlieObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and not _checkRoleIsInState(fenlieObj, EFFECTTYPE_FROZEN) then
              local damageHpBak = 0
              if isSBAttack then
                damageHpBak = 1
              else
                local damageHpTemp, _, _, _, _ = _getFinalWuliDamage(userObj, fenlieObj, userPos, nHit, maxHitTimes, true, false, damageParam)
                damageHpBak = damageHpTemp
              end
              local yjckDamageHp = _checkDamage(damageHpBak * yjckCoeff)
              local fenlieEffList = {}
              local maxHpMpChanged_fl = false
              local fenliePosHp, fenlieDamageHp, maxHpMpChanged_fl, shareSeq_fl = _realWuliDamageOnTarget(warId, warRound, feiliePos, fenlieObj, yjckDamageHp, fenlieEffList, userPos, userObj, true)
              local fenliePosMp = fenlieObj:getProperty(PROPERTY_MP)
              if fenlieObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and _checkRoleIsInState(fenlieObj, EFFECTTYPE_SLEEP) then
                _removeRoleEffectState(fenlieObj, EFFECTTYPE_SLEEP)
                fenlieEffList[#fenlieEffList + 1] = EFFECTTYPE_SLEEP_OFF
              end
              tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, feiliePos, fenliePosHp, fenliePosMp, fenlieDamageHp, 0, {}, fenlieEffList, nil, nil, nil, nil, yjckSkill, nil)
              if maxHpMpChanged_fl == true then
                local flMaxHp = fenlieObj:getMaxProperty(PROPERTY_HP)
                local flMaxMp = fenlieObj:getMaxProperty(PROPERTY_MP)
                tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillHpMpBase(userPos, feiliePos, fenliePosHp, fenliePosMp, flMaxHp, flMaxMp)
              end
              yjckSkill = nil
              if shareSeq_fl ~= nil then
                for _, sSeq in pairs(shareSeq_fl) do
                  tInfo[#tInfo + 1] = sSeq
                end
              end
            end
          end
          _checkInitPetSkill_YingJiChangKong(warId, warRound, userObj, true)
          yjckFlag = true
        end
      end
      if not yjckFlag then
        local fenliePro, fenlieNum, fenlieSkill = userObj:GetPetSkillFenLieGongJi()
        local fenliefu = userObj:getProperty(PROPERTY_ADDFENLIE) or 0
        if fenliefu > 0 then
          fenliePro = fenliePro + fenliefu
          fenlieNum = math.max(fenlieNum, 1)
          fenlieSkill = PETSKILL_FENLIEGONGJI
        end
        if _canAffectOnPro(fenliePro) and not _checkRoleIsInState(targetObj, EFFECTTYPE_FROZEN) then
          local fenlieList = _getNormalAttackExtraTarget(warId, userPos, targetPos, targetTeam, fenlieNum, protectPos)
          local index = 1
          for _, feiliePos in pairs(fenlieList) do
            fenlieObj = _getFightRoleObjByPos(warId, feiliePos)
            if fenlieObj and fenlieObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and not _checkRoleIsInState(fenlieObj, EFFECTTYPE_FROZEN) then
              local damageHpBak = 0
              if isSBAttack then
                damageHpBak = 1
              else
                local damageHpTemp, _, _, _, _ = _getFinalWuliDamage(userObj, fenlieObj, userPos, nHit, maxHitTimes, true, false, damageParam)
                damageHpBak = damageHpTemp
              end
              local fenlieEffList = {}
              local maxHpMpChanged_fl = false
              local fenliePosHp, fenlieDamageHp, maxHpMpChanged_fl, shareSeq_fl = _realWuliDamageOnTarget(warId, warRound, feiliePos, fenlieObj, damageHpBak, fenlieEffList, userPos, userObj, true)
              local fenliePosMp = fenlieObj:getProperty(PROPERTY_MP)
              if fenlieObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and _checkRoleIsInState(fenlieObj, EFFECTTYPE_SLEEP) then
                _removeRoleEffectState(fenlieObj, EFFECTTYPE_SLEEP)
                fenlieEffList[#fenlieEffList + 1] = EFFECTTYPE_SLEEP_OFF
              end
              if index == 1 then
                tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, feiliePos, fenliePosHp, fenliePosMp, fenlieDamageHp, 0, {EFFECTTYPE_FENSHEN}, fenlieEffList, nil, nil, nil, nil, fenlieSkill, nil)
              else
                tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, feiliePos, fenliePosHp, fenliePosMp, fenlieDamageHp, 0, {EFFECTTYPE_FENSHEN}, fenlieEffList, nil, nil, nil, nil, nil, nil)
              end
              if maxHpMpChanged_fl == true then
                local flMaxHp = fenlieObj:getMaxProperty(PROPERTY_HP)
                local flMaxMp = fenlieObj:getMaxProperty(PROPERTY_MP)
                tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillHpMpBase(userPos, feiliePos, fenliePosHp, fenliePosMp, flMaxHp, flMaxMp)
              end
              index = index + 1
              if shareSeq_fl ~= nil then
                for _, sSeq in pairs(shareSeq_fl) do
                  tInfo[#tInfo + 1] = sSeq
                end
              end
            end
          end
        end
      end
      if not isHunLuan and not isSBAttack then
        local fanbuPro, fanbuCoeff, fanbuSkill = userObj:GetPetSkillCiWuFanBu()
        if _canAffectOnPro(fanbuPro) then
          local masterPos = _getMasterPosByPetPos(userPos)
          local masterObj = _getFightRoleObjByPos_WithDeadHero(warId, masterPos)
          if masterObj then
            local masterHp = masterObj:getProperty(PROPERTY_HP)
            local masterMp = masterObj:getProperty(PROPERTY_MP)
            local masterMaxHp = masterObj:getMaxProperty(PROPERTY_HP)
            if masterHp < masterMaxHp then
              if _checkRoleIsInState(masterObj, EFFECTTYPE_FROZEN) then
                tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillAddHpMp(userPos, masterPos, masterHp, masterMp, 0, 0, fanbuSkill, nil, nil, {EFFECTTYPE_IMMUNITY})
              elseif _checkRoleIsInState(masterObj, EFFECTTYPE_DUOHUNSUOMING) then
                tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillAddHpMp(userPos, masterPos, masterHp, masterMp, 0, 0, fanbuSkill, nil, nil, {EFFECTTYPE_INVALID})
              else
                local fanbuHp = _checkDamage(damageHp * fanbuCoeff)
                masterHp = masterHp + fanbuHp
                if masterMaxHp < masterHp then
                  masterHp = masterMaxHp
                end
                masterObj:setProperty(PROPERTY_HP, masterHp)
                local masterFuhuo
                if masterObj:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD then
                  masterObj:setProperty(PROPERTY_DEAD, ROLESTATE_LIVE)
                  masterFuhuo = 1
                end
                tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillAddHpMp(userPos, masterPos, masterHp, masterMp, fanbuHp, 0, fanbuSkill, nil, masterFuhuo)
              end
            end
          end
        end
      end
      if not isHunLuan and not isSBAttack then
        local fanbuPro, fanbuCoeff, fanbuSkill = userObj:GetPetSkillFanBuZhiSi()
        if _canAffectOnPro(fanbuPro) then
          local masterPos = _getMasterPosByPetPos(userPos)
          local masterObj = _getFightRoleObjByPos_WithDeadHero(warId, masterPos)
          if masterObj then
            local masterHp = masterObj:getProperty(PROPERTY_HP)
            local masterMp = masterObj:getProperty(PROPERTY_MP)
            local masterMaxMp = masterObj:getMaxProperty(PROPERTY_MP)
            if masterMp < masterMaxMp then
              if _checkRoleIsInState(masterObj, EFFECTTYPE_FROZEN) then
                tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillAddHpMp(userPos, masterPos, masterHp, masterMp, 0, 0, fanbuSkill, nil, nil, {EFFECTTYPE_IMMUNITY})
              else
                local fanbuMp = _checkDamage(damageHp * fanbuCoeff)
                masterMp = masterMp + fanbuMp
                if masterMaxMp < masterMp then
                  masterMp = masterMaxMp
                end
                masterObj:setProperty(PROPERTY_MP, masterMp)
                tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillAddHpMp(userPos, masterPos, masterHp, masterMp, 0, fanbuMp, fanbuSkill)
              end
            end
          end
        end
      end
      if targetObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and (targetObj:getType() == LOGICTYPE_PET or targetObj:getType() == LOGICTYPE_HERO) and not isHunLuan and not isSBAttack and nHit == 1 then
        local sstzPro, sstzRound, sstzCoeff_1, sstzCoeff_2, sstzSkillId = userObj:GetPetSkillShunShuiTuiZhou()
        if _canAffectOnPro(sstzPro) then
          local tObjEffect = targetObj:getEffects()
          local effInfo = tObjEffect[EFFECTTYPE_SHUNSHUITUIZHOU]
          if effInfo == nil then
            local maxAttr
            for _, tAttr in pairs({
              PROPERTY_GenGu,
              PROPERTY_Lingxing,
              PROPERTY_LiLiang,
              PROPERTY_MinJie
            }) do
              local tAttrValue = targetObj:getProperty(tAttr)
              if maxAttr == nil or tAttrValue > maxAttr[2] then
                maxAttr = {tAttr, tAttrValue}
              elseif maxAttr[2] == tAttrValue and math.random(1, 2) == 1 then
                maxAttr = {tAttr, tAttrValue}
              end
            end
            if maxAttr ~= nil then
              local effectData = {}
              if maxAttr[1] == PROPERTY_GenGu then
                local gg = targetObj:getProperty(PROPERTY_GenGu)
                local hp = targetObj:getProperty(PROPERTY_HP)
                local maxHp = targetObj:getMaxProperty(PROPERTY_HP)
                local eCoeff = math.max(1 - sstzCoeff_1, 0)
                local eAttrValue = math.floor(gg * eCoeff)
                targetObj:setProperty(PROPERTY_GenGu, eAttrValue)
                local newMaxHp = CalculateRoleHP(targetObj)
                targetObj:setMaxProperty(PROPERTY_HP, newMaxHp)
                local subHp = 0
                if hp > newMaxHp then
                  subHp = hp - newMaxHp
                  targetObj:setProperty(PROPERTY_HP, newMaxHp)
                end
                effectData.eAttr = PROPERTY_GenGu
                effectData.gg = gg
                effectData.subHp = subHp
                objEffectList[#objEffectList + 1] = EFFECTTYPE_SHUNSHUITUIZHOU
                local hp = targetObj:getProperty(PROPERTY_HP)
                local mp = targetObj:getProperty(PROPERTY_MP)
                local maxhp = targetObj:getMaxProperty(PROPERTY_HP)
                local maxmp = targetObj:getMaxProperty(PROPERTY_MP)
                tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillHpMpBase(userPos, targetPos, hp, mp, maxhp, maxmp, sstzSkillId)
              elseif maxAttr[1] == PROPERTY_Lingxing then
                local lx = targetObj:getProperty(PROPERTY_Lingxing)
                local mp = targetObj:getProperty(PROPERTY_MP)
                local maxMp = targetObj:getMaxProperty(PROPERTY_MP)
                local eCoeff = math.max(1 - sstzCoeff_1, 0)
                local eAttrValue = math.floor(lx * eCoeff)
                targetObj:setProperty(PROPERTY_Lingxing, eAttrValue)
                local newMaxMp = CalculateRoleMP(targetObj)
                targetObj:setMaxProperty(PROPERTY_MP, newMaxMp)
                local subMp = 0
                if mp > newMaxMp then
                  subMp = mp - newMaxMp
                  targetObj:setProperty(PROPERTY_MP, newMaxMp)
                end
                effectData.eAttr = PROPERTY_Lingxing
                effectData.lx = lx
                effectData.subMp = subMp
                objEffectList[#objEffectList + 1] = EFFECTTYPE_SHUNSHUITUIZHOU
                local hp = targetObj:getProperty(PROPERTY_HP)
                local mp = targetObj:getProperty(PROPERTY_MP)
                local maxhp = targetObj:getMaxProperty(PROPERTY_HP)
                local maxmp = targetObj:getMaxProperty(PROPERTY_MP)
                tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillHpMpBase(userPos, targetPos, hp, mp, maxhp, maxmp, sstzSkillId)
              elseif maxAttr[1] == PROPERTY_LiLiang then
                local ll = targetObj:getProperty(PROPERTY_LiLiang)
                local eCoeff = math.max(1 - sstzCoeff_1, 0)
                local eAttrValue = math.floor(ll * eCoeff)
                targetObj:setProperty(PROPERTY_LiLiang, eAttrValue)
                local newAp = CalculateRoleAP(targetObj)
                targetObj:setProperty(PROPERTY_AP, newAp)
                effectData.eAttr = PROPERTY_LiLiang
                effectData.ll = ll
                objEffectList[#objEffectList + 1] = EFFECTTYPE_SHUNSHUITUIZHOU
                local hp = targetObj:getProperty(PROPERTY_HP)
                local mp = targetObj:getProperty(PROPERTY_MP)
                local maxhp = targetObj:getMaxProperty(PROPERTY_HP)
                local maxmp = targetObj:getMaxProperty(PROPERTY_MP)
                tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillHpMpBase(userPos, targetPos, hp, mp, maxhp, maxmp, sstzSkillId)
              elseif maxAttr[1] == PROPERTY_MinJie then
                local mj = targetObj:getProperty(PROPERTY_MinJie)
                local eCoeff = math.max(1 - sstzCoeff_2, 0)
                local eAttrValue = math.floor(mj * eCoeff)
                targetObj:setProperty(PROPERTY_MinJie, eAttrValue)
                local newSp = CalculateRoleSP(targetObj)
                targetObj:setProperty(PROPERTY_SP, newSp)
                effectData.eAttr = PROPERTY_MinJie
                effectData.mj = mj
                objEffectList[#objEffectList + 1] = EFFECTTYPE_SHUNSHUITUIZHOU
                local hp = targetObj:getProperty(PROPERTY_HP)
                local mp = targetObj:getProperty(PROPERTY_MP)
                local maxhp = targetObj:getMaxProperty(PROPERTY_HP)
                local maxmp = targetObj:getMaxProperty(PROPERTY_MP)
                tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillHpMpBase(userPos, targetPos, hp, mp, maxhp, maxmp, sstzSkillId)
              end
              _addEffectOnTarget(targetObj, EFFECTTYPE_SHUNSHUITUIZHOU, sstzRound, effectData)
            end
          else
            _addEffectOnTarget(targetObj, EFFECTTYPE_SHUNSHUITUIZHOU, sstzRound, effInfo[3])
            local hp = targetObj:getProperty(PROPERTY_HP)
            local mp = targetObj:getProperty(PROPERTY_MP)
            local maxhp = targetObj:getMaxProperty(PROPERTY_HP)
            local maxmp = targetObj:getMaxProperty(PROPERTY_MP)
            tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillHpMpBase(userPos, targetPos, hp, mp, maxhp, maxmp, sstzSkillId)
          end
        end
      end
      if userObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and targetObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
        local fEffList = {EFFECTTYPE_REVERBERATE}
        local fObjEffList = {}
        local ftHp = _getNormalExtraReverberate(userObj, targetObj, damageHp)
        local fEffList_Extra = {}
        local nd_wfcz
        local ftHp_Extra = _getNeiDan_WanFoChaoZong_Reverberate(userObj, targetObj, fEffList_Extra, damageHp)
        if ftHp_Extra > 0 then
          ftHp = ftHp + ftHp_Extra
          fEffList = fEffList_Extra
          nd_wfcz = {NDSKILL_WANFOCHAOZONG}
        end
        local ftWeak = userObj:getProperty(PROPERTY_DEL_ZHEN)
        if ftHp > 0 then
          ftHp = _checkDamage(ftHp - ftWeak)
        end
        if ftHp > 0 then
          if not _RoleIsDamgeImmunity(userObj) then
            local ftMp = 0
            local jgbrCoeff, jgbrSkill = targetObj:GetPetSkillJingGuanBaiRi()
            if jgbrCoeff > 0 then
              ftMp = _checkDamage(ftHp * jgbrCoeff)
              fEffList[#fEffList + 1] = EFFECTTYPE_JINGGUANBAIRI
            end
            userHp = userObj:getProperty(PROPERTY_HP)
            userMp = userObj:getProperty(PROPERTY_MP)
            userHp = userHp - ftHp
            local maxHpMpChanged_ft = false
            if userHp <= 0 then
              userHp = 0
              userHp, maxHpMpChanged_ft = _setRoleIsDeadInWar(warId, warRound, userPos, userObj, fObjEffList)
            end
            userObj:setProperty(PROPERTY_HP, userHp)
            if ftMp > 0 then
              userMp = math.max(userMp - ftMp, 0)
              userObj:setProperty(PROPERTY_MP, userMp)
            end
            tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(targetPos, userPos, userHp, userMp, ftHp, ftMp, fEffList, fObjEffList, nil, nil, nd_wfcz)
            if maxHpMpChanged_ft == true then
              local uMaxHp = userObj:getMaxProperty(PROPERTY_HP)
              local uMaxMp = userObj:getMaxProperty(PROPERTY_MP)
              tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillHpMpBase(targetPos, userPos, userHp, userMp, uMaxHp, uMaxMp)
            end
            print_SkillLog_Reverberate(warId, targetPos, userPos, ftHp, 0)
          else
            userHp = userObj:getProperty(PROPERTY_HP)
            userMp = userObj:getProperty(PROPERTY_MP)
            tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(targetPos, userPos, userHp, userMp, 0, 0, fEffList, {EFFECTTYPE_IMMUNITY_DAMAGE}, nil, nil, nd_wfcz)
          end
        end
      end
      if not flag_gsdn and not isSBAttack and userObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and targetObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
        _checkNeiDan_HaoRanZhengQi_ExtraDamageOnTarget(warId, warRound, userPos, userObj, targetPos, targetObj, tInfo)
      end
      if not isSBAttack and userObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and targetObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
        _checkWuLi_ExtraSkillOnTarget(warId, warRound, userPos, userObj, targetPos, targetObj, tInfo)
      end
      if nHit == 1 and userObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and targetObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
        if not isHunLuan and not isSBAttack then
          local spro, sround, petSkillId, skillId = userObj:GetPetSkillFengYin()
          if _canAffectOnPro(spro) and _canSkillOnRole_Ice(targetObj) then
            local targetHp = targetObj:getProperty(PROPERTY_HP)
            local targetMp = targetObj:getProperty(PROPERTY_MP)
            local tEffList = {}
            local currAllEffectList = targetObj:getEffects()
            local newEffects = {}
            local maxHpMpChanged = false
            for eID, eData in pairs(currAllEffectList) do
              if EFFECTBUFF_FROZEN_CLEAR[eID] ~= nil then
                local eOffID = _getEffectOffID(eID)
                if eOffID ~= nil then
                  maxHpMpChanged = _checkDurativeEffectOnRole_Off(warId, targetPos, targetObj, eID, eOffID, eData, false) or maxHpMpChanged
                  tEffList[#tEffList + 1] = eOffID
                end
              else
                newEffects[eID] = eData
              end
            end
            targetObj:setEffects(newEffects)
            _addEffectOnTarget(targetObj, EFFECTTYPE_FROZEN, sround, FROZENTYPE_PET)
            tEffList[#tEffList + 1] = EFFECTTYPE_FROZEN
            tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, 0, 0, {}, tEffList, skillId, nil, nil, nil, petSkillId, nil)
            if maxHpMpChanged == true then
              local tMaxHp = targetObj:getMaxProperty(PROPERTY_HP)
              local tMaxMp = targetObj:getMaxProperty(PROPERTY_MP)
              tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillHpMpBase(userPos, targetPos, targetHp, targetMp, tMaxHp, tMaxMp)
            end
          end
        end
        if not isHunLuan and not isSBAttack then
          local spro, sround, petSkillId, skillId = userObj:GetPetSkillHunLuan()
          if _canAffectOnPro(spro) and _canSkillOnRole_Confuse(targetObj) then
            local targetHp = targetObj:getProperty(PROPERTY_HP)
            local targetMp = targetObj:getProperty(PROPERTY_MP)
            _addEffectOnTarget(targetObj, EFFECTTYPE_CONFUSE, sround, CONFUSETYPE_PET)
            local tEffList = {}
            tEffList = {EFFECTTYPE_CONFUSE}
            tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, 0, 0, {}, tEffList, skillId, nil, nil, nil, petSkillId, nil)
          end
        end
      end
      if userObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and targetObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and not _checkRoleIsInState(targetObj, EFFECTTYPE_FROZEN) and _checkCounterAttack(userObj, targetObj) then
        local caTimes = targetObj:getTempProperty(PROPERTY_PWLFJTIMES) or 0
        if caTimes > 0 then
          targetObj:setTempProperty(PROPERTY_PWLFJTIMES, caTimes - 1)
          local caHp, attEList, objEList = _getFinalWuliDamage(targetObj, userObj, targetPos, 1, maxHitTimes, false, false)
          local maxHpMpChanged_ca = false
          local shareSeq_ca
          userHp, caHp, maxHpMpChanged_ca, shareSeq_ca = _realWuliDamageOnTarget(warId, warRound, userPos, userObj, caHp, objEList, targetPos, targetObj, false)
          objEffectList[#objEffectList + 1] = EFFECTTYPE_COUNTERATTACK_COME
          userMp = userObj:getProperty(PROPERTY_MP)
          attEList[#attEList + 1] = EFFECTTYPE_COUNTERATTACK
          tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(targetPos, userPos, userHp, userMp, caHp, 0, attEList, objEList)
          print_SkillLog_CounterAttack(warId, targetPos, userPos, caHp)
          if maxHpMpChanged_ca == true then
            local uMaxHp = userObj:getMaxProperty(PROPERTY_HP)
            local uMaxMp = userObj:getMaxProperty(PROPERTY_MP)
            tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillHpMpBase(targetPos, userPos, userHp, userMp, uMaxHp, uMaxMp)
          end
          if shareSeq_ca ~= nil then
            for _, sSeq in pairs(shareSeq_ca) do
              tInfo[#tInfo + 1] = sSeq
            end
          end
        else
          print_SkillLog_NoDoubleHitTimes(warId, targetPos)
        end
      end
      if userObj:getProperty(PROPERTY_DEAD) ~= ROLESTATE_LIVE or targetObj:getProperty(PROPERTY_DEAD) ~= ROLESTATE_LIVE then
        break
      end
      if _checkRoleIsInState(targetObj, EFFECTTYPE_FROZEN) then
        break
      end
    end
  else
    tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, 0, 0, {}, {EFFECTTYPE_MISS})
    print_SkillLog_Miss(warId, targetPos)
    if attParamOfFirstAttack ~= nil and attParamOfFirstAttack.blcx ~= nil then
      local _, blcxHpCoeff, blcxMpCoeff, blcxApCoeff, blcxSkill = userObj:GetPetSkillBingLinChengXia()
      if blcxHpCoeff > 0 and blcxMpCoeff > 0 and blcxApCoeff > 0 then
        local uHp = userObj:getProperty(PROPERTY_HP)
        local uMp = userObj:getProperty(PROPERTY_MP)
        local uMaxHp = userObj:getMaxProperty(PROPERTY_HP)
        local uMaxMp = userObj:getMaxProperty(PROPERTY_MP)
        local blcxHp = math.ceil(uMaxHp * blcxHpCoeff)
        local blcxMp = math.ceil(uMaxMp * blcxMpCoeff)
        if uHp > blcxHp and uMp >= blcxMp then
          uHp = uHp - blcxHp
          uMp = uMp - blcxMp
          userObj:setProperty(PROPERTY_HP, uHp)
          userObj:setProperty(PROPERTY_MP, uMp)
          tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillDamageHpMp(userPos, userPos, uHp, uMp, 0, 0, blcxSkill, nil, nil)
        end
      end
    end
  end
  _onNewFormatFightSequence(warId, formatFightSeq)
  if protectObj ~= nil then
    _formatAndSendBackToPosSeqOfTarget(warId, protectPos)
    g_WarAiInsList[warId]:DelProtectData(protectPos)
  end
  if pursuitFlag and not isSBAttack then
    local canPursuitFlag = false
    if userObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and not yjckFlag and not _getTheFightIsEnd(warId) then
      for _, liveObj in pairs(allLiveObjBeforeAttack) do
        if liveObj == nil or liveObj:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD then
          local pursuitTimes = userObj:getTempProperty(PROPERTY_PURSUIT) or 0
          if pursuitTimes > 0 then
            canPursuitFlag = true
            userObj:setTempProperty(PROPERTY_PURSUIT, pursuitTimes - 1)
          end
          break
        end
      end
    end
    if canPursuitFlag then
      _formatTipSequence(warId, userPos, SKILLTIP_PURSUIT, 2)
      if _checkRoleIsInState(userObj, EFFECTTYPE_CONFUSE) then
        userObj:ConfuseAttack()
      elseif _checkRoleIsInState(userObj, EFFECTTYPE_FENGMO) then
        userObj:FengMoAttack(nil)
      else
        userObj:NormalAttackOneRandomEnemy()
      end
    else
      userObj:setTempProperty(PROPERTY_PURSUIT, DEFINE_PETSKILL_PURSUIT_MAXTIMES)
    end
  end
  _callBack(callback)
end
function _checkSelectTarget(warId, userPos, selectPos, deadIsOk, exceptSelf, certainType, stealthIsOk)
  if selectPos == nil or selectPos == 0 then
    return nil
  end
  deadIsOk = deadIsOk or false
  exceptSelf = exceptSelf or false
  stealthIsOk = stealthIsOk or false
  local selectObj = _getFightRoleObjByPos_WithDeadHero(warId, selectPos)
  if selectObj and (selectObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE or deadIsOk) and (not _checkRoleIsInState(selectObj, EFFECTTYPE_STEALTH) or userPos == selectPos or stealthIsOk) and (userPos ~= selectPos or exceptSelf ~= true) and (certainType == nil or certainType[selectObj:getType()] ~= nil) then
    return selectPos
  end
  local team = _getTeamByPos(warId, selectPos)
  local postList = _getPosListByPosAndTeamWithSpeedSorted(warId, team, TARGETTYPE_MYSIDE)
  while true do
    if #postList <= 0 then
      break
    end
    local pos = table.remove(postList, math.random(1, #postList))
    local posObj = _getFightRoleObjByPos_WithDeadHero(warId, pos)
    if posObj and (posObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE or deadIsOk) and (not _checkRoleIsInState(posObj, EFFECTTYPE_STEALTH) or userPos == pos or stealthIsOk) and (userPos ~= pos or exceptSelf ~= true) and (certainType == nil or certainType[posObj:getType()] ~= nil) then
      return pos
    end
  end
  return nil
end
function _getNormalAttackExtraTarget(warId, userPos, selectPos, team, targetNum, protectPos)
  local posList = _getPosListByPosAndTeamWithSpeedSorted(warId, team, TARGETTYPE_MYSIDE)
  local targetList = {}
  local i = 1
  while targetNum >= i do
    local n = #posList
    if n <= 0 then
      break
    end
    local rdIdx = math.random(1, n)
    local pos = table.remove(posList, rdIdx)
    if pos ~= selectPos and pos ~= protectPos and pos ~= userPos then
      local posObj = _getFightRoleObjByPos(warId, pos)
      if posObj and not _checkRoleIsInState(posObj, EFFECTTYPE_STEALTH) then
        targetList[#targetList + 1] = pos
        i = i + 1
      end
    end
  end
  return targetList
end
function _checkMiss(userObj, targetObj)
  local hitPro = userObj:getProperty(PROPERTY_PACC)
  local hitPro_Ex = _getTargetTempAttr(userObj, PROPERTY_PACC)
  hitPro = hitPro + hitPro_Ex
  local missProKang = userObj:getProperty(PROPERTY_PFSBL)
  local missPro = targetObj:getProperty(PROPERTY_PSBL)
  local finalPro = hitPro + missProKang - missPro
  if finalPro <= 0.5 then
    finalPro = 0.5
  end
  return not _canAffectOnPro(finalPro)
end
function _checkFury(userObj)
  local pro = userObj:getProperty(PROPERTY_PKUANGBAO)
  local pro_Ex = _getTargetTempAttr(userObj, PROPERTY_PKUANGBAO)
  pro = pro + pro_Ex
  return _canAffectOnPro(pro)
end
function _checkFatally(userObj, targetObj)
  local pro = userObj:getProperty(PROPERTY_PCRIT)
  local pro_Ex = _getTargetTempAttr(userObj, PROPERTY_PKUANGBAO)
  pro = pro + pro_Ex
  local kangPro = targetObj:getProperty(PROPERTY_FPCRIT)
  finalPro = pro - kangPro
  return _canAffectOnPro(finalPro)
end
function _checkDoubleHit(userObj, targetObj)
  local pro = userObj:getProperty(PROPERTY_PLJPRO)
  return _canAffectOnPro(pro)
end
function _checkCounterAttack(userObj, targetObj)
  local proKang = userObj:getProperty(PROPERTY_PFWLFJPRO)
  local pro = targetObj:getProperty(PROPERTY_PWLFJPRO)
  pro = pro - proKang
  return _canAffectOnPro(pro)
end
function _checkReverberate(targetObj)
  local pro = targetObj:getProperty(PROPERTY_FTPRO)
  return _canAffectOnPro(pro)
end
function _getFinalWuliDamage(userObj, targetObj, userPos, nHit, maxHitTimes, isNormalAttack, isMainTarget, oriparam)
  if oriparam == nil then
    oriparam = {}
  end
  local param = DeepCopyTable(oriparam)
  local warId = userObj:getWarID()
  local attEffectList = {}
  local objEffectList = {}
  local userSeq
  local damageHp = userObj:getProperty(PROPERTY_AP)
  local damageHp_Ex = _getTargetTempAttr(userObj, PROPERTY_AP)
  damageHp = damageHp * (1 + damageHp_Ex)
  local defence = targetObj:getProperty(PROPERTY_PFYL)
  if _checkRoleIsInState(targetObj, EFFECTTYPE_FURY) then
    defence = 0
  end
  local wlkang = targetObj:getProperty(PROPERTY_PDEFEND)
  local wlkang_Ex = _getTargetAllTempKangPro(targetObj, SKILLATTR_WULI)
  wlkang = wlkang + wlkang_Ex
  local wlfkang = userObj:getProperty(PROPERTY_FPDEFEND)
  if isNormalAttack then
    local pro = userObj:getProperty(PROPERTY_PASSIVE_PHYSICAL_RATE)
    if _canAffectOnPro(pro) then
      local sub_coeff = userObj:getProperty(PROPERTY_PASSIVE_PHYSICAL)
      defence = defence * (1 - sub_coeff)
      defence = math.max(defence, 0)
      wlkang = math.max(wlkang - sub_coeff, 0)
    end
  end
  if oriparam.dk ~= nil then
    damageHp = damageHp * oriparam.dk
  end
  damageHp = (damageHp - defence) * (1 - wlkang + wlfkang)
  local xqCoeff = userObj:getProperty(PROPERTY_QHSH)
  damageHp = damageHp * (1 + xqCoeff)
  local wxCoeff = _getWuXingKeZhiXiuZheng(userObj, targetObj, WUXING_WULI)
  damageHp = damageHp * (1 + wxCoeff)
  if oriparam.blcx ~= nil and isNormalAttack and nHit == 1 then
    local _, blcxHpCoeff, blcxMpCoeff, blcxApCoeff, blcxSkill = userObj:GetPetSkillBingLinChengXia()
    if blcxHpCoeff > 0 and blcxMpCoeff > 0 and blcxApCoeff > 0 then
      if isMainTarget == true then
        local uHp = userObj:getProperty(PROPERTY_HP)
        local uMp = userObj:getProperty(PROPERTY_MP)
        local uMaxHp = userObj:getMaxProperty(PROPERTY_HP)
        local uMaxMp = userObj:getMaxProperty(PROPERTY_MP)
        local blcxHp = math.ceil(uMaxHp * blcxHpCoeff)
        local blcxMp = math.ceil(uMaxMp * blcxMpCoeff)
        if uHp > blcxHp and uMp >= blcxMp then
          uHp = uHp - blcxHp
          uMp = uMp - blcxMp
          userObj:setProperty(PROPERTY_HP, uHp)
          userObj:setProperty(PROPERTY_MP, uMp)
          damageHp = damageHp * blcxApCoeff
          param.blcx_ok = true
          userSeq = _formatSubNormalSeqOfTarget_PetSkillDamageHpMp(userPos, userPos, uHp, uMp, 0, 0, blcxSkill, nil, nil)
        end
      elseif oriparam.blcx_ok == true then
        damageHp = damageHp * blcxApCoeff
      end
    end
  end
  if param.rdk == nil then
    local k = math.random(95, 105) / 100
    damageHp = damageHp * k
    param.rdk = k
  else
    damageHp = damageHp * param.rdk
  end
  local isFury = false
  if param.fury == nil then
    isFury = _checkFury(userObj)
  end
  if param.fury == true or param.fury == nil and isFury then
    local defence = userObj:getProperty(PROPERTY_PFYL)
    damageHp = damageHp * 2.2 + defence
    _addEffectOnTarget(userObj, EFFECTTYPE_FURY, 1)
    attEffectList[#attEffectList + 1] = EFFECTTYPE_FURY
    param.fury = true
    isFury = true
    print_SkillLog_KuangBao(warId, userPos)
  else
    param.fury = false
  end
  if param.fatal == true or param.fatal == nil and not isFury and _checkFatally(userObj, targetObj) then
    local targetHp = targetObj:getProperty(PROPERTY_HP)
    local damageHp_ZM_Max = damageHp * data_Variables.ZhiMingMaxCoeff
    damageHp = damageHp * 1.5 + targetHp * 0.1
    if damageHp_ZM_Max < damageHp then
      damageHp = damageHp_ZM_Max
    end
    attEffectList[#attEffectList + 1] = EFFECTTYPE_FATALLY
    param.fatal = true
    print_SkillLog_ZhiMing(warId, userPos)
  else
    param.fatal = false
  end
  damageHp = _checkDamage(damageHp)
  if maxHitTimes > 1 and nHit > 1 then
    damageHp = _checkDamage(damageHp * 0.6 ^ (nHit - 1))
  end
  return damageHp, attEffectList, objEffectList, userSeq, param
end
function _realWuliDamageOnTarget(warId, warRound, targetPos, targetObj, damageHp, objEffectList, userPos, userObj, checkTx)
  local targetHp = targetObj:getProperty(PROPERTY_HP)
  if _RoleIsDamgeImmunity(targetObj) then
    objEffectList[#objEffectList + 1] = EFFECTTYPE_IMMUNITY_DAMAGE
    return targetHp, 0, false, nil
  else
    local dk = targetObj:getProperty(PROPERTY_PWLFYXS)
    local dk_Exp = targetObj:getTempProperty(PROPERTY_PWLFYXS) or 0
    dk = math.max(dk + dk_Exp, 0)
    damageHp = _checkDamage(damageHp * (1 - dk))
    if checkTx == true and userObj and userObj:getType() == LOGICTYPE_MONSTER and _checkRoleIsInState(userObj, EFFECTTYPE_CONFUSE) and targetObj:getType() == LOGICTYPE_MONSTER then
      local uteam = userObj:getProperty(PROPERTY_TEAM)
      local tteam = targetObj:getProperty(PROPERTY_TEAM)
      if uteam == tteam then
        if userObj:PossessMonsterTeXing(MONSTER_TX_15) then
          local tableData = data_MonsterTeXing[MONSTER_TX_15] or {}
          local calparam = tableData.calparam or {}
          local coeff = calparam[1] or 1
          damageHp = _checkDamage(damageHp * coeff)
        elseif userObj:PossessMonsterTeXing(MONSTER_TX_16) then
          local tableData = data_MonsterTeXing[MONSTER_TX_16] or {}
          local calparam = tableData.calparam or {}
          local coeff = calparam[1] or 1
          damageHp = _checkDamage(damageHp * coeff)
        end
      end
    end
    if _checkRoleIsInState(targetObj, EFFECTTYPE_ADV_DEFEND) then
      objEffectList[#objEffectList + 1] = EFFECTTYPE_ADV_DEFEND
    end
    local sharePos, shareObj = _getShareDamagePos(warId, targetObj, targetPos)
    local shareSeq
    if shareObj ~= nil then
      local sk_1, sk_2, _ = _computeSkillEffect_ShouHuCangSheng(SKILL_SHOUHUCANGSHENG)
      local shareDamage = _checkDamage(damageHp * sk_2)
      damageHp = _checkDamage(damageHp * sk_1)
      objEffectList[#objEffectList + 1] = EFFECTTYPE_SHAREDAMAGE
      shareSeq = {}
      local shareHp = shareObj:getProperty(PROPERTY_HP)
      local shareMp = shareObj:getProperty(PROPERTY_MP)
      local shareEffList = {EFFECTTYPE_NOSKILLANI}
      if not _RoleIsDamgeImmunity(shareObj) then
        local maxHpMpChanged_Share = false
        shareHp = math.max(shareHp - shareDamage)
        if shareHp <= 0 then
          shareHp, maxHpMpChanged_Share = _setRoleIsDeadInWar(warId, warRound, sharePos, shareObj, shareEffList)
        end
        shareObj:setProperty(PROPERTY_HP, shareHp)
        if shareObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and _checkRoleIsInState(shareObj, EFFECTTYPE_SLEEP) then
          _removeRoleEffectState(shareObj, EFFECTTYPE_SLEEP)
          shareEffList[#shareEffList + 1] = EFFECTTYPE_SLEEP_OFF
        end
        shareSeq[#shareSeq + 1] = _formatSubNormalSeqOfTarget(userPos, sharePos, shareHp, shareMp, shareDamage, 0, {}, shareEffList)
        if maxHpMpChanged_Share then
          local shareMaxHp = shareObj:getMaxProperty(PROPERTY_HP)
          local shareMaxMp = shareObj:getMaxProperty(PROPERTY_MP)
          shareSeq[#shareSeq + 1] = _formatSubNormalSeqOfTarget_PetSkillHpMpBase(userPos, sharePos, shareHp, shareMp, shareMaxHp, shareMaxMp)
        end
      else
        shareEffList[#shareEffList + 1] = EFFECTTYPE_IMMUNITY_DAMAGE
        shareSeq[#shareSeq + 1] = _formatSubNormalSeqOfTarget(userPos, sharePos, shareHp, shareMp, 0, 0, {}, shareEffList)
      end
    end
    local maxHpMpChanged = false
    targetHp = targetHp - damageHp
    if targetHp <= 0 then
      targetHp = 0
      targetHp, maxHpMpChanged = _setRoleIsDeadInWar(warId, warRound, targetPos, targetObj, objEffectList)
    end
    targetObj:setProperty(PROPERTY_HP, targetHp)
    return targetHp, damageHp, maxHpMpChanged, shareSeq
  end
end
function _getNormalExtraReverberate(userObj, targetObj, damageHp)
  if _checkReverberate(targetObj) then
    local ftPro = targetObj:getProperty(PROPERTY_FTLV)
    local ftPro_k = userObj:getProperty(PROPERTY_PKFTLV)
    ftPro = ftPro - ftPro_k
    if ftPro < MIN_FTLV_NUM then
      ftPro = MIN_FTLV_NUM
    elseif ftPro > MAX_FTLV_NUM then
      ftPro = MAX_FTLV_NUM
    end
    ftHp = _checkDamage(damageHp * ftPro)
    return ftHp
  end
  return 0
end
function _checkNeiDan_GeShanDaNiu_OnTarget(warId, warRound, userPos, userObj, targetPos, tInfo, damageHp, protectPos)
  local success, rate = _getGeShanDaNiuSuccess(userObj)
  if not _canAffectOnPro(success) then
    return false
  end
  local okList = {}
  local targetList = {
    targetPos - 1,
    targetPos + 1,
    targetPos + DefineRelativePetAddPos,
    targetPos - DefineRelativePetAddPos,
    targetPos + DefineRelativePetAddPos + 1,
    targetPos + DefineRelativePetAddPos - 1,
    targetPos - DefineRelativePetAddPos + 1,
    targetPos - DefineRelativePetAddPos - 1
  }
  for _, pos in pairs(targetList) do
    local roleObj = _getFightRoleObjByPos(warId, pos)
    if roleObj and roleObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and pos ~= protectPos and pos ~= userPos and not _checkRoleIsInState(roleObj, EFFECTTYPE_STEALTH) then
      okList[#okList + 1] = {pos, roleObj}
    end
  end
  if #okList <= 0 then
    return false
  end
  local rdIndex = math.random(1, #okList)
  local tPos = okList[rdIndex][1]
  local tObj = okList[rdIndex][2]
  local tHp = tObj:getProperty(PROPERTY_HP)
  local tMp = tObj:getProperty(PROPERTY_MP)
  local attEffList = {}
  local objEffectList = {}
  local shareSeq = {}
  local maxHpMpChanged = false
  if _canSkillOnRole_NormalAttack(tObj) then
    if not _RoleIsDamgeImmunity(tObj) then
      damageHp = damageHp * rate
      local wxCoeff = _getWuXingKeZhiXiuZheng(userObj, tObj, WUXING_WULI)
      damageHp = damageHp * (1 + wxCoeff)
      local kGSDN = tObj:getProperty(PROPERTY_KANGNEIDAN_CALD)
      damageHp = _checkDamage(damageHp - kGSDN)
      local sharePos, shareObj = _getShareDamagePos(warId, tObj, tPos)
      if shareObj ~= nil then
        local sk_1, sk_2, _ = _computeSkillEffect_ShouHuCangSheng(SKILL_SHOUHUCANGSHENG)
        local shareDamage = _checkDamage(damageHp * sk_2)
        damageHp = _checkDamage(damageHp * sk_1)
        objEffectList[#objEffectList + 1] = EFFECTTYPE_SHAREDAMAGE
        local shareHp = shareObj:getProperty(PROPERTY_HP)
        local shareMp = shareObj:getProperty(PROPERTY_MP)
        local shareEffList = {EFFECTTYPE_NOSKILLANI}
        if not _RoleIsDamgeImmunity(shareObj) then
          local maxHpMpChanged_Share = false
          shareHp = math.max(shareHp - shareDamage)
          if shareHp <= 0 then
            shareHp, maxHpMpChanged_Share = _setRoleIsDeadInWar(warId, warRound, sharePos, shareObj, shareEffList)
          end
          shareObj:setProperty(PROPERTY_HP, shareHp)
          if shareObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and _checkRoleIsInState(shareObj, EFFECTTYPE_SLEEP) then
            _removeRoleEffectState(shareObj, EFFECTTYPE_SLEEP)
            shareEffList[#shareEffList + 1] = EFFECTTYPE_SLEEP_OFF
          end
          shareSeq[#shareSeq + 1] = _formatSubNormalSeqOfTarget(userPos, sharePos, shareHp, shareMp, shareDamage, 0, {}, shareEffList)
          if maxHpMpChanged_Share then
            local shareMaxHp = shareObj:getMaxProperty(PROPERTY_HP)
            local shareMaxMp = shareObj:getMaxProperty(PROPERTY_MP)
            shareSeq[#shareSeq + 1] = _formatSubNormalSeqOfTarget_PetSkillHpMpBase(userPos, sharePos, shareHp, shareMp, shareMaxHp, shareMaxMp)
          end
        else
          shareEffList[#shareEffList + 1] = EFFECTTYPE_IMMUNITY_DAMAGE
          shareSeq[#shareSeq + 1] = _formatSubNormalSeqOfTarget(userPos, sharePos, shareHp, shareMp, 0, 0, {}, shareEffList)
        end
      end
      tHp = tHp - damageHp
      if tHp <= 0 then
        tHp = 0
        tHp, maxHpMpChanged = _setRoleIsDeadInWar(warId, warRound, tPos, tObj, objEffectList)
      end
      tObj:setProperty(PROPERTY_HP, tHp)
    else
      damageHp = 0
      objEffectList[#objEffectList + 1] = EFFECTTYPE_IMMUNITY_DAMAGE
    end
  else
    damageHp = 0
    objEffectList[#objEffectList + 1] = EFFECTTYPE_IMMUNITY
  end
  tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, tPos, tHp, tMp, damageHp, 0, attEffList, objEffectList, nil, nil, {NDSKILL_GESHANDANIU})
  if maxHpMpChanged == true then
    local tMaxHp = tObj:getMaxProperty(PROPERTY_HP)
    local tMaxMp = tObj:getMaxProperty(PROPERTY_MP)
    tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillHpMpBase(userPos, tPos, tHp, tMp, tMaxHp, tMaxMp)
  end
  if #shareSeq > 0 then
    for _, sSeq in pairs(shareSeq) do
      tInfo[#tInfo + 1] = sSeq
    end
  end
  if damageHp > 0 and tObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and _checkRoleIsInState(tObj, EFFECTTYPE_SLEEP) then
    _removeRoleEffectState(tObj, EFFECTTYPE_SLEEP)
    objEffectList[#objEffectList + 1] = EFFECTTYPE_SLEEP_OFF
  end
  if tObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
    _checkNeiDan_WanFoChaoZong_Reverberate(warId, warRound, userPos, userObj, tPos, tObj, tInfo, damageHp)
  end
  return true
end
function _checkWuLi_ExtraSkillOnTarget(warId, warRound, userPos, userObj, targetPos, targetObj, tInfo)
  local poison_success, poison_skillID = _getWuLi_ExtraPoisonSkillDamageSuccess(userObj)
  if _canAffectOnPro(poison_success) then
    local kAttr = _getTotalKangPro(targetObj, SKILLATTR_POISON)
    local fkAttr = _getTotalFKangPro(userObj, SKILLATTR_POISON)
    local poison_skillExp = 1
    if _useSkillSuccess(userObj, poison_skillID, kAttr, fkAttr, poison_skillExp) then
      local pLevel = userObj:getProperty(PROPERTY_ROLELEVEL)
      local maxHp = targetObj:getMaxProperty(PROPERTY_HP)
      local ssv = userObj:getProperty(PROPERTY_STARSKILLVALUE)
      local extraCoeff = _getNormalSkill_ExtraDamageCoeff(userObj, SKILLATTR_POISON)
      local skillWeakCeoff = userObj:getProperty(PROPERTY_SKILLCOEFF)
      local damageWeak = _getNormalSkill_WeakenDamage(targetObj, SKILLATTR_POISON)
      local damageHp = _computeSkillDamage_Poison(poison_skillID, kAttr, fkAttr, poison_skillExp, 1, pLevel, maxHp, ssv, extraCoeff, skillWeakCeoff, damageWeak)
      local wxCoeff = _getWuXingKeZhiXiuZheng(userObj, targetObj, WUXING_RENFA)
      damageHp = _checkDamage(damageHp * (1 + wxCoeff))
      local skillRound = _computeSkillRound(poison_skillID, poison_skillExp, kAttr, fkAttr)
      local effectData = {}
      effectData.skillID = poison_skillID
      effectData.fkAttr = fkAttr
      effectData.skillExp = poison_skillExp
      effectData.pLevel = pLevel
      _addEffectOnTarget(targetObj, EFFECTTYPE_POISON, skillRound, effectData)
      local objEffectList = {EFFECTTYPE_POISON}
      _setExtraSkillDamageOnTarget(warId, warRound, poison_skillID, damageHp, 0, userPos, userObj, targetPos, targetObj, tInfo, objEffectList, false)
    end
  end
  local zhen_success, zhen_skillID = _getWuLi_ExtraZhenSkillDamageSuccess(userObj)
  if _canAffectOnPro(zhen_success) then
    local kAttr = _getTotalKangPro(targetObj, SKILLATTR_ZHEN)
    local fkAttr = _getTotalFKangPro(userObj, SKILLATTR_ZHEN)
    local zhen_skillExp = 1
    if _useSkillSuccess(userObj, zhen_skillID, kAttr, fkAttr, zhen_skillExp) then
      local pLevel = userObj:getProperty(PROPERTY_ROLELEVEL)
      local targetHp = targetObj:getProperty(PROPERTY_HP)
      local targetMp = targetObj:getProperty(PROPERTY_MP)
      local ssv = userObj:getProperty(PROPERTY_STARSKILLVALUE)
      local extraCoeff = _getNormalSkill_ExtraDamageCoeff(userObj, SKILLATTR_ZHEN)
      local skillWeakCeoff = userObj:getProperty(PROPERTY_SKILLCOEFF)
      local damageWeak = _getNormalSkill_WeakenDamage(targetObj, SKILLATTR_ZHEN)
      local damageHp, damageMp = _computeSkillDamage_Zhen(zhen_skillID, kAttr, fkAttr, zhen_skillExp, pLevel, targetHp, targetMp, ssv, extraCoeff, skillWeakCeoff, damageWeak)
      local wxCoeff = _getWuXingKeZhiXiuZheng(userObj, targetObj, WUXING_MOFA)
      damageHp = _checkDamage(damageHp * (1 + wxCoeff))
      damageMp = _checkDamage(damageMp * (1 + wxCoeff))
      _setExtraSkillDamageOnTarget(warId, warRound, zhen_skillID, damageHp, damageMp, userPos, userObj, targetPos, targetObj, tInfo, {}, false)
    end
  end
  local speed_success, speed_skillID = _getWuLi_ExtraSpeedSkillSuccess(targetObj)
  if _canAffectOnPro(speed_success) then
    local kAttr = _getTotalKangPro(userObj, SKILLATTR_SPEED)
    local fkAttr = _getTotalFKangPro(targetObj, SKILLATTR_SPEED)
    local speed_skillExp = 1
    if _useSkillSuccess(targetObj, speed_skillID, kAttr, fkAttr, speed_skillExp) then
      local ssv = userObj:getProperty(PROPERTY_STARSKILLVALUE)
      local sp = _computeSkillEffect_Speed(speed_skillID, speed_skillExp, ssv)
      local extraCoeff = _getNormalSkill_ExtraDamageCoeff(targetObj, SKILLATTR_SPEED)
      sp = sp + extraCoeff
      _setTargetTempAttr(targetObj, PROPERTY_SP, sp, EFFECTTYPE_ADV_SPEED)
      local skillRound = _computeSkillRound(speed_skillID, speed_skillExp, kAttr, fkAttr)
      _addEffectOnTarget(targetObj, EFFECTTYPE_ADV_SPEED, skillRound)
      local objEffectList = {EFFECTTYPE_ADV_SPEED}
      _setExtraSkillEffectOnTarget(userPos, targetPos, targetObj, tInfo, objEffectList)
    end
  end
  local pan_success, pan_skillID = _getWuLi_ExtraPanSkillSuccess(targetObj)
  if _canAffectOnPro(pan_success) then
    local kAttr = _getTotalKangPro(userObj, SKILLATTR_PAN)
    local fkAttr = _getTotalFKangPro(targetObj, SKILLATTR_PAN)
    local pan_skillExp = 1
    if _useSkillSuccess(targetObj, pan_skillID, kAttr, fkAttr, pan_skillExp) then
      local ssv = userObj:getProperty(PROPERTY_STARSKILLVALUE)
      local wlKang, xzKang, rzKang = _computeSkillEffect_Pan(pan_skillID, pan_skillExp, ssv)
      local extraCoeff = _getNormalSkill_ExtraDamageCoeff(targetObj, SKILLATTR_PAN)
      wlKang = wlKang + extraCoeff
      xzKang = xzKang + extraCoeff
      rzKang = rzKang + extraCoeff
      _setTargetTempKangPro(targetObj, SKILLATTR_WULI, wlKang, EFFECTTYPE_ADV_WULI)
      _setTargetTempKangPro(targetObj, SKILLATTR_POISON, rzKang, EFFECTTYPE_ADV_RENZU)
      _setTargetTempKangPro(targetObj, SKILLATTR_SLEEP, rzKang, EFFECTTYPE_ADV_RENZU)
      _setTargetTempKangPro(targetObj, SKILLATTR_CONFUSE, rzKang, EFFECTTYPE_ADV_RENZU)
      _setTargetTempKangPro(targetObj, SKILLATTR_ICE, rzKang, EFFECTTYPE_ADV_RENZU)
      _setTargetTempKangPro(targetObj, SKILLATTR_FIRE, xzKang, EFFECTTYPE_ADV_XIANZU)
      _setTargetTempKangPro(targetObj, SKILLATTR_WIND, xzKang, EFFECTTYPE_ADV_XIANZU)
      _setTargetTempKangPro(targetObj, SKILLATTR_THUNDER, xzKang, EFFECTTYPE_ADV_XIANZU)
      _setTargetTempKangPro(targetObj, SKILLATTR_WATER, xzKang, EFFECTTYPE_ADV_XIANZU)
      local skillRound = _computeSkillRound(pan_skillID, pan_skillExp, kAttr, fkAttr)
      _addEffectOnTarget(targetObj, EFFECTTYPE_ADV_WULI, skillRound)
      _addEffectOnTarget(targetObj, EFFECTTYPE_ADV_RENZU, skillRound)
      _addEffectOnTarget(targetObj, EFFECTTYPE_ADV_XIANZU, skillRound)
      local objEffectList = {
        EFFECTTYPE_ADV_WULI,
        EFFECTTYPE_ADV_RENZU,
        EFFECTTYPE_ADV_XIANZU
      }
      _setExtraSkillEffectOnTarget(userPos, targetPos, targetObj, tInfo, objEffectList)
    end
  end
  local attack_success, attack_skillID = _getWuLi_ExtraAttackSkillSuccess(targetObj)
  if _canAffectOnPro(attack_success) then
    local kAttr = _getTotalKangPro(userObj, SKILLATTR_ATTACK)
    local fkAttr = _getTotalFKangPro(targetObj, SKILLATTR_ATTACK)
    local attack_skillExp = 1
    if _useSkillSuccess(targetObj, attack_skillID, kAttr, fkAttr, attack_skillExp) then
      local ssv = userObj:getProperty(PROPERTY_STARSKILLVALUE)
      local ap, mz = _computeSkillEffect_Attack(attack_skillID, attack_skillExp, ssv)
      local extraCoeff = _getNormalSkill_ExtraDamageCoeff(targetObj, SKILLATTR_ATTACK)
      ap = ap + extraCoeff
      mz = mz + extraCoeff
      _setTargetTempAttr(targetObj, PROPERTY_AP, ap, EFFECTTYPE_ADV_DAMAGE)
      _setTargetTempAttr(targetObj, PROPERTY_PACC, mz, EFFECTTYPE_ADV_MINGZHONG)
      local skillRound = _computeSkillRound(attack_skillID, attack_skillExp, kAttr, fkAttr)
      _addEffectOnTarget(targetObj, EFFECTTYPE_ADV_DAMAGE, skillRound)
      _addEffectOnTarget(targetObj, EFFECTTYPE_ADV_MINGZHONG, skillRound)
      local objEffectList = {EFFECTTYPE_ADV_DAMAGE, EFFECTTYPE_ADV_MINGZHONG}
      _setExtraSkillEffectOnTarget(userPos, targetPos, targetObj, tInfo, objEffectList)
    end
  end
  local isPetNeiDan = userObj:getType() == LOGICTYPE_PET
  local fire_success, fire_skillID = _getWuLi_ExtraFireSkillDamageSuccess(userObj)
  if _canAffectOnPro(fire_success) then
    local kAttr = _getTotalKangPro(targetObj, SKILLATTR_FIRE)
    local fkAttr = _getTotalFKangPro(userObj, SKILLATTR_FIRE)
    local fire_skillExp = 1
    if _useSkillSuccess(userObj, fire_skillID, kAttr, fkAttr, fire_skillExp) then
      local extraCoeff = _getNormalSkill_ExtraDamageCoeff(userObj, SKILLATTR_FIRE)
      local damageWeak = _getNormalSkill_WeakenDamage(targetObj, SKILLATTR_FIRE)
      local skillWeakCeoff = userObj:getProperty(PROPERTY_SKILLCOEFF)
      local wxCoeff = _getWuXingKeZhiXiuZheng(userObj, targetObj, WUXING_XIANFA)
      if isPetNeiDan then
        local damageHp = _getNeiDanDamage_ZhuRongQuHuo(userObj, kAttr, fkAttr, extraCoeff, skillWeakCeoff, damageWeak)
        damageHp = _checkDamage(damageHp * (1 + wxCoeff))
        _setExtraSkillDamageOnTarget(warId, warRound, fire_skillID, damageHp, 0, userPos, userObj, targetPos, targetObj, tInfo, {}, true, {NDSKILL_ZHURONGQUHUO})
        return
      else
        local uLevel = userObj:getProperty(PROPERTY_ROLELEVEL)
        local ssv = userObj:getProperty(PROPERTY_STARSKILLVALUE)
        local damageHp = _computeSkillDamage_XianZu(fire_skillID, kAttr, fkAttr, 1, uLevel, ssv, extraCoeff, skillWeakCeoff, damageWeak)
        damageHp = _checkDamage(damageHp * (1 + wxCoeff))
        _setExtraSkillDamageOnTarget(warId, warRound, fire_skillID, damageHp, 0, userPos, userObj, targetPos, targetObj, tInfo, {}, true)
      end
    end
  end
  local wind_success, wind_skillID = _getWuLi_ExtraWindSkillDamageSuccess(userObj)
  if _canAffectOnPro(wind_success) then
    local kAttr = _getTotalKangPro(targetObj, SKILLATTR_WIND)
    local fkAttr = _getTotalFKangPro(userObj, SKILLATTR_WIND)
    local wind_skillExp = 1
    if _useSkillSuccess(userObj, wind_skillID, kAttr, fkAttr, wind_skillExp) then
      local extraCoeff = _getNormalSkill_ExtraDamageCoeff(userObj, SKILLATTR_WIND)
      local damageWeak = _getNormalSkill_WeakenDamage(targetObj, SKILLATTR_WIND)
      local skillWeakCeoff = userObj:getProperty(PROPERTY_SKILLCOEFF)
      local wxCoeff = _getWuXingKeZhiXiuZheng(userObj, targetObj, WUXING_XIANFA)
      if isPetNeiDan then
        local damageHp = _getNeiDanDamage_ChengFengPoLang(userObj, kAttr, fkAttr, extraCoeff, skillWeakCeoff, damageWeak)
        damageHp = _checkDamage(damageHp * (1 + wxCoeff))
        _setExtraSkillDamageOnTarget(warId, warRound, wind_skillID, damageHp, 0, userPos, userObj, targetPos, targetObj, tInfo, {}, true, {NDSKILL_CHENGFENGPOLANG})
        return
      else
        local uLevel = userObj:getProperty(PROPERTY_ROLELEVEL)
        local ssv = userObj:getProperty(PROPERTY_STARSKILLVALUE)
        local damageHp = _computeSkillDamage_XianZu(wind_skillID, kAttr, fkAttr, 1, uLevel, ssv, extraCoeff, skillWeakCeoff, damageWeak)
        damageHp = _checkDamage(damageHp * (1 + wxCoeff))
        _setExtraSkillDamageOnTarget(warId, warRound, wind_skillID, damageHp, 0, userPos, userObj, targetPos, targetObj, tInfo, {}, true)
      end
    end
  end
  local thunder_success, thunder_skillID = _getWuLi_ExtraThunderSkillDamageSuccess(userObj)
  if _canAffectOnPro(thunder_success) then
    local kAttr = _getTotalKangPro(targetObj, SKILLATTR_THUNDER)
    local fkAttr = _getTotalFKangPro(userObj, SKILLATTR_THUNDER)
    local thunder_skillExp = 1
    if _useSkillSuccess(userObj, thunder_skillID, kAttr, fkAttr, thunder_skillExp) then
      local extraCoeff = _getNormalSkill_ExtraDamageCoeff(userObj, SKILLATTR_THUNDER)
      local damageWeak = _getNormalSkill_WeakenDamage(targetObj, SKILLATTR_THUNDER)
      local skillWeakCeoff = userObj:getProperty(PROPERTY_SKILLCOEFF)
      local wxCoeff = _getWuXingKeZhiXiuZheng(userObj, targetObj, WUXING_XIANFA)
      if isPetNeiDan then
        local damageHp = _getNeiDanDamage_PiLiLiuXing(userObj, kAttr, fkAttr, extraCoeff, skillWeakCeoff, damageWeak)
        damageHp = _checkDamage(damageHp * (1 + wxCoeff))
        _setExtraSkillDamageOnTarget(warId, warRound, thunder_skillID, damageHp, 0, userPos, userObj, targetPos, targetObj, tInfo, {}, true, {NDSKILL_PILILIUXING})
        return
      else
        local uLevel = userObj:getProperty(PROPERTY_ROLELEVEL)
        local ssv = userObj:getProperty(PROPERTY_STARSKILLVALUE)
        local damageHp = _computeSkillDamage_XianZu(thunder_skillID, kAttr, fkAttr, 1, uLevel, ssv, extraCoeff, skillWeakCeoff, damageWeak)
        damageHp = _checkDamage(damageHp * (1 + wxCoeff))
        _setExtraSkillDamageOnTarget(warId, warRound, thunder_skillID, damageHp, 0, userPos, userObj, targetPos, targetObj, tInfo, {}, true)
      end
    end
  end
  local water_success, water_skillID = _getWuLi_ExtraWaterSkillDamageSuccess(userObj)
  if _canAffectOnPro(water_success) then
    local kAttr = _getTotalKangPro(targetObj, SKILLATTR_WATER)
    local fkAttr = _getTotalFKangPro(userObj, SKILLATTR_WATER)
    local water_skillExp = 1
    if _useSkillSuccess(userObj, water_skillID, kAttr, fkAttr, water_skillExp) then
      local extraCoeff = _getNormalSkill_ExtraDamageCoeff(userObj, SKILLATTR_WATER)
      local damageWeak = _getNormalSkill_WeakenDamage(targetObj, SKILLATTR_WATER)
      local skillWeakCeoff = userObj:getProperty(PROPERTY_SKILLCOEFF)
      local wxCoeff = _getWuXingKeZhiXiuZheng(userObj, targetObj, WUXING_XIANFA)
      if isPetNeiDan then
        local damageHp = _getNeiDanDamage_DaHaiWuLiang(userObj, kAttr, fkAttr, extraCoeff, skillWeakCeoff, damageWeak)
        damageHp = _checkDamage(damageHp * (1 + wxCoeff))
        _setExtraSkillDamageOnTarget(warId, warRound, water_skillID, damageHp, 0, userPos, userObj, targetPos, targetObj, tInfo, {}, true, {NDSKILL_DAHAIWULIANG})
        return
      else
        local uLevel = userObj:getProperty(PROPERTY_ROLELEVEL)
        local ssv = userObj:getProperty(PROPERTY_STARSKILLVALUE)
        local damageHp = _computeSkillDamage_XianZu(water_skillID, kAttr, fkAttr, 1, uLevel, ssv, extraCoeff, skillWeakCeoff, damageWeak)
        damageHp = _checkDamage(damageHp * (1 + wxCoeff))
        _setExtraSkillDamageOnTarget(warId, warRound, water_skillID, damageHp, 0, userPos, userObj, targetPos, targetObj, tInfo, {}, true)
      end
    end
  end
end
function _setExtraSkillDamageOnTarget(warId, warRound, skillID, damageHp, damageMp, userPos, userObj, targetPos, targetObj, tInfo, objEffectList, wfczReverberate, ndSkillId_att)
  local targetHp = targetObj:getProperty(PROPERTY_HP)
  local targetMp = targetObj:getProperty(PROPERTY_MP)
  if damageHp > 0 or damageMp > 0 then
    objEffectList = objEffectList or {}
    local maxHpMpChanged = false
    local shareSeq = {}
    local damageHpBak = 0
    if damageHp > 0 then
      damageHp = _checkDamage(damageHp)
      damageHpBak = damageHp
      local sharePos, shareObj = _getShareDamagePos(warId, targetObj, targetPos)
      if shareObj ~= nil then
        local sk_1, sk_2, _ = _computeSkillEffect_ShouHuCangSheng(SKILL_SHOUHUCANGSHENG)
        local shareDamage = _checkDamage(damageHp * sk_2)
        damageHp = _checkDamage(damageHp * sk_1)
        objEffectList[#objEffectList + 1] = EFFECTTYPE_SHAREDAMAGE
        local shareHp = shareObj:getProperty(PROPERTY_HP)
        local shareMp = shareObj:getProperty(PROPERTY_MP)
        local shareEffList = {EFFECTTYPE_NOSKILLANI}
        if not _RoleIsDamgeImmunity(shareObj) then
          local maxHpMpChanged_Share = false
          shareHp = math.max(shareHp - shareDamage)
          if shareHp <= 0 then
            shareHp, maxHpMpChanged_Share = _setRoleIsDeadInWar(warId, warRound, sharePos, shareObj, shareEffList)
          end
          shareObj:setProperty(PROPERTY_HP, shareHp)
          if shareObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and _checkRoleIsInState(shareObj, EFFECTTYPE_SLEEP) then
            _removeRoleEffectState(shareObj, EFFECTTYPE_SLEEP)
            shareEffList[#shareEffList + 1] = EFFECTTYPE_SLEEP_OFF
          end
          shareSeq[#shareSeq + 1] = _formatSubNormalSeqOfTarget(userPos, sharePos, shareHp, shareMp, shareDamage, 0, {}, shareEffList)
          if maxHpMpChanged_Share then
            local shareMaxHp = shareObj:getMaxProperty(PROPERTY_HP)
            local shareMaxMp = shareObj:getMaxProperty(PROPERTY_MP)
            shareSeq[#shareSeq + 1] = _formatSubNormalSeqOfTarget_PetSkillHpMpBase(userPos, sharePos, shareHp, shareMp, shareMaxHp, shareMaxMp)
          end
        else
          shareEffList[#shareEffList + 1] = EFFECTTYPE_IMMUNITY_DAMAGE
          shareSeq[#shareSeq + 1] = _formatSubNormalSeqOfTarget(userPos, sharePos, shareHp, shareMp, 0, 0, {}, shareEffList)
        end
      end
      targetHp = targetHp - damageHp
      if targetHp <= 0 then
        objEffectList = {}
        targetHp = 0
        targetHp, maxHpMpChanged = _setRoleIsDeadInWar(warId, warRound, targetPos, targetObj, objEffectList)
      end
      targetObj:setProperty(PROPERTY_HP, targetHp)
    end
    if damageMp > 0 then
      damageMp = _checkDamage(damageMp)
      targetMp = targetMp - damageMp
      if targetMp < 0 then
        targetMp = 0
      end
      targetObj:setProperty(PROPERTY_MP, targetMp)
    end
    tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, damageHp, damageMp, {}, objEffectList, skillID, nil, ndSkillId_att)
    if maxHpMpChanged == true then
      local tMaxHp = targetObj:getMaxProperty(PROPERTY_HP)
      local tMaxMp = targetObj:getMaxProperty(PROPERTY_MP)
      tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillHpMpBase(userPos, targetPos, targetHp, targetMp, tMaxHp, tMaxMp)
    end
    if #shareSeq > 0 then
      for _, sSeq in pairs(shareSeq) do
        tInfo[#tInfo + 1] = sSeq
      end
    end
    if wfczReverberate and targetObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
      _checkNeiDan_WanFoChaoZong_Reverberate(warId, warRound, userPos, userObj, targetPos, targetObj, tInfo, damageHpBak)
    end
  end
end
function _setExtraSkillEffectOnTarget(userPos, targetPos, targetObj, tInfo, objEffectList)
  local targetHp = targetObj:getProperty(PROPERTY_HP)
  local targetMp = targetObj:getProperty(PROPERTY_MP)
  tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, 0, 0, {}, objEffectList)
end
function _checkNeiDan_HaoRanZhengQi_ExtraDamageOnTarget(warId, warRound, userPos, userObj, targetPos, targetObj, tInfo)
  local success, rate = _getNeiDan_HaoRanZhengQiSuccess(userObj)
  if _canAffectOnPro(success) then
    local targetMaxMp = targetObj:getMaxProperty(PROPERTY_MP)
    local damageHp = _getNeiDanDamage_HaoRanZhengQi(rate, targetMaxMp)
    local kHRZQ = targetObj:getProperty(PROPERTY_KANGNEIDAN_SSRS)
    damageHp = _checkDamage(damageHp - kHRZQ)
    local wxCoeff = _getWuXingKeZhiXiuZheng(userObj, targetObj, WUXING_WULI)
    damageHp = _checkDamage(damageHp * (1 + wxCoeff))
    _setExtraSkillDamageOnTarget(warId, warRound, nil, damageHp, 0, userPos, userObj, targetPos, targetObj, tInfo, {}, true, {NDSKILL_HAORANZHENGQI})
  end
end
function _getNeiDan_WanFoChaoZong_Reverberate(userObj, targetObj, effList, damageHp)
  local success, rate = _getNeiDan_WanFoChaoZongSuccess(targetObj)
  if _canAffectOnPro(success) and damageHp > 0 then
    local hp = userObj:getProperty(PROPERTY_HP)
    effList[#effList + 1] = EFFECTTYPE_WANFOCHAOZONG
    local dhp = _checkDamage(hp * rate)
    local dhpMax = _checkDamage(damageHp * 15)
    return math.min(dhp, dhpMax)
  end
  return 0
end
function _checkNeiDan_WanFoChaoZong_Reverberate(warId, warRound, userPos, userObj, targetPos, targetObj, tInfo, damageHp)
  if damageHp <= 0 then
    return
  end
  local eList = {}
  local eObjList = {}
  local ftHp_Extra = _getNeiDan_WanFoChaoZong_Reverberate(userObj, targetObj, eList, damageHp)
  if ftHp_Extra > 0 then
    if not _RoleIsDamgeImmunity(userObj) then
      local ftWeak = userObj:getProperty(PROPERTY_DEL_ZHEN)
      ftHp_Extra = _checkDamage(ftHp_Extra - ftWeak)
      local ftMp = 0
      local jgbrCoeff, jgbrSkill = targetObj:GetPetSkillJingGuanBaiRi()
      if jgbrCoeff > 0 then
        ftMp = _checkDamage(ftHp_Extra * jgbrCoeff)
        eList[#eList + 1] = EFFECTTYPE_JINGGUANBAIRI
      end
      local userHp = userObj:getProperty(PROPERTY_HP)
      local userMp = userObj:getProperty(PROPERTY_MP)
      userHp = userHp - ftHp_Extra
      local maxHpMpChanged = false
      if userHp <= 0 then
        userHp = 0
        userHp, maxHpMpChanged = _setRoleIsDeadInWar(warId, warRound, userPos, userObj, eObjList)
      end
      userObj:setProperty(PROPERTY_HP, userHp)
      if ftMp > 0 then
        userMp = math.max(userMp - ftMp, 0)
        userObj:setProperty(PROPERTY_MP, userMp)
      end
      tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(targetPos, userPos, userHp, userMp, ftHp_Extra, ftMp, eList, eObjList, nil, nil, {NDSKILL_WANFOCHAOZONG})
      if maxHpMpChanged == true then
        local uMaxHp = userObj:getMaxProperty(PROPERTY_HP)
        local uMaxMp = userObj:getMaxProperty(PROPERTY_MP)
        tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillHpMpBase(targetPos, userPos, userHp, userMp, uMaxHp, uMaxMp)
      end
    else
      local userHp = userObj:getProperty(PROPERTY_HP)
      local userMp = userObj:getProperty(PROPERTY_MP)
      tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(targetPos, userPos, userHp, userMp, 0, 0, eList, {EFFECTTYPE_IMMUNITY_DAMAGE}, nil, nil, {NDSKILL_WANFOCHAOZONG})
    end
  end
end
function _useNeiDanSkillOnTarget(warId, warRound, userPos, selectPos, skillID, callback)
  local skillData = _getSkillData(skillID)
  if skillData == nil then
    print_SkillLog_SkillDataError(warId, userPos, selectPos, skillID)
    _callBack(callback)
    return
  end
  local userObj = _getFightRoleObjByPos(warId, userPos)
  if userObj == nil then
    print_SkillLog_RoleIsNotExist(warId, userPos)
    _callBack(callback)
    return
  end
  selectPos = _checkSelectTarget(warId, userPos, selectPos)
  print_SkillLog_UseSkill(warId, userPos, selectPos, skillData.name)
  local team = userObj:getProperty(PROPERTY_TEAM)
  local mainTargetObj = _getFightRoleObjByPos_WithDeadHero(warId, selectPos)
  if mainTargetObj == nil then
    return
  end
  local selectTeam = mainTargetObj:getProperty(PROPERTY_TEAM)
  local targetPosList = _getNeiDanSkillAllTargets(warId, userPos, userObj, skillID, skillData, selectPos, selectTeam)
  if targetPosList == nil or #targetPosList <= 0 then
    print_SkillLog_NoRightTarget(warId, userPos, selectPos)
    _callBack(callback)
    return
  end
  local damageHp = 0
  local damageMp = 0
  local skillRequireMp = _computeNeiDanRequireMp(skillID)
  local loseHp, loseMp = 0, 0
  local extraCoeff = 0
  local attr = skillData.attr
  if attr == NDATTR_MOJIE then
    if skillID == NDSKILL_TIANMOJIETI then
      loseHp, damageHp = _getNeiDanDamage_TianMoJieTi(userObj)
      extraCoeff = userObj:GetPetSkillShiSiYaoJue()
    elseif skillID == NDSKILL_FENGUANGHUAYING then
      loseHp, damageMp = _getNeiDanDamage_FenGuangHuaYing(userObj)
      extraCoeff = userObj:GetPetSkillFenShenYaoJue()
    elseif skillID == NDSKILL_QINGMIANLIAOYA then
      loseMp, damageHp = _getNeiDanDamage_QingMianLiaoYa(userObj)
      extraCoeff = userObj:GetPetSkillHunFeiYaoJue()
    elseif skillID == NDSKILL_XIAOLOUYEKU then
      loseMp, damageMp = _getNeiDanDamage_XiaoLouYeKu(userObj)
      extraCoeff = userObj:GetPetSkillWanYingYaoJue()
    end
  end
  if damageHp > 0 then
    damageHp = _checkDamage(damageHp * (1 + extraCoeff))
  end
  if damageMp > 0 then
    damageMp = _checkDamage(damageMp * (1 + extraCoeff))
  end
  local userHp = userObj:getProperty(PROPERTY_HP)
  local userMp = userObj:getProperty(PROPERTY_MP)
  if (skillRequireMp > 0 or loseMp > 0) and userMp < skillRequireMp + loseMp then
    _LackManaWhenSkill(warId, userPos, userObj, skillID)
    print_SkillLog_LackMp(warId, userMp, skillRequireMp + loseMp)
    _callBack(callback)
    return
  end
  if loseHp > 0 and loseHp > userHp then
    _LackHpWhenSkill(warId, userPos, userObj, skillID)
    print_SkillLog_LackHp(warId, userHp, loseHp)
    _callBack(callback)
    return
  end
  _checkCancelStealth(warId, userPos, userObj)
  userMp = userMp - skillRequireMp
  userObj:setProperty(PROPERTY_MP, userMp)
  local tempRestMp = userMp
  local formatFightSeq = {
    seqType = SEQTYPE_USENEIDANSKILL,
    userPos = userPos,
    targetInfo = {}
  }
  local tInfo = formatFightSeq.targetInfo
  print_SkillLog_UseSkill(warId, userPos, selectPos, skillData.name)
  local isFirstTarget = true
  for tIndex, targetPos in pairs(targetPosList) do
    local targetObj = _getFightRoleObjByPos(warId, targetPos)
    if targetObj then
      local targetHp = targetObj:getProperty(PROPERTY_HP)
      local targetMp = targetObj:getProperty(PROPERTY_MP)
      local wxCoeff = _getWuXingKeZhiXiuZheng(userObj, targetObj, WUXING_NEIDAN)
      if damageHp > 0 then
        damageHp = _checkDamage(damageHp * (1 + wxCoeff))
      end
      if damageMp > 0 then
        damageMp = _checkDamage(damageMp * (1 + wxCoeff))
      end
      if not _canSkillOnRole_NormalAttack(targetObj) then
        if isFirstTarget then
          tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, 0, 0, {}, {EFFECTTYPE_IMMUNITY}, skillID, tempRestMp)
        else
          tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, 0, 0, {}, {EFFECTTYPE_IMMUNITY})
        end
        print_SkillLog_AttackInvalid(warId, userPos, targetPos)
      elseif _RoleIsDamgeImmunity(targetObj) then
        if isFirstTarget then
          tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, 0, 0, {}, {EFFECTTYPE_IMMUNITY_DAMAGE}, skillID, tempRestMp)
        else
          tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, 0, 0, {}, {EFFECTTYPE_IMMUNITY_DAMAGE})
        end
        print_SkillLog_AttackInvalid(warId, userPos, targetPos)
      elseif not _checkNeiDanMiss(skillID, userObj, targetObj) or _checkRoleIsInState(targetObj, EFFECTTYPE_SLEEP) then
        local dHp = damageHp
        local dMp = damageMp
        local dHpBak = dHp
        local attEffectList = {}
        local objEffectList = {}
        local kNeiDanDamage = 0
        local kNeiDanPro = NEIDAN_SKILL_TO_KANGPRO_TABLE[skillID]
        if kNeiDanPro ~= nil then
          kNeiDanDamage = targetObj:getProperty(kNeiDanPro)
        end
        local maxHpMpChanged = false
        local shareSeq = {}
        if dHp > 0 then
          dHp = _checkDamage(dHp - kNeiDanDamage)
          dHpBak = dHp
          local sharePos, shareObj = _getShareDamagePos(warId, targetObj, targetPos)
          if shareObj ~= nil then
            local sk_1, sk_2, _ = _computeSkillEffect_ShouHuCangSheng(SKILL_SHOUHUCANGSHENG)
            local shareDamage = _checkDamage(dHp * sk_2)
            dHp = _checkDamage(dHp * sk_1)
            objEffectList[#objEffectList + 1] = EFFECTTYPE_SHAREDAMAGE
            local shareHp = shareObj:getProperty(PROPERTY_HP)
            local shareMp = shareObj:getProperty(PROPERTY_MP)
            local shareEffList = {EFFECTTYPE_NOSKILLANI}
            if not _RoleIsDamgeImmunity(shareObj) then
              local maxHpMpChanged_Share = false
              shareHp = math.max(shareHp - shareDamage)
              if shareHp <= 0 then
                shareHp, maxHpMpChanged_Share = _setRoleIsDeadInWar(warId, warRound, sharePos, shareObj, shareEffList)
              end
              shareObj:setProperty(PROPERTY_HP, shareHp)
              if shareObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and _checkRoleIsInState(shareObj, EFFECTTYPE_SLEEP) then
                _removeRoleEffectState(shareObj, EFFECTTYPE_SLEEP)
                shareEffList[#shareEffList + 1] = EFFECTTYPE_SLEEP_OFF
              end
              shareSeq[#shareSeq + 1] = _formatSubNormalSeqOfTarget(userPos, sharePos, shareHp, shareMp, shareDamage, 0, {}, shareEffList)
              if maxHpMpChanged_Share then
                local shareMaxHp = shareObj:getMaxProperty(PROPERTY_HP)
                local shareMaxMp = shareObj:getMaxProperty(PROPERTY_MP)
                shareSeq[#shareSeq + 1] = _formatSubNormalSeqOfTarget_PetSkillHpMpBase(userPos, sharePos, shareHp, shareMp, shareMaxHp, shareMaxMp)
              end
            else
              shareEffList[#shareEffList + 1] = EFFECTTYPE_IMMUNITY_DAMAGE
              shareSeq[#shareSeq + 1] = _formatSubNormalSeqOfTarget(userPos, sharePos, shareHp, shareMp, 0, 0, {}, shareEffList)
            end
          end
          targetHp = targetHp - dHp
          if targetHp <= 0 then
            targetHp = 0
            targetHp, maxHpMpChanged = _setRoleIsDeadInWar(warId, warRound, targetPos, targetObj, objEffectList)
          end
          targetObj:setProperty(PROPERTY_HP, targetHp)
        end
        if dMp > 0 then
          dMp = _checkDamage(dMp - kNeiDanDamage)
          targetMp = targetMp - dMp
          if targetMp <= 0 then
            targetMp = 0
          end
          targetObj:setProperty(PROPERTY_MP, targetMp)
        end
        if isFirstTarget then
          tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, dHp, dMp, attEffectList, objEffectList, skillID, tempRestMp)
        else
          tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, dHp, dMp, attEffectList, objEffectList)
        end
        print_SkillLog_DamageHp(warId, userPos, targetPos, dHp, targetHp)
        if maxHpMpChanged == true then
          local uMaxHp = targetObj:getMaxProperty(PROPERTY_HP)
          local uMaxMp = targetObj:getMaxProperty(PROPERTY_MP)
          tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillHpMpBase(userPos, targetPos, targetHp, targetMp, uMaxHp, uMaxMp)
        end
        if #shareSeq > 0 then
          for _, sSeq in pairs(shareSeq) do
            tInfo[#tInfo + 1] = sSeq
          end
        end
        if targetObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and (dHp > 0 or dMp > 0) and _checkRoleIsInState(targetObj, EFFECTTYPE_SLEEP) then
          _removeRoleEffectState(targetObj, EFFECTTYPE_SLEEP)
          objEffectList[#objEffectList + 1] = EFFECTTYPE_SLEEP_OFF
        end
        if targetObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and userObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
          _checkNeiDan_WanFoChaoZong_Reverberate(warId, warRound, userPos, userObj, targetPos, targetObj, tInfo, dHpBak)
        end
      else
        if isFirstTarget then
          tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, 0, 0, {}, {EFFECTTYPE_MISS}, skillID, tempRestMp)
        else
          tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, 0, 0, {}, {EFFECTTYPE_MISS})
        end
        print_SkillLog_Miss(warId, targetPos)
      end
      isFirstTarget = false
    end
  end
  if loseHp > 0 or loseMp > 0 then
    local uEffList = {}
    userHp = userObj:getProperty(PROPERTY_HP)
    userMp = userObj:getProperty(PROPERTY_MP)
    local maxHpMpChanged = false
    if loseHp > 0 then
      userHp = userHp - loseHp
      if userHp <= 0 then
        userHp = 0
        userHp, maxHpMpChanged = _setRoleIsDeadInWar(warId, warRound, userPos, userObj, uEffList)
      end
      userObj:setProperty(PROPERTY_HP, userHp)
      uEffList[#uEffList + 1] = EFFECTTYPE_DAMAGESELF_HP
    end
    if loseMp > 0 then
      userMp = userMp - loseMp
      if userMp <= 0 then
        userMp = 0
      end
      userObj:setProperty(PROPERTY_MP, userMp)
      uEffList[#uEffList + 1] = EFFECTTYPE_DAMAGESELF_MP
    end
    tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(targetPos, userPos, userHp, userMp, loseHp, loseMp, {}, uEffList)
    if maxHpMpChanged == true then
      local uMaxHp = userObj:getMaxProperty(PROPERTY_HP)
      local uMaxMp = userObj:getMaxProperty(PROPERTY_MP)
      tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillHpMpBase(targetPos, userPos, userHp, userMp, uMaxHp, uMaxMp)
    end
  end
  _onNewFormatFightSequence(warId, formatFightSeq)
  _callBack(callback)
end
function _getNeiDanSkillAllTargets(warId, userPos, userObj, skillID, skillData, selectPos, team)
  return _getSkillAllTargets(warId, userPos, userObj, skillID, 0, skillData, selectPos, team)
end
function _checkNeiDanMiss(skillID, userObj, targetObj)
  local hitPro = _getNeiDanSuccess(skillID)
  local hitPro_Ex = _getTargetTempAttr(userObj, PROPERTY_PACC)
  hitPro = hitPro + hitPro_Ex
  local missPro = targetObj:getProperty(PROPERTY_PSBL)
  local finalPro = hitPro - missPro
  return not _canAffectOnPro(finalPro)
end
function _checkBaoFuSkillWhenUseSkill(warId, warRound, userPos, userObj, tInfo)
  local team = userObj:getProperty(PROPERTY_TEAM)
  local petList = _getPosListByTeamAndTargetType(team, TARGETTYPE_ENEMYSIDE)
  for _, petPos in pairs(petList) do
    if userObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
      local petObj = _getFightRoleObjByPos(warId, petPos)
      if petObj and not _checkRoleIsInState(petObj, EFFECTTYPE_FROZEN) and not _checkRoleIsInState(petObj, EFFECTTYPE_STEALTH) then
        local pro, bfHp, pskillId = petObj:GetPetSkillBaoFu()
        if _canAffectOnPro(pro) then
          local wxCoeff = _getWuXingKeZhiXiuZheng(petObj, userObj, WUXING_CHONGWU)
          bfHp = _checkDamage(bfHp * (1 + wxCoeff))
          local curHp = userObj:getProperty(PROPERTY_HP)
          local curMp = userObj:getProperty(PROPERTY_MP)
          if not _RoleIsDamgeImmunity(userObj) then
            local effList = {}
            curHp = curHp - bfHp
            local maxHpMpChanged_bf = false
            if curHp <= 0 then
              curHp = 0
              curHp, maxHpMpChanged_bf = _setRoleIsDeadInWar(warId, warRound, userPos, userObj, effList)
            end
            userObj:setProperty(PROPERTY_HP, curHp)
            tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(petPos, userPos, curHp, curMp, bfHp, 0, {}, effList, nil, nil, nil, nil, pskillId)
            if maxHpMpChanged_bf == true then
              local uMaxHp = userObj:getMaxProperty(PROPERTY_HP)
              local uMaxMp = userObj:getMaxProperty(PROPERTY_MP)
              tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillHpMpBase(petPos, userPos, curHp, curMp, uMaxHp, uMaxMp)
            end
          else
            tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(petPos, userPos, curHp, curMp, 0, 0, {}, {EFFECTTYPE_IMMUNITY_DAMAGE}, nil, nil, nil, nil, pskillId)
          end
        end
      end
    end
  end
end
function _checkHuiYuanSkillWhenUseSkill(warId, userPos, userObj, tInfo)
  local team = userObj:getProperty(PROPERTY_TEAM)
  local petList = _getPosListByTeamAndTargetType(team, TARGETTYPE_MYSIDE)
  for _, petPos in pairs(petList) do
    local curHp = userObj:getProperty(PROPERTY_HP)
    local curMp = userObj:getProperty(PROPERTY_MP)
    local curMaxMp = userObj:getMaxProperty(PROPERTY_MP)
    if curMp < curMaxMp and petPos ~= userPos then
      local petObj = _getFightRoleObjByPos(warId, petPos)
      if petObj and not _checkRoleIsInState(petObj, EFFECTTYPE_FROZEN) then
        local pro, coeff, pskillId = petObj:GetPetSkillHuiYuan()
        if _canAffectOnPro(pro) then
          local hyMp = _checkDamage(curMaxMp * coeff)
          curMp = curMp + hyMp
          if curMaxMp < curMp then
            curMp = curMaxMp
          end
          userObj:setProperty(PROPERTY_MP, curMp)
          tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillAddHpMp(petPos, userPos, curHp, curMp, 0, hyMp, pskillId)
        end
      end
    end
  end
end
function _usePetSkillOnTarget(warId, warRound, userPos, targetPos, skillID, callback)
  local userObj = _getFightRoleObjByPos(warId, userPos)
  if userObj == nil then
    print_SkillLog_RoleIsNotExist(warId, userPos)
    return
  end
  local warType = _getTheWarType(warId)
  local isPvpWar = IsPVPWarType(warType)
  local team = userObj:getProperty(PROPERTY_TEAM)
  local isMonster = userObj:getType() == LOGICTYPE_MONSTER
  local formatFightSeq = {
    seqType = SEQTYPE_PETSKILL,
    userPos = userPos,
    targetInfo = {}
  }
  local tInfo = formatFightSeq.targetInfo
  if skillID == PETSKILL_ZHAOYUNMUYU then
    if not isPvpWar then
      return
    end
    targetPos = _checkSelectTarget(warId, userPos, targetPos, false)
    local targetObj = _getFightRoleObjByPos(warId, targetPos)
    if targetObj == nil then
      return
    end
    local canUseRound = _getPetSkillCDRound(userObj, skillID)
    if warRound < canUseRound then
      return
    end
    if _checkSkillGGLXMJLL(warId, userPos, userObj, skillID, true) ~= true then
      return
    end
    local petLv = userObj:getProperty(PROPERTY_ROLELEVEL)
    local petClose = userObj:getProperty(PROPERTY_CLOSEVALUE)
    local userMp = userObj:getProperty(PROPERTY_MP)
    local userMaxMp = userObj:getMaxProperty(PROPERTY_MP)
    local skillNeedMp = _getPetSkillRequireMp(userObj, skillID, petLv, petClose, userMaxMp)
    if userMp < skillNeedMp then
      print_SkillLog_LackMp(warId, userMp, skillNeedMp)
      _LackManaWhenSkill(warId, userPos, userObj, skillID)
      return
    end
    _checkCancelStealth(warId, userPos, userObj)
    local checkFlag = _checkWhenUseSkillOfWar(warId, warRound, userPos, skillID)
    if checkFlag == false then
      return
    end
    userMp = userObj:getProperty(PROPERTY_MP)
    if skillNeedMp > userMp then
      print_SkillLog_LackMp(warId, userMp, skillNeedMp)
      _LackManaWhenSkill(warId, userPos, userObj, skillID)
      return
    end
    userMp = userMp - skillNeedMp
    userObj:setProperty(PROPERTY_MP, userMp)
    local damageHp, round, _ = _computePetSkill_ZhaoYunMuYu(petLv, petClose, userObj:getType())
    local wxCoeff = _getWuXingKeZhiXiuZheng(userObj, targetObj, WUXING_CHONGWU)
    damageHp = _checkDamage(damageHp * (1 + wxCoeff))
    local targetHp = targetObj:getProperty(PROPERTY_HP)
    local targetMp = targetObj:getProperty(PROPERTY_MP)
    local maxHpMpChanged = false
    if _canSkillOnRole_ZhaoYunMuYu(targetObj) then
      if team == TEAM_ATTACK and g_WarAiInsList[warId]:WarAiGetAttackZhaoYunMuYuFlag() == true or team == TEAM_DEFEND and g_WarAiInsList[warId]:WarAiGetDefendZhaoYunMuYuFlag() == true then
        local isDouble = false
        local userType = userObj:getTypeId()
        local petPosList = _getPetPosListByTeamAndTargetType(team, TARGETTYPE_MYSIDE)
        for _, petPos in pairs(petPosList) do
          if petPos ~= userPos then
            local petObj = _getFightRoleObjByPos(warId, petPos)
            if petObj and petObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and petObj:getType() == LOGICTYPE_PET and petObj:getTypeId() == userType then
              isDouble = true
              break
            end
          end
        end
        if isDouble then
          damageHp = damageHp * 2
          if team == TEAM_ATTACK then
            g_WarAiInsList[warId]:WarAiSetAttackZhaoYunMuYuFlag(false)
          elseif team == TEAM_DEFEND then
            g_WarAiInsList[warId]:WarAiSetDefendZhaoYunMuYuFlag(false)
          end
        end
      end
      local attEffectList = {}
      local objEffectList = {}
      if not _RoleIsDamgeImmunity(targetObj) then
        targetHp = targetHp - damageHp
        if targetHp <= 0 then
          targetHp, maxHpMpChanged = _setRoleIsDeadInWar(warId, warRound, targetPos, targetObj, objEffectList)
        end
        targetObj:setProperty(PROPERTY_HP, targetHp)
        tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, damageHp, 0, attEffectList, objEffectList, skillID, userMp)
      else
        tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, 0, 0, attEffectList, {EFFECTTYPE_IMMUNITY_DAMAGE}, skillID, userMp)
      end
    else
      local objEffectList = {EFFECTTYPE_IMMUNITY}
      tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, 0, 0, {}, objEffectList, skillID, userMp)
    end
    if maxHpMpChanged == true then
      local tMaxHp = targetObj:getMaxProperty(PROPERTY_HP)
      local tMaxMp = targetObj:getMaxProperty(PROPERTY_MP)
      tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillHpMpBase(userPos, targetPos, targetHp, targetMp, tMaxHp, tMaxMp)
    end
    _setPetSkillCDRound(userObj, skillID, warRound + round + 1)
    _onNewFormatFightSequence(warId, formatFightSeq)
  elseif skillID == PETSKILL_HUIGEHUIRI then
    targetPos = _checkSelectTarget(warId, userPos, targetPos, true, false, nil, true)
    local targetObj = _getFightRoleObjByPos_WithDeadHero(warId, targetPos)
    if targetObj == nil then
      return
    end
    if _checkSkillGGLXMJLL(warId, userPos, userObj, skillID, true) ~= true then
      return
    end
    local petLv = userObj:getProperty(PROPERTY_ROLELEVEL)
    local petClose = userObj:getProperty(PROPERTY_CLOSEVALUE)
    local userMp = userObj:getProperty(PROPERTY_MP)
    local userMaxMp = userObj:getMaxProperty(PROPERTY_MP)
    local skillNeedMp = _getPetSkillRequireMp(userObj, skillID, petLv, petClose, userMaxMp)
    if userMp < skillNeedMp then
      print_SkillLog_LackMp(warId, userMp, skillNeedMp)
      _LackManaWhenSkill(warId, userPos, userObj, skillID)
      return
    end
    _checkCancelStealth(warId, userPos, userObj)
    local checkFlag = _checkWhenUseSkillOfWar(warId, warRound, userPos, skillID)
    if checkFlag == false then
      return
    end
    userMp = userObj:getProperty(PROPERTY_MP)
    if skillNeedMp > userMp then
      print_SkillLog_LackMp(warId, userMp, skillNeedMp)
      _LackManaWhenSkill(warId, userPos, userObj, skillID)
      return
    end
    userMp = userMp - skillNeedMp
    userObj:setProperty(PROPERTY_MP, userMp)
    local targetHp = targetObj:getProperty(PROPERTY_HP)
    local targetMp = targetObj:getProperty(PROPERTY_MP)
    if _canSkillOnRole_HuiGeHuiRi(targetObj) then
      local coeff = _computePetSkill_HuiGeHuiRi()
      local addHp = _checkDamage(skillNeedMp * coeff)
      local targetMaxHp = targetObj:getMaxProperty(PROPERTY_HP)
      local fuhuo
      targetHp = math.min(targetHp + addHp, targetMaxHp)
      targetObj:setProperty(PROPERTY_HP, targetHp)
      if targetObj:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD and targetHp > 0 then
        targetObj:setProperty(PROPERTY_DEAD, ROLESTATE_LIVE)
        fuhuo = 1
      end
      tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillAddHpMp(userPos, targetPos, targetHp, targetMp, addHp, 0, nil, nil, fuhuo, nil, skillID, userMp)
    elseif _checkRoleIsInState(targetObj, EFFECTTYPE_DUOHUNSUOMING) then
      local objEffectList = {EFFECTTYPE_INVALID}
      tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, 0, 0, {EFFECTTYPE_ADDHPFAILED_DHSM}, objEffectList, skillID, userMp)
    else
      local objEffectList = {EFFECTTYPE_IMMUNITY}
      tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, 0, 0, {}, objEffectList, skillID, userMp)
    end
    _onNewFormatFightSequence(warId, formatFightSeq)
  elseif skillID == PETSKILL_FEIYANHUIXIANG then
    targetPos = _checkSelectTarget(warId, userPos, targetPos, false, false, nil, true)
    local targetObj = _getFightRoleObjByPos(warId, targetPos)
    if targetObj == nil then
      return
    end
    if _checkSkillGGLXMJLL(warId, userPos, userObj, skillID, true) ~= true then
      return
    end
    local petLv = userObj:getProperty(PROPERTY_ROLELEVEL)
    local petClose = userObj:getProperty(PROPERTY_CLOSEVALUE)
    local userMp = userObj:getProperty(PROPERTY_MP)
    local userMaxMp = userObj:getMaxProperty(PROPERTY_MP)
    local skillNeedMp = _getPetSkillRequireMp(userObj, skillID, petLv, petClose, userMaxMp)
    if userMp < skillNeedMp then
      print_SkillLog_LackMp(warId, userMp, skillNeedMp)
      _LackManaWhenSkill(warId, userPos, userObj, skillID)
      return
    end
    _checkCancelStealth(warId, userPos, userObj)
    local checkFlag = _checkWhenUseSkillOfWar(warId, warRound, userPos, skillID)
    if checkFlag == false then
      return
    end
    userMp = userObj:getProperty(PROPERTY_MP)
    if skillNeedMp > userMp then
      print_SkillLog_LackMp(warId, userMp, skillNeedMp)
      _LackManaWhenSkill(warId, userPos, userObj, skillID)
      return
    end
    userMp = userMp - skillNeedMp
    userObj:setProperty(PROPERTY_MP, userMp)
    local coeff, round, _ = _computePetSkill_FeiYanHuiXiang(petLv, petClose, userObj:getType())
    local targetHp = targetObj:getProperty(PROPERTY_HP)
    local targetMp = targetObj:getProperty(PROPERTY_MP)
    if _canSkillOnRole_Speed(targetObj) then
      local sp = userObj:getProperty(PROPERTY_SP)
      local decSp = math.floor(sp * coeff)
      _setTargetTempAttr(targetObj, PROPERTY_SP, -decSp, EFFECTTYPE_DEC_SPEED)
      _addEffectOnTarget(targetObj, EFFECTTYPE_DEC_SPEED, round)
      local objEffectList = {EFFECTTYPE_DEC_SPEED}
      tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, 0, 0, {}, objEffectList, skillID, userMp)
    else
      local objEffectList = {EFFECTTYPE_IMMUNITY}
      tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, 0, 0, {}, objEffectList, skillID, userMp)
    end
    _onNewFormatFightSequence(warId, formatFightSeq)
    userObj:setProperty(PROPERTY_DEAD, ROLESTATE_LEAVE)
    _formatAndSendLeaveBattleSeq(warId, userPos)
  elseif skillID == PETSKILL_BUBUSHENGLIAN then
    if not isPvpWar then
      return
    end
    targetPos = _checkSelectTarget(warId, userPos, targetPos, false)
    local targetObj = _getFightRoleObjByPos(warId, targetPos)
    if targetObj == nil then
      return
    end
    local canUseRound = _getPetSkillCDRound(userObj, skillID)
    if warRound < canUseRound then
      return
    end
    if _checkSkillGGLXMJLL(warId, userPos, userObj, skillID, true) ~= true then
      return
    end
    local petLv = userObj:getProperty(PROPERTY_ROLELEVEL)
    local petClose = userObj:getProperty(PROPERTY_CLOSEVALUE)
    local userMp = userObj:getProperty(PROPERTY_MP)
    local userMaxMp = userObj:getMaxProperty(PROPERTY_MP)
    local skillNeedMp = _getPetSkillRequireMp(userObj, skillID, petLv, petClose, userMaxMp)
    if userMp < skillNeedMp then
      print_SkillLog_LackMp(warId, userMp, skillNeedMp)
      _LackManaWhenSkill(warId, userPos, userObj, skillID)
      return
    end
    local team = userObj:getProperty(PROPERTY_TEAM)
    local selectTeam = targetObj:getProperty(PROPERTY_TEAM)
    local targetNum, baseCoeff, addCoeff, recoverCoeff, round = _computePetSkill_BuBuShengLian(petLv, petClose, userObj:getType())
    local targetList = _getSkillAllTargetsOfNum(warId, userPos, userObj, skillID, targetPos, targetNum, selectTeam, TARGETTYPE_MYSIDE, SKILLATTR_PETSKILL)
    if #targetList <= 0 then
      return
    end
    _checkCancelStealth(warId, userPos, userObj)
    local checkFlag = _checkWhenUseSkillOfWar(warId, warRound, userPos, skillID)
    if checkFlag == false then
      return
    end
    userMp = userObj:getProperty(PROPERTY_MP)
    if skillNeedMp > userMp then
      print_SkillLog_LackMp(warId, userMp, skillNeedMp)
      _LackManaWhenSkill(warId, userPos, userObj, skillID)
      return
    end
    userMp = userMp - skillNeedMp
    userObj:setProperty(PROPERTY_MP, userMp)
    local coeff = baseCoeff
    local totalHp = 0
    local totalMp = 0
    local index = 1
    for _, objPos in pairs(targetList) do
      local effObj = _getFightRoleObjByPos(warId, objPos)
      if effObj and effObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
        local objHp = effObj:getProperty(PROPERTY_HP)
        local objMp = effObj:getProperty(PROPERTY_MP)
        local objEffectList = {}
        local dHp, dMp = 0, 0
        local maxHpMpChanged = false
        if _canSkillOnRole_BuBuShengLian(effObj) then
          if not _RoleIsDamgeImmunity(effObj) then
            dHp = objHp * coeff
            dMp = objMp * coeff
            local wxCoeff = _getWuXingKeZhiXiuZheng(userObj, effObj, WUXING_CHONGWU)
            dHp = _checkDamage(dHp * (1 + wxCoeff))
            if dMp > 0 then
              dMp = _checkDamage(dMp * (1 + wxCoeff))
            end
            if objHp < dHp then
              dHp = objHp
            end
            if objMp < dMp then
              dMp = objMp
            end
            totalHp = totalHp + dHp
            totalMp = totalMp + dMp
            objHp = objHp - dHp
            objMp = objMp - dMp
            if objHp <= 0 then
              objHp, maxHpMpChanged = _setRoleIsDeadInWar(warId, warRound, objPos, effObj, objEffectList)
            end
            effObj:setProperty(PROPERTY_HP, objHp)
            effObj:setProperty(PROPERTY_MP, objMp)
          else
            objEffectList = {EFFECTTYPE_IMMUNITY_DAMAGE}
          end
        else
          objEffectList = {EFFECTTYPE_IMMUNITY}
        end
        if index == 1 then
          tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, objPos, objHp, objMp, dHp, dMp, {}, objEffectList, skillID, userMp)
        else
          objEffectList[#objEffectList + 1] = EFFECTTYPE_JUMPHIT
          tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, objPos, objHp, objMp, dHp, dMp, {}, objEffectList)
        end
        if maxHpMpChanged == true then
          local tMaxHp = effObj:getMaxProperty(PROPERTY_HP)
          local tMaxMp = effObj:getMaxProperty(PROPERTY_MP)
          tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillHpMpBase(userPos, objPos, objHp, objMp, tMaxHp, tMaxMp)
        end
        coeff = coeff + addCoeff
        index = index + 1
      end
    end
    if totalHp > 0 or totalMp > 0 then
      local addHp, addMp = 0, 0
      if totalHp > 0 then
        addHp = _checkDamage(totalHp * recoverCoeff)
      end
      if totalMp > 0 then
        addMp = _checkDamage(totalMp * recoverCoeff)
      end
      local masterPos = _getMasterPosByPetPos(userPos)
      local masterObj = _getFightRoleObjByPos_WithDeadHero(warId, masterPos)
      if masterObj then
        local uHp = masterObj:getProperty(PROPERTY_HP)
        local uMp = masterObj:getProperty(PROPERTY_MP)
        if not _checkRoleIsInState(masterObj, EFFECTTYPE_DUOHUNSUOMING) then
          local uMaxHp = masterObj:getMaxProperty(PROPERTY_HP)
          local uMaxMp = masterObj:getMaxProperty(PROPERTY_MP)
          uHp = math.min(uHp + addHp, uMaxHp)
          uMp = math.min(uMp + addMp, uMaxMp)
          masterObj:setProperty(PROPERTY_HP, uHp)
          masterObj:setProperty(PROPERTY_MP, uMp)
          local fuhuo
          if masterObj:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD and uHp > 0 then
            masterObj:setProperty(PROPERTY_DEAD, ROLESTATE_LIVE)
            fuhuo = 1
          end
          tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillAddHpMp(userPos, masterPos, uHp, uMp, addHp, addMp, nil, nil, fuhuo)
        else
          tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillAddHpMp(userPos, masterPos, uHp, uMp, 0, 0, nil, nil, nil, {EFFECTTYPE_INVALID}, nil, nil, {EFFECTTYPE_ADDHPFAILED_DHSM})
        end
      end
    end
    _setPetSkillCDRound(userObj, skillID, warRound + round + 1)
    _onNewFormatFightSequence(warId, formatFightSeq)
  elseif skillID == PETSKILL_LONGZHANYUYE then
    targetPos = _checkSelectTarget(warId, userPos, targetPos, false, false, {
      [LOGICTYPE_PET] = true
    })
    local targetObj = _getFightRoleObjByPos(warId, targetPos)
    if targetObj == nil then
      return
    end
    if targetObj:getType() ~= LOGICTYPE_PET then
      return
    end
    local canUseRound = _getPetSkillCDRound(userObj, skillID)
    if warRound < canUseRound then
      return
    end
    if _checkSkillGGLXMJLL(warId, userPos, userObj, skillID, true) ~= true then
      return
    end
    local petLv = userObj:getProperty(PROPERTY_ROLELEVEL)
    local petClose = userObj:getProperty(PROPERTY_CLOSEVALUE)
    local userMp = userObj:getProperty(PROPERTY_MP)
    local userMaxMp = userObj:getMaxProperty(PROPERTY_MP)
    local skillNeedMp = _getPetSkillRequireMp(userObj, skillID, petLv, petClose, userMaxMp)
    if userMp < skillNeedMp then
      print_SkillLog_LackMp(warId, userMp, skillNeedMp)
      _LackManaWhenSkill(warId, userPos, userObj, skillID)
      return
    end
    local team = userObj:getProperty(PROPERTY_TEAM)
    local selectTeam = targetObj:getProperty(PROPERTY_TEAM)
    local effCoeff, targetNum, keepround, cdround = _computePetSkill_LongZhanYuYe(petLv, petClose, userObj:getType())
    local targetList = _getSkillAllTargetsOfNum(warId, userPos, userObj, skillID, targetPos, targetNum, selectTeam, TARGETTYPE_MYSIDE, SKILLATTR_PETSKILL, {
      [LOGICTYPE_PET] = true
    })
    if #targetList <= 0 then
      return
    end
    _checkCancelStealth(warId, userPos, userObj)
    local checkFlag = _checkWhenUseSkillOfWar(warId, warRound, userPos, skillID)
    if checkFlag == false then
      return
    end
    userMp = userObj:getProperty(PROPERTY_MP)
    if skillNeedMp > userMp then
      print_SkillLog_LackMp(warId, userMp, skillNeedMp)
      _LackManaWhenSkill(warId, userPos, userObj, skillID)
      return
    end
    userMp = userMp - skillNeedMp
    userObj:setProperty(PROPERTY_MP, userMp)
    local index = 1
    for _, objPos in pairs(targetList) do
      local effObj = _getFightRoleObjByPos(warId, objPos)
      if effObj and effObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and effObj:getType() == LOGICTYPE_PET then
        local objHp = effObj:getProperty(PROPERTY_HP)
        local objMp = effObj:getProperty(PROPERTY_MP)
        local objEffectList = {}
        if _canSkillOnRole_LongZhanYuYe(effObj) then
          local effectData = {}
          effectData.coeff = effCoeff
          _addEffectOnTarget(effObj, EFFECTTYPE_LONGZHANYUYE, keepround, effectData)
          objEffectList[#objEffectList + 1] = EFFECTTYPE_LONGZHANYUYE
        else
          objEffectList = {EFFECTTYPE_IMMUNITY}
        end
        if index == 1 then
          tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, objPos, objHp, objMp, 0, 0, {}, objEffectList, skillID, userMp)
        else
          tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, objPos, objHp, objMp, 0, 0, {}, objEffectList)
        end
        index = index + 1
      end
    end
    _setPetSkillCDRound(userObj, skillID, warRound + cdround + 1)
    _onNewFormatFightSequence(warId, formatFightSeq)
  elseif skillID == PETSKILL_HENGYUNDUANFENG then
    targetPos = _checkSelectTarget(warId, userPos, targetPos, false)
    local targetObj = _getFightRoleObjByPos(warId, targetPos)
    if targetObj == nil then
      return
    end
    local canUseRound = _getPetSkillCDRound(userObj, skillID)
    if warRound < canUseRound then
      return
    end
    if _checkSkillGGLXMJLL(warId, userPos, userObj, skillID, true) ~= true then
      return
    end
    local petLv = userObj:getProperty(PROPERTY_ROLELEVEL)
    local petClose = userObj:getProperty(PROPERTY_CLOSEVALUE)
    local userMp = userObj:getProperty(PROPERTY_MP)
    local userMaxMp = userObj:getMaxProperty(PROPERTY_MP)
    local skillNeedMp = _getPetSkillRequireMp(userObj, skillID, petLv, petClose, userMaxMp)
    if userMp < skillNeedMp then
      print_SkillLog_LackMp(warId, userMp, skillNeedMp)
      _LackManaWhenSkill(warId, userPos, userObj, skillID)
      return
    end
    local team = userObj:getProperty(PROPERTY_TEAM)
    local selectTeam = targetObj:getProperty(PROPERTY_TEAM)
    local effCoeff, targetNum, keepround, cdround = _computePetSkill_HengYunDuanFeng(petLv, petClose, userObj:getType())
    local targetList = _getSkillAllTargetsOfNum(warId, userPos, userObj, skillID, targetPos, targetNum, selectTeam, TARGETTYPE_MYSIDE, SKILLATTR_PETSKILL)
    if #targetList <= 0 then
      return
    end
    _checkCancelStealth(warId, userPos, userObj)
    local checkFlag = _checkWhenUseSkillOfWar(warId, warRound, userPos, skillID)
    if checkFlag == false then
      return
    end
    userMp = userObj:getProperty(PROPERTY_MP)
    if skillNeedMp > userMp then
      print_SkillLog_LackMp(warId, userMp, skillNeedMp)
      _LackManaWhenSkill(warId, userPos, userObj, skillID)
      return
    end
    userMp = userMp - skillNeedMp
    userObj:setProperty(PROPERTY_MP, userMp)
    local index = 1
    for _, objPos in pairs(targetList) do
      local effObj = _getFightRoleObjByPos(warId, objPos)
      if effObj and effObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
        local objHp = effObj:getProperty(PROPERTY_HP)
        local objMp = effObj:getProperty(PROPERTY_MP)
        local objEffectList = {}
        if _canSkillOnRole_HengYunDuanFeng(effObj) then
          local effectData = {}
          effectData.coeff = effCoeff
          _addEffectOnTarget(effObj, EFFECTTYPE_HENGYUNDUANFENG, keepround, effectData)
          objEffectList[#objEffectList + 1] = EFFECTTYPE_HENGYUNDUANFENG
        else
          objEffectList = {EFFECTTYPE_IMMUNITY}
        end
        if index == 1 then
          tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, objPos, objHp, objMp, 0, 0, {}, objEffectList, skillID, userMp)
        else
          tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, objPos, objHp, objMp, 0, 0, {}, objEffectList)
        end
        index = index + 1
      end
    end
    _setPetSkillCDRound(userObj, skillID, warRound + cdround + 1)
    _onNewFormatFightSequence(warId, formatFightSeq)
  elseif skillID == PETSKILL_SHUSHOUWUCE then
    targetPos = _checkSelectTarget(warId, userPos, targetPos, false)
    local targetObj = _getFightRoleObjByPos(warId, targetPos)
    if targetObj == nil then
      return
    end
    if _checkSkillGGLXMJLL(warId, userPos, userObj, skillID, true) ~= true then
      return
    end
    local petLv = userObj:getProperty(PROPERTY_ROLELEVEL)
    local petClose = userObj:getProperty(PROPERTY_CLOSEVALUE)
    local userMp = userObj:getProperty(PROPERTY_MP)
    local userMaxMp = userObj:getMaxProperty(PROPERTY_MP)
    local skillNeedMp = _getPetSkillRequireMp(userObj, skillID, petLv, petClose, userMaxMp)
    if userMp < skillNeedMp then
      print_SkillLog_LackMp(warId, userMp, skillNeedMp)
      _LackManaWhenSkill(warId, userPos, userObj, skillID)
      return
    end
    _checkCancelStealth(warId, userPos, userObj)
    local checkFlag = _checkWhenUseSkillOfWar(warId, warRound, userPos, skillID)
    if checkFlag == false then
      return
    end
    userMp = userObj:getProperty(PROPERTY_MP)
    if skillNeedMp > userMp then
      print_SkillLog_LackMp(warId, userMp, skillNeedMp)
      _LackManaWhenSkill(warId, userPos, userObj, skillID)
      return
    end
    userMp = userMp - skillNeedMp
    userObj:setProperty(PROPERTY_MP, userMp)
    local targetHp = targetObj:getProperty(PROPERTY_HP)
    local targetMp = targetObj:getProperty(PROPERTY_MP)
    local pro, round = _computePetSkill_ShuShouWuCe(petLv, petClose, userObj:getType())
    if _canSkillOnRole_ShuShouWuCe(targetObj) and _canAffectOnPro(pro) then
      _addEffectOnTarget(targetObj, EFFECTTYPE_SHUSHOUWUCE, round)
      tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, 0, 0, {}, {EFFECTTYPE_SHUSHOUWUCE}, skillID, userMp)
    else
      tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, 0, 0, {}, {EFFECTTYPE_IMMUNITY}, skillID, userMp)
    end
    _onNewFormatFightSequence(warId, formatFightSeq)
  elseif skillID == PETSKILL_NIANHUAYIXIAO then
    targetPos = _checkSelectTarget(warId, userPos, targetPos, false)
    local targetObj = _getFightRoleObjByPos(warId, targetPos)
    if targetObj == nil then
      return
    end
    local canUseRound = _getPetSkillCDRound(userObj, skillID)
    if warRound < canUseRound then
      return
    end
    if _checkSkillGGLXMJLL(warId, userPos, userObj, skillID, true) ~= true then
      return
    end
    local petLv = userObj:getProperty(PROPERTY_ROLELEVEL)
    local petClose = userObj:getProperty(PROPERTY_CLOSEVALUE)
    local userMp = userObj:getProperty(PROPERTY_MP)
    local userMaxMp = userObj:getMaxProperty(PROPERTY_MP)
    local skillNeedMp = _getPetSkillRequireMp(userObj, skillID, petLv, petClose, userMaxMp)
    if userMp < skillNeedMp then
      print_SkillLog_LackMp(warId, userMp, skillNeedMp)
      _LackManaWhenSkill(warId, userPos, userObj, skillID)
      return
    end
    _checkCancelStealth(warId, userPos, userObj)
    local checkFlag = _checkWhenUseSkillOfWar(warId, warRound, userPos, skillID)
    if checkFlag == false then
      return
    end
    userMp = userObj:getProperty(PROPERTY_MP)
    if skillNeedMp > userMp then
      print_SkillLog_LackMp(warId, userMp, skillNeedMp)
      _LackManaWhenSkill(warId, userPos, userObj, skillID)
      return
    end
    userMp = userMp - skillNeedMp
    userObj:setProperty(PROPERTY_MP, userMp)
    local damageHp, round, _ = _computePetSkill_NianHuaYiXiao(petLv, petClose, userObj:getType())
    local targetHp = targetObj:getProperty(PROPERTY_HP)
    local targetMp = targetObj:getProperty(PROPERTY_MP)
    if _canSkillOnRole_NianHuaYiXiao(targetObj) then
      if not _RoleIsDamgeImmunity(targetObj) then
        damageHp = math.random(1, damageHp)
        local wxCoeff = _getWuXingKeZhiXiuZheng(userObj, targetObj, WUXING_CHONGWU)
        damageHp = _checkDamage(damageHp * (1 + wxCoeff))
        local objEffectList = {}
        local maxHpMpChanged = false
        targetHp = targetHp - damageHp
        if targetHp <= 0 then
          targetHp, maxHpMpChanged = _setRoleIsDeadInWar(warId, warRound, targetPos, targetObj, objEffectList)
        end
        targetObj:setProperty(PROPERTY_HP, targetHp)
        if targetObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and _checkRoleIsInState(targetObj, EFFECTTYPE_SLEEP) then
          _removeRoleEffectState(targetObj, EFFECTTYPE_SLEEP)
          objEffectList[#objEffectList + 1] = EFFECTTYPE_SLEEP_OFF
        end
        tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, damageHp, 0, {}, objEffectList, skillID, userMp)
        if maxHpMpChanged == true then
          local tMaxHp = targetObj:getMaxProperty(PROPERTY_HP)
          local tMaxMp = targetObj:getMaxProperty(PROPERTY_MP)
          tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillHpMpBase(userPos, targetPos, targetHp, targetMp, tMaxHp, tMaxMp)
        end
      else
        local objEffectList = {EFFECTTYPE_IMMUNITY_DAMAGE}
        tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, 0, 0, {}, objEffectList, skillID, userMp)
      end
    else
      local objEffectList = {EFFECTTYPE_IMMUNITY}
      tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, 0, 0, {}, objEffectList, skillID, userMp)
    end
    _setPetSkillCDRound(userObj, skillID, warRound + round + 1)
    _onNewFormatFightSequence(warId, formatFightSeq)
  elseif skillID == PETSKILL_MIAOBISHENGHUA then
    targetPos = _checkSelectTarget(warId, userPos, targetPos, false, false, nil, true)
    local targetObj = _getFightRoleObjByPos(warId, targetPos)
    if targetObj == nil then
      return
    end
    local canUseRound = _getPetSkillCDRound(userObj, skillID)
    if warRound < canUseRound then
      return
    end
    if _checkSkillGGLXMJLL(warId, userPos, userObj, skillID, true) ~= true then
      return
    end
    local petLv = userObj:getProperty(PROPERTY_ROLELEVEL)
    local petClose = userObj:getProperty(PROPERTY_CLOSEVALUE)
    local userMp = userObj:getProperty(PROPERTY_MP)
    local userMaxMp = userObj:getMaxProperty(PROPERTY_MP)
    local skillNeedMp = _getPetSkillRequireMp(userObj, skillID, petLv, petClose, userMaxMp)
    if userMp < skillNeedMp then
      print_SkillLog_LackMp(warId, userMp, skillNeedMp)
      _LackManaWhenSkill(warId, userPos, userObj, skillID)
      return
    end
    _checkCancelStealth(warId, userPos, userObj)
    local checkFlag = _checkWhenUseSkillOfWar(warId, warRound, userPos, skillID)
    if checkFlag == false then
      return
    end
    userMp = userObj:getProperty(PROPERTY_MP)
    if skillNeedMp > userMp then
      print_SkillLog_LackMp(warId, userMp, skillNeedMp)
      _LackManaWhenSkill(warId, userPos, userObj, skillID)
      return
    end
    local pro, round = _computePetSkill_MiaoBiShengHua(petLv, petClose, userObj:getType())
    userMp = userMp - skillNeedMp
    userObj:setProperty(PROPERTY_MP, userMp)
    local targetHp = targetObj:getProperty(PROPERTY_HP)
    local targetMp = targetObj:getProperty(PROPERTY_MP)
    if _canSkillOnRole_MiaoBiShengHua(targetObj) then
      if _canAffectOnPro(pro) then
        local effectList = targetObj:getEffects()
        local rmvEffList = {}
        for effectID, effectInfo in pairs(effectList) do
          if effectID == EFFECTTYPE_CONFUSE then
            local effData = _getRoleEffectData(roleObj, effectID)
            if effData ~= CONFUSETYPE_HERO then
              rmvEffList[#rmvEffList + 1] = effectID
            end
          elseif effectID == EFFECTTYPE_FROZEN then
            local effData = _getRoleEffectData(roleObj, effectID)
            if effData ~= FROZENTYPE_HERO then
              rmvEffList[#rmvEffList + 1] = effectID
            end
          elseif EFFECTBUFF_MIAOBISHENGHUA_CLEAR[effectID] ~= nil then
            rmvEffList[#rmvEffList + 1] = effectID
          end
        end
        local objEffectList = {}
        local maxHpMpChanged = false
        if #rmvEffList > 0 then
          local selEffID = rmvEffList[math.random(1, #rmvEffList)]
          local rmvDict = {selEffID}
          if selEffID == EFFECTTYPE_DEC_WULI or selEffID == EFFECTTYPE_DEC_RENZU or selEffID == EFFECTTYPE_DEC_XIANZU then
            rmvDict = {
              EFFECTTYPE_DEC_WULI,
              EFFECTTYPE_DEC_RENZU,
              EFFECTTYPE_DEC_XIANZU
            }
          end
          for _, rmvEffID in pairs(rmvDict) do
            local effectInfo = effectList[rmvEffID]
            local effectData = effectInfo[3]
            local effectOffID = _getEffectOffID(rmvEffID)
            objEffectList[#objEffectList + 1] = effectOffID
            maxHpMpChanged = _checkDurativeEffectOnRole_Off(warId, targetPos, targetObj, rmvEffID, effectOffID, effectData, false) or maxHpMpChanged
            effectList[rmvEffID] = nil
          end
          targetObj:setEffects(effectList)
        end
        targetHp = targetObj:getProperty(PROPERTY_HP)
        targetMp = targetObj:getProperty(PROPERTY_MP)
        tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, 0, 0, {}, objEffectList, skillID, userMp)
        if maxHpMpChanged == true then
          local objMaxHp = targetObj:getMaxProperty(PROPERTY_HP)
          local objMaxMp = targetObj:getMaxProperty(PROPERTY_MP)
          tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillHpMpBase(userPos, targetPos, targetHp, targetMp, objMaxHp, objMaxMp)
        end
      else
        local objEffectList = {EFFECTTYPE_INVALID}
        tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, 0, 0, {}, objEffectList, skillID, userMp)
      end
    else
      local objEffectList = {EFFECTTYPE_IMMUNITY}
      tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, 0, 0, {}, objEffectList, skillID, userMp)
    end
    _setPetSkillCDRound(userObj, skillID, warRound + round + 1)
    _onNewFormatFightSequence(warId, formatFightSeq)
  elseif skillID == PETSKILL_TIESHUKAIHUA then
    local useTimes = userObj:getTempProperty(PROPERTY_TIESHUKAIHUA)
    if useTimes >= 1 then
      return
    end
    local canUseRound = _getPetSkillCDRound(userObj, skillID)
    if warRound < canUseRound then
      return
    end
    if _checkSkillGGLXMJLL(warId, userPos, userObj, skillID, true) ~= true then
      return
    end
    local petLv = userObj:getProperty(PROPERTY_ROLELEVEL)
    local petClose = userObj:getProperty(PROPERTY_CLOSEVALUE)
    local userMp = userObj:getProperty(PROPERTY_MP)
    local userMaxMp = userObj:getMaxProperty(PROPERTY_MP)
    local skillNeedMp = _getPetSkillRequireMp(userObj, skillID, petLv, petClose, userMaxMp)
    if userMp < skillNeedMp then
      print_SkillLog_LackMp(warId, userMp, skillNeedMp)
      _LackManaWhenSkill(warId, userPos, userObj, skillID)
      return
    end
    _checkCancelStealth(warId, userPos, userObj)
    local checkFlag = _checkWhenUseSkillOfWar(warId, warRound, userPos, skillID)
    if checkFlag == false then
      return
    end
    userMp = userObj:getProperty(PROPERTY_MP)
    if skillNeedMp > userMp then
      print_SkillLog_LackMp(warId, userMp, skillNeedMp)
      _LackManaWhenSkill(warId, userPos, userObj, skillID)
      return
    end
    userMp = userMp - skillNeedMp
    userObj:setProperty(PROPERTY_MP, userMp)
    local hpCoeff, mpCoeff, targetNum, _ = _computePetSkill_TieShuKaiHua()
    local selList = {}
    if _getFightRoleObjByPos_WithDeadHero(warId, targetPos) ~= nil then
      selList[#selList + 1] = targetPos
      targetNum = targetNum - 1
    end
    if targetNum > 0 then
      local posList = _getPosListByTeamAndTargetType(team, TARGETTYPE_MYSIDE)
      local function _tskh_sortFunc(a, b)
        local posObj_a = _getFightRoleObjByPos_WithDeadHero(warId, a)
        local posObj_b = _getFightRoleObjByPos_WithDeadHero(warId, b)
        if posObj_a == nil or posObj_b == nil then
          if posObj_a ~= nil then
            return true
          else
            return false
          end
        else
          local eHp_a = posObj_a:getProperty(PROPERTY_HP)
          local eMaxHp_a = posObj_a:getMaxProperty(PROPERTY_HP)
          local chp_a = eHp_a / math.max(eMaxHp_a, 1)
          local eHp_b = posObj_b:getProperty(PROPERTY_HP)
          local eMaxHp_b = posObj_b:getMaxProperty(PROPERTY_HP)
          local chp_b = eHp_b / math.max(eMaxHp_b, 1)
          if chp_a ~= chp_b then
            return chp_a < chp_b
          else
            local eMp_a = posObj_a:getProperty(PROPERTY_MP)
            local eMaxMp_a = posObj_a:getMaxProperty(PROPERTY_MP)
            local cmp_a = eMp_a / math.max(eMaxMp_a, 1)
            local eMp_b = posObj_b:getProperty(PROPERTY_MP)
            local eMaxMp_b = posObj_b:getMaxProperty(PROPERTY_MP)
            local cmp_b = eMp_b / math.max(eMaxMp_b, 1)
            if cmp_a ~= cmp_b then
              return cmp_a < cmp_b
            else
              return a < b
            end
          end
        end
      end
      table.sort(posList, _tskh_sortFunc)
      for i = 1, #posList do
        if targetNum <= 0 then
          break
        end
        local pos = posList[i]
        if pos ~= targetPos then
          if pos ~= nil then
            selList[#selList + 1] = pos
          end
          targetNum = targetNum - 1
        end
      end
    end
    local index = 1
    for _, effPos in pairs(selList) do
      local effObj = _getFightRoleObjByPos_WithDeadHero(warId, effPos)
      if effObj then
        local eHp = effObj:getProperty(PROPERTY_HP)
        local eMp = effObj:getProperty(PROPERTY_MP)
        local eMaxHp = effObj:getMaxProperty(PROPERTY_HP)
        local eMaxMp = effObj:getMaxProperty(PROPERTY_MP)
        local addHp, addMp = 0, 0
        local fuhuo
        local effList = {}
        local attEffList
        if not _checkRoleIsInState(effObj, EFFECTTYPE_DUOHUNSUOMING) then
          addHp = _checkDamage(eMaxHp * hpCoeff)
          if eMaxMp > 0 then
            addMp = _checkDamage(eMaxMp * mpCoeff)
          end
          eHp = math.min(eHp + addHp, eMaxHp)
          eMp = math.min(eMp + addMp, eMaxMp)
          effObj:setProperty(PROPERTY_HP, eHp)
          effObj:setProperty(PROPERTY_MP, eMp)
          if effObj:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD then
            effObj:setProperty(PROPERTY_DEAD, ROLESTATE_LIVE)
            fuhuo = 1
          end
        else
          effList = {EFFECTTYPE_INVALID}
          attEffList = {EFFECTTYPE_ADDHPFAILED_DHSM}
        end
        if index == 1 then
          tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillAddHpMp(userPos, effPos, eHp, eMp, addHp, addMp, nil, nil, fuhuo, effList, skillID, userMp, attEffList)
        else
          tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillAddHpMp(userPos, effPos, eHp, eMp, addHp, addMp, nil, nil, fuhuo, effList, nil, nil, attEffList)
        end
        index = index + 1
      end
    end
    _checkIsThieveSkill(userObj, skillID)
    userObj:setTempProperty(PROPERTY_TIESHUKAIHUA, useTimes + 1)
    _setPetSkillCDRound(userObj, skillID, 9999)
    _onNewFormatFightSequence(warId, formatFightSeq)
  elseif skillID == PETSKILL_JUEJINGFENGSHENG then
    local useTimes = userObj:getTempProperty(PROPERTY_JUEJINGFENGSHENG)
    if useTimes >= 1 then
      return
    end
    local canUseRound = _getPetSkillCDRound(userObj, skillID)
    if warRound < canUseRound then
      return
    end
    if _checkSkillGGLXMJLL(warId, userPos, userObj, skillID, true) ~= true then
      return
    end
    local petLv = userObj:getProperty(PROPERTY_ROLELEVEL)
    local petClose = userObj:getProperty(PROPERTY_CLOSEVALUE)
    local userMp = userObj:getProperty(PROPERTY_MP)
    local userMaxMp = userObj:getMaxProperty(PROPERTY_MP)
    local skillNeedMp = _getPetSkillRequireMp(userObj, skillID, petLv, petClose, userMaxMp)
    if userMp < skillNeedMp then
      print_SkillLog_LackMp(warId, userMp, skillNeedMp)
      _LackManaWhenSkill(warId, userPos, userObj, skillID)
      return
    end
    _checkCancelStealth(warId, userPos, userObj)
    local checkFlag = _checkWhenUseSkillOfWar(warId, warRound, userPos, skillID)
    if checkFlag == false then
      return
    end
    userMp = userObj:getProperty(PROPERTY_MP)
    if skillNeedMp > userMp then
      print_SkillLog_LackMp(warId, userMp, skillNeedMp)
      _LackManaWhenSkill(warId, userPos, userObj, skillID)
      return
    end
    userMp = userMp - skillNeedMp
    userObj:setProperty(PROPERTY_MP, userMp)
    local hpCoeff, mpCoeff, _ = _computePetSkill_JueJingFengSheng()
    local posList = _getPosListByTeamAndTargetType(team, TARGETTYPE_MYSIDE)
    local index = 1
    for _, effPos in pairs(posList) do
      local effObj = _getFightRoleObjByPos_WithDeadHero(warId, effPos)
      if effObj then
        local eHp = effObj:getProperty(PROPERTY_HP)
        local eMp = effObj:getProperty(PROPERTY_MP)
        local eMaxHp = effObj:getMaxProperty(PROPERTY_HP)
        local eMaxMp = effObj:getMaxProperty(PROPERTY_MP)
        local addHp, addMp = 0, 0
        local fuhuo
        local effList = {}
        local attEffList
        if not _checkRoleIsInState(effObj, EFFECTTYPE_DUOHUNSUOMING) then
          addHp = _checkDamage(eMaxHp * hpCoeff)
          if eMaxMp > 0 then
            addMp = _checkDamage(eMaxMp * mpCoeff)
          end
          eHp = math.min(eHp + addHp, eMaxHp)
          eMp = math.min(eMp + addMp, eMaxMp)
          effObj:setProperty(PROPERTY_HP, eHp)
          effObj:setProperty(PROPERTY_MP, eMp)
          if effObj:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD then
            effObj:setProperty(PROPERTY_DEAD, ROLESTATE_LIVE)
            fuhuo = 1
          end
        else
          effList = {EFFECTTYPE_INVALID}
          attEffList = {EFFECTTYPE_ADDHPFAILED_DHSM}
        end
        if index == 1 then
          tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillAddHpMp(userPos, effPos, eHp, eMp, addHp, addMp, nil, nil, fuhuo, effList, skillID, userMp, attEffList)
        else
          tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillAddHpMp(userPos, effPos, eHp, eMp, addHp, addMp, nil, nil, fuhuo, effList, nil, nil, attEffList)
        end
        index = index + 1
      end
    end
    _checkIsThieveSkill(userObj, skillID)
    userObj:setTempProperty(PROPERTY_JUEJINGFENGSHENG, useTimes + 1)
    _setPetSkillCDRound(userObj, skillID, 9999)
    _onNewFormatFightSequence(warId, formatFightSeq)
  elseif skillID == PETSKILL_ZIXUWUYOU then
    local canUseRound = _getPetSkillCDRound(userObj, skillID)
    if warRound < canUseRound then
      return
    end
    if _checkSkillGGLXMJLL(warId, userPos, userObj, skillID, true) ~= true then
      return
    end
    local petLv = userObj:getProperty(PROPERTY_ROLELEVEL)
    local petClose = userObj:getProperty(PROPERTY_CLOSEVALUE)
    local userMp = userObj:getProperty(PROPERTY_MP)
    local userMaxMp = userObj:getMaxProperty(PROPERTY_MP)
    local skillNeedMp = _getPetSkillRequireMp(userObj, skillID, petLv, petClose, userMaxMp)
    if userMp < skillNeedMp then
      print_SkillLog_LackMp(warId, userMp, skillNeedMp)
      _LackManaWhenSkill(warId, userPos, userObj, skillID)
      return
    end
    _checkCancelStealth(warId, userPos, userObj)
    local checkFlag = _checkWhenUseSkillOfWar(warId, warRound, userPos, skillID)
    if checkFlag == false then
      return
    end
    userMp = userObj:getProperty(PROPERTY_MP)
    if skillNeedMp > userMp then
      print_SkillLog_LackMp(warId, userMp, skillNeedMp)
      _LackManaWhenSkill(warId, userPos, userObj, skillID)
      return
    end
    userMp = userMp - skillNeedMp
    userObj:setProperty(PROPERTY_MP, userMp)
    local checPosList = {userPos, targetPos}
    if userPos == targetPos then
      checPosList = {userPos}
    end
    local keepRound, cdRound = _computePetSkill_ZiXuWuYou()
    local index = 1
    for _, effPos in pairs(checPosList) do
      local effObj = _getFightRoleObjByPos(warId, effPos)
      if effObj then
        local eHp = effObj:getProperty(PROPERTY_HP)
        local eMp = effObj:getProperty(PROPERTY_MP)
        local objEffectList = {}
        if not _checkRoleIsInState(effObj, EFFECTTYPE_FROZEN) then
          _addEffectOnTarget(effObj, EFFECTTYPE_STEALTH, keepRound)
          objEffectList[#objEffectList + 1] = EFFECTTYPE_STEALTH
        else
          objEffectList = {EFFECTTYPE_IMMUNITY}
        end
        if index == 1 then
          tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, effPos, eHp, eMp, 0, 0, {}, objEffectList, skillID, userMp)
        else
          tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, effPos, eHp, eMp, 0, 0, {}, objEffectList)
        end
        index = index + 1
      end
    end
    _checkIsThieveSkill(userObj, skillID)
    _setPetSkillCDRound(userObj, skillID, warRound + cdRound + 1)
    _onNewFormatFightSequence(warId, formatFightSeq)
  elseif skillID == PETSKILL_CHUNNUANHUAKAI then
    targetPos = _checkSelectTarget(warId, userPos, targetPos, false, false, {
      [LOGICTYPE_PET] = true
    }, true)
    local targetObj = _getFightRoleObjByPos(warId, targetPos)
    if targetObj == nil then
      return
    end
    local canUseRound = _getPetSkillCDRound(userObj, skillID)
    if warRound < canUseRound then
      return
    end
    if _checkSkillGGLXMJLL(warId, userPos, userObj, skillID, true) ~= true then
      return
    end
    local petLv = userObj:getProperty(PROPERTY_ROLELEVEL)
    local petClose = userObj:getProperty(PROPERTY_CLOSEVALUE)
    local userMp = userObj:getProperty(PROPERTY_MP)
    local userMaxMp = userObj:getMaxProperty(PROPERTY_MP)
    local skillNeedMp = _getPetSkillRequireMp(userObj, skillID, petLv, petClose, userMaxMp)
    if userMp < skillNeedMp then
      print_SkillLog_LackMp(warId, userMp, skillNeedMp)
      _LackManaWhenSkill(warId, userPos, userObj, skillID)
      return
    end
    _checkCancelStealth(warId, userPos, userObj)
    local checkFlag = _checkWhenUseSkillOfWar(warId, warRound, userPos, skillID)
    if checkFlag == false then
      return
    end
    userMp = userObj:getProperty(PROPERTY_MP)
    if skillNeedMp > userMp then
      print_SkillLog_LackMp(warId, userMp, skillNeedMp)
      _LackManaWhenSkill(warId, userPos, userObj, skillID)
      return
    end
    local cdRound_1, cdRound_2 = _computePetSkill_ChunNuanHuaKai(petLv, petClose)
    userMp = userMp - skillNeedMp
    userObj:setProperty(PROPERTY_MP, userMp)
    local cdRound = cdRound_1
    local cdInfo = targetObj:getTempProperty(PROPERTY_PETSKILLCD)
    if type(cdInfo) ~= "table" then
      cdInfo = {}
    end
    local newcdInfo = {}
    for sId, cdR in pairs(cdInfo) do
      if warRound < cdR and warRound >= _getSkillUseOfMinRoundFlag(sId) then
        if sId == PETSKILL_JUEJINGFENGSHENG then
          cdRound = cdRound_2
          targetObj:setTempProperty(PROPERTY_JUEJINGFENGSHENG, 0)
        elseif sId == PETSKILL_CHUNHUIDADI then
          cdRound = cdRound_2
          targetObj:setTempProperty(PROPERTY_CHUNHUIDADI, 0)
        elseif sId == PETSKILL_TIESHUKAIHUA then
          cdRound = cdRound_2
          targetObj:setTempProperty(PROPERTY_TIESHUKAIHUA, 0)
        elseif sId == PETSKILL_HUICHUNMIAOSHOU then
          cdRound = cdRound_2
          targetObj:setTempProperty(PROPERTY_HUICHUNMIAOSHOU, 0)
        end
      else
        newcdInfo[sId] = cdR
      end
    end
    targetObj:setTempProperty(PROPERTY_PETSKILLCD, newcdInfo)
    local formatFightSeq = {
      seqType = SEQTYPE_USESKILL,
      userPos = userPos,
      targetInfo = {}
    }
    local tInfo = formatFightSeq.targetInfo
    local targetHp = targetObj:getProperty(PROPERTY_HP)
    local targetMp = targetObj:getProperty(PROPERTY_MP)
    tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, 0, 0, {}, {}, skillID, userMp)
    _checkIsThieveSkill(userObj, skillID)
    _setPetSkillCDRound(userObj, skillID, warRound + cdRound + 1)
    _onNewFormatFightSequence(warId, formatFightSeq)
    _formatAndSendWordTipSequence(warId, targetObj:getPlayerId(), SUBSEQTYPE_SKILLCDFRESH)
  elseif skillID == PETSKILL_CHUNHUIDADI then
    local useTimes = userObj:getTempProperty(PROPERTY_CHUNHUIDADI)
    if useTimes >= 1 and not isMonster then
      return
    end
    local canUseRound = _getPetSkillCDRound(userObj, skillID)
    if warRound < canUseRound and not isMonster then
      return
    end
    if _checkSkillGGLXMJLL(warId, userPos, userObj, skillID, true) ~= true then
      return
    end
    local petLv = userObj:getProperty(PROPERTY_ROLELEVEL)
    local petClose = userObj:getProperty(PROPERTY_CLOSEVALUE)
    local userMp = userObj:getProperty(PROPERTY_MP)
    local userMaxMp = userObj:getMaxProperty(PROPERTY_MP)
    local skillNeedMp = _getPetSkillRequireMp(userObj, skillID, petLv, petClose, userMaxMp)
    if isMonster then
      skillNeedMp = 0
    end
    if userMp < skillNeedMp then
      print_SkillLog_LackMp(warId, userMp, skillNeedMp)
      _LackManaWhenSkill(warId, userPos, userObj, skillID)
      return
    end
    _checkCancelStealth(warId, userPos, userObj)
    local checkFlag = _checkWhenUseSkillOfWar(warId, warRound, userPos, skillID)
    if checkFlag == false then
      return
    end
    userMp = userObj:getProperty(PROPERTY_MP)
    if skillNeedMp > userMp then
      print_SkillLog_LackMp(warId, userMp, skillNeedMp)
      _LackManaWhenSkill(warId, userPos, userObj, skillID)
      return
    end
    userMp = userMp - skillNeedMp
    userObj:setProperty(PROPERTY_MP, userMp)
    local pairs = pairs
    local posList = _getPosListByTeamAndTargetType(team, TARGETTYPE_MYSIDE)
    local index = 1
    for _, effPos in pairs(posList) do
      local effObj = _getFightRoleObjByPos_WithDeadHero(warId, effPos)
      if effObj and effObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
        local currAllEffectList = effObj:getEffects()
        local objEffectList = {}
        local maxHpMpChanged = false
        for eID, eInfo in pairs(currAllEffectList) do
          if EFFECTBUFF_CHUNHUIDADI_CLEAR[eID] ~= nil then
            local eOffID = _getEffectOffID(eID)
            local eData = eInfo[3]
            if eOffID ~= nil then
              maxHpMpChanged = _checkDurativeEffectOnRole_Off(warId, effPos, effObj, eID, eOffID, eData, false) or maxHpMpChanged
              objEffectList[#objEffectList + 1] = eOffID
            end
          end
        end
        local eHp = effObj:getProperty(PROPERTY_HP)
        local eMp = effObj:getProperty(PROPERTY_MP)
        if #objEffectList > 0 then
          objEffectList[#objEffectList + 1] = EFFECTTYPE_CHUNHUIDADI
        end
        if index == 1 then
          tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, effPos, eHp, eMp, 0, 0, {}, objEffectList, skillID, userMp)
        else
          tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, effPos, eHp, eMp, 0, 0, {}, objEffectList)
        end
        if maxHpMpChanged == true then
          local objMaxHp = effObj:getMaxProperty(PROPERTY_HP)
          local objMaxMp = effObj:getMaxProperty(PROPERTY_MP)
          tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillHpMpBase(userPos, effPos, eHp, eMp, objMaxHp, objMaxMp)
        end
        index = index + 1
      end
    end
    _checkIsThieveSkill(userObj, skillID)
    if not isMonster then
      userObj:setTempProperty(PROPERTY_CHUNHUIDADI, useTimes + 1)
      _setPetSkillCDRound(userObj, skillID, 9999)
    elseif userObj:PossessMonsterTeXing(MONSTER_TX_11) then
      formatFightSeq.txId = MONSTER_TX_11
    end
    _onNewFormatFightSequence(warId, formatFightSeq)
  elseif skillID == PETSKILL_DUOHUNSUOMING then
    local targetObj = _getFightRoleObjByPos_WithDeadHero(warId, targetPos)
    if targetObj == nil or targetObj:getType() ~= LOGICTYPE_HERO or targetObj:getProperty(PROPERTY_DEAD) ~= ROLESTATE_DEAD then
      return
    end
    local canUseRound = _getPetSkillCDRound(userObj, skillID)
    if warRound < canUseRound then
      return
    end
    if _checkSkillGGLXMJLL(warId, userPos, userObj, skillID, true) ~= true then
      return
    end
    local petLv = userObj:getProperty(PROPERTY_ROLELEVEL)
    local petClose = userObj:getProperty(PROPERTY_CLOSEVALUE)
    local userMp = userObj:getProperty(PROPERTY_MP)
    local userMaxMp = userObj:getMaxProperty(PROPERTY_MP)
    local skillNeedMp = _getPetSkillRequireMp(userObj, skillID, petLv, petClose, userMaxMp)
    if userMp < skillNeedMp then
      print_SkillLog_LackMp(warId, userMp, skillNeedMp)
      _LackManaWhenSkill(warId, userPos, userObj, skillID)
      return
    end
    _checkCancelStealth(warId, userPos, userObj)
    local checkFlag = _checkWhenUseSkillOfWar(warId, warRound, userPos, skillID)
    if checkFlag == false then
      return
    end
    userMp = userObj:getProperty(PROPERTY_MP)
    if skillNeedMp > userMp then
      print_SkillLog_LackMp(warId, userMp, skillNeedMp)
      _LackManaWhenSkill(warId, userPos, userObj, skillID)
      return
    end
    userMp = userMp - skillNeedMp
    userObj:setProperty(PROPERTY_MP, userMp)
    local pro, round, cdRound, _ = _computePetSkill_DuoHunSuoMing(petLv, petClose, userObj:getType())
    local targetHp = targetObj:getProperty(PROPERTY_HP)
    local targetMp = targetObj:getProperty(PROPERTY_MP)
    if _canAffectOnPro(pro) then
      _addEffectOnTarget(targetObj, EFFECTTYPE_DUOHUNSUOMING, round)
      local objEffectList = {EFFECTTYPE_DUOHUNSUOMING}
      tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, 0, 0, {}, objEffectList, skillID, userMp)
    else
      local objEffectList = {EFFECTTYPE_INVALID}
      tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, 0, 0, {}, objEffectList, skillID, userMp)
    end
    _checkIsThieveSkill(userObj, skillID)
    _setPetSkillCDRound(userObj, skillID, warRound + cdRound + 1)
    _onNewFormatFightSequence(warId, formatFightSeq)
  elseif skillID == PETSKILL_BINGLINCHENGXIA then
    targetPos = _checkSelectTarget(warId, userPos, targetPos, false)
    local targetObj = _getFightRoleObjByPos(warId, targetPos)
    if targetObj == nil then
      return
    end
    if _checkSkillGGLXMJLL(warId, userPos, userObj, skillID, true) ~= true then
      return
    end
    local userHp = userObj:getProperty(PROPERTY_HP)
    local userMp = userObj:getProperty(PROPERTY_MP)
    local maxHp = userObj:getMaxProperty(PROPERTY_HP)
    local maxMp = userObj:getMaxProperty(PROPERTY_MP)
    local _, hpCoeff, mpCoeff, dCoeff = _computePetSkill_BingLinChengXia()
    local skillNeedHp = maxHp * hpCoeff
    if userHp <= skillNeedHp then
      print_SkillLog_LackMp(warId, userMp, skillNeedHp)
      _LackHpWhenSkill(warId, userPos, userObj, skillID)
      return
    end
    local skillNeedMp = maxMp * mpCoeff
    if userMp < skillNeedMp then
      print_SkillLog_LackMp(warId, userMp, skillNeedMp)
      _LackManaWhenSkill(warId, userPos, userObj, skillID)
      return
    end
    _checkCancelStealth(warId, userPos, userObj)
    _normalAttackOnTarget(warId, warRound, userPos, targetPos, nil, {blcx = true})
    _checkIsThieveSkill(userObj, skillID)
  elseif skillID == PETSKILL_JINYUZHOU or skillID == PETSKILL_XIUMUZHOU or skillID == PETSKILL_LIUSHUIZHOU or skillID == PETSKILL_LIEYANZHOU or skillID == PETSKILL_LIETUZHOU then
    targetPos = _checkSelectTarget(warId, userPos, targetPos, false)
    local targetObj = _getFightRoleObjByPos(warId, targetPos)
    if targetObj == nil then
      return
    end
    local canUseRound = _getPetSkillCDRound(userObj, skillID)
    if warRound < canUseRound then
      return
    end
    if _checkSkillGGLXMJLL(warId, userPos, userObj, skillID, true) ~= true then
      return
    end
    local petLv = userObj:getProperty(PROPERTY_ROLELEVEL)
    local petClose = userObj:getProperty(PROPERTY_CLOSEVALUE)
    local userMp = userObj:getProperty(PROPERTY_MP)
    local userMaxMp = userObj:getMaxProperty(PROPERTY_MP)
    local skillNeedMp = _getPetSkillRequireMp(userObj, skillID, petLv, petClose, userMaxMp)
    if userMp < skillNeedMp then
      print_SkillLog_LackMp(warId, userMp, skillNeedMp)
      _LackManaWhenSkill(warId, userPos, userObj, skillID)
      return
    end
    _checkCancelStealth(warId, userPos, userObj)
    local checkFlag = _checkWhenUseSkillOfWar(warId, warRound, userPos, skillID)
    if checkFlag == false then
      return
    end
    userMp = userObj:getProperty(PROPERTY_MP)
    if skillNeedMp > userMp then
      print_SkillLog_LackMp(warId, userMp, skillNeedMp)
      _LackManaWhenSkill(warId, userPos, userObj, skillID)
      return
    end
    userMp = userMp - skillNeedMp
    userObj:setProperty(PROPERTY_MP, userMp)
    local coeff_1, coeff_2, round, cdRound = _computePetSkill_JinYuZhou(skillID)
    local pairs = pairs
    local posList = _getPosListByTeamAndTargetType(team, TARGETTYPE_ENEMYSIDE)
    local index = 1
    for _, effPos in pairs(posList) do
      local effObj = _getFightRoleObjByPos(warId, effPos)
      if effObj and effObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and not _checkRoleIsInState(effObj, EFFECTTYPE_STEALTH) then
        local eHp = effObj:getProperty(PROPERTY_HP)
        local eMp = effObj:getProperty(PROPERTY_MP)
        if not _checkRoleIsInState(effObj, EFFECTTYPE_FROZEN) then
          local effData = _getRoleEffectData(effObj, EFFECTTYPE_WUXING)
          if effData ~= nil then
            _checkDurativeEffectOnRole_Off(warId, effPos, effObj, EFFECTTYPE_WUXING, EFFECTTYPE_WUXING_OFF, effData)
          end
          local effectData = {}
          for _, proName in pairs({
            PROPERTY_WXJIN,
            PROPERTY_WXMU,
            PROPERTY_WXSHUI,
            PROPERTY_WXHUO,
            PROPERTY_WXTU
          }) do
            local v = effObj:getProperty(proName)
            effectData[proName] = v
            if skillID == PETSKILL_JINYUZHOU and proName == PROPERTY_WXJIN or skillID == PETSKILL_XIUMUZHOU and proName == PROPERTY_WXMU or skillID == PETSKILL_LIUSHUIZHOU and proName == PROPERTY_WXSHUI or skillID == PETSKILL_LIEYANZHOU and proName == PROPERTY_WXHUO or skillID == PETSKILL_LIETUZHOU and proName == PROPERTY_WXTU then
              local newV = v * coeff_1 + coeff_2
              effObj:setProperty(proName, newV)
            else
              local newV = v * coeff_1
              effObj:setProperty(proName, newV)
            end
          end
          _addEffectOnTarget(effObj, EFFECTTYPE_WUXING, round, effectData)
          if skillID == PETSKILL_JINYUZHOU then
            objEffectList = {EFFECTTYPE_WUXING_JIN}
          elseif skillID == PETSKILL_XIUMUZHOU then
            objEffectList = {EFFECTTYPE_WUXING_MU}
          elseif skillID == PETSKILL_LIUSHUIZHOU then
            objEffectList = {EFFECTTYPE_WUXING_SHUI}
          elseif skillID == PETSKILL_LIEYANZHOU then
            objEffectList = {EFFECTTYPE_WUXING_HUO}
          elseif skillID == PETSKILL_LIETUZHOU then
            objEffectList = {EFFECTTYPE_WUXING_TU}
          end
        else
          objEffectList = {EFFECTTYPE_IMMUNITY}
        end
        if index == 1 then
          tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, effPos, eHp, eMp, 0, 0, {}, objEffectList, skillID, userMp)
        else
          tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, effPos, eHp, eMp, 0, 0, {}, objEffectList)
        end
        index = index + 1
      end
    end
    _setPetSkillCDRound(userObj, skillID, warRound + cdRound + 1)
    _onNewFormatFightSequence(warId, formatFightSeq)
  elseif skillID == PETSKILL_FENGMO then
    if not isPvpWar then
      return
    end
    targetPos = _checkSelectTarget(warId, userPos, targetPos, false)
    local targetObj = _getFightRoleObjByPos(warId, targetPos)
    if targetObj == nil then
      return
    end
    if _checkSkillGGLXMJLL(warId, userPos, userObj, skillID, true) ~= true then
      return
    end
    local petLv = userObj:getProperty(PROPERTY_ROLELEVEL)
    local petClose = userObj:getProperty(PROPERTY_CLOSEVALUE)
    local userMp = userObj:getProperty(PROPERTY_MP)
    local userMaxMp = userObj:getMaxProperty(PROPERTY_MP)
    local skillNeedMp = _getPetSkillRequireMp(userObj, skillID, petLv, petClose, userMaxMp)
    if userMp < skillNeedMp then
      print_SkillLog_LackMp(warId, userMp, skillNeedMp)
      _LackManaWhenSkill(warId, userPos, userObj, skillID)
      return
    end
    _checkCancelStealth(warId, userPos, userObj)
    local checkFlag = _checkWhenUseSkillOfWar(warId, warRound, userPos, skillID)
    if checkFlag == false then
      return
    end
    userMp = userObj:getProperty(PROPERTY_MP)
    if skillNeedMp > userMp then
      print_SkillLog_LackMp(warId, userMp, skillNeedMp)
      _LackManaWhenSkill(warId, userPos, userObj, skillID)
      return
    end
    userMp = userMp - skillNeedMp
    userObj:setProperty(PROPERTY_MP, userMp)
    local pro, round = _computePetSkill_FengMo(petLv, petClose, userObj:getType())
    local targetHp = targetObj:getProperty(PROPERTY_HP)
    local targetMp = targetObj:getProperty(PROPERTY_MP)
    if _canSkillOnRole_FengMo(targetObj) then
      if _canAffectOnPro(pro) then
        _addEffectOnTarget(targetObj, EFFECTTYPE_FENGMO, round)
        tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, 0, 0, {}, {EFFECTTYPE_FENGMO}, skillID, userMp)
      else
        tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, 0, 0, {}, {EFFECTTYPE_INVALID}, skillID, userMp)
      end
    else
      tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, 0, 0, {}, {EFFECTTYPE_IMMUNITY}, skillID, userMp)
    end
    local userEffList = {}
    local userHp, maxHpMpChanged = _setRoleIsDeadInWar(warId, warRound, userPos, userObj, userEffList)
    userObj:setProperty(PROPERTY_HP, userHp)
    local userMp = userObj:getProperty(PROPERTY_MP)
    tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, userPos, userHp, userMp, 0, 0, {}, userEffList)
    if maxHpMpChanged == true then
      local userMaxHp = userObj:getMaxProperty(PROPERTY_HP)
      local userMaxMp = userObj:getMaxProperty(PROPERTY_MP)
      tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillHpMpBase(userPos, userPos, userHp, userMp, userMaxHp, userMaxMp)
    end
    _onNewFormatFightSequence(warId, formatFightSeq)
  elseif skillID == PETSKILL_HUICHUNMIAOSHOU then
    local useTimes = userObj:getTempProperty(PROPERTY_HUICHUNMIAOSHOU)
    if useTimes >= 1 then
      return
    end
    local canUseRound = _getPetSkillCDRound(userObj, skillID)
    if warRound < canUseRound then
      return
    end
    if _checkSkillGGLXMJLL(warId, userPos, userObj, skillID, true) ~= true then
      return
    end
    local petLv = userObj:getProperty(PROPERTY_ROLELEVEL)
    local petClose = userObj:getProperty(PROPERTY_CLOSEVALUE)
    local userMp = userObj:getProperty(PROPERTY_MP)
    local userMaxMp = userObj:getMaxProperty(PROPERTY_MP)
    local skillNeedMp = _getPetSkillRequireMp(userObj, skillID, petLv, petClose, userMaxMp)
    if userMp < skillNeedMp then
      print_SkillLog_LackMp(warId, userMp, skillNeedMp)
      _LackManaWhenSkill(warId, userPos, userObj, skillID)
      return
    end
    _checkCancelStealth(warId, userPos, userObj)
    local checkFlag = _checkWhenUseSkillOfWar(warId, warRound, userPos, skillID)
    if checkFlag == false then
      return
    end
    userMp = userObj:getProperty(PROPERTY_MP)
    if skillNeedMp > userMp then
      print_SkillLog_LackMp(warId, userMp, skillNeedMp)
      _LackManaWhenSkill(warId, userPos, userObj, skillID)
      return
    end
    userMp = userMp - skillNeedMp
    userObj:setProperty(PROPERTY_MP, userMp)
    local pairs = pairs
    local targetNum, _ = _computePetSkill_HuiChunMiaoShou()
    local skillPosList = {}
    local bakPosList = {}
    printLogDebug("skill_ai", "【war log】[warid%d] 准备使用【春意盎然】 ", warId, targetPos, targetNum)
    if _getFightRoleObjByPos(warId, targetPos) ~= nil then
      table.insert(skillPosList, 1, targetPos)
      printLogDebug("skill_ai", "【war log】[warid%d] 准备使用【春意盎然】,手选的目标如果没有死亡，则必然选中", warId, targetPos, targetNum)
    end
    local posList = _getPosListByTeamAndTargetType(team, TARGETTYPE_MYSIDE)
    posList = RandomSortList(posList)
    for _, effPos in pairs(posList) do
      if targetNum <= #skillPosList then
        break
      end
      if effPos ~= targetPos then
        local effObj = _getFightRoleObjByPos(warId, effPos)
        if effObj then
          local currAllEffectList = effObj:getEffects()
          local selFlag = false
          for eID, eInfo in pairs(currAllEffectList) do
            if EFFECTBUFF_CHUNHUIDADI_CLEAR[eID] ~= nil then
              skillPosList[#skillPosList + 1] = effPos
              printLogDebug("skill_ai", "【war log】[warid%d] 准备使用【春意盎然】,去除当前身上所有的控制状态", warId, effPos, targetNum)
              selFlag = true
              break
            end
          end
          if not selFlag then
            bakPosList[#bakPosList + 1] = effPos
            printLogDebug("skill_ai", "【war log】[warid%d] 准备使用【春意盎然】,身上没有控制状态，加入备用列表", warId, effPos, targetNum)
          end
        end
      end
    end
    if targetNum > #skillPosList then
      local j = 1
      for i = #skillPosList + 1, targetNum do
        local effPos = bakPosList[j]
        if effPos ~= nil then
          skillPosList[#skillPosList + 1] = effPos
          j = j + 1
          printLogDebug("skill_ai", "【war log】[warid%d] 准备使用【春意盎然】,则从备选的没有可清除buff的列表里选择一个", warId, effPos, targetNum)
        else
          printLogDebug("skill_ai", "【war log】[warid%d] 准备使用【春意盎然】,则从备选的没有可清除buff的列表里选择一个，但是没有备选目标了", warId, effPos, targetNum)
          break
        end
      end
    end
    local index = 1
    for _, effPos in pairs(skillPosList) do
      printLogDebug("skill_ai", "【war log】[warid%d] 准备使用【春意盎然】,目标", warId, effPos, index)
      local effObj = _getFightRoleObjByPos(warId, effPos)
      if effObj then
        printLogDebug("skill_ai", "【war log】[warid%d] 使用【春意盎然】成功,目标", warId, effPos, index)
        local currAllEffectList = effObj:getEffects()
        local objEffectList = {}
        local maxHpMpChanged = false
        for eID, eInfo in pairs(currAllEffectList) do
          if EFFECTBUFF_CHUNHUIDADI_CLEAR[eID] ~= nil then
            local eOffID = _getEffectOffID(eID)
            local eData = eInfo[3]
            if eOffID ~= nil then
              maxHpMpChanged = _checkDurativeEffectOnRole_Off(warId, effPos, effObj, eID, eOffID, eData, false) or maxHpMpChanged
              objEffectList[#objEffectList + 1] = eOffID
            end
          end
        end
        local eHp = effObj:getProperty(PROPERTY_HP)
        local eMp = effObj:getProperty(PROPERTY_MP)
        if index == 1 then
          tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, effPos, eHp, eMp, 0, 0, {}, objEffectList, skillID, userMp)
        else
          tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, effPos, eHp, eMp, 0, 0, {}, objEffectList)
        end
        if maxHpMpChanged == true then
          local objMaxHp = effObj:getMaxProperty(PROPERTY_HP)
          local objMaxMp = effObj:getMaxProperty(PROPERTY_MP)
          tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillHpMpBase(userPos, effPos, eHp, eMp, objMaxHp, objMaxMp)
        end
        index = index + 1
      end
    end
    userObj:setTempProperty(PROPERTY_HUICHUNMIAOSHOU, useTimes + 1)
    _setPetSkillCDRound(userObj, skillID, 9999)
    _onNewFormatFightSequence(warId, formatFightSeq)
  elseif skillID == SKILL_SHOUHUCANGSHENG then
    local canUseRound = _getPetSkillCDRound(userObj, skillID)
    if warRound < canUseRound then
      return
    end
    local userMp = userObj:getProperty(PROPERTY_MP)
    local skillNeedMp = _computeSkillRequireMp(skillID)
    if userMp < skillNeedMp then
      print_SkillLog_LackMp(warId, userMp, skillNeedMp)
      _LackManaWhenSkill(warId, userPos, userObj, skillID)
      return
    end
    _checkCancelStealth(warId, userPos, userObj)
    local checkFlag = _checkWhenUseSkillOfWar(warId, warRound, userPos, skillID)
    if checkFlag == false then
      return
    end
    userMp = userObj:getProperty(PROPERTY_MP)
    if skillNeedMp > userMp then
      print_SkillLog_LackMp(warId, userMp, skillNeedMp)
      _LackManaWhenSkill(warId, userPos, userObj, skillID)
      return
    end
    userMp = userMp - skillNeedMp
    userObj:setProperty(PROPERTY_MP, userMp)
    local skillRound = _computeSkillRound(skillID)
    local _, _, cdRound = _computeSkillEffect_ShouHuCangSheng(skillID)
    local pairs = pairs
    local posList = _getPosListByTeamAndTargetType(team, TARGETTYPE_MYSIDE)
    local index = 1
    for _, effPos in pairs(posList) do
      if effPos ~= userPos then
        local effObj = _getFightRoleObjByPos(warId, effPos)
        if effObj and effObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
          local eHp = effObj:getProperty(PROPERTY_HP)
          local eMp = effObj:getProperty(PROPERTY_MP)
          local objEffectList = {}
          local _checkFlag = _canSkillOnRole_ShouHuCangSheng(effObj)
          if _checkFlag == true then
            local effectData = {}
            effectData.pos = userPos
            _addEffectOnTarget(effObj, EFFECTTYPE_SHOUHUCANGSHENG, skillRound, effectData)
            objEffectList = {EFFECTTYPE_SHOUHUCANGSHENG}
          elseif _checkFlag == -1 then
            objEffectList = {EFFECTTYPE_IMMUNITY}
          elseif _checkFlag == -2 then
            objEffectList = {EFFECTTYPE_INVALID}
          end
          if index == 1 then
            tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, effPos, eHp, eMp, 0, 0, {}, objEffectList, skillID, userMp)
          else
            tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, effPos, eHp, eMp, 0, 0, {}, objEffectList)
          end
          index = index + 1
        end
      end
    end
    _checkBaoFuSkillWhenUseSkill(warId, warRound, userPos, userObj, tInfo)
    _checkHuiYuanSkillWhenUseSkill(warId, userPos, userObj, tInfo)
    _setPetSkillCDRound(userObj, skillID, warRound + cdRound + 1)
    _onNewFormatFightSequence(warId, formatFightSeq)
  elseif skillID == SKILL_YIHUAJIEYU then
    local targetObj = _getFightRoleObjByPos(warId, targetPos)
    if targetObj == nil then
      _formatAndSendWordTipSequence(warId, userObj:getPlayerId(), SUBSEQTYPE_TARGETISDEAD, skillID)
      return
    end
    local canUseRound = _getPetSkillCDRound(userObj, skillID)
    if warRound < canUseRound then
      return
    end
    local userMp = userObj:getProperty(PROPERTY_MP)
    local skillNeedMp = _computeSkillRequireMp(skillID)
    if userMp < skillNeedMp then
      print_SkillLog_LackMp(warId, userMp, skillNeedMp)
      _LackManaWhenSkill(warId, userPos, userObj, skillID)
      return
    end
    _checkCancelStealth(warId, userPos, userObj)
    local checkFlag = _checkWhenUseSkillOfWar(warId, warRound, userPos, skillID)
    if checkFlag == false then
      return
    end
    userMp = userObj:getProperty(PROPERTY_MP)
    if skillNeedMp > userMp then
      print_SkillLog_LackMp(warId, userMp, skillNeedMp)
      _LackManaWhenSkill(warId, userPos, userObj, skillID)
      return
    end
    userMp = userMp - skillNeedMp
    userObj:setProperty(PROPERTY_MP, userMp)
    local cdRound = _computeSkillEffect_YiHuaJieYu(skillID)
    local userEffList = DeepCopyTable(userObj:getEffects())
    local targetEffList = DeepCopyTable(targetObj:getEffects())
    local user_2_target = {}
    local target_2_user = {}
    local user_2_target_TempAttr = {}
    local target_2_user_TempAttr = {}
    local user_2_target_TempKang = {}
    local target_2_user_TempKang = {}
    local userEffList_send = {}
    local targetEffList_send = {}
    _getRoleEffectsForExchange(userObj, userEffList, user_2_target, user_2_target_TempAttr, user_2_target_TempKang)
    _getRoleEffectsForExchange(targetObj, targetEffList, target_2_user, target_2_user_TempAttr, target_2_user_TempKang)
    _clearRoleCurrEffectsForExchange(warId, userPos, userObj, user_2_target, userEffList_send)
    _clearRoleCurrEffectsForExchange(warId, targetPos, targetObj, target_2_user, targetEffList_send)
    _exchangeRoleEffectsForExchage(userPos, userObj, target_2_user, target_2_user_TempAttr, target_2_user_TempKang, userEffList_send)
    _exchangeRoleEffectsForExchage(targetPos, targetObj, user_2_target, user_2_target_TempAttr, user_2_target_TempKang, targetEffList_send)
    local targetHp = targetObj:getProperty(PROPERTY_HP)
    local targetMp = targetObj:getProperty(PROPERTY_MP)
    tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, 0, 0, userEffList_send, targetEffList_send, skillID, userMp)
    _checkBaoFuSkillWhenUseSkill(warId, warRound, userPos, userObj, tInfo)
    _checkHuiYuanSkillWhenUseSkill(warId, userPos, userObj, tInfo)
    _setPetSkillCDRound(userObj, skillID, warRound + cdRound + 1)
    _onNewFormatFightSequence(warId, formatFightSeq)
  end
end
function _getRoleEffectsForExchange(userObj, userEffList, user_2_target, user_2_target_TempAttr, user_2_target_TempKang)
  for eId, eData in pairs(userEffList) do
    local d = EFFECTBUFF_YIHUAJIEYU[eId]
    if d ~= nil then
      user_2_target[eId] = eData
      if type(d) == "table" then
        if d[1] == 1 then
          local tempAttrProName = d[2]
          if type(tempAttrProName) == "table" then
            for _, attrName in pairs(tempAttrProName) do
              local value = _getTargetTempAttrByEffect(userObj, attrName, eId)
              user_2_target_TempAttr[#user_2_target_TempAttr + 1] = {
                eId,
                attrName,
                value
              }
            end
          else
            local value = _getTargetTempAttrByEffect(userObj, tempAttrProName, eId)
            user_2_target_TempAttr[#user_2_target_TempAttr + 1] = {
              eId,
              tempAttrProName,
              value
            }
          end
        elseif d[1] == 2 then
          local tempKangProName = d[2]
          if type(tempKangProName) == "table" then
            for _, kangName in pairs(tempKangProName) do
              local value = _getTargetTempKangProOfEffect(userObj, kangName, eId)
              user_2_target_TempKang[#user_2_target_TempKang + 1] = {
                eId,
                kangName,
                value
              }
            end
          else
            local value = _getTargetTempKangProOfEffect(userObj, tempKangProName, eId)
            user_2_target_TempKang[#user_2_target_TempKang + 1] = {
              eId,
              tempKangProName,
              value
            }
          end
        end
      end
    end
  end
end
function _clearRoleCurrEffectsForExchange(warId, userPos, userObj, user_2_target, userEffList_send)
  for eId, eData in pairs(user_2_target) do
    local eOffId = _getEffectOffID(eId)
    if eOffId ~= nil then
      userEffList_send[#userEffList_send + 1] = eOffId
    end
    _checkDurativeEffectOnRole_Off(warId, userPos, userObj, eId, eOffId, eData)
  end
end
function _exchangeRoleEffectsForExchage(userPos, userObj, target_2_user, target_2_user_TempAttr, target_2_user_TempKang, userEffList_send)
  local userEffectList = userObj:getEffects()
  for eId, eData in pairs(target_2_user) do
    userEffectList[eId] = eData
    userEffList_send[#userEffList_send + 1] = eId
  end
  for _, d in pairs(target_2_user_TempAttr) do
    local eId, attrName, value = unpack(d, 1, 3)
    _setTargetTempAttr(userObj, attrName, value, eId)
  end
  for _, d in pairs(target_2_user_TempKang) do
    local eId, kangName, value = unpack(d, 1, 3)
    _setTargetTempKangPro(userObj, kangName, value, eId)
  end
end
function _getPetSkillRequireMp(userObj, skillID, petLv, petClose, userMaxMp)
  local roleType = userObj:getType()
  local skillNeedMp = _computePetSkillRequireMp(skillID, petLv, petClose, userMaxMp, roleType)
  if _checkRoleIsInState(userObj, EFFECTTYPE_LONGZHANYUYE) then
    local effData = _getRoleEffectData(userObj, EFFECTTYPE_LONGZHANYUYE)
    if effData and effData.coeff then
      skillNeedMp = math.floor(skillNeedMp * (1 + effData.coeff))
    end
  end
  return skillNeedMp
end
function _getPetSkillCDRound(userObj, skillID)
  local cdInfo = userObj:getTempProperty(PROPERTY_PETSKILLCD)
  if type(cdInfo) ~= "table" then
    cdInfo = {}
    userObj:setTempProperty(PROPERTY_PETSKILLCD, cdInfo)
  end
  local cdRound = cdInfo[skillID]
  if cdRound == nil then
    cdRound = 0
  end
  return cdRound
end
function _setPetSkillCDRound(userObj, skillID, round)
  local cdInfo = userObj:getTempProperty(PROPERTY_PETSKILLCD)
  if type(cdInfo) ~= "table" then
    cdInfo = {}
  end
  cdInfo[skillID] = round
  userObj:setTempProperty(PROPERTY_PETSKILLCD, cdInfo)
end
function _checkSkillGGLXMJLL(warId, userPos, userObj, skillID, formatSeq)
  if userObj:getType() == LOGICTYPE_MONSTER then
    return true
  end
  local gg, lx, mj, ll = data_getGGLXMJLL(skillID)
  if gg > 0 then
    local ugg = userObj:getProperty(PROPERTY_GenGu)
    if gg > ugg then
      if formatSeq ~= false then
        _LackGenGuWhenSkill(warId, userPos, userObj, skillID)
      end
      return SIXING_LACK_GENGU
    end
  end
  if lx > 0 then
    local ulx = userObj:getProperty(PROPERTY_Lingxing)
    if lx > ulx then
      if formatSeq ~= false then
        _LackLingXingWhenSkill(warId, userPos, userObj, skillID)
      end
      return SIXING_LACK_LINGXING
    end
  end
  if mj > 0 then
    local umj = userObj:getProperty(PROPERTY_MinJie)
    if mj > umj then
      if formatSeq ~= false then
        _LackMinJieWhenSkill(warId, userPos, userObj, skillID)
      end
      return SIXING_LACK_MINJIE
    end
  end
  if ll > 0 then
    local ull = userObj:getProperty(PROPERTY_LiLiang)
    if ll > ull then
      if formatSeq ~= false then
        _LackLiLiangWhenSkill(warId, userPos, userObj, skillID)
      end
      return SIXING_LACK_LILIANG
    end
  end
  local jin, mu, shui, huo, tu = data_getSkillWuXingRequire(skillID)
  if jin > 0 then
    local ujin = userObj:getProperty(PROPERTY_WXJIN)
    if jin > ujin then
      if formatSeq ~= false then
        _LackWuXingJinWhenSkill(warId, userPos, userObj, skillID)
      end
      return WUXING_LACK_JIN
    end
  end
  if mu > 0 then
    local umu = userObj:getProperty(PROPERTY_WXMU)
    if mu > umu then
      if formatSeq ~= false then
        _LackWuXingMuWhenSkill(warId, userPos, userObj, skillID)
      end
      return WUXING_LACK_MU
    end
  end
  if shui > 0 then
    local ushui = userObj:getProperty(PROPERTY_WXSHUI)
    if shui > ushui then
      if formatSeq ~= false then
        _LackWuXingShuiWhenSkill(warId, userPos, userObj, skillID)
      end
      return WUXING_LACK_SHUI
    end
  end
  if huo > 0 then
    local uhuo = userObj:getProperty(PROPERTY_WXHUO)
    if huo > uhuo then
      if formatSeq ~= false then
        _LackWuXingHuoWhenSkill(warId, userPos, userObj, skillID)
      end
      return WUXING_LACK_HUO
    end
  end
  if tu > 0 then
    local utu = userObj:getProperty(PROPERTY_WXTU)
    if tu > utu then
      if formatSeq ~= false then
        _LackWuXingTuWhenSkill(warId, userPos, userObj, skillID)
      end
      return WUXING_LACK_TU
    end
  end
  return true
end
function _defendOnTarget(warId, userPos, round, callback)
  local userObj = _getFightRoleObjByPos(warId, userPos)
  if userObj == nil then
    printLogDebug("war_skill", "【war log】[warid%d] 找不到进入防御的角色对象 @%d!", warId, userPos)
    _callBack(callback)
    return
  end
  printLogDebug("war_skill", "【war log】[warid%d] @%d 进入防御状态", warId, userPos)
  local userHp = userObj:getProperty(PROPERTY_HP)
  local userMp = userObj:getProperty(PROPERTY_MP)
  if round == nil then
    round = 1
  end
  _addEffectOnTarget(userObj, EFFECTTYPE_ADV_DEFEND, round)
  userObj:setTempProperty(PROPERTY_PWLFYXS, 0.5)
  local formatFightSeq = {}
  formatFightSeq.seqType = SEQTYPE_DEFEND
  formatFightSeq.userPos = userPos
  _onNewFormatFightSequence(warId, formatFightSeq)
  _callBack(callback)
end
function _onCreateNewRoleOnPos(warId, userPos, skillID, newParamList, callback)
  local userObj = _getFightRoleObjByPos(warId, userPos)
  if userObj == nil then
    printLogDebug("war_skill", "【war log】[warid%d] 找不到的召唤角色对象 @%d!", warId, userPos)
    _callBack(callback)
    return
  end
  local skillExp = userObj:getProficiency(skillID)
  local skillNeedMp = _getNormalSkillRequireMp(userObj, skillID, skillExp)
  local userMp = userObj:getProperty(PROPERTY_MP)
  if skillNeedMp > userMp then
    _LackManaWhenSkill(warId, userPos, userObj, skillID)
    print_SkillLog_LackMp(warId, userMp, skillNeedMp)
    printLogDebug("war_skill", "【war log】[warid%d] 魔法值不够(%d,%d)，@%d 无法召唤生物 !!!", warId, userPos, userMp, skillNeedMp)
    _callBack(callback)
    return
  end
  userObj:setProperty(PROPERTY_MP, userMp - skillNeedMp)
  printLogDebug("war_skill", "【war log】[warid%d] @%d 召唤生物", warId, userPos)
  _checkCancelStealth(warId, userPos, userObj)
  local formatFightSeq = {}
  formatFightSeq.seqType = SEQTYPE_CALLUP
  formatFightSeq.userPos = userPos
  formatFightSeq.skillID = skillID
  local param = {}
  for pos, newParam in pairs(newParamList) do
    local p = {}
    param[pos] = p
    p.typeId = newParam.typeId
    p.hp = newParam.hp
    p.maxHp = newParam.maxHp
    p.mp = newParam.mp
    p.maxMp = newParam.maxMp
    p.team = newParam.team
    p.name = newParam.name
    p.objId = newParam.objId
    p.zs = newParam.zs
    p.lv = newParam.lv
    p.playerId = newParam.playerId
    p.hasND = newParam.hasND
    p.op = newParam.op
  end
  formatFightSeq.param = param
  _onNewFormatFightSequence(warId, formatFightSeq)
  _callBack(callback)
end
function _createPetShanXian(warId, pos, newParam)
  local formatFightSeq = {}
  formatFightSeq.seqType = SEQTYPE_SHANXIAN
  formatFightSeq.pos = pos
  formatFightSeq.typeId = newParam.typeId
  formatFightSeq.hp = newParam.hp
  formatFightSeq.maxHp = newParam.maxHp
  formatFightSeq.mp = newParam.mp
  formatFightSeq.maxMp = newParam.maxMp
  formatFightSeq.team = newParam.team
  formatFightSeq.name = newParam.name
  formatFightSeq.objId = newParam.objId
  formatFightSeq.zs = newParam.zs
  formatFightSeq.lv = newParam.lv
  formatFightSeq.playerId = newParam.playerId
  formatFightSeq.hasND = newParam.hasND
  formatFightSeq.op = newParam.op
  _onNewFormatFightSequence(warId, formatFightSeq)
end
function _createAddOneMst(warId, pos, newParam)
  local formatFightSeq = {}
  formatFightSeq.seqType = SEQTYPE_CHUXIAN_NPC
  formatFightSeq.pos = pos
  formatFightSeq.typeId = newParam.typeId
  formatFightSeq.hp = newParam.hp
  formatFightSeq.maxHp = newParam.maxHp
  formatFightSeq.mp = newParam.mp
  formatFightSeq.maxMp = newParam.maxMp
  formatFightSeq.team = newParam.team
  formatFightSeq.name = newParam.name
  formatFightSeq.objId = newParam.objId
  formatFightSeq.zs = newParam.zs
  formatFightSeq.lv = newParam.lv
  formatFightSeq.playerId = newParam.playerId
  formatFightSeq.hasND = newParam.hasND
  formatFightSeq.op = newParam.op
  _onNewFormatFightSequence(warId, formatFightSeq)
end
function _escapeWar(warId, userPos, exPara)
  printLogDebug("war_skill", "【war log】[warid%d]  @%d 逃跑了", warId, userPos)
  local userObj = _getFightRoleObjByPos_WithDeadHero(warId, userPos)
  if userObj == nil then
    return
  end
  _checkCancelStealth(warId, userPos, userObj)
  local formatFightSeq = {}
  formatFightSeq.seqType = SEQTYPE_ESCAPE
  formatFightSeq.userPos = userPos
  if exPara ~= nil and type(exPara) == "table" then
    formatFightSeq.rtype = exPara.rtype
  end
  _onNewFormatFightSequence(warId, formatFightSeq)
end
function _useDrugOnPos(warId, userPos, drugPos, drugID, callback)
  local userObj = _getFightRoleObjByPos(warId, userPos)
  if userObj == nil then
    printLogDebug("war_skill", "【war log】[warid%d] 【defend error】找不到使用药品的角色 @%d!", warId, userPos)
    return
  end
  if _checkSkillIsYiWang(userObj, SKILLTYPE_USEDRUG) then
    _formatAndSendWordTipSequence(warId, userObj:getPlayerId(), SUBSEQTYPE_YIWANGSKILL, SKILLTYPE_USEDRUG, userPos)
    return
  end
  drugPos = _checkSelectTarget(warId, userPos, drugPos, true, nil, nil, true)
  if drugPos == nil then
    return
  end
  local drugObj = _getFightRoleObjByPosOnUseDrug(warId, drugPos)
  if drugObj == nil then
    printLogDebug("war_skill", "【war log】[warid%d] 【defend error】找不到被使用药品的角色对象 @%d!", warId, drugPos)
    _callBack(callback)
    return
  end
  local normalDrugFlag = true
  local drugData = data_Drug[drugID]
  if drugData == nil then
    drugData = data_LifeSkill_Drug[drugID]
    normalDrugFlag = false
  else
    normalDrugFlag = true
  end
  if drugData == nil then
    printLogDebug("war_skill", "【war log】[warid%d] 【defend error】找不到药品信息 @%d!", warId, drugID)
    _callBack(callback)
    return
  end
  printLogDebug("war_skill", "【war log】[warid%d]  @%d 使用药品 %s", warId, drugPos, drugID)
  local addHPValue = 0
  local addMPValue = 0
  local addHPPercent = 0
  local addMPPercent = 0
  if normalDrugFlag then
    addHPValue = drugData.drugAddHPValue
    addMPValue = drugData.drugAddMPValue
    addHPPercent = drugData.drugAddHPPercent
    addMPPercent = drugData.drugAddMPPercent
  else
    addHPValue = drugData.AddHp or 0
    addMPValue = drugData.AddMp or 0
  end
  local userHp = drugObj:getProperty(PROPERTY_HP)
  local userMp = drugObj:getProperty(PROPERTY_MP)
  local userMaxHp = drugObj:getMaxProperty(PROPERTY_HP)
  local userMaxMp = drugObj:getMaxProperty(PROPERTY_MP)
  local stype
  local fuhuoFlag = 0
  if addHPPercent > 0 then
    addHPValue = addHPValue + _checkDamage(userMaxHp * (addHPPercent / 100))
  end
  if addMPPercent > 0 then
    addMPValue = addMPValue + _checkDamage(userMaxMp * (addMPPercent / 100))
  end
  if _checkRoleIsInState(drugObj, EFFECTTYPE_FROZEN) then
    addHPValue = 0
    addMPValue = 0
  elseif _checkRoleIsInState(drugObj, EFFECTTYPE_DUOHUNSUOMING) and addHPValue > 0 then
    addHPValue = 0
    addMPValue = 0
    stype = SUBSEQTYPE_INVALID
  else
    if _checkRoleIsInState(drugObj, EFFECTTYPE_HENGYUNDUANFENG) then
      local effectData = _getRoleEffectData(drugObj, EFFECTTYPE_HENGYUNDUANFENG)
      if effectData ~= nil then
        local coeff = effectData.coeff or 0
        coeff = math.max(1 - coeff, 0)
        if addHPValue > 0 then
          addHPValue = _checkDamage(addHPValue * coeff)
        end
        if addMPValue > 0 then
          addMPValue = _checkDamage(addMPValue * coeff)
        end
      end
    end
    userHp = math.min(userHp + addHPValue, userMaxHp)
    userMp = math.min(userMp + addMPValue, userMaxMp)
    drugObj:setProperty(PROPERTY_HP, userHp)
    drugObj:setProperty(PROPERTY_MP, userMp)
    if drugObj:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD and userHp > 0 then
      fuhuoFlag = 1
      drugObj:setProperty(PROPERTY_DEAD, ROLESTATE_LIVE)
    end
  end
  _checkCancelStealth(warId, userPos, userObj)
  local formatFightSeq = {}
  formatFightSeq.seqType = SEQTYPE_USEDRUG
  formatFightSeq.userPos = userPos
  formatFightSeq.drugPos = drugPos
  formatFightSeq.drugID = drugID
  formatFightSeq.hp = userHp
  formatFightSeq.addhp = addHPValue
  formatFightSeq.mp = userMp
  formatFightSeq.addmp = addMPValue
  formatFightSeq.fuhuo = fuhuoFlag
  formatFightSeq.stype = stype
  _onNewFormatFightSequence(warId, formatFightSeq)
  _callBack(callback)
end
function _formatTipSequence(warId, objPos, tipID, actType)
  local roleObj = _getFightRoleObjByPos(warId, objPos)
  if roleObj == nil then
    printLogDebug("war_skill", "【war log】[warid%d] 【defend error】找不到技能状态提示的角色对象 @%d!", warId, objPos)
    return
  end
  local formatFightSeq = {}
  formatFightSeq.seqType = SEQTYPE_SKILLTIP
  formatFightSeq.objPos = objPos
  formatFightSeq.tipID = tipID
  formatFightSeq.actType = actType
  _onNewFormatFightSequence(warId, formatFightSeq)
end
function _formatLackManaTipSequence(warId, objPos, skillId)
  local roleObj = _getFightRoleObjByPos(warId, objPos)
  if roleObj == nil then
    printLogDebug("war_skill", "【war log】[warid%d] 【defend error】找不到技能状态提示的角色对象 @%d!", warId, objPos)
    return
  end
  _LackManaWhenSkill(warId, objPos, roleObj, skillId)
end
function _catchPet(warId, pos, targetPos)
  if WAR_CODE_IS_SERVER ~= true then
    return
  end
  local role = _getFightRoleObjByPos(warId, pos)
  local playerID = role:getPlayerId()
  local player = WarAIGetOnePlayerData(warId, playerID)
  local petRole = _getFightRoleObjByPos(warId, targetPos)
  if g_WarAiInsList[warId] == nil then
    printLogDebug("war_skill", "【war log】[warid%d] 抓宠没有战斗ai对象", warId)
    return
  end
  if player == nil then
    printLogDebug("war_skill", "【war log】[warid%d] 抓宠没有玩家", warId, pos)
    return
  end
  if role == nil or petRole == nil then
    printLogDebug("war_skill", "【war log】[warid%d] 抓宠没有对象", warId, pos)
    return
  end
  local petTypeId = petRole:getTypeId()
  local petsid = data_getPetIdByShape(data_getRoleShape(petTypeId))
  local petData = data_Pet[petsid] or {}
  local openLv = petData.OPENLV or 0
  local curZs = role:getProperty(PROPERTY_ZHUANSHENG)
  local curLv = role:getProperty(PROPERTY_ROLELEVEL)
  if openLv > curLv and curZs <= 0 then
    printLogDebug("war_skill", "【war log】[warid%d] %d级才能捕捉", warId, openLv)
    return
  end
  local cLv = player:GetCatchLv()
  local lvType = data_getPetLevelType(petsid)
  if data_getPetTypeIsGaoJiShouHu(petsid) and cLv < 0 then
    printLogDebug("war_skill", "【war log】捕捉高级守护时没有学会捉宠生活技能", warId, cLv)
    return
  else
    printLogDebug("war_skill", "【war log】允许捕捉宠物", warId, petTypeId, petsid, cLv, lvType)
  end
  local curZs = role:getProperty(PROPERTY_ZHUANSHENG)
  local maxPetNum = data_getMaxPetNum(curZs) + player:GetPlayerCanAddPetNum()
  if maxPetNum <= g_WarAiInsList[warId]:GetPetNum(playerID) then
    printLogDebug("war_skill", "【war log】[warid%d] 身上召唤兽已满，不能捕捉", warId, pos)
    _LackPetNumWhenSkill(warId, pos, playerID, SKILLTYPE_CATCHPET)
    return
  end
  local event51Flag = g_WarAiInsList[warId]:Get51HuoLiFlag()
  local needHlValue = _getCatchPetNeedHuoLi_Succeed(petsid, event51Flag)
  local curHlValue = player:GetHlValue()
  if needHlValue > curHlValue then
    printLogDebug("war_skill", "【war log】[warid%d] 抓宠活力不足", warId, pos)
    _LackHuoLiWhenSkill(warId, pos, playerID, SKILLTYPE_CATCHPET)
    return
  end
  local cRate, cMp = data_getNpcCatchData(petRole:getTypeId())
  local clvNum = cLv
  if clvNum < 0 then
    clvNum = 0
  end
  local needMp = _checkDamage((cMp + petRole:getProperty(PROPERTY_ROLELEVEL)) * (1 - math.pow(clvNum, 0.7) / 100))
  local mp = role:getProperty(PROPERTY_MP)
  if needMp > mp then
    printLogDebug("war_skill", "【war log】[warid%d] 抓宠法力不足", warId, pos)
    _LackManaWhenSkill(warId, pos, role, SKILLTYPE_CATCHPET)
    return
  end
  local sRate = cRate + (1 - petRole:getProperty(PROPERTY_HP) / petRole:getMaxProperty(PROPERTY_HP)) * 0.2 + clvNum / 100 * 0.4
  printLogDebug("war_skill", "【war log】[warid%d] 抓宠概率为%s", warId, pos, tostring(sRate))
  local isSucceed = false
  if math.random(0, 100) < sRate * 100 then
    isSucceed = true
  end
  role:setProperty(PROPERTY_MP, mp - needMp)
  g_WarAiInsList[warId]:RoleCatchPet(pos, targetPos, isSucceed)
  _checkCancelStealth(warId, pos, role)
  local rhp = role:getProperty(PROPERTY_HP)
  local rmp = role:getProperty(PROPERTY_MP)
  if isSucceed == false then
    printLogDebug("war_skill", "【war log】[warid%d] 抓宠概率失败", warId, pos)
    _formatAndSendCatchPetSeq(warId, pos, targetPos, rhp, rmp, playerID, 0)
  else
    if petRole then
      petRole:setProperty(PROPERTY_DEAD, ROLESTATE_DEAD)
    end
    printLogDebug("war_skill", "【war log】[warid%d] 抓宠概率成功", warId, pos)
    _formatAndSendCatchPetSeq(warId, pos, targetPos, rhp, rmp, playerID, 1)
  end
end
function _checkCDValueOfSkill(warId, warRound, userPos, skillID)
  local userObj = _getFightRoleObjByPos(warId, userPos)
  if userObj == nil then
    return true
  end
  local cdRound = _getPetSkillCDRound(userObj, skillID)
  if warRound >= cdRound then
    return true
  else
    return cdRound - warRound
  end
end
function _checkNeedProsOfSkill(warId, warRound, userPos, skillID)
  local userObj = _getFightRoleObjByPos(warId, userPos)
  if userObj == nil then
    return true
  end
  return _checkSkillGGLXMJLL(warId, userPos, userObj, skillID, false)
end
function _checkXuanRenFlagOfTeam(warId, team)
  local warType = _getTheWarType(warId)
  local isPvpWar = IsPVPWarType(warType)
  if not isPvpWar then
    return nil
  end
  local warAiObj = g_WarAiInsList[warId]
  if warAiObj == nil then
    return nil
  end
  if team == TEAM_ATTACK and warAiObj:WarAiGetAttackFirstUseMagicSkillHpHurt() == -1 then
    return nil
  elseif team == TEAM_DEFEND and warAiObj:WarAiGetDefendFirstUseMagicSkillHpHurt() == -1 then
    return nil
  end
  local allPetPosList = _getPetPosListByTeamAndTargetType(team, TARGETTYPE_MYSIDE)
  local selectInfo
  for _, petPos in pairs(allPetPosList) do
    local petObj = _getFightRoleObjByPos(warId, petPos)
    if petObj and petObj:getType() == LOGICTYPE_PET and petObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
      local damageHp, skillId = petObj:GetPetSkillXuanRen()
      if damageHp > 0 and (selectInfo == nil or damageHp > selectInfo[2]) then
        selectInfo = {
          petPos,
          damageHp,
          skillId
        }
      end
    end
  end
  if selectInfo ~= nil then
    local petPos, damageHp, skillId = selectInfo[1], selectInfo[2], selectInfo[3]
    if team == TEAM_ATTACK then
      warAiObj:WarAiSetAttackFirstUseMagicSkillHpHurt(damageHp)
    else
      warAiObj:WarAiSetDefendFirstUseMagicSkillHpHurt(damageHp)
    end
    return 1
  end
  return nil
end
function _checkYiHuanFlagOfTeam(warId, team)
  local warType = _getTheWarType(warId)
  local isPvpWar = IsPVPWarType(warType)
  if not isPvpWar then
    return nil
  end
  local warAiObj = g_WarAiInsList[warId]
  if warAiObj == nil then
    return nil
  end
  if team == TEAM_ATTACK and warAiObj:WarAiGetAttackFirstUseMagicSkillMpHurt() == -1 then
    return nil
  elseif team == TEAM_DEFEND and warAiObj:WarAiGetDefendFirstUseMagicSkillMpHurt() == -1 then
    return nil
  end
  local allPetPosList = _getPetPosListByTeamAndTargetType(team, TARGETTYPE_MYSIDE)
  local selectInfo
  for _, petPos in pairs(allPetPosList) do
    local petObj = _getFightRoleObjByPos(warId, petPos)
    if petObj and petObj:getType() == LOGICTYPE_PET and petObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
      local damageMp, skillId = petObj:GetPetSkillYiHuan()
      if damageMp > 0 and (selectInfo == nil or damageMp > selectInfo[2]) then
        selectInfo = {
          petPos,
          damageMp,
          skillId
        }
      end
    end
  end
  if selectInfo ~= nil then
    local petPos, damageMp, skillId = selectInfo[1], selectInfo[2], selectInfo[3]
    if team == TEAM_ATTACK then
      warAiObj:WarAiSetAttackFirstUseMagicSkillMpHurt(damageMp)
    else
      warAiObj:WarAiSetDefendFirstUseMagicSkillMpHurt(damageMp)
    end
    return 1
  end
  return nil
end
function _checkHuaWuFlagOfTeam(warId, petObj, team)
  local warAiObj = g_WarAiInsList[warId]
  if warAiObj == nil then
    return
  end
  if petObj:getType() ~= LOGICTYPE_PET then
    return
  end
  local skillId = petObj:GetPetSkillHuaWu()
  if skillId ~= 0 and skillId ~= nil then
    local times = petObj:getTempProperty(PROPERTY_HUAWU)
    if times <= 0 then
      local targetPosList = _getPosListByTeamAndTargetType(team, TARGETTYPE_ENEMYSIDE)
      for _, pos in pairs(targetPosList) do
        local roleObj = _getFightRoleObjByPos_WithDeadHero(warId, pos)
        if roleObj then
          roleObj:setTempProperty(PROPERTY_HUAWUMARK, 1)
        end
      end
    end
  end
end
function _getOnceSkillUseFlag(warId, userPos, skillID)
  local userObj = _getFightRoleObjByPos_WithDeadHero(warId, userPos)
  if userObj == nil then
    return false
  end
  if skillID == PETSKILL_JUEJINGFENGSHENG then
    local useTimes = userObj:getTempProperty(PROPERTY_JUEJINGFENGSHENG)
    return useTimes >= 1
  elseif skillID == PETSKILL_CHUNHUIDADI then
    local useTimes = userObj:getTempProperty(PROPERTY_CHUNHUIDADI)
    return useTimes >= 1
  elseif skillID == MARYYSKILL_QINGSHENSIHAI then
    local useTimes = userObj:getTempProperty(PROPERTY_QINGSHENSIHAI)
    return useTimes >= 1
  elseif skillID == PETSKILL_TIESHUKAIHUA then
    local useTimes = userObj:getTempProperty(PROPERTY_TIESHUKAIHUA)
    return useTimes >= 1
  elseif skillID == PETSKILL_HUICHUNMIAOSHOU then
    local useTimes = userObj:getTempProperty(PROPERTY_HUICHUNMIAOSHOU)
    return useTimes >= 1
  else
    return false
  end
end
function _getSkillUseOfMinRoundFlag(skillID)
  if skillID == PETSKILL_JUEJINGFENGSHENG then
    local _, _, startRound = _computePetSkill_JueJingFengSheng()
    return startRound
  elseif skillID == PETSKILL_CHUNHUIDADI then
    local startRound = _computePetSkill_ChunHuiDaDi()
    return startRound
  elseif skillID == PETSKILL_TIESHUKAIHUA then
    local _, _, _, startRound = _computePetSkill_TieShuKaiHua()
    return startRound
  elseif skillID == PETSKILL_HUICHUNMIAOSHOU then
    local _, startRound = _computePetSkill_HuiChunMiaoShou()
    return startRound
  else
    return 0
  end
end
function _getShowEnemyHpMpPosList(warId, warType)
  local isPvpWar = IsPVPWarType(warType)
  if not isPvpWar then
    return nil
  end
  local attTeamShow, defTeamShow
  local allPetPosList = _getAllPetPosList()
  for _, petPos in pairs(allPetPosList) do
    local petObj = _getFightRoleObjByPos(warId, petPos)
    if petObj and petObj:getType() == LOGICTYPE_PET and petObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and petObj:GetPetSkillMingChaQiuHao() then
      local masterPos = _getMasterPosByPetPos(petPos)
      local masterObj = _getFightRoleObjByPos_WithDeadHero(warId, masterPos)
      if masterObj then
        local team = masterObj:getProperty(PROPERTY_TEAM)
        if team == TEAM_ATTACK then
          attTeamShow = 1
        elseif team == TEAM_DEFEND then
          defTeamShow = 1
        end
      end
    end
  end
  return attTeamShow, defTeamShow
end
function _getPetStolenSkillList(warId, warRound, userPos, warType)
  local isPvpWar = IsPVPWarType(warType)
  if not isPvpWar then
    return {}
  end
  local userObj = _getFightRoleObjByPos_WithDeadHero(warId, userPos)
  if userObj == nil then
    return {}
  end
  return userObj:getAllThieveInitiativeSkills()
end
function _checkSkillCanUseOnPVE(warId, skillID)
  if skillID == PETSKILL_ZHAOYUNMUYU then
    return false
  elseif skillID == PETSKILL_XIANFENGDAOGU then
    return false
  elseif skillID == PETSKILL_MIAOSHOURENXIN then
    return false
  elseif skillID == PETSKILL_YIHUAN then
    return false
  elseif skillID == PETSKILL_XUANREN then
    return false
  elseif skillID == PETSKILL_RENLAIFENG then
    return false
  elseif skillID == PETSKILL_TAOMING then
    return false
  elseif skillID == PETSKILL_BUBUSHENGLIAN then
    return false
  elseif skillID == PETSKILL_HUAWU then
    return false
  elseif skillID == PETSKILL_MINGCHAQIUHAO then
    return false
  elseif skillID == PETSKILL_SHUANGGUANQIXIA then
    return false
  elseif skillID == PETSKILL_QIANGHUAYIHUAN then
    return false
  elseif skillID == PETSKILL_QIANGHUAXUANREN then
    return false
  elseif skillID == PETSKILL_FENGMO then
    return false
  elseif skillID == PETSKILL_SHUNSHOUQIANYANG then
    return false
  end
  return true
end
function _checkSkillCanUseBeforeRound(warId, warRound, userPos, skillID)
  return warRound >= _getSkillUseOfMinRoundFlag(skillID)
end
function _useMarrySkillOnTarget(warId, warRound, userPos, targetPos, skillID, callback)
  local userObj = _getFightRoleObjByPos(warId, userPos)
  if userObj == nil then
    print_SkillLog_RoleIsNotExist(warId, userPos)
    return
  end
  printLogDebug("war_skill", "【war log】[warid%d] @%d 准备对目标 @%d 使用结婚技能(%s)", warId, userPos, targetPos, skillID)
  local userHp = userObj:getProperty(PROPERTY_HP)
  local userMp = userObj:getProperty(PROPERTY_MP)
  local skillExp = userObj:getProficiency(skillID)
  local userLv = userObj:getProperty(PROPERTY_ROLELEVEL)
  local team = userObj:getProperty(PROPERTY_TEAM)
  local targetObj = _getFightRoleObjByPos_WithDeadHero(warId, targetPos)
  if targetObj == nil then
    return
  end
  if skillID == MARRYSKILL_QINMIWUJIAN or skillID == MARRYSKILL_TONGCHOUDIKAI then
    local canUseRound = _getPetSkillCDRound(userObj, skillID)
    if warRound < canUseRound then
      return
    end
  elseif skillID == MARYYSKILL_QINGSHENSIHAI then
    local useTimes = userObj:getTempProperty(PROPERTY_QINGSHENSIHAI)
    if useTimes >= 1 then
      return
    end
  end
  local deadOkFlag = false
  if skillID == MARRYSKILL_QINMIWUJIAN then
    deadOkFlag = true
  end
  if targetObj:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD and not deadOkFlag then
    _formatAndSendWordTipSequence(warId, userObj:getPlayerId(), SUBSEQTYPE_TARGETISDEAD, skillID)
    return
  end
  local skillNeedMp = _computeMarrySkillRequireMp(skillID, skillExp)
  if userMp < skillNeedMp then
    _LackManaWhenSkill(warId, userPos, userObj, skillID)
    print_SkillLog_LackMp(warId, userMp, skillNeedMp)
    _callBack(callback)
    return
  end
  _checkCancelStealth(warId, userPos, userObj)
  local checkFlag = _checkWhenUseSkillOfWar(warId, warRound, userPos, skillID)
  if checkFlag == false then
    return
  end
  userHp = userObj:getProperty(PROPERTY_HP)
  userMp = userObj:getProperty(PROPERTY_MP)
  if skillNeedMp > userMp then
    _LackManaWhenSkill(warId, userPos, userObj, skillID)
    print_SkillLog_LackMp(warId, userMp, skillNeedMp)
    _callBack(callback)
    return
  end
  userMp = userMp - skillNeedMp
  userObj:setProperty(PROPERTY_MP, userMp)
  local formatFightSeq = {
    seqType = SEQTYPE_USESKILL,
    userPos = userPos,
    targetInfo = {}
  }
  local tInfo = formatFightSeq.targetInfo
  if skillID == MARRYSKILL_QINMIWUJIAN then
    local targetHp = targetObj:getProperty(PROPERTY_HP)
    local targetMp = targetObj:getProperty(PROPERTY_MP)
    local targetMaxHp = targetObj:getMaxProperty(PROPERTY_HP)
    local targetMaxMp = targetObj:getMaxProperty(PROPERTY_MP)
    local addHp, addMp, cdRound = _computeMarrySkill_QinMiWuJian(userLv, skillExp)
    local fuhuo
    local effList = {}
    local attEffList
    if _checkRoleIsInState(targetObj, EFFECTTYPE_DUOHUNSUOMING) then
      addHp = 0
      addMp = 0
      effList = {EFFECTTYPE_INVALID}
      attEffList = {EFFECTTYPE_ADDHPFAILED_DHSM}
    elseif _checkRoleIsInState(targetObj, EFFECTTYPE_FROZEN) then
      addHp = 0
      addMp = 0
      effList = {EFFECTTYPE_IMMUNITY}
    else
      targetHp = math.min(targetHp + addHp, targetMaxHp)
      targetMp = math.min(targetMp + addMp, targetMaxMp)
      targetObj:setProperty(PROPERTY_HP, targetHp)
      targetObj:setProperty(PROPERTY_MP, targetMp)
      if targetObj:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD then
        targetObj:setProperty(PROPERTY_DEAD, ROLESTATE_LIVE)
        fuhuo = 1
      end
    end
    tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillAddHpMp(userPos, targetPos, targetHp, targetMp, addHp, addMp, nil, nil, fuhuo, effList, skillID, userMp, attEffList)
    _setPetSkillCDRound(userObj, skillID, warRound + cdRound + 1)
  elseif skillID == MARRYSKILL_TONGCHOUDIKAI then
    local targetHp = targetObj:getProperty(PROPERTY_HP)
    local targetMp = targetObj:getProperty(PROPERTY_MP)
    local objEffectList = {}
    local pro, skillRound, cdRound = _computeMarrySkill_TongChouDiKai(userLv, skillExp)
    printLogDebug("skill_ai", "使用结婚技能【同仇敌忾】的成功率", userPos, targetPos, pro, userLv, skillExp)
    if _canSkillOnRole_TongChouDiKai(targetObj) then
      if _canAffectOnPro(pro) then
        _addEffectOnTarget(targetObj, EFFECTTYPE_TONGCHOUDIKAI, skillRound)
        objEffectList = {EFFECTTYPE_TONGCHOUDIKAI}
      else
        objEffectList = {EFFECTTYPE_INVALID}
      end
    else
      objEffectList = {EFFECTTYPE_IMMUNITY}
    end
    tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, 0, 0, {}, objEffectList, skillID, userMp)
    _setPetSkillCDRound(userObj, skillID, warRound + cdRound + 1)
  elseif skillID == MARYYSKILL_QINGSHENSIHAI then
    local pro = _computeMarrySkill_QingShenSiHai(userLv, skillExp)
    printLogDebug("skill_ai", "使用结婚技能【情深似海】的成功率", userPos, targetPos, pro, userLv, skillExp)
    if _canAffectOnPro(pro) then
      local effectList = targetObj:getEffects()
      local rmvEffList = {}
      for effectID, _ in pairs(effectList) do
        if EFFECTBUFF_QINGSHENSIHAI_CLEAR[effectID] ~= nil then
          rmvEffList[#rmvEffList + 1] = effectID
        end
      end
      local objEffectList = {}
      local maxHpMpChanged = false
      if #rmvEffList > 0 then
        for _, rmvEffID in pairs(rmvEffList) do
          local effectInfo = effectList[rmvEffID]
          local effectData = effectInfo[3]
          local effectOffID = _getEffectOffID(rmvEffID)
          objEffectList[#objEffectList + 1] = effectOffID
          maxHpMpChanged = _checkDurativeEffectOnRole_Off(warId, targetPos, targetObj, rmvEffID, effectOffID, effectData, false) or maxHpMpChanged
          effectList[rmvEffID] = nil
        end
        targetObj:setEffects(effectList)
      end
      local targetHp = targetObj:getProperty(PROPERTY_HP)
      local targetMp = targetObj:getProperty(PROPERTY_MP)
      tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, 0, 0, {}, objEffectList, skillID, userMp)
      if maxHpMpChanged == true then
        local objMaxHp = targetObj:getMaxProperty(PROPERTY_HP)
        local objMaxMp = targetObj:getMaxProperty(PROPERTY_MP)
        tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget_PetSkillHpMpBase(userPos, targetPos, targetHp, targetMp, objMaxHp, objMaxMp)
      end
    else
      local targetHp = targetObj:getProperty(PROPERTY_HP)
      local targetMp = targetObj:getProperty(PROPERTY_MP)
      local objEffectList = {EFFECTTYPE_INVALID}
      tInfo[#tInfo + 1] = _formatSubNormalSeqOfTarget(userPos, targetPos, targetHp, targetMp, 0, 0, {}, objEffectList, skillID, userMp)
    end
    local useTimes = userObj:getTempProperty(PROPERTY_QINGSHENSIHAI)
    userObj:setTempProperty(PROPERTY_QINGSHENSIHAI, useTimes + 1)
  end
  _checkBaoFuSkillWhenUseSkill(warId, warRound, userPos, userObj, tInfo)
  _checkHuiYuanSkillWhenUseSkill(warId, userPos, userObj, tInfo)
  _onNewFormatFightSequence(warId, formatFightSeq)
end
function _checkSkillIsYiWang(roleObj, skillId)
  if roleObj == nil then
    return false
  end
  local ywList = roleObj:getTempProperty(PROPERTY_YIWANGSKILL)
  if ywList == nil or ywList == 0 then
    return false
  elseif type(ywList) == "table" then
    for _, sId in pairs(ywList) do
      if sId == skillId then
        return true
      end
    end
  end
  return false
end
