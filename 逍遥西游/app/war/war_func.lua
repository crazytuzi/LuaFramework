function CalculateMainTotemKang(totemId, bpOffer)
  if totemId == nil or totemId == 0 then
    return nil, 0
  end
  local kangPro = BangPaiTotem_2_Kang_New[totemId]
  if kangPro == nil then
    return nil, 0
  end
  local data = data_OrgTotem[totemId] or {}
  local k = data.MainKLimit or 0
  local value = k * math.min(bpOffer / 3000000, 1)
  return kangPro, value
end
function CalculateFuTotemKang(totemId, bpOffer)
  if totemId == nil or totemId == 0 then
    return nil, 0
  end
  local kangPro = BangPaiTotem_2_Kang_New[totemId]
  if kangPro == nil then
    return nil, 0
  end
  local data = data_OrgTotem[totemId] or {}
  local k = data.FuKLimit or 0
  local value = k * math.min(bpOffer / 3000000, 1)
  return kangPro, value
end
function GetWarMaxRound(warType)
  if warType == WARTYPE_BIWU then
    return WAR_MAX_ROUND_BWC
  elseif warType == WARTYPE_YIZHANDAODI_HUODONG then
    return WAR_MAX_ROUND_YZDD
  elseif warType == WARTYPE_XueZhanShaChang then
    return WAR_MAX_ROUND_XZSC
  elseif warType == WARTYPE_HUANGGONG then
    return WAR_MAX_ROUND_HGZB
  end
  return WAR_MAX_ROUND
end
function IsPVPWarType(warType)
  for _, t in pairs(WAR_PVP_LIST) do
    if t == warType then
      return true
    end
  end
  return false
end
function IsPVEWarType(warType)
  for _, t in pairs(WAR_PVE_LIST) do
    if t == warType then
      return true
    end
  end
  return false
end
function IsMaxRoundAsDaPingWarType(warType)
  for _, t in pairs(WAR_MaxRound_As_DaPing_LIST) do
    if t == warType then
      return true
    end
  end
  return false
end
function IsAllDeadAsDaPingWarType(warType)
  for _, t in pairs(WAR_AllDead_As_DaPing_LIST) do
    if t == warType then
      return true
    end
  end
  return false
end
function IsNeedRecord_HP_MP(warType)
  return true
end
function IsCanWatchWarType(warType)
  for _, t in pairs(WAR_CANWATCH_LIST) do
    if t == warType then
      return true
    end
  end
  return false
end
function IsMagicSkill(skillID)
  if skillID == SKILLTYPE_NORMALATTACK then
    return false
  elseif skillID == SKILLTYPE_BABYMONSTER or skillID == SKILLTYPE_BABYPET then
    return false
  elseif skillID == SKILLTYPE_DEFEND then
    return false
  elseif skillID == SKILLTYPE_RUNAWAY then
    return false
  elseif skillID == SKILLTYPE_USEDRUG then
    return false
  else
    local logicType = GetObjType(skillID)
    if logicType == LOGICTYPE_NEIDANSKILL then
      return false
    else
      return true
    end
  end
  return false
end
function IsWuliSkill(skillId)
  if skillId == SKILLTYPE_NORMALATTACK then
    return true
  end
  return false
end
function GetDefaultOperation(typeId, gender, race)
  if GetRoleObjType(typeId) == LOGICTYPE_PET then
    local data_table = data_Pet[typeId]
    if data_table ~= nil and data_table.skills[1] ~= nil and data_table.skills[1] ~= 0 then
      return {
        aiActionType = AI_ACTION_TYPE_USESKILL,
        targetPos = 0,
        skillId = data_table.skills[1]
      }
    else
      return {
        aiActionType = AI_ACTION_TYPE_NORMALATTACK,
        targetPos = 0,
        skillId = SKILLTYPE_NORMALATTACK
      }
    end
  end
  if gender == HERO_MALE then
    if race == RACE_REN then
      return {
        aiActionType = AI_ACTION_TYPE_USESKILL,
        targetPos = 0,
        skillId = 30013
      }
    elseif race == RACE_MO then
      return {
        aiActionType = AI_ACTION_TYPE_USESKILL,
        targetPos = 0,
        skillId = 30058
      }
    elseif race == RACE_XIAN then
      return {
        aiActionType = AI_ACTION_TYPE_USESKILL,
        targetPos = 0,
        skillId = 30028
      }
    elseif race == RACE_GUI then
      return {
        aiActionType = AI_ACTION_TYPE_USESKILL,
        targetPos = 0,
        skillId = 30065
      }
    end
  elseif gender == HERO_FEMALE then
    if race == RACE_REN then
      return {
        aiActionType = AI_ACTION_TYPE_USESKILL,
        targetPos = 0,
        skillId = 30003
      }
    elseif race == RACE_MO then
      return {
        aiActionType = AI_ACTION_TYPE_USESKILL,
        targetPos = 0,
        skillId = 30058
      }
    elseif race == RACE_XIAN then
      return {
        aiActionType = AI_ACTION_TYPE_USESKILL,
        targetPos = 0,
        skillId = 30023
      }
    elseif race == RACE_GUI then
      return {
        aiActionType = AI_ACTION_TYPE_USESKILL,
        targetPos = 0,
        skillId = 30065
      }
    end
  end
  return {
    aiActionType = AI_ACTION_TYPE_NORMALATTACK,
    targetPos = 0,
    skillId = SKILLTYPE_NORMALATTACK
  }
end
function CalculateRoleHP(obj)
  if obj:getType() == LOGICTYPE_PET then
    local gg = obj:getProperty(PROPERTY_GenGu)
    local growup = obj:getProperty(PROPERTY_GROWUP)
    local lv = obj:getProperty(PROPERTY_ROLELEVEL)
    local hpbase = obj:getProperty(PROPERTY_RANDOM_HPBASE) + obj:getProperty(PROPERTY_LONGGU_ADDHP) + obj:getProperty(PROPERTY_HUAJING_ADDHP)
    local hp = math.floor(hpbase * lv * growup * 0.7 + gg * growup * lv + hpbase + obj:GetZhuangBeiAddNum(PROPERTY_HP) + obj:GetPetSkillChangYinDongDu())
    hp = math.floor(hp * (1 + CalculateRoleZq_AddProValue(obj, PROPERTY_HP)))
    return hp
  elseif obj:getType() == LOGICTYPE_HERO then
    local gg = obj:getProperty(PROPERTY_GenGu)
    local starValue = obj:getProperty(PROPERTY_STARSKILLVALUE)
    local lv = obj:getProperty(PROPERTY_ROLELEVEL)
    local hp = math.floor(data_getRoleProFromData(obj:getTypeId(), PROPERTY_HP) + gg * (lv + (2000 - lv * 20) / 100) * (1 + data_getRoleProFromData(obj:getTypeId(), PROPERTY_GGenGu)) * (1 + obj:getProperty(PROPERTY_ZSHP)) + obj:GetZhuangBeiAddNum(PROPERTY_HP))
    hp = hp * starValue
    hp = math.floor(hp * (1 + obj:GetZhuangBeiAddNum(PROPERTY_HP_P)))
    return hp
  else
    local lv = obj:getProperty(PROPERTY_ROLELEVEL)
    local hp_ = data_getRoleProFromData(obj:getTypeId(), PROPERTY_HP)
    local hp = hp_ * math.pow(lv, (85 + lv / 6.666666666666667) / 100) + obj:GetPetSkillChangYinDongDu()
    return hp
  end
end
function CalculateRoleMP(obj)
  if obj:getType() == LOGICTYPE_PET then
    local lx = obj:getProperty(PROPERTY_Lingxing)
    local growup = obj:getProperty(PROPERTY_GROWUP)
    local lv = obj:getProperty(PROPERTY_ROLELEVEL)
    local mpbase = obj:getProperty(PROPERTY_RANDOM_MPBASE) + obj:getProperty(PROPERTY_LONGGU_ADDMP) + obj:getProperty(PROPERTY_HUAJING_ADDMP)
    local mp = math.floor(mpbase * lv * growup * 0.7 + lx * growup * lv + mpbase + obj:GetZhuangBeiAddNum(PROPERTY_MP) + obj:GetPetSkillYuanQuanWanHu())
    mp = math.floor(mp * (1 + CalculateRoleZq_AddProValue(obj, PROPERTY_MP)))
    return mp
  elseif obj:getType() == LOGICTYPE_HERO then
    local lx = obj:getProperty(PROPERTY_Lingxing)
    local starValue = obj:getProperty(PROPERTY_STARSKILLVALUE)
    local lv = obj:getProperty(PROPERTY_ROLELEVEL)
    local mp = math.floor(data_getRoleProFromData(obj:getTypeId(), PROPERTY_MP) + lx * (lv + (2000 - lv * 20) / 100) * (1 + data_getRoleProFromData(obj:getTypeId(), PROPERTY_GLingxing)) * (1 + obj:getProperty(PROPERTY_ZSMP)) + obj:GetZhuangBeiAddNum(PROPERTY_MP))
    mp = math.floor(mp * starValue)
    return mp
  else
    local lv = obj:getProperty(PROPERTY_ROLELEVEL)
    local mp_ = data_getRoleProFromData(obj:getTypeId(), PROPERTY_MP)
    local mp = mp_ * math.pow(lv, (85 + lv / 6.666666666666667) / 100) + obj:GetPetSkillYuanQuanWanHu()
    return mp
  end
end
function CalculateRoleAP(obj)
  if obj:getType() == LOGICTYPE_PET then
    local ll = obj:getProperty(PROPERTY_LiLiang)
    local growup = obj:getProperty(PROPERTY_GROWUP)
    local lv = obj:getProperty(PROPERTY_ROLELEVEL)
    local apbase = obj:getProperty(PROPERTY_RANDOM_APBASE) + obj:getProperty(PROPERTY_LONGGU_ADDAP) + obj:getProperty(PROPERTY_HUAJING_ADDAP)
    local ap = math.floor((apbase * lv * growup * 0.7 + ll * growup * lv) / 5 + apbase + obj:GetZhuangBeiAddNum(PROPERTY_AP) + obj:GetPetSkillShenGongGuiLi())
    ap = math.floor(ap * (1 + CalculateRoleZq_AddProValue(obj, PROPERTY_AP)))
    return ap
  elseif obj:getType() == LOGICTYPE_HERO then
    local ll = obj:getProperty(PROPERTY_LiLiang)
    local starValue = obj:getProperty(PROPERTY_STARSKILLVALUE)
    local lv = obj:getProperty(PROPERTY_ROLELEVEL)
    local ap = math.floor(data_getRoleProFromData(obj:getTypeId(), PROPERTY_AP) + ll * (lv + (2000 - lv * 20) / 100) / 5 * (1 + data_getRoleProFromData(obj:getTypeId(), PROPERTY_GLiLiang)) + obj:GetZhuangBeiAddNum(PROPERTY_AP))
    ap = math.floor(ap * starValue)
    return ap
  else
    local lv = obj:getProperty(PROPERTY_ROLELEVEL)
    local ap_ = data_getRoleProFromData(obj:getTypeId(), PROPERTY_AP)
    local ap = ap_ * math.pow(lv, (85 + lv / 6.666666666666667) / 100) + obj:GetPetSkillShenGongGuiLi()
    return ap
  end
end
function CalculateRoleSP(obj)
  if obj:getType() == LOGICTYPE_PET then
    local mj = obj:getProperty(PROPERTY_MinJie)
    local growup = obj:getProperty(PROPERTY_GROWUP)
    local spbase = obj:getProperty(PROPERTY_RANDOM_SPBASE) + obj:getProperty(PROPERTY_LONGGU_ADDSP) + obj:getProperty(PROPERTY_HUAJING_ADDSP)
    local sp = math.floor((spbase + mj) * growup + obj:GetZhuangBeiAddNum(PROPERTY_SP) + obj:GetPetSkillBeiDaoJianXing() - obj:GetPetSkillPanShan())
    sp = math.floor(sp * (1 + CalculateRoleZq_AddProValue(obj, PROPERTY_SP)))
    return sp
  elseif obj:getType() == LOGICTYPE_HERO then
    local mj = obj:getProperty(PROPERTY_MinJie)
    local starValue = obj:getProperty(PROPERTY_STARSKILLVALUE)
    local sp = math.floor(data_getRoleProFromData(obj:getTypeId(), PROPERTY_SP) + mj * (1 + data_getRoleProFromData(obj:getTypeId(), PROPERTY_GMinJie)) * (1 + obj:getProperty(PROPERTY_ZSSP) + obj:getProperty(PROPERTY_ZSSPXIXUE)) + obj:GetZhuangBeiAddNum(PROPERTY_SP))
    sp = math.floor(sp * starValue)
    return sp
  else
    local lv = obj:getProperty(PROPERTY_ROLELEVEL)
    local sp_ = data_getRoleProFromData(obj:getTypeId(), PROPERTY_SP)
    local sp = sp_ + lv + obj:GetPetSkillBeiDaoJianXing() - obj:GetPetSkillPanShan()
    return sp
  end
end
function CalculateRoleZq_AddProValue(obj, addProName)
  local addValue = 0
  local playerId = obj:getPlayerId()
  local player = WarAIGetOnePlayerData(obj:getWarID(), obj:getPlayerId())
  if player and player.getPetAddZQSkillDataForWar then
    local addDict = player:getPetAddZQSkillDataForWar(obj.m_Id)
    for proName, proValue in pairs(addDict) do
      if proName == addProName then
        addValue = addValue + proValue
      end
    end
  end
  return addValue
end
function GetZSXZNumList(zsTypeID, zsNum)
  if ZHUANSHENG_ADD_VALUEDICT[zsTypeID] == nil then
    return {}
  end
  local tempList = {}
  for _, tData in ipairs(ZHUANSHENG_ADD_VALUEDICT[zsTypeID]) do
    local proName = tData[2]
    local eNum = tData[2]
    tempList[#tempList + 1] = {
      proName,
      data_getRoleRebornValue(zsNum - 1, eNum)
    }
  end
  return tempList
end
