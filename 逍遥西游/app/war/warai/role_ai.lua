if not CRoleAI then
  CRoleAI = class("CRoleAI", CRoleData)
end
function CRoleAI:ctor(warId, playerId, objId, lTypeId, pos, copyProperties)
  self.m_WarPos = pos
  self.m_WarID = warId
  if copyProperties == nil then
    printLogDebug("role_ai", "【warai log】[warid%d]-->CRoleAI生成错误，传入数据是空", self:getWarID())
    return
  end
  CRoleAI.super.ctor(self, playerId, objId, lTypeId, copyProperties)
  self.m_LastOperationData = {}
  self.m_AutoOperationData = nil
  EffectReceiver.extend(self)
  self:InitWarProperty()
end
function CRoleAI:InitWarProperty()
  local warProperty = {
    [PROPERTY_YINGJICHANGKONG] = 0,
    [PROPERTY_PURSUIT] = DEFINE_PETSKILL_PURSUIT_MAXTIMES,
    [PROPERTY_JIRENTIANXIANG] = 0,
    [PROPERTY_PROTECTTIMES] = DEFINE_PETSKILL_PROTECT_MAXTIMES,
    [PROPERTY_RELIVETIMES] = DEFINE_PETSKILL_RELIVE_MAXTIMES,
    [PROPERTY_PETSKILLCD] = 0,
    [PROPERTY_JUEJINGFENGSHENG] = 0,
    [PROPERTY_HUAWUMARK] = 0,
    [PROPERTY_HUAWU] = 0,
    [PROPERTY_YIYAHUANYA] = 0,
    [PROPERTY_CHUNHUIDADI] = 0,
    [PROPERTY_QINGSHENSIHAI] = 0,
    [PROPERTY_TIESHUKAIHUA] = 0,
    [PROPERTY_HUICHUNMIAOSHOU] = 0,
    [PROPERTY_YIWANGSKILL] = 0
  }
  for k, v in pairs(warProperty) do
    self:setProperty(k, v)
    self:setTempProperty(k, v)
  end
end
function CRoleAI:getWarPos()
  return self.m_WarPos
end
function CRoleAI:getWarID()
  return self.m_WarID
end
function CRoleAI:getIsMainHero()
  local mFlag = false
  if self:getPlayerId() then
    local tempPlayer = WarAIGetOnePlayerData(self:getWarID(), self:getPlayerId())
    if tempPlayer and tempPlayer:getMainHeroId() == self:getObjId() and self:getObjId() ~= nil then
      mFlag = true
    end
  end
  return mFlag
end
function CRoleAI:getCanUseSkillTypeList(skillAttrList)
  if self.skills_ == nil then
    return {}
  end
  local skillTypeList = {}
  for skillId, p in pairs(self.skills_) do
    local attrStyle = data_getSkillAttrStyle(skillId)
    if skillAttrList[attrStyle] == true and p > 0 and g_SkillAI.getSkillStyle(skillId) == SKILLSTYLE_INITIATIVE and g_SkillAI.checkUserMpOfSkill(self:getWarID(), self:getWarPos(), skillId) then
      local attrTable = skillTypeList[attrStyle]
      if attrTable == nil then
        attrTable = {}
        skillTypeList[attrStyle] = attrTable
      end
      attrTable[#attrTable + 1] = skillId
    else
    end
  end
  local function compareJieshu(skill1, skill2)
    if skill1 == nil or skill2 == nil then
      return false
    end
    local attr = data_getSkillAttr(skill1)
    local onlyOneTargetFlag = false
    local tempTargetList = {}
    if attr == SKILLATTR_PAN or attr == SKILLATTR_ATTACK or attr == SKILLATTR_SPEED or attr == SKILLATTR_NIAN then
      tempTargetList = g_SkillAI.getMySideOfNoCertainEffect(self:getWarID(), self:getWarPos(), {EFFECTTYPE_FROZEN})
    else
      tempTargetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), self:getWarPos(), {EFFECTTYPE_FROZEN})
    end
    if #tempTargetList == 1 then
      onlyOneTargetFlag = true
    end
    local jie1 = data_getSkillStep(skill1)
    local jie2 = data_getSkillStep(skill2)
    local skillp1 = self.skills_[skill1] or 0
    local skillp2 = self.skills_[skill2] or 0
    local tarNum1 = _getSkillTargetNum(skill1, skillp1, self:getType())
    local tarNum2 = _getSkillTargetNum(skill2, skillp2, self:getType())
    if onlyOneTargetFlag then
      if tarNum1 == 1 and tarNum2 > 1 then
        return true
      elseif tarNum1 > 1 and tarNum2 == 1 then
        return false
      else
        return jie1 > jie2
      end
    elseif tarNum1 == 1 and tarNum2 > 1 then
      return false
    elseif tarNum1 > 1 and tarNum2 == 1 then
      return true
    else
      return jie1 > jie2
    end
    return jie1 > jie2
  end
  for i, tempList in pairs(skillTypeList) do
    if i == NDATTR_MOJIE then
      tempList = RandomSortList(tempList)
      skillTypeList[i] = tempList
    else
      table.sort(tempList, compareJieshu)
    end
  end
  return skillTypeList
end
function CRoleAI:getOpenSkillTypeList(skillAttrList)
  if self.skills_ == nil then
    return {}
  end
  local skillTypeList = {}
  for skillId, p in pairs(self.skills_) do
    local attrStyle = data_getSkillAttrStyle(skillId)
    if skillAttrList[attrStyle] == true and p > 0 then
      local attrTable = skillTypeList[attrStyle]
      if attrTable == nil then
        attrTable = {}
        skillTypeList[attrStyle] = attrTable
      end
      attrTable[#attrTable + 1] = skillId
    else
    end
  end
  return skillTypeList
end
function CRoleAI:checkAttackTargetListWithTeXing(targetList, targetType)
  return targetList
end
function CRoleAI:NormalAttackOneRandomEnemy()
  local userPos = self:getWarPos()
  printLogDebug("role_ai", "【warai log】[warid%d]-->%d平砍随机一个敌人", self:getWarID(), userPos)
  local targetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, {EFFECTTYPE_FROZEN, EFFECTTYPE_SLEEP})
  if targetList == nil or #targetList <= 0 then
    targetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, {EFFECTTYPE_FROZEN})
    if targetList == nil or #targetList <= 0 then
      targetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, {})
    end
  end
  local canAttackTargetList = {}
  for i, pos in pairs(targetList) do
    if g_SkillAI.canSkillOnTarget(self:getWarID(), pos, SKILLTYPE_NORMALATTACK) then
      canAttackTargetList[#canAttackTargetList + 1] = pos
    end
  end
  if #canAttackTargetList == 0 then
    printLogDebug("role_ai", "【warai log】[warid%d]~~~~异常 平砍随机一个敌人，没有目标了，轮空", self:getWarID())
    return false
  end
  canAttackTargetList = RandomSortList(canAttackTargetList)
  canAttackTargetList = self:checkAttackTargetListWithTeXing(canAttackTargetList, TARGETTYPE_ENEMYSIDE)
  local targetPos = canAttackTargetList[1]
  AIUseSkillOnTarget(self:getWarID(), userPos, targetPos, SKILLTYPE_NORMALATTACK)
  printLogDebug("role_ai", "【warai log】[warid%d]-->平砍随机一个敌人，结束", self:getWarID())
  return true
end
function CRoleAI:DefendSelf()
  local userPos = self:getWarPos()
  printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d防御开始", self:getWarID(), userPos)
  AIUseSkillOnTarget(self:getWarID(), userPos, nil, SKILLTYPE_DEFEND)
  printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d防御结束", self:getWarID(), userPos)
  return true
end
function CRoleAI:RunAway(exPara)
  local userPos = self:getWarPos()
  printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d逃跑开始", self:getWarID(), userPos)
  AIUseSkillOnTarget(self:getWarID(), userPos, nil, SKILLTYPE_RUNAWAY, exPara)
  if self:getType() == LOGICTYPE_PET then
    local hero = g_WarAiInsList[self:getWarID()]:getObjectByPos(userPos - DefineRelativePetAddPos)
    if hero and hero:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
      AIUseSkillOnTarget(self:getWarID(), userPos - DefineRelativePetAddPos, nil, SKILLTYPE_RUNAWAY)
    end
  elseif self:getType() == LOGICTYPE_HERO then
    local pet = g_WarAiInsList[self:getWarID()]:getObjectByPos(userPos + DefineRelativePetAddPos)
    if pet and pet:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
      AIUseSkillOnTarget(self:getWarID(), userPos + DefineRelativePetAddPos, nil, SKILLTYPE_RUNAWAY)
    end
  end
  self:setProperty(PROPERTY_DEAD, ROLESTATE_RUNAWAY)
  if self:getType() == LOGICTYPE_PET then
    local hero = g_WarAiInsList[self:getWarID()]:getObjectByPos(userPos - DefineRelativePetAddPos)
    if hero and hero:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
      hero:setProperty(PROPERTY_DEAD, ROLESTATE_RUNAWAY)
    end
  elseif self:getType() == LOGICTYPE_HERO then
    local pet = g_WarAiInsList[self:getWarID()]:getObjectByPos(userPos + DefineRelativePetAddPos)
    if pet and pet:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
      pet:setProperty(PROPERTY_DEAD, ROLESTATE_RUNAWAY)
    end
  end
  printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d逃跑结束", self:getWarID(), userPos)
  return true
end
function CRoleAI:ChangePet(targetPos, petObj)
  local userPos = self:getWarPos()
  printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d召唤宠物,zz开始", self:getWarID(), userPos)
  if petObj == nil then
    printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d召唤参数有问题，无法召唤宠物,结束", self:getWarID(), userPos)
    return true
  end
  if g_SkillAI.canSkillOnTarget(self:getWarID(), targetPos, SKILLTYPE_BABYPET) then
    local leavePetObj = g_WarAiInsList[self:getWarID()]:getObjectByPos(targetPos)
    if leavePetObj ~= nil then
      g_WarAiInsList[self:getWarID()]:RecordOneRoleHpAndMp(targetPos)
    end
    g_WarAiInsList[self:getWarID()]:ChangeRole(targetPos, petObj, self:getProperty(PROPERTY_TEAM))
    AIUseSkillOnTarget(self:getWarID(), userPos, targetPos, SKILLTYPE_BABYPET)
    if leavePetObj ~= nil and leavePetObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
      g_SkillAI.checkWhenPetLeave(self:getWarID(), targetPos, leavePetObj)
    end
    local op = data_getRoleShapOp(petObj:getTypeId())
    if op == 0 or op == 255 then
      op = nil
    end
    local param = {
      [targetPos] = {
        objId = petObj:getObjId(),
        typeId = petObj:getTypeId(),
        hp = petObj:getProperty(PROPERTY_HP),
        maxHp = petObj:getMaxProperty(PROPERTY_HP),
        mp = petObj:getProperty(PROPERTY_MP),
        maxMp = petObj:getMaxProperty(PROPERTY_MP),
        team = self:getProperty(PROPERTY_TEAM),
        name = petObj:getProperty(PROPERTY_NAME),
        playerId = petObj:getPlayerId(),
        zs = petObj:getProperty(PROPERTY_ZHUANSHENG),
        lv = petObj:getProperty(PROPERTY_ROLELEVEL),
        hasND = petObj:HasNeidanObj(),
        op = op
      }
    }
    g_SkillAI.onCreateNewRoleOnPos(self:getWarID(), userPos, SKILLTYPE_BABYPET, param)
    g_SkillAI.checkWhenPetEnter(self:getWarID(), g_WarAiInsList[self:getWarID()]:GetCurRoundNum(), targetPos, {})
    printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d召唤宠物,结束", self:getWarID(), userPos)
  end
end
function CRoleAI:UseDrugOnTarget(targetPos, useDrugTypeId, showTipsFlag)
  local userPos = self:getWarPos()
  printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d手动战斗,对%d使用药品,开始", self:getWarID(), userPos, targetPos)
  if useDrugTypeId == nil then
    if showTipsFlag ~= false then
      g_SkillAI.formatTipSequence(self:getWarID(), userPos, SKILLTIP_LACKDRUG)
    end
    printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d手动战斗，对%d使用药品参数有问题，无法使用药品,结束", self:getWarID(), userPos, targetPos)
    return false
  end
  local playerId = self:getPlayerId()
  local player = WarAIGetOnePlayerData(self:getWarID(), self:getPlayerId())
  local drugList = player:GetItemTypeList(ITEM_LARGE_TYPE_DRUG)
  local drugNum = g_WarAiInsList[self:getWarID()]:GetDrugNum(playerId, useDrugTypeId)
  if drugNum <= 0 then
    if showTipsFlag ~= false then
      g_SkillAI.formatTipSequence(self:getWarID(), userPos, SKILLTIP_LACKDRUG)
    end
    printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d手动战斗，药品%d数量不足，无法使用药品", self:getWarID(), userPos, useDrugTypeId)
    return false
  end
  local roleObj = g_WarAiInsList[self:getWarID()]:getObjectByPos(targetPos)
  if roleObj == nil or roleObj:getType() == LOGICTYPE_HERO and roleObj:getProperty(PROPERTY_DEAD) == ROLESTATE_RUNAWAY or roleObj:getType() ~= LOGICTYPE_HERO and roleObj:getProperty(PROPERTY_DEAD) ~= ROLESTATE_LIVE then
    printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d手动战斗，使用药品,目标%d不存在或者英雄目标逃跑或者其他类型目标不是活的,修改成对自己使用", self:getWarID(), userPos, targetPos)
    targetPos = userPos
  end
  g_WarAiInsList[self:getWarID()]:DelOneDrug(playerId, useDrugTypeId)
  g_SkillAI.useDrugOnPos(self:getWarID(), userPos, targetPos, useDrugTypeId)
  printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d手动战斗,对pos%d使用药品%d", self:getWarID(), userPos, targetPos, useDrugTypeId)
  printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d手动战斗,使用药品,结束", self:getWarID(), userPos)
  return true
end
function CRoleAI:UseRandomSkillOnRandomEnemy(targetList, canUseSkillTable)
  local userPos = self:getWarPos()
  printLogDebug("role_ai", "【warai log】[warid%d]-->%d,随机使用技能", self:getWarID(), userPos)
  local skillAttrList = {}
  for key, _ in pairs(canUseSkillTable) do
    skillAttrList[#skillAttrList + 1] = key
  end
  skillAttrList = RandomSortList(skillAttrList)
  local skillList = {}
  local pairs = pairs
  for _, key in pairs(skillAttrList) do
    for _, skillId in pairs(canUseSkillTable[key]) do
      skillList[#skillList + 1] = skillId
    end
  end
  for _, tempSkillId in pairs(skillList) do
    local targetPos = self:UseOneSkillOnRandomTarget(tempSkillId, targetList)
    if targetPos ~= nil then
      return targetPos, tempSkillId
    end
  end
  printLogDebug("role_ai", "【warai log】[warid%d]-->随机使用技能，无法使用技能，失败", self:getWarID())
  return nil
end
function CRoleAI:UseOneSkillOnRandomTarget(skillId, targetList)
  local userPos = self:getWarPos()
  printLogDebug("role_ai", "【warai log】[warid%d]-->%d,使用一个技能", self:getWarID(), userPos)
  local targetType
  if skillId == SKILLTYPE_NORMALATTACK then
    targetType = TARGETTYPE_ENEMYSIDE
  else
    targetType = g_SkillAI.getSkillTargetType(skillId)
  end
  targetList = RandomSortList(targetList)
  targetList = self:checkAttackTargetListWithTeXing(targetList, targetType)
  for _, tempTargetPos in pairs(targetList) do
    local sameSide = userPos > DefineDefendPosNumberBase == (tempTargetPos > DefineDefendPosNumberBase)
    local aiCanUseFlag = true
    if g_SkillAI.getIsConfuse(self:getWarID(), userPos) then
      aiCanUseFlag = true
    elseif g_SkillAI.getIsFengMo(self:getWarID(), userPos) and sameSide then
      printLogDebug("role_ai", "【warai log】[warid%d]-->封魔情况下目标是己方，无法使用技能，失败", self:getWarID(), skillId, userPos, tempTargetPos)
      aiCanUseFlag = false
    elseif skillId == SKILLTYPE_NORMALATTACK and userPos ~= tempTargetPos then
      aiCanUseFlag = true
    elseif targetType == TARGETTYPE_SELF and userPos ~= tempTargetPos then
      printLogDebug("role_ai", "【warai log】[warid%d]-->对别人使用一个（只能对自己使用的技能），无法使用技能，失败", self:getWarID(), skillId, userPos, tempTargetPos)
      aiCanUseFlag = false
    elseif targetType == TARGETTYPE_TEAMMATE then
      if not sameSide then
        printLogDebug("role_ai", "【warai log】[warid%d]-->对敌人使用一个(只能对队友使用的技能），无法使用技能，失败", self:getWarID(), skillId, userPos, tempTargetPos)
        aiCanUseFlag = false
      elseif userPos == tempTargetPos then
        printLogDebug("role_ai", "【warai log】[warid%d]-->对自己使用一个(只能对队友使用的技能），无法使用技能，失败", self:getWarID(), skillId, userPos, tempTargetPos)
        aiCanUseFlag = false
      end
    elseif targetType == TARGETTYPE_ENEMYPET then
      if sameSide then
        printLogDebug("role_ai", "【warai log】[warid%d]-->对队友使用一个(只能对敌方召唤兽使用的技能），无法使用技能，失败", self:getWarID(), skillId, userPos, tempTargetPos)
        aiCanUseFlag = false
      else
        local petFlag = false
        local tempRole = g_WarAiInsList[self:getWarID()]:getObjectByPos(tempTargetPos)
        if tempRole and tempRole:getType() == LOGICTYPE_PET then
          petFlag = true
        end
        if not petFlag then
          printLogDebug("role_ai", "【warai log】[warid%d]-->对敌人非宠物使用一个(只能对敌方召唤兽使用的技能），无法使用技能，失败", self:getWarID(), skillId, userPos, tempTargetPos)
          aiCanUseFlag = false
        end
      end
    elseif targetType == TARGETTYPE_MYSIDEPET then
      if not sameSide then
        printLogDebug("role_ai", "【warai log】[warid%d]-->对敌方使用一个(只能对己方召唤兽使用的技能），无法使用技能，失败", self:getWarID(), skillId, userPos, tempTargetPos)
        aiCanUseFlag = false
      else
        local petFlag = false
        local tempRole = g_WarAiInsList[self:getWarID()]:getObjectByPos(tempTargetPos)
        if tempRole and tempRole:getType() == LOGICTYPE_PET then
          petFlag = true
        end
        if not petFlag then
          printLogDebug("role_ai", "【warai log】[warid%d]-->对己方非宠物使用一个(只能对己方召唤兽使用的技能），无法使用技能，失败", self:getWarID(), skillId, userPos, tempTargetPos)
          aiCanUseFlag = false
        end
      end
    elseif targetType == TARGETTYPE_ENEMYSIDE and sameSide then
      printLogDebug("role_ai", "【warai log】[warid%d]-->对队友使用一个敌对技能，无法使用技能，失败", self:getWarID(), skillId, userPos, tempTargetPos)
      aiCanUseFlag = false
    elseif targetType == TARGETTYPE_MYSIDE and not sameSide then
      printLogDebug("role_ai", "【warai log】[warid%d]-->对敌人使用一个增益技能，无法使用技能，失败", self:getWarID(), skillId, userPos, tempTargetPos)
      aiCanUseFlag = false
    end
    if aiCanUseFlag and g_SkillAI.canSkillOnTarget(self:getWarID(), tempTargetPos, skillId) == true then
      AIUseSkillOnTarget(self:getWarID(), userPos, tempTargetPos, skillId)
      if skillId ~= SKILLTYPE_NORMALATTACK then
        local playerId = self:getPlayerId()
        g_WarAiInsList[self:getWarID()]:AddSkillProficiency(playerId, userPos, skillId)
      end
      printLogDebug("role_ai", "【warai log】[warid%d]-->使用一个技能，结束", self:getWarID())
      return tempTargetPos
    end
  end
  printLogDebug("role_ai", "【warai log】[warid%d]-->使用一个技能，无法使用技能，失败", self:getWarID())
  return nil
end
function CRoleAI:UseOneAttrSkillOnRandomTarget(attr)
  local userPos = self:getWarPos()
  printLogDebug("role_ai", "【warai log】[warid%d]-->%d,随机使用一个系别%d的技能", self:getWarID(), userPos, attr)
  local skillAttrList = {
    [attr] = true
  }
  local canUseSkillTable = self:getCanUseSkillTypeList(skillAttrList)
  if attr == SKILLATTR_PAN or attr == SKILLATTR_ATTACK or attr == SKILLATTR_SPEED or attr == SKILLATTR_NIAN then
    local targetList = g_SkillAI.getMySideOfNoCertainEffect(self:getWarID(), userPos, {EFFECTTYPE_FROZEN})
    local needFlag = true
    for _, tempPos in pairs(targetList) do
      if attr == SKILLATTR_PAN then
        if _getEffectRestRound(self:getWarID(), tempPos, EFFECTTYPE_ADV_WULI) > 1 then
          needFlag = false
        end
      elseif attr == SKILLATTR_ATTACK then
        if 1 < _getEffectRestRound(self:getWarID(), tempPos, EFFECTTYPE_ADV_DAMAGE) then
          needFlag = false
        end
      elseif attr == SKILLATTR_SPEED then
        if 1 < _getEffectRestRound(self:getWarID(), tempPos, EFFECTTYPE_ADV_SPEED) then
          needFlag = false
        end
      elseif attr == SKILLATTR_NIAN and 1 < _getEffectRestRound(self:getWarID(), tempPos, EFFECTTYPE_ADV_NIAN) then
        needFlag = false
      end
    end
    if needFlag == false then
      printLogDebug("role_ai", "【warai log】[warid%d]-->%d,随机使用一个系别%d的技能,自己方有人的buff还有大于两个回合，所以不使用", self:getWarID(), userPos, attr)
      return nil
    end
    local targetPos, tempSkillId = self:UseRandomSkillOnRandomEnemy(targetList, canUseSkillTable)
    if targetPos ~= nil then
      printLogDebug("role_ai", "【warai log】[warid%d]-->%d,随机使用一个系别%d的技能,成功12", self:getWarID(), userPos, attr)
      return targetPos, tempSkillId
    else
      printLogDebug("role_ai", "【warai log】[warid%d]-->%d,随机使用一个系别%d的技能,失败1", self:getWarID(), userPos, attr)
      return nil
    end
  elseif attr == SKILLATTR_SHOUHUCANGSHENG then
    local targetList = g_SkillAI.getMyTeammateOfNoCertainEffect(self:getWarID(), userPos, {EFFECTTYPE_FROZEN})
    local needFlag = true
    for _, tempPos in pairs(targetList) do
      if 1 < _getEffectRestRound(self:getWarID(), tempPos, SKILLATTR_SHOUHUCANGSHENG) then
        needFlag = false
      end
    end
    if needFlag == false then
      printLogDebug("role_ai", "【warai log】[warid%d]-->%d,随机使用守护苍生的技能,自己方有人的buff还有大于两个回合，所以不使用", self:getWarID(), userPos)
      return nil
    end
    local targetPos, tempSkillId = self:UseRandomSkillOnRandomEnemy(targetList, canUseSkillTable)
    if targetPos ~= nil then
      printLogDebug("role_ai", "【warai log】[warid%d]-->%d,随机使用一个系别守护苍生的技能,成功12", self:getWarID(), userPos)
      return targetPos, tempSkillId
    else
      printLogDebug("role_ai", "【warai log】[warid%d]-->%d,随机使用一个系别守护苍生的技能,失败1", self:getWarID(), userPos)
      return nil
    end
  elseif attr == SKILLATTR_ICE then
    if g_WarAiInsList[self:getWarID()]:GetCurRoundNum() ~= 1 then
      printLogDebug("role_ai", "【warai log】[warid%d]-->%d,不是第一回合，不能随机使用冰技能", self:getWarID(), userPos)
      return nil
    end
    local targetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, {EFFECTTYPE_FROZEN})
    if targetList == nil or #targetList <= 1 then
      printLogDebug("role_ai", "【warai log】[warid%d]-->%d,随机使用冰技能,要判断对面是否只剩下一个（没有被冰的）人,使用失败", self:getWarID(), userPos)
      return nil
    end
    targetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, {EFFECTTYPE_FROZEN, EFFECTTYPE_SLEEP})
    if targetList == nil or #targetList <= 0 then
      targetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, {EFFECTTYPE_FROZEN})
      if targetList == nil or #targetList <= 0 then
        targetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, {})
      end
    end
    local targetPos, tempSkillId = self:UseRandomSkillOnRandomEnemy(targetList, canUseSkillTable)
    if targetPos ~= nil then
      printLogDebug("role_ai", "【warai log】[warid%d]-->%d,随机使用冰技能,成功32", self:getWarID(), userPos)
      return targetPos, tempSkillId
    else
      printLogDebug("role_ai", "【warai log】[warid%d]-->%d,随机使用冰技能,失败3", self:getWarID(), userPos)
      return nil
    end
  elseif attr == SKILLATTR_CONFUSE then
    local targetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, {EFFECTTYPE_FROZEN})
    local needFlag = true
    if #targetList == 1 then
      for _, tempPos in pairs(targetList) do
        if 1 < _getEffectRestRound(self:getWarID(), tempPos, EFFECTTYPE_CONFUSE) then
          needFlag = false
        end
      end
    end
    if needFlag == false then
      printLogDebug("role_ai", "【warai log】[warid%d]-->%d,随机使用混乱技能,对方有人没有buff,（或者只剩下一个人的buff，还有大于两个回合），所以不使用", self:getWarID(), userPos)
      return nil
    end
    if targetList == nil or #targetList <= 0 then
      targetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, {})
    end
    local targetPos, tempSkillId = self:UseRandomSkillOnRandomEnemy(targetList, canUseSkillTable)
    if targetPos ~= nil then
      printLogDebug("role_ai", "【warai log】[warid%d]-->%d,随机使用一个系别%d的技能,成功42", self:getWarID(), userPos, attr)
      return targetPos, tempSkillId
    else
      printLogDebug("role_ai", "【warai log】[warid%d]-->%d,随机使用一个系别%d的技能,失败4", self:getWarID(), userPos, attr)
      return nil
    end
  elseif attr == SKILLATTR_MINGLINGFEIZI then
    local myTeamList = g_SkillAI.getMySideOfNoCertainEffect(self:getWarID(), userPos, {})
    if myTeamList == nil or #myTeamList <= 1 then
      printLogDebug("role_ai", "【warai log】[warid%d]-->%d,随机使用冥灵妃子的技能,要判断是否只剩下自己一个人，是的话使用失败", self:getWarID(), userPos)
      return nil
    end
    local targetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, {EFFECTTYPE_FROZEN, EFFECTTYPE_SLEEP})
    if targetList == nil or #targetList <= 0 then
      targetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, {EFFECTTYPE_FROZEN})
      if targetList == nil or #targetList <= 0 then
        targetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, {})
      end
    end
    local targetPos, tempSkillId = self:UseRandomSkillOnRandomEnemy(targetList, canUseSkillTable)
    if targetPos ~= nil then
      printLogDebug("role_ai", "【warai log】[warid%d]-->%d,随机使用冥灵妃子的技能,成功22", self:getWarID(), userPos)
      return targetPos, tempSkillId
    else
      printLogDebug("role_ai", "【warai log】[warid%d]-->%d,随机使用冥灵妃子的技能,失败2", self:getWarID(), userPos)
      return nil
    end
  elseif attr == SKILLATTR_JIXIANGGUOZI then
    local myTeamList = g_SkillAI.getMySideOfNoCertainEffect(self:getWarID(), userPos, {})
    local moZuOrGuiZuFlag = false
    for _, tempPos in pairs(myTeamList) do
      local tempRole = g_WarAiInsList[self:getWarID()]:getObjectByPos(tempPos)
      if tempRole ~= nil and (tempRole:getProperty(PROPERTY_RACE) == RACE_MO or tempRole:getProperty(PROPERTY_RACE) == RACE_GUI) then
        moZuOrGuiZuFlag = true
        break
      end
    end
    if moZuOrGuiZuFlag == false then
      printLogDebug("role_ai", "【warai log】[warid%d]-->%d,随机使用吉祥果子的技能,要判断是否自方是否没有魔族，是的话使用失败", self:getWarID(), userPos)
      return nil
    end
    local targetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, {EFFECTTYPE_FROZEN, EFFECTTYPE_SLEEP})
    if targetList == nil or #targetList <= 0 then
      targetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, {EFFECTTYPE_FROZEN})
      if targetList == nil or #targetList <= 0 then
        targetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, {})
      end
    end
    local targetPos, tempSkillId = self:UseRandomSkillOnRandomEnemy(targetList, canUseSkillTable)
    if targetPos ~= nil then
      printLogDebug("role_ai", "【warai log】[warid%d]-->%d,随机使用吉祥果子的技能,成功22", self:getWarID(), userPos)
      return targetPos, tempSkillId
    else
      printLogDebug("role_ai", "【warai log】[warid%d]-->%d,随机使用吉祥果子的技能,失败2", self:getWarID(), userPos)
      return nil
    end
  else
    local targetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, {EFFECTTYPE_FROZEN, EFFECTTYPE_SLEEP})
    if targetList == nil or #targetList <= 0 then
      targetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, {EFFECTTYPE_FROZEN})
      if targetList == nil or #targetList <= 0 then
        targetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, {})
      end
    end
    local targetPos, tempSkillId = self:UseRandomSkillOnRandomEnemy(targetList, canUseSkillTable)
    if targetPos ~= nil then
      printLogDebug("role_ai", "【warai log】[warid%d]-->%d,随机使用一个系别%d的技能,成功9999", self:getWarID(), userPos, attr)
      return targetPos, tempSkillId
    else
      printLogDebug("role_ai", "【warai log】[warid%d]-->%d,随机使用一个系别%d的技能,失败9999", self:getWarID(), userPos, attr)
      return nil
    end
  end
end
function CRoleAI:UseAI()
  printLogDebug("role_ai", "[ERROR]没有实现 UseAI", self:getWarID())
end
function CRoleAI:ManualAction(pos, para)
  local aiActionType = para.aiActionType
  local targetPos = para.targetPos
  local skillId = para.skillId
  local timesupFlag = para.timesupFlag
  local autoFlag = para.autoFlag
  local changeAttackFlag = para.caFlag
  if changeAttackFlag == nil then
    changeAttackFlag = true
  end
  if autoFlag == true then
    self:SetAIAutoOperationData(para)
  end
  if aiActionType == AI_ACTION_TYPE_DEFEND then
    printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d防御放到回合前处理", self:getWarID(), pos)
  elseif aiActionType == AI_ACTION_TYPE_CATCH then
    printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d抓宠,开始", self:getWarID(), pos)
    local aiObj = g_WarAiInsList[self:getWarID()]
    if aiObj and aiObj:GetWarType() == WARTYPE_GuaJi then
      local sameSide = pos > DefineDefendPosNumberBase == (targetPos > DefineDefendPosNumberBase)
      if sameSide == false then
        g_SkillAI.catchPet(self:getWarID(), pos, targetPos)
        printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d抓宠操作完成", self:getWarID(), pos)
        return
      end
    end
    printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d抓宠,失败", self:getWarID(), pos)
  elseif aiActionType == AI_ACTION_TYPE_RUNAWAY then
    if self:RunAway() then
      return true
    end
  elseif aiActionType == AI_ACTION_TYPE_BABYPET then
    printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d召唤宠物,开始", self:getWarID(), pos)
    local playerId = self:getPlayerId()
    local aiObj = g_WarAiInsList[self:getWarID()]
    if aiObj then
      if aiObj:getIsHasWarPet(playerId, para.petId) == false then
        local tempPetObj = aiObj:getTempPetObjById(playerId, para.petId)
        if tempPetObj ~= nil then
          targetPos = pos + DefineRelativePetAddPos
          self:ChangePet(targetPos, tempPetObj)
          printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d召唤宠物,成功", self:getWarID(), pos)
          return true
        end
      else
        printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d召唤宠物,该宠物出过战", self:getWarID(), pos)
      end
    end
    printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d召唤宠物,失败", self:getWarID(), pos)
  elseif aiActionType == AI_ACTION_TYPE_USEDRUG then
    if g_SkillAI.checkSkillIsYiWang(self, SKILLTYPE_USEDRUG) then
      g_SkillAI.setTipsCanNotUseYiWangSkill(self:getWarID(), pos, self, SKILLTYPE_USEDRUG)
      printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d使用物品,失败(被遗忘)", self:getWarID(), pos)
      return true
    else
      self:UseDrugOnTarget(targetPos, para.useDrugTypeId)
    end
  elseif aiActionType == AI_ACTION_TYPE_NORMALATTACK or aiActionType == AI_ACTION_TYPE_USESKILL then
    printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d手动战斗,平砍或者使用技能,开始", self:getWarID(), pos)
    local targetType
    if skillId == SKILLTYPE_NORMALATTACK then
      targetType = TARGETTYPE_ENEMYSIDE
    else
      local canUseFlag = true
      local warRound = g_WarAiInsList[self:getWarID()]:GetCurRoundNum()
      if canUseFlag and self:getProficiency(skillId) <= 0 then
        g_SkillAI.formatTipSequence(self:getWarID(), pos, SKILLTIP_CANNOTUSESKILL)
        printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d手动战斗,使用技能%d,没有学会该技能", self:getWarID(), pos, skillId)
        canUseFlag = false
      end
      local warType = g_WarAiInsList[self:getWarID()]:GetWarType()
      if canUseFlag and g_SkillAI.checkSkillCanUseOnPVE(self:getWarID(), skillId) == false and IsPVEWarType(warType) then
        g_SkillAI.setTipsPVECanNotUse(self:getWarID(), pos, self, skillId)
        printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d手动战斗,使用技能%d,pve不能使用", self:getWarID(), pos, skillId)
        canUseFlag = false
      end
      if canUseFlag and g_SkillAI.checkSkillIsYiWang(self, skillId) then
        g_SkillAI.setTipsCanNotUseYiWangSkill(self:getWarID(), pos, self, skillId)
        printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d手动战斗,使用技能%d,技能被遗忘导致不能使用", self:getWarID(), pos, skillId)
        canUseFlag = false
      end
      if canUseFlag and g_SkillAI.checkSkillCanUseBeforeRound(self:getWarID(), warRound, pos, skillId) ~= true then
        g_SkillAI.setTipsCanNotUseBeforeRound(self:getWarID(), pos, self, skillId)
        printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d手动战斗,使用技能%d,前几个回合不能使用", self:getWarID(), pos, skillId)
        canUseFlag = false
      end
      if canUseFlag and g_SkillAI.checkCDValueOfSkill(self:getWarID(), warRound, pos, skillId) ~= true then
        g_SkillAI.setTipsLackCD(self:getWarID(), pos, self, skillId)
        printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d手动战斗,使用技能%d,cd不足", self:getWarID(), pos, skillId)
        canUseFlag = false
      end
      if canUseFlag and g_SkillAI.getOnceSkillUseFlag(self:getWarID(), pos, skillId) == true then
        g_SkillAI.setTipsHaveUsedOnceSkill(self:getWarID(), pos, self, skillId)
        printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d手动战斗,使用技能%d,只能使用一次，并且已经使用过", self:getWarID(), pos, skillId)
        canUseFlag = false
      end
      local proValue = g_SkillAI.checkNeedProsOfSkill(self:getWarID(), warRound, pos, skillId)
      if canUseFlag and proValue ~= true then
        printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d手动战斗,使用技能%d,四性或五行不足%d", self:getWarID(), pos, skillId, proValue)
        canUseFlag = false
        local warId = self:getWarID()
        if proValue == SIXING_LACK_LILIANG then
          g_SkillAI.setLackLiLiangWhenSkill(warId, pos, self, skillId)
        elseif proValue == SIXING_LACK_GENGU then
          g_SkillAI.setLackGenGuWhenSkill(warId, pos, self, skillId)
        elseif proValue == SIXING_LACK_LINGXING then
          g_SkillAI.setLackLingXingWhenSkill(warId, pos, self, skillId)
        elseif proValue == SIXING_LACK_MINJIE then
          g_SkillAI.setLackMinJieWhenSkill(warId, pos, self, skillId)
        elseif proValue == WUXING_LACK_JIN then
          g_SkillAI.setLackWxJinWhenSkill(warId, pos, self, skillId)
        elseif proValue == WUXING_LACK_MU then
          g_SkillAI.setLackWxMuWhenSkill(warId, pos, self, skillId)
        elseif proValue == WUXING_LACK_SHUI then
          g_SkillAI.setLackWxShuiWhenSkill(warId, pos, self, skillId)
        elseif proValue == WUXING_LACK_HUO then
          g_SkillAI.setLackWxHuoWhenSkill(warId, pos, self, skillId)
        elseif proValue == WUXING_LACK_TU then
          g_SkillAI.setLackWxTuWhenSkill(warId, pos, self, skillId)
        end
      end
      if canUseFlag and g_SkillAI.checkUserMpOfSkill(self:getWarID(), pos, skillId) == false then
        g_SkillAI.setTipsLackMp(self:getWarID(), pos, self, skillId)
        printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d手动战斗,使用技能%d,魔法不足", self:getWarID(), pos, skillId)
        canUseFlag = false
      end
      if canUseFlag and g_SkillAI.checkUserHpOfSkill(self:getWarID(), pos, skillId) ~= true then
        g_SkillAI.setTipsLackHp(self:getWarID(), pos, self, skillId)
        printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d手动战斗,使用技能%d,气血不足", self:getWarID(), pos, skillId)
        canUseFlag = false
      end
      if canUseFlag then
        local skillLogicType = GetObjType(skillId)
        if skillLogicType == LOGICTYPE_MARRYSKILL then
          local myPlayerId = self:getPlayerId()
          local myBLPos = g_WarAiInsList[self:getWarID()]:GetBanLvPos(myPlayerId)
          if targetPos == nil or targetPos == 0 or myBLPos == nil or myBLPos ~= targetPos then
            printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d手动战斗,使用结婚技能%d,没有目标", self:getWarID(), pos, skillId)
            canUseFlag = false
          end
        end
      end
      if canUseFlag and skillId == PETSKILL_DUOHUNSUOMING then
        local hasTarget = false
        for _, targetPos in pairs(AllWarPosList) do
          local sameSide = pos > DefineDefendPosNumberBase == (targetPos > DefineDefendPosNumberBase)
          if sameSide == false then
            local roleObj = g_WarAiInsList[self:getWarID()]:getObjectByPos(targetPos)
            if roleObj ~= nil and roleObj:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD and roleObj:getType() == LOGICTYPE_HERO then
              hasTarget = true
              break
            end
          end
        end
        if not hasTarget then
          g_SkillAI.setTipsNoTarget(self:getWarID(), pos, self, skillId)
          printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d手动战斗,使用技能夺魂索命,没有目标", self:getWarID(), pos)
          canUseFlag = false
        end
      end
      if canUseFlag and skillId == SKILL_YIHUAJIEYU then
        if targetPos == nil or targetPos == 0 then
          if autoFlag == true then
            g_SkillAI.setTipsCanNotUseSkillInAutoState(self:getWarID(), pos, self, skillId)
          end
          canUseFlag = false
        else
          local roleObj = g_WarAiInsList[self:getWarID()]:getObjectByPos(targetPos)
          if roleObj == nil or roleObj:getProperty(PROPERTY_DEAD) ~= ROLESTATE_LIVE then
            g_SkillAI.setTipsCanNotUseSkillOnDeadRole(self:getWarID(), pos, self, skillId)
            canUseFlag = false
          end
        end
      end
      if canUseFlag == false then
        if changeAttackFlag == true and autoFlag == true then
          g_SkillAI.setTipsChangeToAttack(self:getWarID(), pos, self, skillId)
          printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d手动战斗,使用技能%d,条件不满足，自动战斗并且选择了使用平砍代替", self:getWarID(), pos, skillId)
          self:NormalAttackOneRandomEnemy()
        end
        return true
      end
      targetType = g_SkillAI.getSkillTargetType(skillId)
    end
    if targetPos ~= nil or targetPos == 0 then
      printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d手动战斗,尝试使用传进来的目标", self:getWarID(), pos)
      if g_SkillAI.canSkillOnTarget(self:getWarID(), targetPos, skillId) == true then
        local changeNewTargetPos = self:UseOneSkillOnRandomTarget(skillId, {targetPos})
        if changeNewTargetPos ~= nil then
          printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d手动战斗,对传进来的目标%d平砍或者使用技能%d,成功", self:getWarID(), pos, targetPos, skillId)
          if timesupFlag ~= true then
            self:SetLastOperationData(targetType, changeNewTargetPos)
          end
          return true
        end
      end
      printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d手动战斗,对传进来的目标%d平砍或者使用技能%d,失败", self:getWarID(), pos, targetPos, skillId)
    end
    local targetList = self:getRandomTargetList(skillId)
    printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d手动战斗,平砍或者使用技能,没有目标说明是随机选目标", self:getWarID(), pos)
    local changeNewTargetPos = self:UseOneSkillOnRandomTarget(skillId, targetList)
    if changeNewTargetPos ~= nil then
      printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d手动战斗,平砍或者使用技能,随机选目标,成功", self:getWarID(), pos)
      if timesupFlag ~= true then
        self:SetLastOperationData(targetType, changeNewTargetPos)
      end
      return true
    end
    printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d手动战斗,平砍或者使用技能,没有目标说明是随机选目标,还是失效了", self:getWarID(), pos)
    printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d手动战斗,平砍或者使用技能,结束", self:getWarID(), pos)
  end
  return true
end
function CRoleAI:getRandomTargetList(skillId)
  printLogDebug("role_ai", "【warai log】[warid%d]-->getRandomTargetList", self:getWarID(), skillId)
  local userPos = self:getWarPos()
  local targetList = {}
  local skillLogicType = GetObjType(skillId)
  if skillLogicType == LOGICTYPE_MARRYSKILL then
    return targetList
  end
  if skillId == SKILL_YIHUAJIEYU then
    return targetList
  end
  if skillId == SKILLTYPE_NORMALATTACK then
    targetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, {EFFECTTYPE_FROZEN, EFFECTTYPE_SLEEP})
    if targetList == nil or #targetList <= 0 then
      targetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, {EFFECTTYPE_FROZEN})
      if targetList == nil or #targetList <= 0 then
        targetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, {})
      end
    end
    return targetList
  else
    local targetType = g_SkillAI.getSkillTargetType(skillId)
    local attr = data_getSkillAttr(skillId)
    if attr == SKILLATTR_PAN or attr == SKILLATTR_ATTACK or attr == SKILLATTR_SPEED or attr == SKILLATTR_NIAN then
      local noCertainEffect = {}
      if attr == SKILLATTR_PAN then
        noCertainEffect = {
          EFFECTTYPE_FROZEN,
          EFFECTTYPE_ADV_WULI,
          EFFECTTYPE_ADV_RENZU,
          EFFECTTYPE_ADV_XIANZU
        }
      elseif attr == SKILLATTR_ATTACK then
        noCertainEffect = {EFFECTTYPE_FROZEN, EFFECTTYPE_ADV_DAMAGE}
      elseif attr == SKILLATTR_SPEED then
        noCertainEffect = {EFFECTTYPE_FROZEN, EFFECTTYPE_ADV_SPEED}
      elseif attr == SKILLATTR_NIAN then
        noCertainEffect = {EFFECTTYPE_FROZEN, EFFECTTYPE_ADV_NIAN}
      end
      targetList = g_SkillAI.getMySideOfNoCertainEffect(self:getWarID(), userPos, noCertainEffect)
      if targetList == nil or #targetList <= 0 then
        targetList = g_SkillAI.getMySideOfNoCertainEffect(self:getWarID(), userPos, {EFFECTTYPE_FROZEN})
        if targetList == nil or #targetList <= 0 then
          targetList = g_SkillAI.getMySideOfNoCertainEffect(self:getWarID(), userPos, {})
        end
      end
      return targetList
    end
    if attr == SKILLATTR_SHOUHUCANGSHENG then
      local noCertainEffect = {EFFECTTYPE_FROZEN, EFFECTTYPE_SHOUHUCANGSHENG}
      targetList = g_SkillAI.getMyTeammateOfNoCertainEffect(self:getWarID(), userPos, noCertainEffect)
      if targetList == nil or #targetList <= 0 then
        targetList = g_SkillAI.getMyTeammateOfNoCertainEffect(self:getWarID(), userPos, {EFFECTTYPE_FROZEN})
        if targetList == nil or #targetList <= 0 then
          targetList = g_SkillAI.getMyTeammateOfNoCertainEffect(self:getWarID(), userPos, {})
        end
      end
      return targetList
    end
    if attr == SKILLATTR_MINGLINGFEIZI or attr == SKILLATTR_JIXIANGGUOZI then
      local noCertainEffect = {}
      if attr == SKILLATTR_MINGLINGFEIZI then
        noCertainEffect = {
          EFFECTTYPE_FROZEN,
          EFFECTTYPE_SLEEP,
          EFFECTTYPE_DEC_WULI,
          EFFECTTYPE_DEC_RENZU,
          EFFECTTYPE_DEC_XIANZU
        }
      elseif attr == SKILLATTR_JIXIANGGUOZI then
        noCertainEffect = {
          EFFECTTYPE_FROZEN,
          EFFECTTYPE_SLEEP,
          EFFECTTYPE_DEC_ZHEN
        }
      end
      targetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, noCertainEffect)
      if targetList == nil or #targetList <= 0 then
        targetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, {EFFECTTYPE_FROZEN, EFFECTTYPE_SLEEP})
        if targetList == nil or #targetList <= 0 then
          targetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, {EFFECTTYPE_FROZEN})
          if targetList == nil or #targetList <= 0 then
            targetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, {})
          end
        end
      end
      return targetList
    end
    if skillId == PETSKILL_HUIGEHUIRI or skillId == PETSKILL_TIESHUKAIHUA then
      targetList = {}
      local targetList_ex = {}
      local minHp
      for _, targetPos in pairs(AllWarPosList) do
        local sameSide = userPos > DefineDefendPosNumberBase == (targetPos > DefineDefendPosNumberBase)
        if sameSide == true then
          local roleObj = g_WarAiInsList[self:getWarID()]:getObjectByPos(targetPos)
          if roleObj ~= nil and (roleObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE or roleObj:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD and roleObj:getType() == LOGICTYPE_HERO) then
            targetList_ex[#targetList_ex + 1] = targetPos
            local hp = roleObj:getProperty(PROPERTY_HP)
            local maxhp = roleObj:getMaxProperty(PROPERTY_HP)
            if hp < maxhp then
              if minHp == nil then
                targetList = {targetPos}
                minHp = hp
              elseif minHp == hp then
                targetList[#targetList + 1] = targetPos
              elseif hp < minHp then
                targetList = {targetPos}
                minHp = hp
              end
            end
          end
        end
      end
      if #targetList > 0 then
        targetList = RandomSortList(targetList)
        return targetList
      else
        targetList_ex = RandomSortList(targetList_ex)
        return targetList_ex
      end
    end
    if skillId == PETSKILL_CHUNNUANHUAKAI then
      targetList = {}
      local targetList_ex = {}
      local pairs = pairs
      for _, targetPos in pairs(AllWarPosList) do
        local sameSide = userPos > DefineDefendPosNumberBase == (targetPos > DefineDefendPosNumberBase)
        if sameSide == true then
          local roleObj = g_WarAiInsList[self:getWarID()]:getObjectByPos(targetPos)
          if roleObj ~= nil and roleObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and roleObj:getType() == LOGICTYPE_PET then
            targetList_ex[#targetList_ex + 1] = targetPos
            local warRound = g_WarAiInsList[self:getWarID()]:GetCurRoundNum()
            for petSkillId, p in pairs(roleObj:getSkills()) do
              if p > 0 and g_SkillAI.checkSkillCanUseBeforeRound(self:getWarID(), warRound, targetPos, petSkillId) == true and g_SkillAI.checkCDValueOfSkill(self:getWarID(), warRound, targetPos, petSkillId) ~= true then
                targetList[#targetList + 1] = targetPos
                break
              end
            end
          end
        end
      end
      if #targetList > 0 then
        targetList = RandomSortList(targetList)
        return targetList
      else
        targetList_ex = RandomSortList(targetList_ex)
        return targetList_ex
      end
    end
    if skillId == PETSKILL_MIAOBISHENGHUA then
      targetList = {}
      local targetList_ex = {}
      local pairs = pairs
      for _, targetPos in pairs(AllWarPosList) do
        local sameSide = userPos > DefineDefendPosNumberBase == (targetPos > DefineDefendPosNumberBase)
        if sameSide == true then
          local roleObj = g_WarAiInsList[self:getWarID()]:getObjectByPos(targetPos)
          if roleObj ~= nil and roleObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
            targetList_ex[#targetList_ex + 1] = targetPos
            local effectList = roleObj:getEffects()
            for effectID, effectInfo in pairs(effectList) do
              if EFFECTBUFF_MIAOBISHENGHUA_CLEAR[effectID] ~= nil then
                targetList[#targetList + 1] = targetPos
                break
              end
            end
          end
        end
      end
      if #targetList > 0 then
        targetList = RandomSortList(targetList)
        return targetList
      else
        targetList_ex = RandomSortList(targetList_ex)
        return targetList_ex
      end
    end
    if skillId == PETSKILL_DUOHUNSUOMING then
      targetList = {}
      for _, targetPos in pairs(AllWarPosList) do
        local sameSide = userPos > DefineDefendPosNumberBase == (targetPos > DefineDefendPosNumberBase)
        if sameSide == false then
          local roleObj = g_WarAiInsList[self:getWarID()]:getObjectByPos(targetPos)
          if roleObj ~= nil and roleObj:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD and roleObj:getType() == LOGICTYPE_HERO then
            targetList[#targetList + 1] = targetPos
          end
        end
      end
      targetList = RandomSortList(targetList)
      return targetList
    end
    if targetType == TARGETTYPE_ENEMYSIDE then
      targetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, {EFFECTTYPE_FROZEN, EFFECTTYPE_SLEEP})
      if targetList == nil or #targetList <= 0 then
        targetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, {EFFECTTYPE_FROZEN})
        if targetList == nil or #targetList <= 0 then
          targetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, {})
        end
      end
      return targetList
    elseif targetType == TARGETTYPE_MYSIDE then
      targetList = g_SkillAI.getMySideOfNoCertainEffect(self:getWarID(), userPos, {})
      return targetList
    elseif targetType == TARGETTYPE_TEAMMATE then
      targetList = g_SkillAI.getMySideOfNoCertainEffect(self:getWarID(), userPos, {})
      local newTargetList = {}
      for _, tempTargetPos in pairs(targetList) do
        if tempTargetPos ~= userPos then
          newTargetList[#newTargetList + 1] = tempTargetPos
        end
      end
      return newTargetList
    elseif targetType == TARGETTYPE_SELF then
      return {userPos}
    elseif targetType == TARGETTYPE_ENEMYPET then
      local newTargetList = {}
      local pairs = pairs
      for _, effList in ipairs({
        {EFFECTTYPE_FROZEN, EFFECTTYPE_SLEEP},
        {EFFECTTYPE_FROZEN},
        {}
      }) do
        if #newTargetList > 0 then
          break
        end
        targetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, effList)
        for _, tempTargetPos in pairs(targetList) do
          local tempRole = g_WarAiInsList[self:getWarID()]:getObjectByPos(tempTargetPos)
          if tempRole and tempRole:getType() == LOGICTYPE_PET then
            newTargetList[#newTargetList + 1] = tempTargetPos
          end
        end
      end
      return newTargetList
    elseif targetType == TARGETTYPE_MYSIDEPET then
      targetList = g_SkillAI.getMySideOfNoCertainEffect(self:getWarID(), userPos, {})
      local newTargetList = {}
      for _, tempTargetPos in pairs(targetList) do
        local tempRole = g_WarAiInsList[self:getWarID()]:getObjectByPos(tempTargetPos)
        if tempRole and tempRole:getType() == LOGICTYPE_PET then
          newTargetList[#newTargetList + 1] = tempTargetPos
        end
      end
      return newTargetList
    end
  end
  return targetList
end
function CRoleAI:getRandomTargetListForAI(skillId)
  printLogDebug("role_ai", "【warai log】[warid%d]-->getRandomTargetListForAI", self:getWarID(), skillId)
  local userPos = self:getWarPos()
  local targetList = {}
  if skillId == SKILLTYPE_NORMALATTACK then
    targetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, {EFFECTTYPE_FROZEN, EFFECTTYPE_SLEEP})
    if targetList == nil or #targetList <= 0 then
      targetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, {EFFECTTYPE_FROZEN})
      if targetList == nil or #targetList <= 0 then
        targetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, {})
      end
    end
    return targetList
  else
    local targetType = g_SkillAI.getSkillTargetType(skillId)
    local attr = data_getSkillAttr(skillId)
    if attr == SKILLATTR_PAN or attr == SKILLATTR_ATTACK or attr == SKILLATTR_SPEED or attr == SKILLATTR_NIAN then
      local noCertainEffect = {}
      if attr == SKILLATTR_PAN then
        noCertainEffect = {
          EFFECTTYPE_FROZEN,
          EFFECTTYPE_ADV_WULI,
          EFFECTTYPE_ADV_RENZU,
          EFFECTTYPE_ADV_XIANZU
        }
      elseif attr == SKILLATTR_ATTACK then
        noCertainEffect = {EFFECTTYPE_FROZEN, EFFECTTYPE_ADV_DAMAGE}
      elseif attr == SKILLATTR_SPEED then
        noCertainEffect = {EFFECTTYPE_FROZEN, EFFECTTYPE_ADV_SPEED}
      elseif attr == SKILLATTR_NIAN then
        noCertainEffect = {EFFECTTYPE_FROZEN, EFFECTTYPE_ADV_NIAN}
      end
      targetList = g_SkillAI.getMySideOfNoCertainEffect(self:getWarID(), userPos, noCertainEffect)
      if targetList == nil or #targetList <= 0 then
        targetList = g_SkillAI.getMySideOfNoCertainEffect(self:getWarID(), userPos, {EFFECTTYPE_FROZEN})
        if targetList == nil or #targetList <= 0 then
          targetList = g_SkillAI.getMySideOfNoCertainEffect(self:getWarID(), userPos, {})
        end
      end
      return targetList
    end
    if attr == SKILLATTR_SHOUHUCANGSHENG then
      local noCertainEffect = {EFFECTTYPE_FROZEN, EFFECTTYPE_SHOUHUCANGSHENG}
      targetList = g_SkillAI.getMyTeammateOfNoCertainEffect(self:getWarID(), userPos, noCertainEffect)
      if targetList == nil or #targetList <= 0 then
        targetList = g_SkillAI.getMyTeammateOfNoCertainEffect(self:getWarID(), userPos, {EFFECTTYPE_FROZEN})
        if targetList == nil or #targetList <= 0 then
          targetList = g_SkillAI.getMyTeammateOfNoCertainEffect(self:getWarID(), userPos, {})
        end
      end
      return targetList
    end
    if attr == SKILLATTR_MINGLINGFEIZI or attr == SKILLATTR_JIXIANGGUOZI then
      local noCertainEffect = {}
      if attr == SKILLATTR_MINGLINGFEIZI then
        noCertainEffect = {
          EFFECTTYPE_FROZEN,
          EFFECTTYPE_SLEEP,
          EFFECTTYPE_DEC_WULI,
          EFFECTTYPE_DEC_RENZU,
          EFFECTTYPE_DEC_XIANZU
        }
      elseif attr == SKILLATTR_JIXIANGGUOZI then
        noCertainEffect = {
          EFFECTTYPE_FROZEN,
          EFFECTTYPE_SLEEP,
          EFFECTTYPE_DEC_ZHEN
        }
      end
      targetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, noCertainEffect)
      if targetList == nil or #targetList <= 0 then
        targetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, {EFFECTTYPE_FROZEN, EFFECTTYPE_SLEEP})
        if targetList == nil or #targetList <= 0 then
          targetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, {EFFECTTYPE_FROZEN})
          if targetList == nil or #targetList <= 0 then
            targetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, {})
          end
        end
      end
      return targetList
    end
    if skillId == SKILL_YIHUAJIEYU then
      local roleObj = g_WarAiInsList[self:getWarID()]:getObjectByPos(targetPos)
      if roleObj ~= nil then
        local checkEffects = {
          EFFECTTYPE_CONFUSE,
          EFFECTTYPE_SLEEP,
          EFFECTTYPE_FROZEN,
          EFFECTTYPE_YIWANG,
          EFFECTTYPE_POISON,
          EFFECTTYPE_SHUAIRUO
        }
        if g_SkillAI.getRoleIsInEffect(roleObj, checkEffects) then
          targetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, checkEffects)
        else
          targetList = g_SkillAI.getMyTeammateOfCertainEffect(self:getWarID(), userPos, checkEffects)
        end
      end
      return targetList
    end
    if skillId == PETSKILL_HUIGEHUIRI or skillId == PETSKILL_TIESHUKAIHUA then
      targetList = {}
      local minHp
      for _, targetPos in pairs(AllWarPosList) do
        local sameSide = userPos > DefineDefendPosNumberBase == (targetPos > DefineDefendPosNumberBase)
        if sameSide == true then
          local roleObj = g_WarAiInsList[self:getWarID()]:getObjectByPos(targetPos)
          if roleObj ~= nil and (roleObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE or roleObj:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD and roleObj:getType() == LOGICTYPE_HERO) then
            local hp = roleObj:getProperty(PROPERTY_HP)
            local maxhp = roleObj:getMaxProperty(PROPERTY_HP)
            if hp < maxhp then
              if minHp == nil then
                targetList = {targetPos}
                minHp = hp
              elseif minHp == hp then
                targetList[#targetList + 1] = targetPos
              elseif hp < minHp then
                targetList = {targetPos}
                minHp = hp
              end
            end
          end
        end
      end
      targetList = RandomSortList(targetList)
      return targetList
    end
    if skillId == PETSKILL_CHUNNUANHUAKAI then
      targetList = {}
      local pairs = pairs
      for _, targetPos in pairs(AllWarPosList) do
        local sameSide = userPos > DefineDefendPosNumberBase == (targetPos > DefineDefendPosNumberBase)
        if sameSide == true then
          local roleObj = g_WarAiInsList[self:getWarID()]:getObjectByPos(targetPos)
          if roleObj ~= nil and roleObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and roleObj:getType() == LOGICTYPE_PET then
            local warRound = g_WarAiInsList[self:getWarID()]:GetCurRoundNum()
            for petSkillId, p in pairs(roleObj:getSkills()) do
              if p > 0 and g_SkillAI.checkSkillCanUseBeforeRound(self:getWarID(), warRound, targetPos, petSkillId) == true and g_SkillAI.checkCDValueOfSkill(self:getWarID(), warRound, targetPos, petSkillId) ~= true then
                targetList[#targetList + 1] = targetPos
                break
              end
            end
          end
        end
      end
      targetList = RandomSortList(targetList)
      return targetList
    end
    if skillId == PETSKILL_MIAOBISHENGHUA then
      targetList = {}
      local pairs = pairs
      for _, targetPos in pairs(AllWarPosList) do
        local sameSide = userPos > DefineDefendPosNumberBase == (targetPos > DefineDefendPosNumberBase)
        if sameSide == true then
          local roleObj = g_WarAiInsList[self:getWarID()]:getObjectByPos(targetPos)
          if roleObj ~= nil and roleObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
            local effectList = roleObj:getEffects()
            for effectID, effectInfo in pairs(effectList) do
              if EFFECTBUFF_MIAOBISHENGHUA_CLEAR[effectID] ~= nil then
                targetList[#targetList + 1] = targetPos
                break
              end
            end
          end
        end
      end
      targetList = RandomSortList(targetList)
      return targetList
    end
    if skillId == PETSKILL_DUOHUNSUOMING then
      targetList = {}
      for _, targetPos in pairs(AllWarPosList) do
        local sameSide = userPos > DefineDefendPosNumberBase == (targetPos > DefineDefendPosNumberBase)
        if sameSide == false then
          local roleObj = g_WarAiInsList[self:getWarID()]:getObjectByPos(targetPos)
          if roleObj ~= nil and roleObj:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD and roleObj:getType() == LOGICTYPE_HERO then
            targetList[#targetList + 1] = targetPos
          end
        end
      end
      targetList = RandomSortList(targetList)
      return targetList
    end
    if targetType == TARGETTYPE_ENEMYSIDE then
      targetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, {EFFECTTYPE_FROZEN, EFFECTTYPE_SLEEP})
      if targetList == nil or #targetList <= 0 then
        targetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, {EFFECTTYPE_FROZEN})
        if targetList == nil or #targetList <= 0 then
          targetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, {})
        end
      end
      return targetList
    elseif targetType == TARGETTYPE_MYSIDE then
      targetList = g_SkillAI.getMySideOfNoCertainEffect(self:getWarID(), userPos, {})
      return targetList
    elseif targetType == TARGETTYPE_TEAMMATE then
      targetList = g_SkillAI.getMySideOfNoCertainEffect(self:getWarID(), userPos, {})
      local newTargetList = {}
      for _, tempTargetPos in pairs(targetList) do
        if tempTargetPos ~= userPos then
          newTargetList[#newTargetList + 1] = tempTargetPos
        end
      end
      return newTargetList
    elseif targetType == TARGETTYPE_SELF then
      return {userPos}
    elseif targetType == TARGETTYPE_ENEMYPET then
      local newTargetList = {}
      for _, effList in ipairs({
        {EFFECTTYPE_FROZEN, EFFECTTYPE_SLEEP},
        {EFFECTTYPE_FROZEN},
        {}
      }) do
        if #newTargetList > 0 then
          break
        end
        targetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, effList)
        for _, tempTargetPos in pairs(targetList) do
          local tempRole = g_WarAiInsList[self:getWarID()]:getObjectByPos(tempTargetPos)
          if tempRole and tempRole:getType() == LOGICTYPE_PET then
            newTargetList[#newTargetList + 1] = tempTargetPos
          end
        end
      end
      return newTargetList
    elseif targetType == TARGETTYPE_MYSIDEPET then
      targetList = g_SkillAI.getMySideOfNoCertainEffect(self:getWarID(), userPos, {})
      local newTargetList = {}
      for _, tempTargetPos in pairs(targetList) do
        local tempRole = g_WarAiInsList[self:getWarID()]:getObjectByPos(tempTargetPos)
        if tempRole and tempRole:getType() == LOGICTYPE_PET then
          newTargetList[#newTargetList + 1] = tempTargetPos
        end
      end
      return newTargetList
    end
  end
  return targetList
end
function CRoleAI:JudgeCanUseSkillForAI(skillId)
  local pos = self:getWarPos()
  printLogDebug("role_ai", "【warai log】[warid%d]-->JudgeCanUseSkillForAI角色%dAI,使用技能%d", self:getWarID(), pos, skillId)
  local canUseFlag = true
  local warRound = g_WarAiInsList[self:getWarID()]:GetCurRoundNum()
  if canUseFlag and self:getProficiency(skillId) <= 0 then
    printLogDebug("role_ai", "【warai log】[warid%d]-->角色%dAI,使用技能%d,没有学会该技能", self:getWarID(), pos, skillId)
    canUseFlag = false
  end
  local warType = g_WarAiInsList[self:getWarID()]:GetWarType()
  if canUseFlag and g_SkillAI.checkSkillCanUseOnPVE(self:getWarID(), skillId) == false and IsPVEWarType(warType) then
    printLogDebug("role_ai", "【warai log】[warid%d]-->角色%dAI,使用技能%d,pve不能使用", self:getWarID(), pos, skillId)
    canUseFlag = false
  end
  if canUseFlag and g_SkillAI.checkSkillIsYiWang(self, skillId) then
    printLogDebug("role_ai", "【warai log】[warid%d]-->角色%dAI,使用技能%d,技能被遗忘导致不能使用", self:getWarID(), pos, skillId)
    canUseFlag = false
  end
  if canUseFlag and g_SkillAI.checkSkillCanUseBeforeRound(self:getWarID(), warRound, pos, skillId) ~= true then
    printLogDebug("role_ai", "【warai log】[warid%d]-->角色%dAI,使用技能%d,前几个回合不能使用", self:getWarID(), pos, skillId)
    canUseFlag = false
  end
  if canUseFlag and g_SkillAI.checkCDValueOfSkill(self:getWarID(), warRound, pos, skillId) ~= true then
    printLogDebug("role_ai", "【warai log】[warid%d]-->角色%dAI,使用技能%d,cd不足", self:getWarID(), pos, skillId)
    canUseFlag = false
  end
  if canUseFlag and g_SkillAI.getOnceSkillUseFlag(self:getWarID(), pos, skillId) == true then
    printLogDebug("role_ai", "【warai log】[warid%d]-->角色%dAI,使用技能%d,只能使用一次，并且已经使用过", self:getWarID(), pos, skillId)
    canUseFlag = false
  end
  local proValue = g_SkillAI.checkNeedProsOfSkill(self:getWarID(), warRound, pos, skillId)
  if canUseFlag and proValue ~= true then
    printLogDebug("role_ai", "【warai log】[warid%d]-->角色%dAI,使用技能%d,四性或者五行不足%d", self:getWarID(), pos, skillId, proValue)
    canUseFlag = false
  end
  if canUseFlag and g_SkillAI.checkUserMpOfSkill(self:getWarID(), pos, skillId) == false then
    printLogDebug("role_ai", "【warai log】[warid%d]-->角色%dAI,使用技能%d,魔法不足", self:getWarID(), pos, skillId)
    canUseFlag = false
  end
  if canUseFlag and g_SkillAI.checkUserHpOfSkill(self:getWarID(), pos, skillId) ~= true then
    printLogDebug("role_ai", "【warai log】[warid%d]-->角色%dAI,使用技能%d,气血不足", self:getWarID(), pos, skillId)
    canUseFlag = false
  end
  if canUseFlag and skillId == PETSKILL_DUOHUNSUOMING then
    local hasTarget = false
    for _, targetPos in pairs(AllWarPosList) do
      local sameSide = pos > DefineDefendPosNumberBase == (targetPos > DefineDefendPosNumberBase)
      if sameSide == false then
        local roleObj = g_WarAiInsList[self:getWarID()]:getObjectByPos(targetPos)
        if roleObj ~= nil and roleObj:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD and roleObj:getType() == LOGICTYPE_HERO then
          hasTarget = true
          break
        end
      end
    end
    if not hasTarget then
      printLogDebug("role_ai", "【warai log】[warid%d]-->角色%dAI,使用技能夺魂索命,没有目标", self:getWarID(), pos)
      canUseFlag = false
    end
  end
  return canUseFlag
end
function CRoleAI:ConfuseAttack()
  local userPos = self:getWarPos()
  printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d处于混乱中,随便选一个角色平砍", self:getWarID(), userPos)
  local tempTargetList = {}
  local hurtTeammateValue = 50
  local hitSelfFlag = hurtTeammateValue >= math.random(1, 100)
  if hitSelfFlag then
    local tempList = g_SkillAI.getMySideOfNoCertainEffect(self:getWarID(), userPos, {EFFECTTYPE_FROZEN, EFFECTTYPE_STEALTH})
    for _, tempPos in pairs(tempList) do
      if tempPos ~= userPos then
        tempTargetList[#tempTargetList + 1] = tempPos
      end
    end
  end
  if #tempTargetList <= 0 then
    local tempList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, {EFFECTTYPE_FROZEN, EFFECTTYPE_STEALTH})
    for _, tempPos in pairs(tempList) do
      if tempPos ~= userPos then
        tempTargetList[#tempTargetList + 1] = tempPos
      end
    end
  end
  if hitSelfFlag then
    if #tempTargetList <= 0 then
      local tempList = g_SkillAI.getMySideOfNoCertainEffect(self:getWarID(), userPos, {EFFECTTYPE_STEALTH})
      for _, tempPos in pairs(tempList) do
        if tempPos ~= userPos then
          tempTargetList[#tempTargetList + 1] = tempPos
        end
      end
    end
    if #tempTargetList <= 0 then
      local tempList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, {EFFECTTYPE_STEALTH})
      for _, tempPos in pairs(tempList) do
        if tempPos ~= userPos then
          tempTargetList[#tempTargetList + 1] = tempPos
        end
      end
    end
  else
    if #tempTargetList <= 0 then
      local tempList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, {EFFECTTYPE_STEALTH})
      for _, tempPos in pairs(tempList) do
        if tempPos ~= userPos then
          tempTargetList[#tempTargetList + 1] = tempPos
        end
      end
    end
    if #tempTargetList <= 0 then
      local tempList = g_SkillAI.getMySideOfNoCertainEffect(self:getWarID(), userPos, {EFFECTTYPE_STEALTH})
      for _, tempPos in pairs(tempList) do
        if tempPos ~= userPos then
          tempTargetList[#tempTargetList + 1] = tempPos
        end
      end
    end
  end
  tempTargetList = RandomSortList(tempTargetList)
  for _, tempTargetPos in pairs(tempTargetList) do
    if g_SkillAI.canSkillOnTarget(self:getWarID(), tempTargetPos, SKILLTYPE_NORMALATTACK) == true then
      AIUseSkillOnTarget(self:getWarID(), userPos, tempTargetPos, SKILLTYPE_NORMALATTACK)
      printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d处于混乱中,选%d平砍,结束", self:getWarID(), userPos, tempTargetPos)
      return
    end
  end
  printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d处于混乱中,选不到人平砍，轮空", self:getWarID(), userPos)
  return
end
function CRoleAI:FengMoAttack(targetPos)
  local userPos = self:getWarPos()
  if targetPos ~= nil then
  else
    if userPos > DefineDefendPosNumberBase == (targetPos > DefineDefendPosNumberBase) then
      targetPos = nil
  end
  else
    local roleObj = g_WarAiInsList[self:getWarID()]:getObjectByPos(targetPos)
    if roleObj == nil or roleObj:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD or g_SkillAI.getIsStealth(self:getWarID(), targetPos) then
      targetPos = nil
    end
  end
  local tempTargetList = {}
  if targetPos == nil then
    local tempList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, {EFFECTTYPE_FROZEN, EFFECTTYPE_STEALTH})
    for _, tempPos in pairs(tempList) do
      if tempPos ~= userPos then
        tempTargetList[#tempTargetList + 1] = tempPos
      end
    end
    if #tempTargetList <= 0 then
      local tempList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, {EFFECTTYPE_STEALTH})
      for _, tempPos in pairs(tempList) do
        if tempPos ~= userPos then
          tempTargetList[#tempTargetList + 1] = tempPos
        end
      end
    end
  else
    tempTargetList = {targetPos}
  end
  tempTargetList = RandomSortList(tempTargetList)
  for _, tempTargetPos in pairs(tempTargetList) do
    if g_SkillAI.canSkillOnTarget(self:getWarID(), tempTargetPos, SKILLTYPE_NORMALATTACK) == true then
      AIUseSkillOnTarget(self:getWarID(), userPos, tempTargetPos, SKILLTYPE_NORMALATTACK)
      printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d处于封魔中,选%d平砍,结束", self:getWarID(), userPos, tempTargetPos)
      return
    end
  end
  printLogDebug("role_ai", "【warai log】[warid%d]-->角色%d处于封魔中,选不到人平砍，轮空", self:getWarID(), userPos)
  return
end
function CRoleAI:SetLastOperationData(targetType, pos)
  do return end
  local userPos = self:getWarPos()
  local sameSide = userPos > DefineDefendPosNumberBase == (pos > DefineDefendPosNumberBase)
  if targetType == TARGETTYPE_ENEMYSIDE and sameSide == true then
    return
  end
  self.m_LastOperationData[targetType] = pos
end
function CRoleAI:SetAIAutoOperationData(actionData)
  printLogDebug("role_ai", "【warai log】[warid%d]-->角色pos%d  SetAIAutoOperationData", self:getWarID(), self:getWarPos())
  print_lua_table(actionData)
  self.m_AutoOperationData = DeepCopyTable(actionData)
end
function CRoleAI:GetAIAutoOperationData()
  printLogDebug("role_ai", "【warai log】[warid%d]-->角色pos%d  GetAIAutoOperationData", self:getWarID(), self:getWarPos())
  if self.m_AutoOperationData == nil then
    local autoData = self:getProperty(PROPERTY_WARAUTOSKILL) or 0
    if autoData == 0 then
      return nil
    elseif autoData == 10 then
      return {
        aiActionType = AI_ACTION_TYPE_NORMALATTACK,
        targetPos = 0,
        skillId = SKILLTYPE_NORMALATTACK
      }
    elseif autoData == 20 then
      return {aiActionType = AI_ACTION_TYPE_DEFEND}
    else
      local skillId = math.floor(autoData / 10)
      if 0 < self:getProficiency(skillId) then
        local caFlagNum = autoData % 10
        local caFlag = false
        if caFlagNum == 1 then
          caFlag = true
        end
        return {
          aiActionType = AI_ACTION_TYPE_USESKILL,
          targetPos = 0,
          skillId = skillId,
          caFlag = caFlag
        }
      else
        return {
          aiActionType = AI_ACTION_TYPE_NORMALATTACK,
          targetPos = 0,
          skillId = SKILLTYPE_NORMALATTACK
        }
      end
    end
  end
  return self.m_AutoOperationData
end
