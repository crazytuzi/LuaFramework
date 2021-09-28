if not CPetAI then
  CPetAI = class("CPetAI", CRoleAI)
end
function CPetAI:ctor(warId, playerId, objId, lTypeId, pos, copyProperties)
  CPetAI.super.ctor(self, warId, playerId, objId, lTypeId, pos, copyProperties)
end
function CPetAI:UseAI()
  printLogDebug("pet_ai", "【warai log】[warid%d]-->宠物AI开始", self:getWarID())
  local petType = self:getProperty(PROPERTY_PETTYPE)
  local hasSkill = false
  local petSkillList = self:getSkills()
  local pairs = pairs
  for skillId, p in pairs(petSkillList) do
    if p > 0 then
      if data_getSkillAttrStyle(skillId) == NDATTR_MOJIE then
        hasSkill = true
        break
      end
      for _, tempSkillId in pairs(ACTIVE_PETSKILLLIST) do
        if tempSkillId == skillId then
          hasSkill = true
          break
        end
      end
    end
  end
  local petAIType = PET_AI_TYPE_PHYSICS_WITHOUT_NEIDAN
  if petType == PETTYPE_PHYSICS then
    if hasSkill then
      petAIType = PET_AI_TYPE_PHYSICS_WITH_NEIDAN
    else
      petAIType = PET_AI_TYPE_PHYSICS_WITHOUT_NEIDAN
    end
  elseif petType == PETTYPE_MAGIC then
    if hasSkill then
      petAIType = PET_AI_TYPE_MAGIC_WITH_NEIDAN
    else
      petAIType = PET_AI_TYPE_MAGIC_WITHOUT_NEIDAN
    end
  end
  local tempAITypeDict = {}
  for _, valueName in ipairs(AI_PET_VALUE_LIST) do
    tempAITypeDict[#tempAITypeDict + 1] = {
      data_AI_PET[petAIType][valueName],
      math.random(1000),
      valueName
    }
  end
  function _sort(data_A, data_B)
    if data_A == nil or data_B == nil then
      return false
    end
    local value_a = data_A[1]
    local index_a = data_A[2]
    local value_b = data_B[1]
    local index_b = data_B[2]
    if value_a ~= value_b then
      return value_a > value_b
    else
      return index_a < index_b
    end
  end
  table.sort(tempAITypeDict, _sort)
  local userPos = self:getWarPos()
  local pairs = pairs
  for _, tempData in pairs(tempAITypeDict) do
    local valueName = tempData[3]
    local value = data_AI_PET[petAIType][valueName]
    if value >= math.random(0, 100) then
      if valueName == AI_NeidanSkill_VALUE then
        printLogDebug("pet_ai", "【warai log】[warid%d]-->宠物判断为使用魂石或领悟法术", self:getWarID())
        local canUseSkillList = {}
        for skillId, p in pairs(self:getSkills()) do
          if p > 0 then
            if data_getSkillAttrStyle(skillId) == NDATTR_MOJIE then
              canUseSkillList[#canUseSkillList + 1] = skillId
            else
              for _, tempSkillId in pairs(ACTIVE_PETSKILLLIST) do
                if tempSkillId == skillId then
                  canUseSkillList[#canUseSkillList + 1] = skillId
                end
              end
            end
          end
        end
        canUseSkillList = RandomSortList(canUseSkillList)
        for _, skillID in ipairs(canUseSkillList) do
          printLogDebug("pet_ai", "【warai log】[warid%d]-->宠物AI,@%d，使用魂石或领悟法术 尝试使用%d", self:getWarID(), userPos, skillID)
          if self:JudgeCanUseSkillForAI(skillID) == true then
            local targetList = self:getRandomTargetListForAI(skillID)
            if self:UseOneSkillOnRandomTarget(skillID, targetList) ~= nil then
              printLogDebug("pet_ai", "【warai log】[warid%d]-->宠物AI,@%d，使用魂石或领悟法术%d,成功", self:getWarID(), userPos, skillID)
              return
            else
              printLogDebug("pet_ai", "【warai log】[warid%d]-->宠物AI,@%d，使用魂石或领悟法术%d,失败,没有成功的使用目标", self:getWarID(), userPos, skillID)
            end
          else
            printLogDebug("pet_ai", "【warai log】[warid%d]-->宠物AI,@%d，使用魂石或领悟法术%d,失败,无法使用", self:getWarID(), userPos, skillID)
          end
          printLogDebug("pet_ai", "【warai log】[warid%d]-->宠物AI,@%d，使用魂石或领悟法术%d,失败直接平砍", self:getWarID(), userPos, skillID)
          self:NormalAttackOneRandomEnemy()
          return
        end
        printLogDebug("pet_ai", "【warai log】[warid%d]-->宠物AI,@%d，使用魂石或领悟法术,失败", self:getWarID(), userPos)
      elseif valueName == AI_Attack_VALUE then
        printLogDebug("pet_ai", "【warai log】[warid%d]-->宠物,@%d判断为普通攻击", self:getWarID(), userPos)
        self:NormalAttackOneRandomEnemy()
        printLogDebug("pet_ai", "【warai log】[warid%d]-->宠物AI,@%d，普通攻击,成功", self:getWarID(), userPos)
        return
      elseif valueName == AI_PetSkill_VALUE then
        printLogDebug("pet_ai", "【warai log】[warid%d]-->宠物,@%d判断为使用宠物自带法术", self:getWarID(), userPos)
        local petSkillAttr
        local data_table = data_Pet[self:getTypeId()]
        if data_table ~= nil and data_table.skills[1] ~= nil and data_table.skills[1] ~= 0 then
          petSkillAttr = data_getSkillAttrStyle(data_table.skills[1])
        end
        if petSkillAttr == nil then
          printLogDebug("pet_ai", "【warai log】[warid%d]-->宠物AI,@%d，使用宠物自带法术,失败1", self:getWarID(), userPos)
        elseif self:UseOneAttrSkillOnRandomTarget(petSkillAttr) ~= nil then
          printLogDebug("pet_ai", "【warai log】[warid%d]-->宠物AI,@%d，使用宠物自带法术,成功", self:getWarID(), userPos)
          return
        else
          printLogDebug("pet_ai", "【warai log】[warid%d]-->宠物AI,@%d，使用宠物自带法术,失败2", self:getWarID(), userPos)
        end
      end
    end
  end
  printLogDebug("pet_ai", "【warai log】[warid%d]-->宠物所有判断都失败,直接平砍", self:getWarID())
  self:NormalAttackOneRandomEnemy()
  printLogDebug("pet_ai", "【warai log】[warid%d]-->宠物AI结束", self:getWarID())
end
