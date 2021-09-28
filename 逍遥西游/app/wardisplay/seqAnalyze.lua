DRUG_ANIID_HP = 86
DRUG_ANIID_MP = 87
DRUG_ANIID_HPMP = 88
CATCHPET_ANIID = 2000
function JudgeSkillIsMagicAttack(skillID)
  if skillID == nil or skillID == SKILLTYPE_NORMALATTACK then
    return false
  else
    return true
  end
end
function JudgeSkillIsActive(skillID)
  return _getSkillStyle(skillID) == SKILLSTYLE_INITIATIVE
end
local DefineMoveSpeed = 1800
local seqAnalyze = {}
function seqAnalyze.extend(object)
  function object:analyzeWarBeginSeqList()
    if object.m_WarBeginSeq == nil then
      return
    end
    object.m_ChasingFlag_Seq = object.m_ChasingFlag
    for _, warSeq in ipairs(object.m_WarBeginSeq) do
      local seqType = warSeq.seqType
      if seqType == SEQTYPE_USERWORDTIP then
        object:fightAction_UserWordTip(warSeq, true)
      elseif seqType == SEQTYPE_ADDPOSANI then
        object:fightAction_AddPosAni(warSeq, true)
      end
    end
  end
  function object:analyzeRoundWarSeqList(round, warSeqList, warTime)
    object.m_WarSeqTotalList[round] = {seq = warSeqList, warTime = warTime}
    if object.m_ChasingFlag == true then
      if round == object.m_ChasingRound then
        object:startChasing()
      end
    else
      object:readyNextRound()
    end
  end
  function object:readyNextRound()
    if not object.m_LastRoundAnalyzeFinish or object.m_PauseAnalyze then
      print("--->>>>上一回合解析还未结束或者被暂停", object.m_LastRoundAnalyzeFinish, object.m_PauseAnalyze)
      return
    end
    print("开始播放动作")
    object:StartRunAction()
    local netInfo = object.m_WarSeqTotalList[object.m_CurrRound + 1]
    if netInfo == nil then
      if object.m_IsReview then
      else
        object.m_CurrRound = object.m_CurrRound + 1
        object:onWarAnalyzeFinish()
      end
    else
      object.m_CurrRound = object.m_CurrRound + 1
      local nextSeqList = netInfo.seq
      local warTime = netInfo.warTime
      object:analyzeNextRound(nextSeqList, warTime)
    end
  end
  function object:analyzeNextRound(warSeqList, warTime)
    object.m_CurrSeqList = warSeqList
    object.m_CurrSeqIndex = 0
    object.m_LastRoundAnalyzeFinish = false
    object.m_HasDurativeEffect = nil
    object.m_HasInstantHpMpEffect = nil
    object.m_CurrRoundTeXingTalk = {}
    object:setRound(object.m_CurrRound)
    local dt = object:checkRoundMonsterTalk() or 0
    if object.m_ChasingFlag then
      local curTime = g_DataMgr:getServerTime()
      object.m_ChasingTime = math.max(curTime - warTime - dt - 0.5, 0)
    end
    if dt > 0 then
      local act1 = CCDelayTime:create(dt)
      local act2 = CCCallFunc:create(function()
        object:readyNextSeq()
      end)
      object:runAction(transition.sequence({act1, act2}))
    else
      object:readyNextSeq()
    end
  end
  function object:checkRoundMonsterTalk()
    local talkDelay = 0
    for _, roleObj in pairs(object.m_WarRoleObj) do
      if not roleObj:isDead() then
        talkDelay = talkDelay + roleObj:checkRoundTalk(object.m_CurrRound, talkDelay)
      end
    end
    return talkDelay
  end
  function object:onRoundAnalyzeFinish()
    object.m_LastRoundAnalyzeFinish = true
    object.m_CurrSeqIndex = 0
    object.m_CurrSeqList = {}
    if object.m_IsReview then
      if object.m_WarSeqTotalList[object.m_CurrRound + 1] == nil then
        if object.m_WarResult ~= WARRESULT_NONE then
          print("录像播放完了")
          object:onWarAnalyzeFinish()
        else
          netsend.netpvp.watchBWCHistoryRoundData(object:getWarID(), object.m_CurrRound + 1)
          print("录像还没有播放完1")
          object:readyNextRound()
        end
      else
        print("录像还没有播放完2")
        object:readyNextRound()
      end
    elseif object.m_IsRunAway == true and object:getSingleWarFlag() ~= true then
      print("逃跑直接弹失败框")
      object:SendOneRoundAnalyzeFinishToAI(object:getWarID(), object:getSingleWarFlag(), object.m_CurrRound)
      ShowWarResult_Lose(object:getWarID(), object:getWarType(), nil)
      ShowAddBSDAfterWar(object:getWarType())
    elseif object.m_WarSeqTotalList[object.m_CurrRound + 1] ~= nil then
      print("---->>>回合解析结束，但是下回合数据已经到了", object.m_ChasingFlag, object.m_IsWatching)
      if object.m_ChasingFlag == true then
        print("战斗恢复，则继续往下追赶")
        object:chaseWarUiTime()
      elseif object.m_IsWatching then
        print("是观战，则继续往下播放")
        object:readyNextRound()
      else
        print("是正常战斗，则立即开启追赶进度")
        object:revertLocalWar()
      end
    elseif object.m_WarResult ~= WARRESULT_NONE then
      object:SendOneRoundAnalyzeFinishToAI(object:getWarID(), object:getSingleWarFlag(), object.m_CurrRound)
      object:onWarAnalyzeFinish()
    elseif object.m_ChasingFlag == true then
      object:chaseWarUiTime()
    else
      object:SendOneRoundAnalyzeFinishToAI(object:getWarID(), object:getSingleWarFlag(), object.m_CurrRound)
    end
  end
  function object:readyNextSeq()
    if object.m_PauseAnalyze then
      return
    end
    object.m_CurrSeqIndex = object.m_CurrSeqIndex + 1
    local nextSeq = object.m_CurrSeqList[object.m_CurrSeqIndex]
    if object.m_IsRunAway == true and object:getSingleWarFlag() ~= true then
      object:onRoundAnalyzeFinish()
    elseif nextSeq == nil then
      object:onRoundAnalyzeFinish()
    else
      object:analyzeNextSeq(nextSeq)
    end
  end
  function object:analyzeNextSeq(warSeq)
    object.m_ChasingFlag_Seq = object.m_ChasingFlag
    local seqType = warSeq.seqType
    if seqType == SEQTYPE_NORMALATTACK then
      object:fightAction_NormalAttack(warSeq)
    elseif seqType == SEQTYPE_USESKILL then
      object:fightAction_UseSkill(warSeq, SEQTYPE_USESKILL)
    elseif seqType == SEQTYPE_USENEIDANSKILL then
      object:fightAction_UseNeiDanSkill(warSeq)
    elseif seqType == SEQTYPE_PETSKILL then
      object:fightAction_UsePetSkill(warSeq)
    elseif seqType == SEQTYPE_EFFECT_OFF then
      object:fightAction_EffectOff(warSeq)
    elseif seqType == SEQTYPE_DURATIVE_EFFECT then
      object:fightAction_DurativeEffect(warSeq)
    elseif seqType == SEQTYPE_CALLUP then
      object:fightAction_CallUp(warSeq)
    elseif seqType == SEQTYPE_ESCAPE then
      object:fightAction_Escape(warSeq)
    elseif seqType == SEQTYPE_FRESHFINISHBEFOREROUND then
      object:fightAction_FreshFinishBeforeRound()
    elseif seqType == SEQTYPE_USEDRUG then
      object:fightAction_UseDrug(warSeq)
    elseif seqType == SEQTYPE_INSTANT_HPMP then
      object:fightAction_InstantHpMp(warSeq)
    elseif seqType == SEQTYPE_SKILLTIP then
      object:fightAction_SkillTip(warSeq)
    elseif seqType == SEQTYPE_DEFEND then
      object:fightAction_Defend(warSeq)
    elseif seqType == SEQTYPE_BASEHPMP then
      object:fightAction_BaseHpAndMp(warSeq)
    elseif seqType == SEQTYPE_PROTECT then
      object:fightAction_Protect(warSeq)
    elseif seqType == SEQTYPE_BACKTOPOS then
      object:fightAction_BackToRolePos(warSeq)
    elseif seqType == SEQTYPE_USERWORDTIP then
      object:fightAction_UserWordTip(warSeq)
    elseif seqType == SEQTYPE_ADDBUFF then
      object:fightAction_AddBuff(warSeq)
    elseif seqType == SEQTYPE_RELIVE then
      object:fightAction_Relive(warSeq)
    elseif seqType == SEQTYPE_LEAVEBATTLE then
      object:fightAction_LeaveBattle(warSeq)
    elseif seqType == SEQTYPE_CATCHPET then
      object:fightAction_CatchPet(warSeq)
    elseif seqType == SEQTYPE_ADDSCENEANI then
      object:fightAction_AddSceneAni(warSeq)
    elseif seqType == SEQTYPE_DELSCENEANI then
      object:fightAction_DelSceneAni(warSeq)
    elseif seqType == SEQTYPE_ADDPOSANI then
      object:fightAction_AddPosAni(warSeq)
    elseif seqType == SEQTYPE_SHOWENEMYHPMP then
      object:fightAction_ShowEnemyHpMp(warSeq)
    elseif seqType == SEQTYPE_MONSTER_TX then
      object:fightAction_MonsterTeXing(warSeq)
    elseif seqType == SEQTYPE_STEALTH_BEFOREROUND then
      object:fightAction_SteathBeforeRound(warSeq)
    elseif seqType == SEQTYPE_TAKEAWARY then
      object:fightAction_TakeAway(warSeq)
    elseif seqType == SEQTYPE_SHANXIAN then
      object:fightAction_ShanXian(warSeq)
    elseif seqType == SEQTYPE_CHUXIAN_NPC then
      object:fightAction_ChuXian_NPC(warSeq)
    elseif seqType == SEQTYPE_MAKEOTEHRRELIVE then
      object:fightAction_MakeOtherRelive(warSeq)
    end
  end
  function object:onSeqAnalyzeFinish(dt)
    if dt == nil then
      dt = 0.15
    end
    if object.m_ChasingFlag == true then
      if dt <= object.m_ChasingTime or object.m_Chasing_Force == true then
        object.m_ChasingTime = object.m_ChasingTime - dt
        object:readyNextSeq()
        return
      else
        object:endChasing()
      end
    end
    if dt > 0 then
      local act1 = CCDelayTime:create(dt)
      local act2 = CCCallFunc:create(function()
        object:readyNextSeq()
      end)
      object:runAction(transition.sequence({act1, act2}))
    else
      object:readyNextSeq()
    end
  end
  function object:onWarAnalyzeFinish()
    print("--->>> onWarAnalyzeFinish !")
    if object.m_PauseAnalyze then
      return
    end
    object.m_WarAnalyzeFinish = true
    object:readyToShowWarResult()
  end
  function object:pauseWarAnalyze()
    object.m_PauseAnalyze = true
    object:stopAllActions()
  end
  function object:fightAction_NormalAttack(warSeq)
    object:fightAction_UseSkill(warSeq, SEQTYPE_NORMALATTACK)
  end
  function object:fightAction_UseSkill(warSeq, seqType)
    local userPos = warSeq.userPos
    local targetInfo = warSeq.targetInfo
    local userViewObj = object:getViewObjByPos(userPos)
    if userViewObj == nil then
      print("【warplay error】攻击者 @%d 不存在，无法进行技能或者普通攻击 !", userPos)
      object:onSeqAnalyzeFinish()
      return
    end
    local talkDelay = 0
    if warSeq.txId ~= nil then
      talkDelay = userViewObj:checkFightTalk_TX(warSeq.txId)
    end
    if talkDelay <= 0 then
      talkDelay = userViewObj:checkFightTalk(seqType, object.m_CurrRound)
    end
    if object.m_ChasingFlag_Seq == true and object.m_ChasingTime < 1.5 and object.m_Chasing_Force ~= true then
      object:endChasing()
    end
    object:preloadSkillAni(targetInfo)
    object:analyzeSkillSeq(userPos, targetInfo, talkDelay, true)
  end
  function object:analyzeSkillSeq(userPos, targetInfo, talkDelay, isFirst)
    if #targetInfo > 0 then
      object:onSubSkillSeqStart(userPos, targetInfo, talkDelay, isFirst)
    else
      do
        local delay
        if object:hideSkillBackground() then
          delay = 0.5
        end
        if not object:checkRoleIsInOriPos(userPos) then
          do
            local userViewObj = object:getViewObjByPos(userPos)
            if userViewObj and not userViewObj:isDead() then
              local currxy = object:getRoleXYByPos(userPos)
              local orixy = object:getXYByPos(userPos)
              local dt = object:getRoleMoveTime(currxy, orixy)
              local dt_0 = 0.1
              if object.m_ChasingFlag_Seq ~= true then
                local act0 = CCDelayTime:create(dt_0)
                local act1 = CCMoveTo:create(dt, orixy)
                local act2 = CCCallFunc:create(function()
                  userViewObj:recoverDirToNormalStand()
                  object:onSkillSeqFinish(delay)
                end)
                userViewObj:runAction(transition.sequence({
                  act0,
                  act1,
                  act2
                }))
              else
                object.m_ChasingTime = object.m_ChasingTime - (dt + dt_0)
                userViewObj:setPosition(orixy)
                userViewObj:recoverDirToNormalStand()
                object:onSkillSeqFinish(delay)
              end
            else
              object:onSkillSeqFinish(delay)
            end
          end
        else
          object:onSkillSeqFinish(delay)
        end
      end
    end
  end
  function object:shoutUsingSkill(dt, pos, skillID)
    if skillID == nil or skillID == SKILLTYPE_NORMALATTACK then
      return 0
    else
      return object:shoutUsingSkillNameAni(dt, pos, skillID)
    end
  end
  function object:checkRoleIsInOriPos(checkPos)
    local currxy = object:getRoleXYByPos(checkPos)
    local orixy = object:getXYByPos(checkPos)
    if math.abs(currxy.x - orixy.x) < 1 and 1 > math.abs(currxy.y - orixy.y) then
      return true
    else
      return false
    end
  end
  function object:checkExistEffect(effectIDList, effectID)
    if effectIDList == nil then
      return
    end
    for _, eId in pairs(effectIDList) do
      if eId == effectID then
        return true
      end
    end
    return false
  end
  function object:displayRoleEffectAniAtPos(rolePos, effectIDList, dt)
    if effectIDList == nil then
      return 0
    end
    local roleObj = object:getViewObjByPos(rolePos)
    if roleObj == nil then
      return 0
    end
    local effTime = 0
    for _, effectID in pairs(effectIDList) do
      if type(effectID) == "table" then
        local et = object:fightAction_ExtraEffect(effectID, dt) or 0
        if effTime < et then
          effTime = et
        end
      else
        local et = roleObj:setEffectForObj(effectID, dt) or 0
        if effTime < et then
          effTime = et
        end
      end
    end
    return effTime
  end
  function object:getRoleDirection(pos)
    local roleObj = object:getViewObjByPos(pos)
    if roleObj then
      return roleObj:getDirection()
    else
      return nil
    end
  end
  function object:getIsSameSideOfLocalPlayer(pos)
    if object.m_IsWatching then
      return true
    end
    local localPlayerPos = object:getMainHeroPos()
    local sameSide = localPlayerPos < DefineDefendPosNumberBase and pos < DefineDefendPosNumberBase or localPlayerPos > DefineDefendPosNumberBase and pos > DefineDefendPosNumberBase
    return sameSide
  end
  function object:onSubSkillSeqStart(userPos, targetInfo, talkDelay, isFirst)
    if #targetInfo > 0 then
      do
        local info = targetInfo[1]
        local attackerPos = info.attPos
        local attackerViewObj = object:getViewObjByPos(attackerPos)
        if attackerViewObj == nil then
          print(string.format("【warplay error】攻击者(@%d)不存在", attackerPos))
          object:onSkillSeqFinish()
          return
        end
        local mainSkillID, mainTarget
        local damageInfoList = {}
        local fenshenViewObj = {}
        local seqSplit = false
        local isCounterAttack = false
        local isDoubleHit = false
        local isDoubleHitCome = false
        local mainTargetMiss = false
        local attND_start, defND_start, attND_start_pos, defND_start_pos
        local stateInfo = {
          attackAniOver = false,
          skillAniOver = false,
          attackerPos = attackerPos
        }
        while true do
          if #targetInfo <= 0 then
            break
          end
          tInfo = targetInfo[1]
          local attPos = tInfo.attPos
          local attEffectList = tInfo.attEffectList
          if _getEffectIsExisted(EFFECTTYPE_COUNTERATTACK, attEffectList) then
            if attPos ~= attackerPos then
              break
            elseif seqSplit then
              break
            else
              seqSplit = true
            end
          end
          local tempSplit = _getEffectIsExisted(EFFECTTYPE_DOUBLEHIT_COME, attEffectList) or _getEffectIsExisted(EFFECTTYPE_DOUBLEHIT, attEffectList)
          if tempSplit then
            if seqSplit then
              isDoubleHit = true
              break
            else
              seqSplit = true
            end
          end
          table.remove(targetInfo, 1)
          local tPos = tInfo.objPos
          local skillID = tInfo.skillID
          if mainTarget == nil then
            mainTarget = tPos
            mainSkillID = skillID
            tInfo.skillID = nil
            mainTargetMiss = _getEffectIsExisted(EFFECTTYPE_MISS, tInfo.objEffectList)
            attND_start = tInfo.attND
            defND_start = tInfo.defND
            attND_start_pos = attPos
            defND_start_pos = tPos
            local attMp = tInfo.attMp
            if attMp ~= nil then
              attackerViewObj:setMp(attMp)
            end
            local attHp = tInfo.attHp
            if attHp ~= nil then
              attackerViewObj:setHp(attHp)
            end
          elseif object.m_ChasingFlag_Seq ~= true then
            local eList = tInfo.attEffectList
            if eList ~= nil and object:checkExistEffect(eList, EFFECTTYPE_FENSHEN) then
              local fsTarDir = object:getRoleDirection(mainTarget)
              local fsViewObj = CRoleFenShenView.new(attackerViewObj, fsTarDir)
              object.m_RoleNode:addChild(fsViewObj)
              fsViewObj:setVisible(false)
              fenshenViewObj[#fenshenViewObj + 1] = {fsViewObj, tPos}
            end
          end
          if _getEffectIsExisted(EFFECTTYPE_COUNTERATTACK, attEffectList) then
            isCounterAttack = true
          end
          if _getEffectIsExisted(EFFECTTYPE_DOUBLEHIT_COME, attEffectList) then
            isDoubleHitCome = true
          end
          damageInfoList[#damageInfoList + 1] = tInfo
        end
        stateInfo.mainSkillID = mainSkillID
        stateInfo.isCounterAttack = isCounterAttack
        local attActList = {}
        local needSpeedUp = not isCounterAttack and isDoubleHit
        local skillTime, damageTime, hasObjAni = data_getSkillAniKeepTime(mainSkillID)
        local t_attack = 0
        local t_skill = 0
        if not JudgeSkillIsMagicAttack(mainSkillID) or isFirst == true then
          attActList[#attActList + 1] = CCCallFunc:create(function()
            if mainSkillID ~= nil then
              object:displaySkillDaZhaoAniAtPos(mainSkillID, mainTarget)
            end
            if needSpeedUp then
              t_attack = t_attack + 0.5
            else
              t_attack = t_attack + 0.8
            end
            attackerViewObj:setAttack(mainSkillID, nil, mainTargetMiss)
            object:displayAttackAniAtObjPos(mainSkillID, attackerViewObj, mainTarget)
            for _, fsData in pairs(fenshenViewObj) do
              local fsViewObj = fsData[1]
              local fsAttPos = fsData[2]
              local fsXY = object:getAttackXYByDirection(fsAttPos, attackerViewObj:getShapeId())
              fsViewObj:setPosition(fsXY)
              fsViewObj:getParent():reorderChild(fsViewObj, -fsXY.y)
              fsViewObj:setVisible(true)
              fsViewObj:setAttack(mainSkillID)
              object:displayAttackAniAtObjPos(mainSkillID, fsViewObj, fsAttPos)
            end
            local a1 = CCDelayTime:create(t_attack)
            local a2 = CCCallFunc:create(function()
              stateInfo.attackAniOver = true
              object:onAttackOrSkillAniOver(userPos, targetInfo, attackerViewObj, stateInfo)
            end)
            object:runAction(transition.sequence({a1, a2}))
            object:displayRoleNeiDanAniAtPosWhenStart(attND_start_pos, attND_start)
            object:displayRoleNeiDanAniAtPosWhenStart(defND_start_pos, defND_start)
          end)
        else
          needSpeedUp = true
          attActList[#attActList + 1] = CCCallFunc:create(function()
            stateInfo.attackAniOver = true
            object:displayRoleNeiDanAniAtPosWhenStart(attND_start_pos, attND_start)
            object:displayRoleNeiDanAniAtPosWhenStart(defND_start_pos, defND_start)
          end)
        end
        if JudgeSkillIsMagicAttack(mainSkillID) and hasObjAni then
          local objAniDelay = 0.7
          if isFirst ~= true then
            objAniDelay = 0.1
          end
          attActList[#attActList + 1] = CCDelayTime:create(objAniDelay)
          t_skill = t_skill + objAniDelay
          attActList[#attActList + 1] = CCCallFunc:create(function()
            if mainSkillID ~= nil then
              for _, tInfo in pairs(damageInfoList) do
                if tInfo.skillID ~= nil then
                  break
                end
                if tInfo.stype ~= SUBSEQTYPE_ADDHPMP and tInfo.stype ~= SUBSEQTYPE_BASEHPMP then
                  local tPos = tInfo.objPos
                  if tPos ~= userPos then
                    if not _getEffectIsExisted(EFFECTTYPE_NOSKILLANI, tInfo.objEffectList) then
                      object:displaySkillObjAniAtPos(mainSkillID, tPos)
                    end
                  else
                    local targetType = data_getSkillTargetType(mainSkillID)
                    if targetType == TARGETTYPE_MYSIDE or targetType == TARGETTYPE_TEAMMATE or targetType == TARGETTYPE_SELF or targetType == TARGETTYPE_MYSIDEPET then
                      object:displaySkillObjAniAtPos(mainSkillID, tPos)
                    end
                  end
                end
              end
            end
          end)
        end
        attActList[#attActList + 1] = CCDelayTime:create(damageTime)
        t_skill = t_skill + damageTime
        local function __setDamage()
          local att_Start = 0
          local att_SkillTime = math.max(skillTime - damageTime, 0)
          local att_dt = 0
          local moreAttSkillID
          local effMaxTime = 0
          local hurtSkill = mainSkillID
          for _, tInfo in pairs(damageInfoList) do
            local stype = tInfo.stype or SUBSEQTYPE_NORMAL
            local attPos = tInfo.attPos
            local tPos = tInfo.objPos
            local objHp = tInfo.objHp
            local objMp = tInfo.objMp
            local attEffectList = tInfo.attEffectList
            local objEffectList = tInfo.objEffectList
            local attPetSkill = tInfo.attPetSkill
            local defPetSkill = tInfo.defPetSkill
            if tInfo.skillID ~= nil and JudgeSkillIsActive(tInfo.skillID) then
              moreAttSkillID = tInfo.skillID
              hurtSkill = moreAttSkillID
              att_Start = att_SkillTime
              local moreAttSkillTime, moreAttDamageTime = data_getObjSkillAniKeepTime(moreAttSkillID)
              att_SkillTime = att_Start + moreAttDamageTime
              att_dt = att_Start + moreAttDamageTime
            end
            local targetViewObj = object:getViewObjByPos(tPos)
            if targetViewObj then
              if _getEffectIsExisted(EFFECTTYPE_JUMPHIT, objEffectList) then
                local jumpSpace = 0.15
                att_dt = att_dt + jumpSpace
                att_SkillTime = att_SkillTime + jumpSpace
              end
              local temp_t_dt = att_dt
              if stype == SUBSEQTYPE_ADDHPMP then
                local addHp = tInfo.addHp or 0
                local addMp = tInfo.addMp or 0
                local fuhuo = tInfo.fuhuo
                local aniFlag = tInfo.aniFlag
                object:displayPetSkillAniAtPosWhenDamageWithDelay(temp_t_dt, attPos, attPetSkill)
                object:displayPetSkillAniAtPosWhenDamageWithDelay(temp_t_dt, tPos, defPetSkill)
                targetViewObj:setAddRoleHpAndMpWithDelay(objHp, objMp, addHp, addMp, nil, temp_t_dt, fuhuo, aniFlag)
                local et_1 = object:displayRoleEffectAniAtPos(tPos, objEffectList, temp_t_dt)
                effMaxTime = math.max(effMaxTime, et_1 + att_dt)
                local et_2 = object:displayRoleEffectAniAtPos(attPos, attEffectList, temp_t_dt)
                effMaxTime = math.max(effMaxTime, et_2 + att_dt)
              elseif stype == SUBSEQTYPE_BASEHPMP then
                local objMaxHp = tInfo.objMaxHp
                local objMaxMp = tInfo.objMaxMp
                object:displayPetSkillAniAtPosWhenDamageWithDelay(temp_t_dt, attPos, attPetSkill)
                object:displayPetSkillAniAtPosWhenDamageWithDelay(temp_t_dt, tPos, defPetSkill)
                targetViewObj:setRoleBaseHpAndMpWithDelay(temp_t_dt, objHp, objMp, objMaxHp, objMaxMp)
              else
                local damageHp = tInfo.damageHp or 0
                local damageMp = tInfo.damageMp or 0
                local attND = tInfo.attND
                local defND = tInfo.defND
                object:displayPetSkillAniAtPosWhenDamageWithDelay(temp_t_dt, attPos, attPetSkill)
                object:displayPetSkillAniAtPosWhenDamageWithDelay(temp_t_dt, tPos, defPetSkill)
                if tPos == attackerPos then
                  targetViewObj:setDamageRoleHpAndMpNoActionWithDelay(temp_t_dt, objHp, objMp, damageHp, damageMp, attEffectList)
                  local et_1 = object:displayRoleEffectAniAtPos(tPos, objEffectList, temp_t_dt)
                  effMaxTime = math.max(effMaxTime, et_1 + att_dt)
                  local et_2 = object:displayRoleEffectAniAtPos(attPos, attEffectList, temp_t_dt)
                  effMaxTime = math.max(effMaxTime, et_2 + att_dt)
                else
                  targetViewObj:setDamageRoleHpAndMpWithDelay(temp_t_dt, objHp, objMp, damageHp, damageMp, attEffectList, objEffectList, hurtSkill)
                  local et_1 = object:displayRoleEffectAniAtPos(tPos, objEffectList, temp_t_dt)
                  effMaxTime = math.max(effMaxTime, et_1 + att_dt)
                  local et_2 = object:displayRoleEffectAniAtPos(attPos, attEffectList, temp_t_dt)
                  effMaxTime = math.max(effMaxTime, et_2 + att_dt)
                  if moreAttSkillID ~= nil then
                    object:displaySkillObjAniAtPosWithDelay(att_Start, moreAttSkillID, tPos)
                  end
                end
                object:displayRoleNeiDanAniAtPosWhenDamageWithDelay(temp_t_dt, attPos, attND)
                object:displayRoleNeiDanAniAtPosWhenDamageWithDelay(temp_t_dt, tPos, defND)
              end
            elseif targetViewObj == nil then
              print("【seqAnalyze error】目标 @%d 不存在，无法对其进行技能或者普通攻击 !", tPos)
            end
          end
          local dt = 0
          if needSpeedUp and #targetInfo > 0 then
            dt = att_dt
          else
            local skillOverRestTime = skillTime - damageTime
            dt = math.max(skillOverRestTime, att_SkillTime)
            dt = math.max(dt, effMaxTime)
          end
          t_skill = t_skill + dt
          if object.m_ChasingFlag_Seq ~= true then
            local a1 = CCDelayTime:create(dt)
            local a2 = CCCallFunc:create(function()
              stateInfo.skillAniOver = true
              object:onAttackOrSkillAniOver(userPos, targetInfo, attackerViewObj, stateInfo)
            end)
            object:runAction(transition.sequence({a1, a2}))
          end
        end
        attActList[#attActList + 1] = CCCallFunc:create(function()
          __setDamage()
        end)
        if mainTarget ~= nil then
          local actList = {}
          local st = 0
          if isFirst == true then
            if talkDelay ~= nil and talkDelay > 0 then
              st = st + talkDelay
              talkDelay = nil
            end
            st = st + object:shoutUsingSkill(st, userPos, mainSkillID)
            actList[#actList + 1] = CCDelayTime:create(st)
          end
          local performType = data_getSkillPerformType(mainSkillID)
          if performType == PERFORMETYPE_MOVE or performType == PERFORMETYPE_MOVE_ONEBYONE then
            do
              local attxy = object:getRoleXYByPos(attackerPos)
              local targetxy = object:getAttackXYByDirection(mainTarget, attackerViewObj:getShapeId())
              local dt = object:getRoleMoveTime(attxy, targetxy)
              local dt_2 = 0.1
              local targetDir = object:getRoleDirection(mainTarget)
              actList[#actList + 1] = CCCallFunc:create(function()
                attackerViewObj:setFightToTargetDir(targetDir)
              end)
              actList[#actList + 1] = CCMoveTo:create(dt, targetxy)
              actList[#actList + 1] = CCDelayTime:create(dt_2)
              st = st + dt
              st = st + dt_2
              if object.m_ChasingFlag_Seq == true then
                attackerViewObj:setFightToTargetDir(targetDir)
                attackerViewObj:setPosition(targetxy)
              end
            end
          end
          if object.m_ChasingFlag_Seq == true then
            __setDamage()
            object.m_ChasingTime = object.m_ChasingTime - math.max(t_attack, t_skill) - st
            stateInfo.attackAniOver = true
            stateInfo.skillAniOver = true
            object:onAttackOrSkillAniOver(userPos, targetInfo, attackerViewObj, stateInfo)
          else
            for _, act in pairs(attActList) do
              actList[#actList + 1] = act
            end
            attackerViewObj:runAction(transition.sequence(actList))
          end
        else
          print("-->>没有主目标？？")
          object:analyzeSkillSeq(userPos, targetInfo)
        end
      end
    else
      object:onSkillSeqFinish()
    end
  end
  function object:onAttackOrSkillAniOver(userPos, targetInfo, attackerViewObj, stateInfo)
    if not stateInfo.attackAniOver or not stateInfo.skillAniOver then
      return
    end
    if stateInfo.isCounterAttack then
      local performType = data_getSkillPerformType(stateInfo.mainSkillID)
      if performType == PERFORMETYPE_MOVE or performType == PERFORMETYPE_MOVE_ONEBYONE then
        local attxy = object:getRoleXYByPos(stateInfo.attackerPos)
        local orixy = object:getXYByPos(stateInfo.attackerPos)
        local dt = object:getRoleMoveTime(attxy, orixy)
        local dt_2 = 0.1
        local act0 = CCDelayTime:create(dt_2)
        local act1 = CCMoveTo:create(dt, orixy)
        local act2 = CCCallFunc:create(function()
          attackerViewObj:recoverDirToNormalStand()
          object:analyzeSkillSeq(userPos, targetInfo)
        end)
        if object.m_ChasingFlag_Seq == true then
          object.m_ChasingTime = object.m_ChasingTime - dt - dt_2
          attackerViewObj:setPosition(orixy)
          attackerViewObj:recoverDirToNormalStand()
          object:analyzeSkillSeq(userPos, targetInfo)
        else
          attackerViewObj:runAction(transition.sequence({
            act0,
            act1,
            act2
          }))
        end
        return
      end
    end
    object:analyzeSkillSeq(userPos, targetInfo)
  end
  function object:onSkillSeqFinish(dt)
    object:onSeqAnalyzeFinish(dt)
  end
  function object:getRoleMoveTime(sXY, eXY)
    return 0
  end
  function object:fightAction_UseNeiDanSkill(warSeq)
    object:fightAction_UseSkill(warSeq, SEQTYPE_USENEIDANSKILL)
  end
  function object:fightAction_UsePetSkill(warSeq)
    object:fightAction_UseSkill(warSeq, SEQTYPE_PETSKILL)
  end
  function object:fightAction_EffectOff(warSeq)
    local objPos = warSeq.objPos
    local effectList = warSeq.effectList
    local userViewObj = object:getViewObjByPos(objPos)
    if userViewObj == nil then
      print("【warplay error】目标 @%d 不存在，无法解除效果 !", objPos)
      object:onSeqAnalyzeFinish(0)
      return
    end
    local function __EffectOff(pos)
      if warSeq.pSkill ~= nil then
        local petPos = warSeq.petPos
        if petPos == nil then
          petPos = objPos
        end
        object:displayPetSkillAniAtPosWhenDamageWithDelay(0, petPos, warSeq.pSkill)
      end
      if warSeq.skill ~= nil then
        object:displaySkillObjAniAtPos(warSeq.skill, objPos)
      end
      object:displayRoleEffectAniAtPos(pos, effectList)
      if warSeq.stype == SUBSEQTYPE_NO_DELAY then
        object:onSeqAnalyzeFinish(0)
      elseif warSeq.stype == SUBSEQTYPE_PETENTER or warSeq.stype == SUBSEQTYPE_ENDDELAY_1S then
        object:onSeqAnalyzeFinish(1)
      else
        object:onSeqAnalyzeFinish(0)
      end
    end
    local dt = 0.25
    local extraDelay = 0
    local needDelay = true
    if _getEffectIsExisted(EFFECTTYPE_ADV_DEFEND_OFF, effectList) and #effectList == 1 then
      dt = 0
      needDelay = false
    elseif warSeq.skill ~= nil then
      local skillTime, _ = data_getObjSkillAniKeepTime(warSeq.skill, false)
      dt = math.max(skillTime, dt)
    end
    if object.m_HasDurativeEffect == nil then
      if needDelay then
        extraDelay = 0.25
      end
      object.m_HasDurativeEffect = dt
    else
      object.m_HasDurativeEffect = math.max(object.m_HasDurativeEffect, dt)
    end
    if object.m_HasInstantHpMpEffect ~= nil then
      extraDelay = object.m_HasInstantHpMpEffect + extraDelay
      object.m_HasInstantHpMpEffect = nil
    end
    if warSeq.stype == SUBSEQTYPE_NO_DELAY then
      extraDelay = 0
    end
    if object.m_ChasingFlag_Seq == true then
      object.m_ChasingTime = object.m_ChasingTime - extraDelay
      __EffectOff(objPos)
    elseif extraDelay > 0 then
      local act1 = CCDelayTime:create(extraDelay)
      local act2 = CCCallFunc:create(function()
        __EffectOff(objPos)
      end)
      object:runAction(transition.sequence({act1, act2}))
    else
      __EffectOff(objPos)
    end
  end
  function object:fightAction_DurativeEffect(warSeq)
    local objPos = warSeq.objPos
    local effectID = warSeq.effectID
    local effList = warSeq.effList
    local hp = warSeq.objHp
    local mp = warSeq.objMp
    local maxhp = warSeq.objMaxHp
    local maxmp = warSeq.objMaxMp
    local damageHp = warSeq.damageHp
    local damageMp = warSeq.damageMp
    local objViewObj = object:getViewObjByPos(objPos)
    if objViewObj == nil then
      print("【warplay error】目标 @%d 不存在，无法持续效果 !", objPos)
      object:onSeqAnalyzeFinish(0)
      return
    end
    local dt = data_getUpdateEffectTime(effectID) or 0
    local extraDelay = 0
    if object.m_HasDurativeEffect == nil then
      extraDelay = 0.5
      object.m_HasDurativeEffect = dt
    else
      object.m_HasDurativeEffect = math.max(object.m_HasDurativeEffect, dt)
    end
    if object.m_HasInstantHpMpEffect ~= nil then
      extraDelay = object.m_HasInstantHpMpEffect + extraDelay
      object.m_HasInstantHpMpEffect = nil
    end
    local function __DurativeEffect(pos)
      if maxhp ~= nil or maxmp ~= nil then
        objViewObj:setRoleBaseHpAndMp(hp, mp, maxhp, maxmp)
      end
      objViewObj:setDamageRoleHpAndMp(hp, mp, damageHp, damageMp, {effectID}, nil, nil, {hurtSound = true})
      object:displayRoleEffectAniAtPos(pos, {effectID})
      object:displayRoleEffectAniAtPos(pos, effList, 0)
      object:onSeqAnalyzeFinish(0)
    end
    if object.m_ChasingFlag_Seq == true then
      object.m_ChasingTime = object.m_ChasingTime - extraDelay
      __DurativeEffect(objPos)
    elseif extraDelay > 0 then
      local act1 = CCDelayTime:create(extraDelay)
      local act2 = CCCallFunc:create(function()
        __DurativeEffect(objPos)
      end)
      object:runAction(transition.sequence({act1, act2}))
    else
      __DurativeEffect(objPos)
    end
  end
  function object:fightAction_CallUp(warSeq)
    local userPos = warSeq.userPos
    local skillID = warSeq.skillID
    local param = warSeq.param
    local userViewObj = object:getViewObjByPos(userPos)
    if userViewObj == nil then
      print("【warplay error】召唤者 @%d 不存在，无法召唤小怪物 !", userPos)
      object:onSeqAnalyzeFinish(0)
      return
    end
    userViewObj:setAttack(skillID)
    local function __createNewObj(objPos, objInfo)
      if skillID == SKILLTYPE_BABYPET then
        objPos = tonumber(objPos)
        object:createNewPet(objPos, objInfo)
      elseif skillID == SKILLTYPE_BABYMONSTER then
        objPos = tonumber(objPos)
        object:createNewMonster(objPos, objInfo)
      end
    end
    local dt = 0.5
    dt = dt + userViewObj:checkFightTalk(SEQTYPE_CALLUP, object.m_CurrRound)
    for objPos, objInfo in pairs(param) do
      do
        local act1 = CCDelayTime:create(dt)
        local act2 = CCCallFunc:create(function()
          __createNewObj(objPos, objInfo)
        end)
        if object.m_ChasingFlag_Seq == true then
          __createNewObj(objPos, objInfo)
        else
          object:runAction(transition.sequence({act1, act2}))
        end
        dt = dt + 0.5
      end
    end
    local endDelay
    local nextSeq = object.m_CurrSeqList[object.m_CurrSeqIndex + 1]
    if nextSeq ~= nil then
      if nextSeq.seqType == SEQTYPE_INSTANT_HPMP and nextSeq.stype == SUBSEQTYPE_PETENTER then
        endDelay = 0
      elseif nextSeq.seqType == SEQTYPE_ADDBUFF and nextSeq.pskill == PETSKILL_RUHUTIANYI then
        endDelay = 0
      elseif nextSeq.seqType == SEQTYPE_EFFECT_OFF and nextSeq.stype == SUBSEQTYPE_PETENTER then
        endDelay = 0
      end
    else
      dt = dt + 0.5
    end
    local dt = math.max(dt, 0.5)
    if object.m_ChasingFlag_Seq == true then
      object.m_ChasingTime = object.m_ChasingTime - dt
      object:onSeqAnalyzeFinish(endDelay)
    else
      local a1 = CCDelayTime:create(dt)
      local a2 = CCCallFunc:create(function()
        object:onSeqAnalyzeFinish(endDelay)
      end)
      object:runAction(transition.sequence({a1, a2}))
    end
  end
  function object:fightAction_Escape(warSeq)
    local userPos = warSeq.userPos
    local userViewObj = object:getViewObjByPos(userPos)
    if userViewObj == nil then
      print("【warplay error】逃跑者 @%d 不存在，无法逃跑 !", userPos)
      object:onSeqAnalyzeFinish(0)
      return
    end
    local runawayType = warSeq.rtype
    local dt_talk = 0
    if runawayType == RUNAWAY_TYPE_Poison then
      dt_talk = userViewObj:checkFightTalk_TX(MONSTER_TX_6)
    elseif runawayType == RUNAWAY_TYPE_OnlyBoss then
      dt_talk = userViewObj:checkFightTalk_TX(MONSTER_TX_9)
    elseif runawayType == RUNAWAY_TYPE_DreadMan then
      dt_talk = userViewObj:checkFightTalk_TX(MONSTER_TX_7)
    else
      dt_talk = userViewObj:checkFightTalk(SEQTYPE_ESCAPE, object.m_CurrRound, {rtype = runawayType})
    end
    local dt = 0.5
    if object.m_ChasingFlag_Seq == true then
      object.m_ChasingTime = object.m_ChasingTime - dt_talk - dt
      object:RoleViewAtPosRunAway(userPos)
      object:onSeqAnalyzeFinish()
    else
      local actList = {}
      if dt_talk > 0 then
        actList[#actList + 1] = CCDelayTime:create(dt_talk)
      end
      actList[#actList + 1] = CCCallFunc:create(function()
        object:displayEffectAniAtPos(userPos, EFFECTTYPE_RUNAWAY)
      end)
      actList[#actList + 1] = CCDelayTime:create(dt)
      actList[#actList + 1] = CCCallFunc:create(function()
        object:RoleViewAtPosRunAway(userPos)
      end)
      actList[#actList + 1] = CCCallFunc:create(function()
        object:onSeqAnalyzeFinish()
      end)
      object:runAction(transition.sequence(actList))
    end
  end
  function object:fightAction_FreshFinishBeforeRound()
    if object.m_HasInstantHpMpEffect ~= nil then
      local dt = object.m_HasInstantHpMpEffect
      object.m_HasInstantHpMpEffect = nil
      if object.m_ChasingFlag_Seq == true then
        object.m_ChasingTime = object.m_ChasingTime - dt
        object:onSeqAnalyzeFinish()
      else
        local act1 = CCDelayTime:create(dt)
        local act2 = CCCallFunc:create(function()
          object:onSeqAnalyzeFinish()
        end)
        object:runAction(transition.sequence({act1, act2}))
      end
    elseif object.m_HasDurativeEffect ~= nil then
      local dt = object.m_HasDurativeEffect
      object.m_HasDurativeEffect = nil
      if object.m_ChasingFlag_Seq == true then
        object.m_ChasingTime = object.m_ChasingTime - dt
        object:onSeqAnalyzeFinish()
      else
        local act1 = CCDelayTime:create(dt)
        local act2 = CCCallFunc:create(function()
          object:onSeqAnalyzeFinish()
        end)
        object:runAction(transition.sequence({act1, act2}))
      end
    else
      object:onSeqAnalyzeFinish(0)
    end
  end
  function object:fightAction_UseDrug(warSeq)
    local userViewObj = object:getViewObjByPos(warSeq.userPos)
    if userViewObj == nil then
      object:onSeqAnalyzeFinish(0)
      return
    end
    local drugViewObj = object:getViewObjByPos(warSeq.drugPos)
    if drugViewObj == nil then
      object:onSeqAnalyzeFinish(0)
      return
    end
    object:delOneDrug(warSeq.drugID, warSeq.userPos)
    local effectList = {}
    if 0 < warSeq.addhp then
      effectList[#effectList + 1] = EFFECTTYPE_USEDRUG_HP
    end
    if 0 < warSeq.addmp then
      effectList[#effectList + 1] = EFFECTTYPE_USEDRUG_MP
    end
    userViewObj:setUseDrug()
    local function __usedrug()
      local dt = 0
      if 0 < warSeq.addhp or 0 < warSeq.addmp then
        dt = drugViewObj:setAddRoleHpAndMpWithDelay(warSeq.hp, warSeq.mp, warSeq.addhp, warSeq.addmp, effectList, 0, warSeq.fuhuo)
      else
        dt = 0.5
        if warSeq.stype == SUBSEQTYPE_INVALID then
          if userViewObj:getPlayerId() == g_LocalPlayer:getPlayerId() then
            ShowNotifyTips("目标被夺魂索命，加血失败")
          end
          object:displayEffectAniAtPos(warSeq.drugPos, EFFECTTYPE_INVALID)
        else
          object:displayEffectAniAtPos(warSeq.drugPos, EFFECTTYPE_IMMUNITY)
        end
      end
      if object.m_ChasingFlag_Seq == true then
        object.m_ChasingTime = object.m_ChasingTime - dt
        object:onSeqAnalyzeFinish()
      else
        local act1 = CCDelayTime:create(dt)
        local act2 = CCCallFunc:create(function()
          object:onSeqAnalyzeFinish()
        end)
        object:runAction(transition.sequence({act1, act2}))
      end
    end
    local dt_0 = 0.5
    if object.m_ChasingFlag_Seq == true then
      object.m_ChasingTime = object.m_ChasingTime - dt_0
      __usedrug()
    else
      local act1 = CCDelayTime:create(dt_0)
      local act2 = CCCallFunc:create(function()
        __usedrug()
      end)
      object:runAction(transition.sequence({act1, act2}))
    end
  end
  function object:fightAction_InstantHpMp(warSeq)
    local userPos = warSeq.userPos
    local userViewObj = object:getViewObjByPos(warSeq.userPos)
    if userViewObj == nil then
      object:onSeqAnalyzeFinish(0)
      return
    end
    local function _InstantHpMp(pos, eDelay, st)
      eDelay = eDelay or 0
      if warSeq.pSkill ~= nil and warSeq.petPos ~= nil then
        object:displayPetSkillAniAtPosWhenDamageWithDelay(0, warSeq.petPos, warSeq.pSkill)
      end
      if warSeq.addhp ~= nil or warSeq.addmp ~= nil then
        local fuhuo = warSeq.fuhuo or 0
        userViewObj:setAddRoleHpAndMpWithDelay(warSeq.hp, warSeq.mp, warSeq.addhp, warSeq.addmp, warSeq.objEffectList, 0, fuhuo, warSeq.ani)
      end
      if warSeq.subhp ~= nil or warSeq.submp ~= nil then
        if st == SUBSEQTYPE_XUANREN or st == SUBSEQTYPE_YIHUAN then
          userViewObj:setDamageRoleHpAndMpWithDelay(0, warSeq.hp, warSeq.mp, warSeq.subhp, warSeq.submp, warSeq.objEffectList, nil, nil)
        else
          userViewObj:setDamageRoleHpAndMpWithDelay(0, warSeq.hp, warSeq.mp, warSeq.subhp, warSeq.submp, warSeq.objEffectList, nil, nil, {noAct = true})
        end
      end
      if warSeq.maxhp ~= nil or warSeq.maxmp ~= nil then
        userViewObj:setRoleBaseHpAndMpWithDelay(0, warSeq.hp, warSeq.mp, warSeq.maxhp, warSeq.maxmp)
      end
      if warSeq.objEffectList ~= nil then
        object:displayRoleEffectAniAtPos(warSeq.userPos, warSeq.objEffectList, 0.1)
      end
      object:onSeqAnalyzeFinish(eDelay)
    end
    local dt = 1
    local endDelay = 0
    local extraDelay = 0
    local stype = warSeq.stype
    if stype == SUBSEQTYPE_BEFOREROUND then
      if object.m_HasInstantHpMpEffect == nil then
        extraDelay = 0.5
        object.m_HasInstantHpMpEffect = dt
      else
        object.m_HasInstantHpMpEffect = math.max(object.m_HasInstantHpMpEffect, dt)
      end
    elseif stype == SUBSEQTYPE_PETENTER then
      extraDelay = 0
      endDelay = 1.5
    elseif stype == SUBSEQTYPE_XUANREN then
      if object:damageXuanRenAni(userPos) then
        extraDelay = 1.1
        endDelay = 0.9
      else
        extraDelay = 0
        endDelay = 0.5
      end
    elseif stype == SUBSEQTYPE_YIHUAN then
      if object:damageYiHuanAni(userPos) then
        extraDelay = 1.1
        endDelay = 0.9
      else
        extraDelay = 0
        endDelay = 0.5
      end
    elseif stype == SUBSEQTYPE_ENDDELAY_1S then
      endDelay = 1
    elseif stype == SUBSEQTYPE_SEQSPACE_PREEND_2 then
      extraDelay = 0.5
      endDelay = 1
    end
    if object.m_ChasingFlag_Seq == true then
      object.m_ChasingTime = object.m_ChasingTime - extraDelay
      _InstantHpMp(userPos, endDelay, stype)
    elseif extraDelay > 0 then
      local act1 = CCDelayTime:create(extraDelay)
      local act2 = CCCallFunc:create(function()
        _InstantHpMp(userPos, endDelay, stype)
      end)
      object:runAction(transition.sequence({act1, act2}))
    else
      _InstantHpMp(userPos, endDelay, stype)
    end
  end
  function object:fightAction_SkillTip(warSeq)
    local objPos = warSeq.objPos
    local roleViewObj = object:getViewObjByPos(objPos)
    if roleViewObj == nil then
      object:onSeqAnalyzeFinish(0)
      return
    end
    local tipID = warSeq.tipID
    local dt = 0.5
    local tip
    if tipID == SKILLTIP_LACKMANA then
      tip = EFFECTTYPE_LACKMP
    elseif tipID == SKILLTIP_LACKDRUG then
      tip = EFFECTTYPE_LACKITEM
    elseif tipID == SKILLTIP_PURSUIT then
      tip = EFFECTTYPE_PURSUIT
    elseif tipID == SKILLTIP_LACKMANA_WHENSKILL then
      tip = EFFECTTYPE_LACKMP
      dt = 1
    elseif tipID == SKILLTIP_LACKHP_WHENSKILL then
      tip = EFFECTTYPE_LACKHP
      dt = 1
    elseif tipID == SKILLTIP_LACKGG_WHENSKILL then
      tip = EFFECTTYPE_LACKGG
    elseif tipID == SKILLTIP_LACKLX_WHENSKILL then
      tip = EFFECTTYPE_LACKLX
    elseif tipID == SKILLTIP_LACKMJ_WHENSKILL then
      tip = EFFECTTYPE_LACKMJ
    elseif tipID == SKILLTIP_LACKLL_WHENSKILL then
      tip = EFFECTTYPE_LACKLL
    elseif tipID == SKILLTIP_LACKLL_HUOLI then
      tip = EFFECTTYPE_LACKHUOLI
    elseif tipID == SKILLTIP_LACKWXJIN_WHENSKILL then
      tip = EFFECTTYPE_LACK_WXJIN
    elseif tipID == SKILLTIP_LACKWXMU_WHENSKILL then
      tip = EFFECTTYPE_LACK_WXMU
    elseif tipID == SKILLTIP_LACKWXSHUI_WHENSKILL then
      tip = EFFECTTYPE_LACK_WXSHUI
    elseif tipID == SKILLTIP_LACKWXHUO_WHENSKILL then
      tip = EFFECTTYPE_LACK_WXHUO
    elseif tipID == SKILLTIP_LACKWXTU_WHENSKILL then
      tip = EFFECTTYPE_LACK_WXTU
    end
    if tip ~= nil then
      if object.m_ChasingFlag_Seq == true then
        object.m_ChasingTime = object.m_ChasingTime - dt
        object:onSeqAnalyzeFinish()
      else
        local actType = warSeq.actType
        if actType == 2 then
          object:displayEffectAniAtPos_2(objPos, tip)
        else
          object:displayEffectAniAtPos(objPos, tip)
        end
        local act1 = CCDelayTime:create(dt)
        local act2 = CCCallFunc:create(function()
          object:onSeqAnalyzeFinish()
        end)
        object:runAction(transition.sequence({act1, act2}))
      end
    else
      object:onSeqAnalyzeFinish(0)
    end
  end
  function object:fightAction_Defend(warSeq)
    object:displayEffectAniAtPos(warSeq.userPos, EFFECTTYPE_ADV_DEFEND)
    local dt = 0.5
    if object.m_ChasingFlag_Seq == true then
      object.m_ChasingTime = object.m_ChasingTime - dt
      object:onSeqAnalyzeFinish()
    else
      local act1 = CCDelayTime:create(dt)
      local act2 = CCCallFunc:create(function()
        object:onSeqAnalyzeFinish()
      end)
      object:runAction(transition.sequence({act1, act2}))
    end
  end
  function object:fightAction_BaseHpAndMp(warSeq)
    local roleViewObj = object:getViewObjByPos(warSeq.objPos)
    if roleViewObj == nil then
      object:onSeqAnalyzeFinish(0)
      return
    end
    roleViewObj:setRoleBaseHpAndMp(warSeq.objHp, warSeq.objMp, warSeq.objMaxHp, warSeq.objMaxMp)
    object:onSeqAnalyzeFinish(0)
  end
  function object:fightAction_Protect(warSeq)
    if object.m_ChasingFlag_Seq == true then
      object:onSeqAnalyzeFinish(0)
      return
    end
    local protectObj = object:getViewObjByPos(warSeq.pPos)
    local objPos = warSeq.objPos
    if protectObj == nil or objPos == nil then
      object:onSeqAnalyzeFinish(0)
      return
    end
    local currxy = object:getRoleXYByPos(warSeq.pPos)
    local toxy = object:getProtectXYByPos(objPos)
    local dt = object:getRoleMoveTime(currxy, toxy)
    protectObj:runAction(CCMoveTo:create(dt, toxy))
    if warSeq.pSkill ~= nil then
      object:displayPetSkillAniAtPosWhenDamage(warSeq.pPos, warSeq.pSkill)
    end
    object:onSeqAnalyzeFinish(0)
  end
  function object:fightAction_BackToRolePos(warSeq)
    if object.m_ChasingFlag_Seq == true then
      object:onSeqAnalyzeFinish(0)
      return
    end
    local pos = warSeq.pos
    local roleObj = object:getViewObjByPos(pos)
    if roleObj == nil then
      object:onSeqAnalyzeFinish(0)
      return
    end
    local currxy = object:getRoleXYByPos(pos)
    local toxy = object:getXYByPos(pos)
    local dt = object:getRoleMoveTime(currxy, toxy)
    roleObj:runAction(CCMoveTo:create(dt, toxy))
    object:onSeqAnalyzeFinish(0.5)
  end
  function object:fightAction_UserWordTip(warSeq, synFlag)
    local playerId = warSeq.pid
    if playerId ~= nil and playerId ~= g_LocalPlayer:getPlayerId() then
      if synFlag ~= true then
        object:onSeqAnalyzeFinish(0)
      end
      return
    end
    local tipID = warSeq.tipID
    local skillId = warSeq.skill
    local pos = warSeq.pos
    local tipContent
    local roleObj = object:getViewObjByPos(pos)
    local huobanName
    if roleObj and roleObj:getType() == LOGICTYPE_HERO and not roleObj:getIsPlayerMainHero() then
      huobanName = roleObj:getRoleName()
    end
    if tipID == SUBSEQTYPE_EXECNORMALATTACK then
      tipContent = "执行物理攻击"
    elseif tipID == SUBSEQTYPE_CDWHENSKILL then
      local skillName = data_getSkillName(skillId)
      tipContent = string.format("#<Y,>%s#技能处于冷却中", skillName)
    elseif tipID == SUBSEQTYPE_CANNNOTUSECURROUND then
      local r = _getSkillUseOfMinRoundFlag(skillId)
      if r > 0 then
        local skillName = data_getSkillName(skillId)
        tipContent = string.format("前#<Y,>%d#回合不能施放#<Y,>%s#技能", r - 1, skillName)
      end
    elseif tipID == SUBSEQTYPE_CANNNOTUSEPVE then
      local skillName = data_getSkillName(skillId)
      tipContent = string.format("#<Y,>%s#技能只能玩家间战斗施放", skillName)
    elseif tipID == SUBSEQTYPE_ONCESKILLHAVEUSED then
      local skillName = data_getSkillName(skillId)
      tipContent = string.format("#<Y,>%s#技能只能施放一次", skillName)
    elseif tipID == SUBSEQTYPE_LACKMANA then
      local skillName = data_getSkillName(skillId)
      if huobanName == nil then
        tipContent = string.format("你的#<R,>法力#不足，无法施放#<Y,>%s#技能", skillName)
      else
        tipContent = string.format("伙伴#<Y,>%s##<R,>法力#不足，无法施放#<Y,>%s#技能", huobanName, skillName)
      end
    elseif tipID == SUBSEQTYPE_LACKHP then
      local skillName = data_getSkillName(skillId)
      if huobanName == nil then
        tipContent = string.format("你的#<R,>气血#不足，无法施放#<Y,>%s#技能", skillName)
      else
        tipContent = string.format("伙伴#<Y,>%s##<R,>气血#不足，无法施放#<Y,>%s#技能", huobanName, skillName)
      end
    elseif tipID == SUBSEQTYPE_PETLACKMANA then
      if skillId == SKILLTYPE_CATCHPET then
        tipContent = "法力值不足，无法捕捉"
      else
        local skillName = data_getSkillName(skillId)
        tipContent = string.format("召唤兽#<R,>法力#不足，无法施放#<Y,>%s#技能", skillName)
      end
    elseif tipID == SUBSEQTYPE_PETLACKHP then
      local skillName = data_getSkillName(skillId)
      tipContent = string.format("召唤兽#<R,>气血#不足，无法施放#<Y,>%s#技能", skillName)
    elseif tipID == SUBSEQTYPE_NOTARGET then
      tipContent = string.format("没有施法目标")
    elseif tipID == SUBSEQTYPE_LACKGENGU then
      local skillPro = GetPetSkillNeedPro(skillId)
      local skillName = data_getSkillName(skillId)
      if huobanName == nil then
        tipContent = string.format("你的#<R,>根骨#不足%d，无法施放#<Y,>%s#技能", skillPro.gg or 0, skillName)
      else
        tipContent = string.format("伙伴#<Y,>%s##<R,>根骨#不足%d，无法施放#<Y,>%s#技能", huobanName, skillPro.gg or 0, skillName)
      end
    elseif tipID == SUBSEQTYPE_PETLACKGENGU then
      local skillPro = GetPetSkillNeedPro(skillId)
      local skillName = data_getSkillName(skillId)
      tipContent = string.format("召唤兽#<R,>根骨#不足%d，无法施放#<Y,>%s#技能", skillPro.gg or 0, skillName)
    elseif tipID == SUBSEQTYPE_LACKLINGXING then
      local skillPro = GetPetSkillNeedPro(skillId)
      local skillName = data_getSkillName(skillId)
      if huobanName == nil then
        tipContent = string.format("你的#<R,>灵性#不足%d，无法施放#<Y,>%s#技能", skillPro.lx or 0, skillName)
      else
        tipContent = string.format("伙伴#<Y,>%s##<R,>灵性#不足%d，无法施放#<Y,>%s#技能", huobanName, skillPro.lx or 0, skillName)
      end
    elseif tipID == SUBSEQTYPE_PETLACKLINGXING then
      local skillPro = GetPetSkillNeedPro(skillId)
      local skillName = data_getSkillName(skillId)
      tipContent = string.format("召唤兽#<R,>灵性#不足%d，无法施放#<Y,>%s#技能", skillPro.lx or 0, skillName)
    elseif tipID == SUBSEQTYPE_LACKMINJIE then
      local skillPro = GetPetSkillNeedPro(skillId)
      local skillName = data_getSkillName(skillId)
      if huobanName == nil then
        tipContent = string.format("你的#<R,>敏捷#不足%d，无法施放#<Y,>%s#技能", skillPro.mj or 0, skillName)
      else
        tipContent = string.format("伙伴#<Y,>%s##<R,>敏捷#不足%d，无法施放#<Y,>%s#技能", huobanName, skillPro.mj or 0, skillName)
      end
    elseif tipID == SUBSEQTYPE_PETLACKMINJIE then
      local skillPro = GetPetSkillNeedPro(skillId)
      local skillName = data_getSkillName(skillId)
      tipContent = string.format("你的召唤兽#<R,>敏捷#不足%d，无法施放#<Y,>%s#技能", skillPro.mj or 0, skillName)
    elseif tipID == SUBSEQTYPE_LACKLILIANG then
      local skillPro = GetPetSkillNeedPro(skillId)
      local skillName = data_getSkillName(skillId)
      if huobanName == nil then
        tipContent = string.format("你的#<R,>力量#不足%d，无法施放#<Y,>%s#技能", skillPro.ll or 0, skillName)
      else
        tipContent = string.format("伙伴#<Y,>%s##<R,>力量#不足%d，无法施放#<Y,>%s#技能", huobanName, skillPro.ll or 0, skillName)
      end
    elseif tipID == SUBSEQTYPE_PETLACKLILIANG then
      local skillPro = GetPetSkillNeedPro(skillId)
      local skillName = data_getSkillName(skillId)
      tipContent = string.format("你的召唤兽#<R,>力量#不足%d，无法施放#<Y,>%s#技能", skillPro.ll or 0, skillName)
    elseif tipID == SUBSEQTYPE_LACKHUOLI then
      if skillId == SKILLTYPE_CATCHPET then
        tipContent = "活力值不足，无法捕捉"
      else
        local skillName = data_getSkillName(skillId)
        if huobanName == nil then
          tipContent = string.format("你的#<R,>活力#不足，无法施放#<Y,>%s#技能", skillName)
        else
          tipContent = string.format("伙伴#<Y,>%s##<R,>活力#不足，无法施放#<Y,>%s#技能", huobanName, skillName)
        end
      end
    elseif tipID == SUBSEQTYPE_LACKPETNUM then
      if skillId == SKILLTYPE_CATCHPET then
        tipContent = "身上召唤兽已满，不能捕捉"
      else
        local skillName = data_getSkillName(skillId)
        tipContent = string.format("无法施放#<Y,>%s#技能", skillName)
      end
    elseif tipID == SUBSEQTYPE_HUAWU then
      local skillName = data_getSkillName(skillId)
      if huobanName == nil then
        tipContent = string.format("受敌方召唤兽化无影响，#<Y,>%s#技能释放失败", skillName)
      else
        tipContent = string.format("伙伴#<Y,>%s#受敌方召唤兽化无影响，#<Y,>%s#技能释放失败", huobanName, skillName)
      end
    elseif tipID == SUBSEQTYPE_THIEVESKILL then
      local skillName = data_getSkillName(skillId)
      tipContent = string.format("你的召唤兽偷取了对方#<Y,>%s#技能", skillName)
    elseif tipID == SUBSEQTYPE_SKILLCDFRESH then
      tipContent = "你的召唤兽技能冷却时间结束，下回合生效"
    elseif tipID == SUBSEQTYPE_HL_LACK_NOTCATCH then
      tipContent = "活力值不足，无法捕捉高级守护"
    elseif tipID == SUBSEQTYPE_MP_LACK_NOTCATCH then
      tipContent = "法力值不足，无法捕捉高级守护"
    elseif tipID == SUBSEQTYPE_LV_LACK_NOTCATCH then
      tipContent = "等级低于召唤兽携带要求，无法捕捉高级守护"
    elseif tipID == SUBSEQTYPE_NUM_LACK_NOTCATCH then
      tipContent = "召唤兽数量已达上限，无法捕捉高级守护"
    elseif tipID == SUBSEQTYPE_TARGETISDEAD then
      local skillName = data_getSkillName(skillId)
      tipContent = string.format("目标已死亡，无法释放#<Y,>%s#技能", skillName)
    elseif tipID == SUBSEQTYPE_CANNOTAUTOSKILL then
      local skillName = data_getSkillName(skillId)
      tipContent = string.format("自动状态下，无法释放#<Y,>%s#技能", skillName)
    elseif tipID == SUBSEQTYPE_PETLACK_WXJIN then
      local jin, mu, shui, huo, tu = data_getSkillWuXingRequire(skillId)
      local skillName = data_getSkillName(skillId)
      tipContent = string.format("召唤兽#<R,>五行金#不足%d，无法施放#<Y,>%s#技能", jin * 100, skillName)
    elseif tipID == SUBSEQTYPE_PETLACK_WXMU then
      local jin, mu, shui, huo, tu = data_getSkillWuXingRequire(skillId)
      local skillName = data_getSkillName(skillId)
      tipContent = string.format("召唤兽#<R,>五行木#不足%d，无法施放#<Y,>%s#技能", mu * 100, skillName)
    elseif tipID == SUBSEQTYPE_PETLACK_WXSHUI then
      local jin, mu, shui, huo, tu = data_getSkillWuXingRequire(skillId)
      local skillName = data_getSkillName(skillId)
      tipContent = string.format("召唤兽#<R,>五行水#不足%d，无法施放#<Y,>%s#技能", shui * 100, skillName)
    elseif tipID == SUBSEQTYPE_PETLACK_WXHUO then
      local jin, mu, shui, huo, tu = data_getSkillWuXingRequire(skillId)
      local skillName = data_getSkillName(skillId)
      tipContent = string.format("召唤兽#<R,>五行火#不足%d，无法施放#<Y,>%s#技能", huo * 100, skillName)
    elseif tipID == SUBSEQTYPE_PETLACK_WXTU then
      local jin, mu, shui, huo, tu = data_getSkillWuXingRequire(skillId)
      local skillName = data_getSkillName(skillId)
      tipContent = string.format("召唤兽#<R,>五行土#不足%d，无法施放#<Y,>%s#技能", tu * 100, skillName)
    elseif tipID == SUBSEQTYPE_LACK_WXJIN then
      local jin, mu, shui, huo, tu = data_getSkillWuXingRequire(skillId)
      local skillName = data_getSkillName(skillId)
      if huobanName == nil then
        tipContent = string.format("你的#<R,>五行金#不足%d，无法施放#<Y,>%s#技能", jin * 100, skillName)
      else
        tipContent = string.format("伙伴#<Y,>%s##<R,>五行金#不足%d，无法施放#<Y,>%s#技能", huobanName, jin * 100, skillName)
      end
    elseif tipID == SUBSEQTYPE_LACK_WXMU then
      local jin, mu, shui, huo, tu = data_getSkillWuXingRequire(skillId)
      local skillName = data_getSkillName(skillId)
      if huobanName == nil then
        tipContent = string.format("你的#<R,>五行木#不足%d，无法施放#<Y,>%s#技能", mu * 100, skillName)
      else
        tipContent = string.format("伙伴#<Y,>%s##<R,>五行木#不足%d，无法施放#<Y,>%s#技能", huobanName, mu * 100, skillName)
      end
    elseif tipID == SUBSEQTYPE_LACK_WXSHUI then
      local jin, mu, shui, huo, tu = data_getSkillWuXingRequire(skillId)
      local skillName = data_getSkillName(skillId)
      if huobanName == nil then
        tipContent = string.format("你的#<R,>五行水#不足%d，无法施放#<Y,>%s#技能", shui * 100, skillName)
      else
        tipContent = string.format("伙伴#<Y,>%s##<R,>五行水#不足%d，无法施放#<Y,>%s#技能", huobanName, shui * 100, skillName)
      end
    elseif tipID == SUBSEQTYPE_LACK_WXHUO then
      local jin, mu, shui, huo, tu = data_getSkillWuXingRequire(skillId)
      local skillName = data_getSkillName(skillId)
      if huobanName == nil then
        tipContent = string.format("你的#<R,>五行火#不足%d，无法施放#<Y,>%s#技能", huo * 100, skillName)
      else
        tipContent = string.format("伙伴#<Y,>%s##<R,>五行火#不足%d，无法施放#<Y,>%s#技能", huobanName, huo * 100, skillName)
      end
    elseif tipID == SUBSEQTYPE_LACK_WXTU then
      local jin, mu, shui, huo, tu = data_getSkillWuXingRequire(skillId)
      local skillName = data_getSkillName(skillId)
      if huobanName == nil then
        tipContent = string.format("你的#<R,>五行土#不足%d，无法施放#<Y,>%s#技能", tu * 100, skillName)
      else
        tipContent = string.format("伙伴#<Y,>%s##<R,>五行土#不足%d，无法施放#<Y,>%s#技能", huobanName, tu * 100, skillName)
      end
    elseif tipID == SUBSEQTYPE_YIWANGSKILL then
      if skillId == SKILLTYPE_USEDRUG then
        tipContent = "受#<Y,>遗忘#的影响，无法使用物品"
      else
        local skillName = data_getSkillName(skillId)
        tipContent = string.format("受#<Y,>遗忘#的影响，无法释放#<Y,>%s#技能", skillName)
      end
    end
    if object.m_ChasingFlag_Seq ~= true and tipContent ~= nil then
      ShowNotifyTips(tipContent)
    end
    if synFlag ~= true then
      object:onSeqAnalyzeFinish(0)
    end
  end
  function object:fightAction_AddBuff(warSeq)
    local userPos = warSeq.userPos
    local roleViewObj = object:getViewObjByPos(userPos)
    if roleViewObj == nil then
      object:onSeqAnalyzeFinish(0)
      return
    end
    local dt = 1
    local pskill = warSeq.pskill
    object:displayPetSkillAniAtPosWhenDamage(userPos, pskill)
    local tInfo = warSeq.tInfo
    for _, info in pairs(tInfo) do
      local effPos = info.effPos
      local effID = info.effID
      local effSkill = info.effSkill
      local skillTime, buffTime = 0, 0
      if effSkill ~= nil then
        skillTime, buffTime = data_getObjSkillAniKeepTime(effSkill)
        skillTime = skillTime + 0.5
        object:displaySkillObjAniAtPos(effSkill, effPos)
      end
      object:displayRoleEffectAniAtPos(effPos, {effID}, buffTime)
      dt = math.max(dt, skillTime)
    end
    object:onSeqAnalyzeFinish(dt)
  end
  function object:fightAction_Relive(warSeq)
    local pos = warSeq.pos
    local pskill = warSeq.pskill
    local roleViewObj = object:getViewObjByPos(pos)
    if roleViewObj == nil then
      roleViewObj = object:getBakViewObjByPos(pos)
      if roleViewObj == nil then
        object:onSeqAnalyzeFinish(0)
        return
      end
    end
    local dt = 0.5
    local endDelay = 1
    if object.m_ChasingFlag_Seq == true then
      object.m_ChasingTime = object.m_ChasingTime - dt
      roleViewObj:setRelive(warSeq.hp, warSeq.mp, true)
      roleViewObj:setRoleBaseHpAndMp(warSeq.hp, warSeq.mp, warSeq.maxhp, warSeq.maxmp)
      object:onSeqAnalyzeFinish(endDelay)
    else
      local act1 = CCDelayTime:create(dt)
      local act2 = CCCallFunc:create(function()
        roleViewObj:setRelive(warSeq.hp, warSeq.mp, true)
        roleViewObj:setRoleBaseHpAndMp(warSeq.hp, warSeq.mp, warSeq.maxhp, warSeq.maxmp)
        object:displayPetSkillAniAtPosWhenDamage(pos, pskill)
        object:onSeqAnalyzeFinish(endDelay)
      end)
      object:runAction(transition.sequence({act1, act2}))
    end
  end
  function object:fightAction_LeaveBattle(warSeq)
    local pos = warSeq.pos
    local roleViewObj = object:getViewObjByPos(pos)
    if roleViewObj == nil then
      object:onSeqAnalyzeFinish(0)
      return
    end
    if warSeq.stype == SUBSEQTYPE_SEQSPACE_PREEND or warSeq.stype == SUBSEQTYPE_SEQSPACE_PREEND_2 then
      do
        local dt_1 = 1
        if warSeq.stype == SUBSEQTYPE_SEQSPACE_PREEND_2 then
          dt_1 = 0.5
        end
        local dt_2 = 1
        if object.m_ChasingFlag_Seq == true then
          object.m_ChasingTime = object.m_ChasingTime - dt_1
          roleViewObj:setRoleLeaveBattle()
          object:onSeqAnalyzeFinish(dt_2)
          return
        else
          local act1 = CCDelayTime:create(dt_1)
          local act2 = CCCallFunc:create(function()
            roleViewObj:setRoleLeaveBattle()
            object:onSeqAnalyzeFinish(dt_2)
          end)
          object:runAction(transition.sequence({act1, act2}))
          return
        end
      end
    end
    roleViewObj:setRoleLeaveBattle()
    object:onSeqAnalyzeFinish(0)
  end
  function object:fightAction_CatchPet(warSeq)
    local pos = warSeq.pos
    local userViewObj = object:getViewObjByPos(pos)
    if userViewObj == nil then
      object:onSeqAnalyzeFinish(0)
      return
    end
    local petPos = warSeq.petPos
    local petViewObj = object:getViewObjByPos(petPos)
    if petViewObj == nil then
      object:onSeqAnalyzeFinish(0)
      return
    end
    local hp = warSeq.hp
    local mp = warSeq.mp
    local success = warSeq.success
    local petName = petViewObj:getRoleName()
    local petTypeId = data_getPetIdByShape(data_getRoleShape(petViewObj:getTypeId()))
    userViewObj:setHp(hp)
    userViewObj:setMp(mp)
    local dt = 1
    if object.m_ChasingFlag_Seq == true then
      object.m_ChasingTime = object.m_ChasingTime - dt
      object:displayCatchPetAniAtPos(petPos, success)
      object:onSeqAnalyzeFinish()
    else
      userViewObj:setAttack(SKILLTYPE_CATCHPET)
      local act1 = CCDelayTime:create(dt)
      local act2 = CCCallFunc:create(function()
        object:displayCatchPetAniAtPos(petPos, success)
      end)
      local act3 = CCDelayTime:create(1)
      local act4 = CCCallFunc:create(function()
        local playerId = warSeq.pid
        if playerId == g_LocalPlayer:getPlayerId() then
          if success == 1 then
            local huoli = object:getCatchPetSuccedHuoliValue(petTypeId)
            if huoli > 0 then
              ShowNotifyTips(string.format("成功捕捉#<Y>%s#，扣除%d#<IR%d>#。", petName, huoli, RESTYPE_HUOLI))
            else
              ShowNotifyTips(string.format("成功捕捉#<Y>%s#。", petName))
            end
          else
            local huoli = object:getCatchPetFailedHuoliValue(petTypeId)
            if huoli > 0 then
              ShowNotifyTips(string.format("捕捉#<Y>%s#失败，扣除%d#<IR%d>#。", petName, huoli, RESTYPE_HUOLI))
            else
              ShowNotifyTips(string.format("捕捉#<Y>%s#失败。", petName))
            end
          end
          if object.m_WaruiObj.SetHuoLi ~= nil then
            object.m_WaruiObj:SetHuoLi()
          end
        end
        object:onSeqAnalyzeFinish()
      end)
      object:runAction(transition.sequence({
        act1,
        act2,
        act3,
        act4
      }))
    end
  end
  function object:fightAction_AddSceneAni(warSeq)
    if warSeq.subType == SUBSEQTYPE_XUANREN then
      if warSeq.param == TEAM_ATTACK then
        object:createAttackXuanRenAni()
      elseif warSeq.param == TEAM_DEFEND then
        object:createDefendXuanRenAni()
      end
    elseif warSeq.subType == SUBSEQTYPE_YIHUAN then
      if warSeq.param == TEAM_ATTACK then
        object:createAttackYiHuanAni()
      elseif warSeq.param == TEAM_DEFEND then
        object:createDefendYiHuanAni()
      end
    end
    object:onSeqAnalyzeFinish(0)
  end
  function object:fightAction_DelSceneAni(warSeq)
    if warSeq.subType == SUBSEQTYPE_XUANREN then
      if warSeq.param == TEAM_ATTACK then
        object:deleteAttackXuanRenAni()
      elseif warSeq.param == TEAM_DEFEND then
        object:deleteDefendXuanRenAni()
      end
    elseif warSeq.subType == SUBSEQTYPE_YIHUAN then
      if warSeq.param == TEAM_ATTACK then
        object:deleteAttackYiHuanAni()
      elseif warSeq.param == TEAM_DEFEND then
        object:deleteDefendYiHuanAni()
      end
    end
    object:onSeqAnalyzeFinish(0)
  end
  function object:fightAction_AddPosAni(warSeq, synFlag)
    local pos = warSeq.pos
    local skillId = warSeq.skill
    local roleObj = object:getViewObjByPos(pos)
    if roleObj == nil or skillId == nil then
      if synFlag ~= true then
        object:onSeqAnalyzeFinish(0)
      end
      return
    end
    if warSeq.petPos ~= nil and warSeq.pSkill ~= nil then
      object:displayPetSkillAniAtPosWhenDamage(warSeq.petPos, warSeq.pSkill)
    end
    local skillTime, _, _ = data_getSkillAniKeepTime(skillId)
    object:displaySkillObjAniAtPos(skillId, pos)
    if synFlag ~= true then
      object:onSeqAnalyzeFinish(skillTime)
    end
  end
  function object:fightAction_ShowEnemyHpMp(warSeq)
    local team = warSeq.team
    local flag = warSeq.flag
    object:setShowEnenmyHpMp(team, flag)
    object:onSeqAnalyzeFinish(0)
  end
  function object:fightAction_MonsterTeXing(warSeq)
    local txType = warSeq.txType
    if txType == MONSTER_TX_4 or txType == MONSTER_TX_5 then
      do
        local userPos = warSeq.userPos
        local userObj = object:getViewObjByPos(userPos)
        if userObj == nil then
          object:onSeqAnalyzeFinish(0)
          return
        end
        local actList = {}
        local talkDelay = userObj:checkFightTalk_TX(txType)
        local attackDelay = 0.5
        if object.m_ChasingFlag_Seq == true then
          object.m_ChasingTime = object.m_ChasingTime - talkDelay
        else
          actList[#actList + 1] = CCDelayTime:create(talkDelay)
          actList[#actList + 1] = CCCallFunc:create(function()
            userObj:setSkillAttack(true)
          end)
        end
        local function __addHpMp()
          local targetInfo = warSeq.targetInfo or {}
          local dt = 0
          for _, tInfo in pairs(targetInfo) do
            local objPos = tInfo.objPos
            local objObj = object:getViewObjByPos(objPos)
            if objObj then
              local hp = tInfo.objHp
              local mp = tInfo.objMp
              local addHp = tInfo.addHp or 0
              local addMp = tInfo.addMp or 0
              local tempdt = objObj:setAddRoleHpAndMpWithDelay(hp, mp, addHp, addMp)
              dt = math.max(dt, tempdt)
            end
          end
          local endDelay = 0.3
          if object.m_ChasingFlag_Seq == true then
            object.m_ChasingTime = object.m_ChasingTime - dt
            object:onSeqAnalyzeFinish(endDelay)
          else
            local act1 = CCDelayTime:create(dt)
            local act2 = CCCallFunc:create(function()
              object:onSeqAnalyzeFinish(endDelay)
            end)
            object:runAction(transition.sequence({act1, act2}))
          end
        end
        if object.m_ChasingFlag_Seq == true then
          object.m_ChasingTime = object.m_ChasingTime - attackDelay
          __addHpMp()
        else
          actList[#actList + 1] = CCDelayTime:create(attackDelay)
          actList[#actList + 1] = CCCallFunc:create(function()
            __addHpMp()
          end)
          object:runAction(transition.sequence(actList))
        end
      end
    end
  end
  function object:fightAction_ExtraEffect(warSeq, dt)
    if warSeq.seqType == SEQTYPE_MONSTER_TX then
      if warSeq.stype == MONSTER_TX_12 then
        local effPos = warSeq.effPos
        local effPosObj = object:getViewObjByPos(effPos)
        if effPosObj == nil then
          return 0
        end
        if object.m_CurrRoundTeXingTalk[effPos] == nil or object.m_CurrRoundTeXingTalk[effPos][MONSTER_TX_12] == nil then
          if object.m_CurrRoundTeXingTalk[effPos] == nil then
            object.m_CurrRoundTeXingTalk[effPos] = {}
          end
          effPosObj:checkFightTalk_TX(MONSTER_TX_12)
          object.m_CurrRoundTeXingTalk[effPos][MONSTER_TX_12] = true
        end
      elseif warSeq.stype == MONSTER_TX_13 then
        local effPos = warSeq.effPos
        local effPosObj = object:getViewObjByPos(effPos)
        if effPosObj == nil then
          return 0
        end
        if object.m_CurrRoundTeXingTalk[effPos] == nil or object.m_CurrRoundTeXingTalk[effPos][MONSTER_TX_13] == nil then
          if object.m_CurrRoundTeXingTalk[effPos] == nil then
            object.m_CurrRoundTeXingTalk[effPos] = {}
          end
          effPosObj:checkFightTalk_TX(MONSTER_TX_13)
          object.m_CurrRoundTeXingTalk[effPos][MONSTER_TX_13] = true
        end
      end
    end
    return 0
  end
  function object:fightAction_SteathBeforeRound(warSeq)
    local pos = warSeq.pos
    local skillId = warSeq.skill
    local roleObj = object:getViewObjByPos(pos)
    if roleObj == nil then
      object:onSeqAnalyzeFinish(0)
      return
    end
    object:displayPetSkillAniAtPosWhenDamage(pos, skillId)
    local dt = 0.8
    local endDelay = 0.8
    if object.m_ChasingFlag_Seq == true then
      object.m_ChasingTime = object.m_ChasingTime - dt
      object:onSeqAnalyzeFinish(endDelay)
    else
      local act1 = CCDelayTime:create(dt)
      local act2 = CCCallFunc:create(function()
        roleObj:setStealth()
        object:onSeqAnalyzeFinish(endDelay)
      end)
      object:runAction(transition.sequence({act1, act2}))
    end
  end
  function object:fightAction_TakeAway(warSeq)
    local pos = warSeq.pos
    local pskill = warSeq.pskill
    object:displayPetSkillAniAtPosWhenDamage(pos, pskill)
    local objPos = warSeq.objPos
    local roleObj = object:getViewObjByPos(objPos)
    if roleObj == nil then
      object:onSeqAnalyzeFinish(0)
      return
    end
    local dt = 0.3
    local aniDelay = 0.3
    local endDelay = 1.2
    if object.m_ChasingFlag_Seq == true then
      object.m_ChasingTime = object.m_ChasingTime - dt - aniDelay
      object:onSeqAnalyzeFinish(endDelay)
    else
      local act1 = CCDelayTime:create(dt)
      local act2 = CCCallFunc:create(function()
        object:displaySkillObjAniAtPos(30026, objPos)
      end)
      local act3 = CCDelayTime:create(aniDelay)
      local act4 = CCCallFunc:create(function()
        roleObj:setRoleLeaveBattle()
        object:onSeqAnalyzeFinish(endDelay)
      end)
      object:runAction(transition.sequence({
        act1,
        act2,
        act3,
        act4
      }))
    end
  end
  function object:fightAction_ShanXian(warSeq)
    local pos = warSeq.pos
    local aniDelay = 0.3
    local petDelay = 0.7
    local endDelay = 0.8
    local nextSeq = object.m_CurrSeqList[object.m_CurrSeqIndex + 1]
    if nextSeq ~= nil then
      if nextSeq.seqType == SEQTYPE_INSTANT_HPMP and nextSeq.stype == SUBSEQTYPE_PETENTER then
        endDelay = 0.4
      elseif nextSeq.seqType == SEQTYPE_ADDBUFF and nextSeq.pskill == PETSKILL_RUHUTIANYI then
        endDelay = 0.4
      elseif nextSeq.seqType == SEQTYPE_EFFECT_OFF and nextSeq.stype == SUBSEQTYPE_PETENTER then
        endDelay = 0.4
      end
    end
    local newPet = object:createNewPet(pos, warSeq)
    if newPet == nil then
      print("====================>>> 序列异常：闪现时创建宠物失败！！！")
      object:onSeqAnalyzeFinish(0)
      return
    end
    newPet:setVisible(false)
    if object.m_ChasingFlag_Seq == true then
      object.m_ChasingTime = object.m_ChasingTime - aniDelay
      object:displaySkillObjAniAtPos(PETSKILL_JISHIYU, pos)
      object.m_ChasingTime = object.m_ChasingTime - petDelay
      newPet:setVisible(true)
      object:onSeqAnalyzeFinish(endDelay)
    else
      local a1 = CCDelayTime:create(aniDelay)
      local a2 = CCCallFunc:create(function()
        object:displaySkillObjAniAtPos(PETSKILL_JISHIYU, pos)
      end)
      local a3 = CCDelayTime:create(petDelay)
      local a4 = CCCallFunc:create(function()
        newPet:setVisible(true)
        object:onSeqAnalyzeFinish(endDelay)
      end)
      object:runAction(transition.sequence({
        a1,
        a2,
        a3,
        a4
      }))
    end
  end
  function object:fightAction_ChuXian_NPC(warSeq)
    local pos = warSeq.pos
    local aniDelay = 0.3
    local petDelay = 0.7
    local endDelay = 0.8
    local nextSeq = object.m_CurrSeqList[object.m_CurrSeqIndex + 1]
    if nextSeq ~= nil then
      if nextSeq.seqType == SEQTYPE_INSTANT_HPMP and nextSeq.stype == SUBSEQTYPE_PETENTER then
        endDelay = 0.4
      elseif nextSeq.seqType == SEQTYPE_ADDBUFF and nextSeq.pskill == PETSKILL_RUHUTIANYI then
        endDelay = 0.4
      elseif nextSeq.seqType == SEQTYPE_EFFECT_OFF and nextSeq.stype == SUBSEQTYPE_PETENTER then
        endDelay = 0.4
      end
    end
    local newPet = object:createNewMonster(pos, warSeq)
    if newPet == nil then
      print("====================>>> 序列异常：闪现时创建宠物失败！！！")
      object:onSeqAnalyzeFinish(0)
      return
    end
    newPet:setVisible(false)
    if object.m_ChasingFlag_Seq == true then
      object.m_ChasingTime = object.m_ChasingTime - aniDelay
      object:displaySkillObjAniAtPos(PETSKILL_JISHIYU, pos)
      object.m_ChasingTime = object.m_ChasingTime - petDelay
      newPet:setVisible(true)
      object:onSeqAnalyzeFinish(endDelay)
    else
      local a1 = CCDelayTime:create(aniDelay)
      local a2 = CCCallFunc:create(function()
        object:displaySkillObjAniAtPos(PETSKILL_JISHIYU, pos)
      end)
      local a3 = CCDelayTime:create(petDelay)
      local a4 = CCCallFunc:create(function()
        newPet:setVisible(true)
        object:onSeqAnalyzeFinish(endDelay)
      end)
      object:runAction(transition.sequence({
        a1,
        a2,
        a3,
        a4
      }))
    end
  end
  function object:fightAction_MakeOtherRelive(warSeq)
    local userPos = warSeq.pos
    local userViewObj = object:getViewObjByPos(userPos)
    if userViewObj == nil then
      object:onSeqAnalyzeFinish(0)
      return
    end
    local rolePos = warSeq.objPos
    local roleViewObj = object:getViewObjByPos(rolePos)
    if roleViewObj == nil then
      roleViewObj = object:getBakViewObjByPos(rolePos)
      if roleViewObj == nil then
        object:onSeqAnalyzeFinish(0)
        return
      end
    end
    local talkDelay = 0
    local actDelay = 0.8
    local endDelay = 1.3
    if warSeq.txId ~= nil then
      talkDelay = userViewObj:checkFightTalk_TX(warSeq.txId)
    end
    if object.m_ChasingFlag_Seq == true then
      object.m_ChasingTime = object.m_ChasingTime - talkDelay - actDelay
      roleViewObj:setRelive(warSeq.hp, warSeq.mp, true)
      roleViewObj:setRoleBaseHpAndMp(warSeq.hp, warSeq.mp, warSeq.maxhp, warSeq.maxmp)
      object:onSeqAnalyzeFinish(endDelay)
    else
      local act1 = CCDelayTime:create(talkDelay)
      local act2 = CCCallFunc:create(function()
        userViewObj:setSkillAttack(true)
      end)
      local act3 = CCDelayTime:create(actDelay)
      local act4 = CCCallFunc:create(function()
        roleViewObj:setRelive(warSeq.hp, warSeq.mp, true)
        roleViewObj:setRoleBaseHpAndMp(warSeq.hp, warSeq.mp, warSeq.maxhp, warSeq.maxmp)
        if warSeq.txId ~= nil then
          object:displayPetSkillAniAtPosWhenDamage(rolePos, warSeq.txId, true)
        end
        object:onSeqAnalyzeFinish(endDelay)
      end)
      object:runAction(transition.sequence({
        act1,
        act2,
        act3,
        act4
      }))
    end
  end
  object.m_CurrRound = 0
  object.m_CurrSeqIndex = 0
  object.m_CurrSeqList = {}
  object.m_WarSeqTotalList = {}
  object.m_CurrRoundTeXingTalk = {}
  object.m_LastRoundAnalyzeFinish = true
  object.m_WarAnalyzeFinish = false
  object.m_IsInDoubleHitState = nil
  object.m_PauseAnalyze = false
end
return seqAnalyze
