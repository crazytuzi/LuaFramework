local ZS_INIT_EXP = {
  [0] = 80,
  [1] = 90,
  [2] = 100,
  [3] = 110,
  [4] = 120
}
function CalculateHeroLevelupExp(lv, zs)
  local expInit = ZS_INIT_EXP[zs]
  if expInit == nil then
    expInit = 0
    printLog("ERROR", "转生等级[%s]找不到对应的初始等级", zs)
  end
  local nextLv = lv + 1
  return math.floor(expInit * (math.pow(nextLv, (300 + nextLv / 4) / 100) - math.pow(lv, (300 + lv / 4) / 100)))
end
function CalculatePetLevelupExp(lv, zs)
  local expInit = ZS_INIT_EXP[zs]
  if expInit == nil then
    expInit = 0
    printLog("ERROR", "转生等级[%s]找不到对应的初始等级", zs)
  end
  local nextLv = lv + 1
  return math.floor(expInit * (math.pow(nextLv, (300 + nextLv / 4) / 100) - math.pow(lv, (300 + lv / 4) / 100)) * 0.7)
end
function CalculateSkillProficiency(zs)
  zs = zs or 0
  return data_getMaxSkillExp(zs)
end
function CalculatePetNeidanLimit(zs)
  if zs <= 0 then
    return 1
  elseif zs == 1 then
    return 2
  else
    return 3
  end
end
function CalculatePetLianYaoLimit(zs)
  local num = 0
  for i = 0, 3 do
    local data = data_RbPetAttr[i + 1]
    if data ~= nil then
      num = num + data.exnum
    end
    if i == zs then
      return num
    end
  end
  return num
end
function CalculateNeidanLevelupExp(lv, zs)
  local expInit = ZS_INIT_EXP[zs]
  if expInit == nil then
    expInit = 0
    printLog("ERROR", "转生等级[%s]找不到对应的初始等级", zs)
  end
  local nextLv = lv + 1
  return math.round(expInit * (math.pow(nextLv, (300 + nextLv / 4) / 100) - math.pow(lv, (300 + lv / 4) / 100)) * 0.7 * 0.3)
end
function CalculateNeidanZSLimit()
  return 3
end
function CalculateNeidanLevelLimit(zs)
  return data_getMaxPetLevel(zs)
end
function getMissionKind(missionId)
  return checkint(missionId / MissionKind_Divisor)
end
function getShimenNpcId(roce, gender)
  local gd = Shimen_NPCId[roce]
  if gd then
    return gd[gender]
  end
  return nil
end
function getShimenNpcIdByTypeId(roleId)
  local roleData = data_getRoleData(roleId)
  if roleData then
    return getShimenNpcId(roleData.RACE, roleData.GENDER)
  end
  return nil
end
function CalculateZuoqiLevelupExp(lv)
  if lv > CalculateZuoqiLevelLimit() then
    lv = CalculateZuoqiLevelLimit()
  end
  return math.floor(((lv + 1) ^ 2 - lv ^ 2) * 15)
end
function CalculateZuoqiBaseLXLimit(zqTypeId, isDh)
  local zqData = data_Zuoqi[zqTypeId]
  if zqData == nil then
    return 0
  end
  local baseLx = zqData.zqBaseLX
  local d = math.ceil(baseLx * 1.2 + 3)
  if isDh == true or isDh == 1 then
    d = d + 3
  end
  return d
end
function CalculateZuoqiBaseLLLimit(zqTypeId, isDh)
  local zqData = data_Zuoqi[zqTypeId]
  if zqData == nil then
    return 0
  end
  local baseLL = zqData.zqBaseLL
  local d = math.ceil(baseLL * 1.2 + 3)
  if isDh == true or isDh == 1 then
    d = d + 3
  end
  return d
end
function CalculateZuoqiBaseGGLimit(zqTypeId, isDh)
  local zqData = data_Zuoqi[zqTypeId]
  if zqData == nil then
    return 0
  end
  local baseGG = zqData.zqBaseGG
  local d = math.ceil(baseGG * 1.2 + 3)
  if isDh == true or isDh == 1 then
    d = d + 3
  end
  return d
end
function CalculateZuoqiUpgradeCDTime()
  return 900
end
function CalculateMarketUpgradeCDTime()
  return 600
end
function CalculateZuoqiManageLimit(isDh)
  if isDh == 1 or isDh == true then
    return 3
  else
    return 2
  end
end
function CalculateZuoqiSkillCost()
  return 200000
end
function CalculateZuoqiSkillNumLimit()
  return 2
end
function CalculateZuoqiSkillPValueLimit()
  return 100000
end
function CalculatePetCloseValueLimit()
  local pctb = data_PetClose[#data_PetClose]
  return pctb.closeValue or 10000000
end
function CalculateUpgradeZuoqiSkillPValueLimit(isDh)
  if isDh == 0 then
    return 100000
  else
    return 80000
  end
end
function CalculateZuoqiSkillPValueCostArch()
  return 1000
end
function Calculate1000ArchCostCoin()
  return data_Variables.ArchCostCoin
end
function CalculateResetZqUpgradeCDTimeCostGold()
  return 20
end
function CalculateZuoqiLevelLimit()
  return 100
end
function GetAddSkillExpNeedCoin(skillId, curSkillExp)
  local step = data_getSkillStep(skillId)
  local l1 = data_Variables.BE_skillRates or {}
  local v1 = data_Variables.BE_allCostMoney or 0
  local v2 = data_Variables.BE_skillExp or 1
  local v3 = data_getMaxSkillExp(3)
  local total = 0
  for _, v in pairs(l1) do
    total = total + v
  end
  local cost = v1 / v3 * v2 * (curSkillExp / v2 + 1) / (v3 / v2 + 1) * 2 / 3 * ((l1[step] or 0) / total)
  return math.floor(cost)
end
function GetAddMarrySkillExpNeedCoin(skillId, curSkillExp)
  local step = 3
  if skillId == ACTIVE_MARRYSKILLLIST[1] then
    step = 1
  elseif skillId == ACTIVE_MARRYSKILLLIST[2] then
    step = 2
  elseif skillId == ACTIVE_MARRYSKILLLIST[3] then
    step = 3
  end
  local l1 = data_Variables.BE_closeSkillCostList or {}
  local v1 = l1[step] or 0
  local v2 = data_Variables.BE_skillExp or 1
  local v3 = data_Variables.FriendCloseLimit
  local cost = v1 / v3 * v2 * (curSkillExp / v2 + 1) / (v3 / v2 + 1) * 2
  return math.floor(cost)
end
