if not SkillAbility then
  SkillAbility = {}
end
function SkillAbility.extend(object)
  object.skills_ = {}
  object.bdskills_ = {}
  function object:addSkill(skillId)
    if skillId == nil then
      return
    end
    local p = object.skills_[skillId]
    if p == nil then
      p = 0
      object.skills_[skillId] = p
    end
    return p
  end
  function object:getSkills()
    return object.skills_
  end
  function object:getSkillTypeList()
    local player = WarAIGetOnePlayerData(object:getWarID(), object:getPlayerId())
    local skillTypeList = {}
    if object:getType() == LOGICTYPE_PET then
      local data_table = data_Pet[object:getTypeId()]
      if data_table ~= nil and data_table.skills[1] ~= nil and data_table.skills[1] ~= 0 then
        skillTypeList = {
          data_getSkillAttrStyle(data_table.skills[1])
        }
      end
      skillTypeList[#skillTypeList + 1] = NDATTR_MOJIE
    elseif object:getType() == LOGICTYPE_HERO then
      if player:getMainHeroId() ~= object:getObjId() then
        local attr = data_getRoleSkillAttrList(object:getTypeId())
        if attr[1] == 0 then
          attr = {}
        end
        skillTypeList = attr
      else
        local lTypeId = object:getTypeId()
        local race = data_getRoleRace(lTypeId)
        local gender = data_getRoleGender(lTypeId)
        if race == RACE_REN then
          if gender == HERO_MALE then
            skillTypeList = {
              SKILLATTR_CONFUSE,
              SKILLATTR_SLEEP,
              SKILLATTR_ICE
            }
          else
            skillTypeList = {
              SKILLATTR_POISON,
              SKILLATTR_SLEEP,
              SKILLATTR_ICE
            }
          end
        elseif race == RACE_MO then
          if gender == HERO_MALE then
            skillTypeList = {
              SKILLATTR_SPEED,
              SKILLATTR_ATTACK,
              SKILLATTR_ZHEN
            }
          else
            skillTypeList = {
              SKILLATTR_PAN,
              SKILLATTR_ATTACK,
              SKILLATTR_ZHEN
            }
          end
        elseif race == RACE_XIAN then
          if gender == HERO_MALE then
            skillTypeList = {
              SKILLATTR_WIND,
              SKILLATTR_THUNDER,
              SKILLATTR_WATER
            }
          else
            skillTypeList = {
              SKILLATTR_FIRE,
              SKILLATTR_THUNDER,
              SKILLATTR_WATER
            }
          end
        elseif race == RACE_GUI then
          if gender == HERO_MALE then
            skillTypeList = {
              SKILLATTR_XIXUE,
              SKILLATTR_AIHAO,
              SKILLATTR_YIWANG
            }
          else
            skillTypeList = {
              SKILLATTR_SHUAIRUO,
              SKILLATTR_AIHAO,
              SKILLATTR_YIWANG
            }
          end
        end
      end
    end
    return skillTypeList
  end
  function object:getUseSkillList()
    local sumIndex = 3
    local skillList = {0, 0}
    local tempSkillList = object:getProperty(PROPERTY_USESKILLLIST)
    local needResetFlag = false
    local newSkillList = {}
    if tempSkillList ~= nil and type(tempSkillList) == "table" then
      local index = 0
      for _, skillId in ipairs(tempSkillList) do
        if 0 < object:getProficiency(skillId) then
          index = index + 1
          if index == sumIndex + 1 then
            needResetFlag = true
            break
          end
          newSkillList[#newSkillList + 1] = skillId
        else
          needResetFlag = true
        end
      end
      if needResetFlag then
        object:setProperty(PROPERTY_USESKILLLIST, newSkillList)
        local player = WarAIGetOnePlayerData(object:getWarID(), object:getPlayerId())
        if player and player.SaveRoleProperty then
          player:SaveRoleProperty(object:getObjId(), PROPERTY_USESKILLLIST, newSkillList, true)
        end
      end
      skillList[1] = newSkillList[1] or 0
      skillList[2] = newSkillList[2] or 0
    end
    return skillList
  end
  function object:setProficiency(skillId, proficiency)
    if skillId == nil then
      return
    end
    if object.skills_[skillId] == nil then
      object:addSkill(skillId)
    end
    object.skills_[skillId] = proficiency
  end
  function object:getProficiency(skillId)
    local p = object.skills_[skillId]
    if p == nil then
      p = 0
    end
    return p
  end
  function object:getSkillIsOpen(skillId)
    return object:getProficiency(skillId) > 0
  end
  function object:addBDSkill(skillId)
    if skillId == nil then
      return 0
    end
    local p = object.bdskills_[skillId]
    if p == nil then
      p = 0
      object.bdskills_[skillId] = p
    end
    return p
  end
  function object:getBDSkills()
    return object.bdskills_
  end
  function object:setBDProficiency(skillId, proficiency)
    if skillId == nil then
      return
    end
    if object.bdskills_[skillId] == nil then
      object:addBDSkill(skillId)
    end
    object.bdskills_[skillId] = proficiency
  end
  function object:getBDProficiency(skillId)
    local p = object.bdskills_[skillId]
    if p == nil then
      p = 0
    end
    return p
  end
  function object:getBDSkillIsOpen(skillId)
    return object:getBDProficiency(skillId) > 0
  end
  function object:getSkillSerialization()
    local cloneSkills = {}
    for k, v in pairs(object.skills_) do
      cloneSkills[k] = v
    end
    local cloneBDSkills = {}
    for k, v in pairs(object.bdskills_) do
      cloneBDSkills[k] = v
    end
    return {cloneSkills, cloneBDSkills}
  end
  function object:setSkillSerialization(proSerialization)
    object.skills_ = {}
    object.bdskills_ = {}
    if proSerialization then
      local cloneSkills = proSerialization[1] or {}
      for k, v in pairs(cloneSkills) do
        object:setProficiency(k, v)
      end
      local cloneBDSkills = proSerialization[2] or {}
      for k, v in pairs(cloneBDSkills) do
        object:setBDProficiency(k, v)
      end
    end
  end
end
