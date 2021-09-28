if not CMonsterAI then
  CMonsterAI = class("CMonsterAI", CRoleAI)
end
function CMonsterAI:ctor(warId, playerId, objId, lTypeId, pos, copyProperties)
  CMonsterAI.super.ctor(self, warId, playerId, objId, lTypeId, pos, copyProperties)
  self:InitMonsterTeXing()
end
function CMonsterAI:ConfuseAttack()
  if self:getType() ~= LOGICTYPE_MONSTER then
    CMonsterAI.super.ConfuseAttack(self)
  else
    local rRate = data_getNpcConfusedRunawayData(self:getTypeId())
    if rRate > 0 and g_WarAiInsList[self:getWarID()]:GetCanConfuseEscape() and math.random(0, 100) <= rRate * 100 then
      local userPos = self:getWarPos()
      printLogDebug("monster_ai", string.format("【warai log】[warid%d]-->怪物AI,@%d,因为混乱而逃跑: %f, %d", self:getWarID(), userPos, rRate, g_WarAiInsList[self:getWarID()].m_ConfuseEscapeTimes))
      g_WarAiInsList[self:getWarID()]:MarkConfuseEscape()
      printLogDebug("monster_ai", string.format("【warai log】[warid%d]-->混乱数值再输出: %f, %d", self:getWarID(), rRate, g_WarAiInsList[self:getWarID()].m_ConfuseEscapeTimes))
      self:RunAway({rtype = RUNAWAY_TYPE_Confuse})
      return
    end
    CMonsterAI.super.ConfuseAttack(self)
  end
end
function CMonsterAI:UseAI()
  printLogDebug("monster_ai", "【warai log】[warid%d]-->怪物AI开始", self:getWarID(), self:getTypeId())
  if self:getType() ~= LOGICTYPE_MONSTER then
    printLogDebug("monster_ai", "【warai log】[warid%d]~~~~异常，不是怪物，用怪物的AI", self:getWarID())
    return
  end
  local userPos = self:getWarPos()
  if WAR_CODE_IS_SERVER == true then
    local clv = 0
    local role = g_WarAiInsList[self:getWarID()]:getObjectByPos(3)
    if role ~= nil then
      local playerID = role:getPlayerId()
      local player = WarAIGetOnePlayerData(self:getWarID(), playerID)
      if player ~= nil then
        clv = player:GetCatchLv()
      end
    end
    if clv < 0 then
      clv = 0
    end
    printLogDebug("monster_ai", string.format("【warai log】[warid%d]-->怪物AI,@%d,看是否要逃跑", self:getWarID(), userPos))
    if g_WarAiInsList[self:getWarID()]:GetWarType() == WARTYPE_GuaJi then
      local rRound, rRate = data_getNpcRunawayData(self:getTypeId())
      if rRound ~= 0 and rRound <= g_WarAiInsList[self:getWarID()]:GetCurRoundNum() and math.random(0, 100) <= (rRate - math.pow(clv, 0.5) / 100) * 100 then
        printLogDebug("monster_ai", string.format("【warai log】[warid%d]-->怪物AI,@%d,看是否要逃跑", self:getWarID(), userPos))
        self:RunAway({rtype = RUNAWAY_TYPE_Catch})
        return
      end
    end
  end
  if self:PossessMonsterTeXing(MONSTER_TX_6) and g_SkillAI.getIsPoison(self:getWarID(), userPos) and not g_SkillAI.getIsFrozen(self:getWarID(), userPos) then
    printLogDebug("monster_ai", string.format("【warai log】[warid%d]-->怪物AI,@%d 具有战斗特性【畏惧毒伤】,中毒后逃跑", self:getWarID(), userPos))
    self:RunAway({rtype = RUNAWAY_TYPE_Poison})
    return
  end
  if self:PossessMonsterTeXing(MONSTER_TX_7) and not g_SkillAI.getIsFrozen(self:getWarID(), userPos) then
    local allPosList = g_WarAiInsList[self:getWarID()]:getHostileAliveTeamerPos(userPos)
    local existManFlag = false
    for _, tempPos in pairs(allPosList) do
      if tempPos ~= userPos then
        local role = g_WarAiInsList[self:getWarID()]:getObjectByPos(tempPos)
        if role and role:getType() == LOGICTYPE_HERO and (role:getProperty(PROPERTY_RACE) == RACE_REN or role:getProperty(PROPERTY_RACE) == RACE_GUI) then
          existManFlag = true
          break
        end
      end
    end
    if existManFlag then
      printLogDebug("monster_ai", string.format("【warai log】[warid%d]-->怪物AI,@%d 具有战斗特性【惧人怕鬼】,存在人族、鬼族时逃跑", self:getWarID(), userPos))
      self:RunAway({rtype = RUNAWAY_TYPE_DreadMan})
      return
    end
  end
  if self:PossessMonsterTeXing(MONSTER_TX_9) and not g_SkillAI.getIsFrozen(self:getWarID(), userPos) then
    local allPosList = g_WarAiInsList[self:getWarID()]:getAlliesAliveTeamerPos(userPos)
    local normalMonsterFlag = false
    for _, tempPos in pairs(allPosList) do
      if tempPos ~= userPos then
        local role = g_WarAiInsList[self:getWarID()]:getObjectByPos(tempPos)
        if role and role:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and role:getType() == LOGICTYPE_MONSTER and not role:IsBossMonster() then
          normalMonsterFlag = true
          break
        end
      end
    end
    if not normalMonsterFlag then
      printLogDebug("monster_ai", string.format("【warai log】[warid%d]-->怪物AI,@%d 具有战斗特性【胆小如鬼】,无小怪存在时逃跑", self:getWarID(), userPos))
      self:RunAway({rtype = RUNAWAY_TYPE_OnlyBoss})
      return
    end
  end
  printLogDebug("monster_ai", string.format("【warai log】[warid%d]-->怪物AI,@%d,看是否能够召唤怪物", self:getWarID(), userPos))
  local targetList = g_WarAiInsList[self:getWarID()]:getAlliesAliveTeamerPos(userPos)
  local enemyListId = g_WarAiInsList[self:getWarID()]:GetNPCEnemyListID()
  local tempWar = data_WarRole[enemyListId] or {}
  local zhjlList = tempWar.zhjlList or {}
  local mstTypeId = self:getTypeId()
  local zhData = zhjlList[mstTypeId] or {}
  local zhList = zhData.list or {}
  local zhRate = zhData.rate or 0
  local zhNum = zhData.num or 0
  if zhRate == 0 or zhNum == 0 then
    printLogDebug("monster_ai", "【warai log】[warid%d]-->怪物AI,不能召唤", self:getWarID())
  elseif zhRate <= math.random(0, 100) then
    printLogDebug("monster_ai", "【warai log】[warid%d]-->怪物AI,召唤概率不够,不能召唤", self:getWarID())
  else
    local allPosList = {
      [10001] = true,
      [10002] = true,
      [10003] = true,
      [10004] = true,
      [10005] = true,
      [10101] = true,
      [10102] = true,
      [10103] = true,
      [10104] = true,
      [10105] = true
    }
    local hasRolePosList = {}
    local emptyPosList = {}
    for _, tempPos in pairs(targetList) do
      hasRolePosList[tempPos] = true
    end
    for tempPos, _ in pairs(allPosList) do
      if hasRolePosList[tempPos] ~= true then
        emptyPosList[#emptyPosList + 1] = tempPos
      end
    end
    emptyPosList = RandomSortList(emptyPosList)
    if #emptyPosList <= 0 then
      printLogDebug("monster_ai", "【warai log】[warid%d]-->怪物AI,召唤位置不够,不能召唤", self:getWarID())
    elseif #zhList <= 0 then
      printLogDebug("monster_ai", "【warai log】[warid%d]-->怪物AI,召唤导表为空,不能召唤", self:getWarID())
    else
      local m_ZHNum = math.random(1, zhNum)
      m_ZHNum = math.min(m_ZHNum, #emptyPosList)
      local newRoleList = {}
      local tempRoleFactory = CRoleFactory.new()
      for i = 1, m_ZHNum do
        local mstID = zhList[math.random(1, #zhList)]
        local playerId = FUBEN_PLAYERID
        local mstObj = tempRoleFactory:newObject(playerId, 0, mstID, nil, self:getWarID())
        local targetPos = emptyPosList[i]
        local lv = data_getRoleProFromData(mstObj:getTypeId(), PROPERTY_MONSTERLEVEL)
        local levelMode = data_getRoleProFromData(mstObj:getTypeId(), PROPERTY_MLEVELMODE)
        if levelMode == MONSTER_LEVLEMODE_NORMAL then
        elseif levelMode == MONSTER_LEVLEMODE_ZHUOGUI then
          lv = g_WarAiInsList[self:getWarID()]:GetZHUOGUILV() + lv
        elseif levelMode == MONSTER_LEVLEMODE_TIANTING then
          lv = g_WarAiInsList[self:getWarID()]:GetTIANTINGLV() + lv
        elseif levelMode == MONSTER_LEVLEMODE_CAPTAIN then
          lv = g_WarAiInsList[self:getWarID()]:GetCAPTAINLV() + lv
        end
        mstObj:setProperty(PROPERTY_ROLELEVEL, lv)
        mstObj:CalculateProperty()
        mstObj:setProperty(PROPERTY_TEAM, TEAM_DEFEND)
        if g_SkillAI.canSkillOnTarget(self:getWarID(), targetPos, SKILLTYPE_BABYMONSTER) then
          g_WarAiInsList[self:getWarID()]:ChangeRole(targetPos, mstObj, TEAM_DEFEND)
          AIUseSkillOnTarget(self:getWarID(), userPos, targetPos, SKILLTYPE_BABYMONSTER)
          newRoleList[targetPos] = mstObj
        end
      end
      local param = {}
      local hasNewRole = false
      for targetPos, mstObj in pairs(newRoleList) do
        hasNewRole = true
        local op = data_getRoleShapOp(mstObj:getTypeId())
        if op == 0 or op == 255 then
          op = nil
        end
        param[targetPos] = {
          objId = FUBEN_OBJID,
          typeId = mstObj:getTypeId(),
          hp = mstObj:getProperty(PROPERTY_HP),
          maxHp = mstObj:getMaxProperty(PROPERTY_HP),
          mp = mstObj:getProperty(PROPERTY_MP),
          maxMp = mstObj:getMaxProperty(PROPERTY_MP),
          team = mstObj:getProperty(PROPERTY_TEAM),
          name = mstObj:getProperty(PROPERTY_NAME),
          playerId = FUBEN_PLAYERID,
          op = op
        }
      end
      if hasNewRole then
        g_SkillAI.onCreateNewRoleOnPos(self:getWarID(), userPos, SKILLTYPE_BABYMONSTER, param)
        for targetPos, _ in pairs(newRoleList) do
          g_SkillAI.checkWhenPetEnter(self:getWarID(), g_WarAiInsList[self:getWarID()]:GetCurRoundNum(), targetPos, {})
        end
      end
      printLogDebug("monster_ai", "【warai log】[warid%d]-->怪物AI结束3", self:getWarID())
      return
    end
  end
  if self:PossessMonsterTeXing(MONSTER_TX_11) then
    local warAiObj = g_WarAiInsList[self:getWarID()]
    local allPosList = warAiObj:getAlliesAliveTeamerPos(userPos)
    local ycList = {}
    for _, tempPos in pairs(allPosList) do
      local role = warAiObj:getObjectByPos(tempPos)
      if role and role:getType() == LOGICTYPE_MONSTER then
        local effectList = role:getEffects()
        for effectID, effectInfo in pairs(effectList) do
          local round = effectInfo[1]
          if round > 0 and EFFECTBUFF_CHUNHUIDADI_CLEAR[effectID] ~= nil then
            ycList[#ycList + 1] = tempPos
            break
          end
        end
      end
    end
    local tableData = data_MonsterTeXing[MONSTER_TX_11] or {}
    local calparam = tableData.calparam or {}
    local ycAmount = calparam[1] or 1
    if ycAmount <= #ycList then
      local txSkillId = PETSKILL_CHUNHUIDADI
      local targetList = RandomSortList(ycList)
      printLogDebug("monster_ai", string.format("【warai log】[warid%d]-->怪物AI,@%d,触发特性【解除异常】 随机选目标", self:getWarID(), userPos))
      if self:UseOneSkillOnRandomTarget(txSkillId, targetList) ~= nil then
        printLogDebug("monster_ai", string.format("【warai log】[warid%d]-->怪物AI,@%d,触发特性【解除异常】,使用领悟技能【春回大地】 成功", self:getWarID(), userPos))
        return
      end
    end
  end
  local data_table = data_Monster[self:getTypeId()]
  printLogDebug("monster_ai", string.format("【warai log】[warid%d]-->怪物AI,@%d,看是否能够使用领悟技能", self:getWarID(), userPos))
  local lwSkillId
  for _, tempSkillId in pairs(data_table.pskills or {}) do
    lwSkillId = tempSkillId
    break
  end
  if lwSkillId ~= nil then
    local warRound = g_WarAiInsList[self:getWarID()]:GetCurRoundNum()
    local useLWSkillFlag = true
    if useLWSkillFlag and math.random(1, 100) > self:getProperty(PROPERTY_LWGJGL) * 100 then
      printLogDebug("monster_ai", string.format("【warai log】[warid%d]-->怪物AI,@%d,使用领悟技能 失败(随机概率，不用技能)", self:getWarID(), userPos))
      useLWSkillFlag = false
    end
    if useLWSkillFlag == true and self:JudgeCanUseSkillForAI(lwSkillId) == false then
      printLogDebug("monster_ai", string.format("【warai log】[warid%d]-->怪物AI,@%d,使用领悟技能%d 失败(无法使用技能)", self:getWarID(), userPos, lwSkillId))
      useLWSkillFlag = false
    end
    if useLWSkillFlag == true then
      local targetList = self:getRandomTargetListForAI(lwSkillId)
      printLogDebug("monster_ai", string.format("【warai log】[warid%d]-->怪物AI,@%d,使用领悟技能 随机选目标", self:getWarID(), userPos))
      if self:UseOneSkillOnRandomTarget(lwSkillId, targetList) ~= nil then
        printLogDebug("monster_ai", string.format("【warai log】[warid%d]-->怪物AI,@%d,使用领悟技能 成功", self:getWarID(), userPos))
        return
      end
      printLogDebug("monster_ai", string.format("【warai log】[warid%d]-->怪物AI,@%d,使用领悟技能 失败(其他原因)", self:getWarID(), userPos))
    end
  else
    printLogDebug("monster_ai", string.format("【warai log】[warid%d]-->怪物AI,@%d,使用领悟技能 失败(没有技能)", self:getWarID(), userPos))
  end
  printLogDebug("monster_ai", string.format("【warai log】[warid%d]-->怪物AI,@%d,看是否能够使用普通技能", self:getWarID(), userPos))
  local skillId
  for _, tempSkillId in pairs(data_table.skills or {}) do
    skillId = tempSkillId
    break
  end
  if skillId ~= nil then
    if math.random(1, 100) <= self:getProperty(PROPERTY_FSGJGL) * 100 then
      local attrStyle = data_getSkillAttrStyle(skillId)
      local targetList
      if attrStyle == SKILLATTR_FIRE or attrStyle == SKILLATTR_WIND or attrStyle == SKILLATTR_THUNDER or attrStyle == SKILLATTR_WATER or attrStyle == SKILLATTR_ZHEN or attrStyle == SKILLATTR_SHUAIRUO or attrStyle == SKILLATTR_XIXUE or attrStyle == SKILLATTR_AIHAO or attrStyle == SKILLATTR_YIWANG then
        targetList = g_WarAiInsList[self:getWarID()]:getHostileAliveTeamerPos(userPos)
      elseif attrStyle == SKILLATTR_POISON or attrStyle == SKILLATTR_SLEEP or attrStyle == SKILLATTR_CONFUSE or attrStyle == SKILLATTR_ICE then
        targetList = g_SkillAI.getEnemySideOfNoNegativeEffect(self:getWarID(), userPos)
      elseif attrStyle == SKILLATTR_PAN or attrStyle == SKILLATTR_ATTACK or attrStyle == SKILLATTR_SPEED or attrStyle == SKILLATTR_NIAN then
        targetList = g_SkillAI.getMySideOfNoPositiveEffect(self:getWarID(), userPos)
      end
      if targetList ~= nil then
        local canUseSkillTable = {}
        if g_SkillAI.getSkillStyle(skillId) == SKILLSTYLE_INITIATIVE and g_SkillAI.checkUserMpOfSkill(self:getWarID(), userPos, skillId) then
          canUseSkillTable = {
            [attrStyle] = {
              [1] = skillId
            }
          }
        end
        if self:UseRandomSkillOnRandomEnemy(targetList, canUseSkillTable) ~= nil then
          printLogDebug("monster_ai", string.format("【warai log】[warid%d]-->怪物AI,@%d,使用普通技能 成功", self:getWarID(), userPos))
          return
        else
          printLogDebug("monster_ai", string.format("【warai log】[warid%d]-->怪物AI,@%d,使用普通技能 失败(其他原因)", self:getWarID(), userPos))
        end
      else
        printLogDebug("monster_ai", string.format("【warai log】[warid%d]-->怪物AI,@%d,使用普通技能 失败(没有目标)", self:getWarID(), userPos))
      end
    else
      printLogDebug("monster_ai", string.format("【warai log】[warid%d]-->怪物AI,@%d,使用普通技能 失败(随机概率，不用技能)", self:getWarID(), userPos))
    end
  else
    printLogDebug("monster_ai", string.format("【warai log】[warid%d]-->怪物AI,@%d,使用普通技能 失败(没有技能)", self:getWarID(), userPos))
  end
  self:NormalAttackOneRandomEnemy()
  printLogDebug("monster_ai", "【warai log】[warid%d]-->怪物AI结束1", self:getWarID())
end
function CMonsterAI:checkAttackTargetListWithTeXing(targetList, targetType)
  if targetType == TARGETTYPE_ENEMYSIDE then
    if self:PossessMonsterTeXing(MONSTER_TX_2) then
      local warAiObj = g_WarAiInsList[self:getWarID()]
      if warAiObj then
        local team = self:getProperty(PROPERTY_TEAM)
        local fightSeq = warAiObj:getFightPosSeq()
        for _, pos in ipairs(fightSeq) do
          local role = warAiObj:getObjectByPos(pos)
          if role and role:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and role:getType() == LOGICTYPE_HERO and role:getProperty(PROPERTY_TEAM) ~= team then
            if role:getProperty(PROPERTY_RACE) == RACE_MO then
              local existIndex
              for index, tarPos in pairs(targetList) do
                if tarPos == pos then
                  existIndex = index
                  break
                end
              end
              if existIndex ~= nil then
                table.remove(targetList, existIndex)
                table.insert(targetList, 1, pos)
                printLogDebug("monster_ai", "【warai log】[warid%d]-->怪物AI触发了敏魔克星 @%d 优先攻击 @%d", self:getWarID(), self:getWarPos(), pos)
                return targetList
              end
            end
            break
          end
        end
      end
    end
    return targetList
  else
    return targetList
  end
end
function CMonsterAI:InitMonsterTeXing()
  self.m_IsBossMonster = data_getIsNpcBoss(self:getTypeId())
  self.m_MonsterTx = {}
  local data_table = data_Monster[self:getTypeId()] or {}
  local txData = data_table.trait
  if txData ~= nil and txData ~= 0 then
    if type(txData) == "number" then
      local txId = txData
      self.m_MonsterTx[txId] = true
    elseif type(txData) == "table" then
      for _, txId in pairs(txData) do
        self.m_MonsterTx[txId] = true
      end
    end
  end
end
function CMonsterAI:PossessMonsterTeXing(txId)
  return self.m_MonsterTx[txId] == true
end
function CMonsterAI:IsBossMonster()
  return self.m_IsBossMonster
end
