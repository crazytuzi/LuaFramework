if not CHeroAI then
  CHeroAI = class("CHeroAI", CRoleAI)
end
function CHeroAI:ctor(warId, playerId, objId, lTypeId, pos, copyProperties)
  CHeroAI.super.ctor(self, warId, playerId, objId, lTypeId, pos, copyProperties)
end
function CHeroAI:UseAI()
  local userPos = self:getWarPos()
  printLogDebug("hero_ai", "【warai log】[warid%d]-->英雄@%d,AI开始", self:getWarID(), userPos)
  local targetList = g_SkillAI.getEnemySideOfNoCertainEffect(self:getWarID(), userPos, {EFFECTTYPE_FROZEN})
  if targetList == nil or #targetList <= 0 then
    printLogDebug("hero_ai", "【warai log】[warid%d]-->英雄%dAI所有人都被冰住了，直接防御", self:getWarID(), userPos)
    self:DefendSelf()
    return
  end
  local attrList = self:getSkillTypeList()
  local heroType = self:getTypeId()
  if heroType == 11002 then
    attrList = {SKILLATTR_ICE, SKILLATTR_CONFUSE}
  elseif heroType == 13005 then
    attrList = {SKILLATTR_SPEED, SKILLATTR_ZHEN}
  elseif heroType == 13001 then
    attrList = {SKILLATTR_ATTACK, SKILLATTR_ZHEN}
  elseif heroType == 13009 then
    attrList = {SKILLATTR_PAN, SKILLATTR_ZHEN}
  end
  for _, attr in ipairs(attrList) do
    printLogDebug("hero_ai", "【warai log】[warid%d]-->英雄%d判断为使用%d系别法术", self:getWarID(), userPos, attr)
    if self:UseOneAttrSkillOnRandomTarget(attr) ~= nil then
      printLogDebug("hero_ai", "【warai log】[warid%d]-->英雄AI,@%d，使用法术,成功", self:getWarID(), userPos)
      return
    else
      printLogDebug("hero_ai", "【warai log】[warid%d]-->英雄AI,@%d，使用法术,失败", self:getWarID(), userPos)
    end
  end
  printLogDebug("hero_ai", "【warai log】[warid%d]-->英雄%d所有判断都失败,直接平砍", self:getWarID(), userPos)
  self:NormalAttackOneRandomEnemy()
  printLogDebug("hero_ai", "【warai log】[warid%d]-->英雄%dAI结束", self:getWarID(), userPos)
end
function CHeroAI:UseAIInBWC()
  local userPos = self:getWarPos()
  printLogDebug("hero_ai", "【warai log】[warid%d]-->比武场被打主英雄@%d,AI开始", self:getWarID(), userPos)
  local gender = self:getProperty(PROPERTY_GENDER)
  local race = self:getProperty(PROPERTY_RACE)
  local isLiliangType = true
  local lx = self:getProperty(PROPERTY_Lingxing)
  local gg = self:getProperty(PROPERTY_GenGu)
  local ll = self:getProperty(PROPERTY_LiLiang)
  local mj = self:getProperty(PROPERTY_MinJie)
  if lx >= ll or ll <= mj or gg >= ll then
    isLiliangType = false
  end
  local heroAIType = ROLE_AI_TYPE_MALE_REN
  if gender == HERO_MALE then
    if race == RACE_REN then
      if isLiliangType then
        heroAIType = ROLE_AI_TYPE_MALE_REN_LL
      else
        heroAIType = ROLE_AI_TYPE_MALE_REN
      end
    elseif race == RACE_MO then
      if isLiliangType then
        heroAIType = ROLE_AI_TYPE_MALE_MO_LL
      else
        heroAIType = ROLE_AI_TYPE_MALE_MO
      end
    elseif race == RACE_XIAN then
      if isLiliangType then
        heroAIType = ROLE_AI_TYPE_MALE_XIAN_LL
      else
        heroAIType = ROLE_AI_TYPE_MALE_XIAN
      end
    elseif race == RACE_GUI then
      if isLiliangType then
        heroAIType = ROLE_AI_TYPE_MALE_GUI_LL
      else
        heroAIType = ROLE_AI_TYPE_MALE_GUI
      end
    end
  elseif gender == HERO_FEMALE then
    if race == RACE_REN then
      if isLiliangType then
        heroAIType = ROLE_AI_TYPE_FEMALE_REN_LL
      else
        heroAIType = ROLE_AI_TYPE_FEMALE_REN
      end
    elseif race == RACE_MO then
      if isLiliangType then
        heroAIType = ROLE_AI_TYPE_FAMALE_MO_LL
      else
        heroAIType = ROLE_AI_TYPE_FAMALE_MO
      end
    elseif race == RACE_XIAN then
      if isLiliangType then
        heroAIType = ROLE_AI_TYPE_FEMALE_XIAN_LL
      else
        heroAIType = ROLE_AI_TYPE_FEMALE_XIAN
      end
    elseif race == RACE_GUI then
      if isLiliangType then
        heroAIType = ROLE_AI_TYPE_FAMALE_GUI_LL
      else
        heroAIType = ROLE_AI_TYPE_FAMALE_GUI
      end
    end
  end
  local tempAITypeDict = {}
  for _, valueName in ipairs(AI_ROLE_VALUE_LIST) do
    tempAITypeDict[#tempAITypeDict + 1] = {
      data_AI_ROLE[heroAIType][valueName],
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
  for _, tempData in pairs(tempAITypeDict) do
    local valueName = tempData[3]
    local value = data_AI_ROLE[heroAIType][valueName]
    if value >= math.random(0, 100) then
      if valueName == AI_Attack_VALUE then
        printLogDebug("hero_ai", "【warai log】[warid%d]-->比武场被打主英雄%d判断为普通攻击", self:getWarID(), userPos)
        self:NormalAttackOneRandomEnemy()
        printLogDebug("hero_ai", "【warai log】[warid%d]-->比武场被打主英雄%d，普通攻击,成功", self:getWarID(), userPos)
        return
      else
        local attr = AI_VALUENAME_2_SKILLATTRLIST[valueName]
        printLogDebug("hero_ai", "【warai log】[warid%d]-->比武场被打主英雄%d判断为使用%d系别法术", self:getWarID(), userPos, attr)
        if self:UseOneAttrSkillOnRandomTarget(attr) ~= nil then
          printLogDebug("hero_ai", "【warai log】[warid%d]-->比武场被打主英雄AI,@%d，使用法术,成功", self:getWarID(), userPos)
          return
        else
          printLogDebug("hero_ai", "【warai log】[warid%d]-->比武场被打主英雄AI,@%d，使用法术,失败", self:getWarID(), userPos)
        end
      end
    end
  end
  printLogDebug("hero_ai", "【warai log】[warid%d]-->比武场被打主英雄%d所有判断都失败,直接平砍", self:getWarID(), userPos)
  self:NormalAttackOneRandomEnemy()
  printLogDebug("hero_ai", "【warai log】[warid%d]-->比武场被打主英雄%dAI结束", self:getWarID(), userPos)
end
