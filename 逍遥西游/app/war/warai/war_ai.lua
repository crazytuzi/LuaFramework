if not g_WarAiInsList then
  g_WarAiInsList = {}
end
local WaitSettingTime = 20
local EndDisplayTime_OnLine = 120
local EndDisplayTime_AllOffLine = 30
local WaitDisplayTime = 20
local DelayTime = 5
function WarAIGetOnePlayerData(warID, playerID)
  if WAR_CODE_IS_SERVER ~= true then
    return g_DataMgr:getPlayer(playerID)
  else
    return g_DataMgr:getPlayer(warID, playerID)
  end
end
function StartOneSingleWar(warID, warType, warTypeData, playerId, fbWarID, posTable)
  printLogDebug("war_ai", "【warai log】[warid%d]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>StartOneSingleWar,warType  %d", warID, warType)
  AICreateOneWar({
    warID = warID,
    warType = warType,
    warTypeData = warTypeData,
    singleFlag = true
  })
  AICalculateHuoDongData({warID = warID})
  local player = WarAIGetOnePlayerData(warID, playerId)
  for pos, roleID in pairs(posTable) do
    local hero = player:getObjById(roleID)
    AICreateOneRole(warID, pos, hero, TEAM_ATTACK)
  end
  AICalculateChengWeiData(warID)
  AICalculateBanLvData(warID)
  AICreateNPCEnemy(warID, fbWarID)
  AIStartOneWar(warID)
  if WAR_CODE_IS_SERVER ~= true then
  else
    CheckAllWarData()
  end
end
function StartOneMultiWar(warID, warType, warTypeData, fbWarID, posTable, huodongData)
  printLogDebug("war_ai", "【warai log】[warid%d]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>StartOneMultiWar,warType%d", warID, warType)
  printLogDebug("war_ai", "【warai log】[warid%d]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>环数%d", warID, warTypeData.i_tNum or 0)
  if fbWarID ~= nil then
    printLogDebug("war_ai", "【warai log】[warid%d]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>StartOneMultiWar,fbWarID  %d", warID, fbWarID)
  end
  AICreateOneWar({
    warID = warID,
    warType = warType,
    warTypeData = warTypeData,
    singleFlag = false
  })
  AICalculateHuoDongData({warID = warID, huodongData = huodongData})
  for pos, data in pairs(posTable) do
    local playerId = data[1]
    local roleID = data[2]
    local player = WarAIGetOnePlayerData(warID, playerId)
    if player ~= nil then
      player:delAllZQData()
    end
    local hero = player:getObjById(roleID)
    if pos >= DefineDefendPosNumberBase then
      AICreateOneRole(warID, pos, hero, TEAM_DEFEND)
    else
      AICreateOneRole(warID, pos, hero, TEAM_ATTACK)
    end
  end
  AICalculateChengWeiData(warID)
  AICalculateBanLvData(warID)
  if fbWarID ~= nil then
    AICreateNPCEnemy(warID, fbWarID)
  end
  AIStartOneWar(warID)
  if WAR_CODE_IS_SERVER ~= true then
  else
    CheckAllWarData()
    local playerList = {}
    for pos, data in pairs(posTable) do
      local playerID = data[1]
      playerList[playerID] = true
    end
    for playerID, _ in pairs(playerList) do
      local player = WarAIGetOnePlayerData(warID, playerID)
      if player then
        if player:GetPlayerAutoFightFlag() == 1 then
          ClearAllWatchData(playerID)
          for _, warAIObj in pairs(g_WarAiInsList) do
            warAIObj:setPlayerIsOffLine(playerID, true, false)
          end
        end
        if g_WarAiInsList ~= nil and g_WarAiInsList[warID] ~= nil then
          g_WarAiInsList[warID]:SetOnePlayerAutoFightData(playerID)
        end
      end
    end
  end
end
function RandomSortList(tempTable)
  local newTable = {}
  local itemNum = #tempTable
  for i = 1, itemNum do
    local newI = math.random(1, itemNum - i + 1)
    newTable[i] = tempTable[newI]
    for j = newI, itemNum - i do
      tempTable[j] = tempTable[j + 1]
    end
  end
  for i, j in pairs(newTable) do
    tempTable[i] = j
  end
  return tempTable
end
function AICreateOneWar(warParams)
  printLogDebug("war_ai", "【warai log】[warid%d]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>AICreateOneWar创建一个新战斗", warParams.warID)
  CWarAI.new(warParams)
end
function AICalculateHuoDongData(warParams)
  printLogDebug("war_ai", "【warai log】[warid%d]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>AICalculateHuoDongData", warParams.warID)
  local warID = warParams.warID
  if g_WarAiInsList[warID] == nil then
    printLogDebug("war_ai", "【warai log】[warid%d]~~~~异常，没有战斗ai对象%d,不能AICalculateHuoDongData", warID)
    return
  end
  if WAR_CODE_IS_SERVER ~= true and activity.huoliHuodong:getIsStarting() then
    g_WarAiInsList[warID]:Set51HuoLiFlag(1)
  end
  local huodongData = warParams.huodongData
  if huodongData and huodongData.event51 == 1 then
    g_WarAiInsList[warID]:Set51HuoLiFlag(1)
  end
end
function AICalculateChengWeiData(warID)
  printLogDebug("war_ai", "【warai log】[warid%d]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>AICalculateChengWeiData", warID)
  if g_WarAiInsList[warID] == nil then
    printLogDebug("war_ai", "【warai log】[warid%d]~~~~异常，没有战斗ai对象%d,不能AICalculateChengWeiData", warID)
    return
  end
  g_WarAiInsList[warID]:SetChengWeiData()
end
function AICalculateBanLvData(warID)
  printLogDebug("war_ai", "【warai log】[warid%d]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>AICalculateBanLvData", warID)
  if g_WarAiInsList[warID] == nil then
    printLogDebug("war_ai", "【warai log】[warid%d]~~~~异常，没有战斗ai对象%d,不能AICalculateBanLvData", warID)
    return
  end
  g_WarAiInsList[warID]:SetBanLvBeiDongData()
end
function AICreateOneRole(warId, pos, role, teamFlag)
  printLogDebug("war_ai", "【warai log】[warid%d]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>AICreateOneRole创建一个对象角色", warId)
  if g_WarAiInsList[warId] == nil then
    printLogDebug("war_ai", "【warai log】[warid%d]~~~~异常，没有战斗ai对象%d,不能AICreateOneRole", warId)
  end
  g_WarAiInsList[warId]:CreateOneRole(pos, role, teamFlag)
end
function AICreateNPCEnemy(warId, warRoleListId)
  printLogDebug("war_ai", "【warai log】[warid%d]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>AICreateNPCEnemy创建NPC敌人", warId)
  if g_WarAiInsList[warId] == nil then
    printLogDebug("war_ai", "【warai log】[warid%d]~~~~异常，没有战斗ai对象,不能AICreateNPCEnemy", warId)
  end
  g_WarAiInsList[warId]:CreateNPCEnemy(warRoleListId)
end
function AIStartOneWar(warId)
  printLogDebug("war_ai", "【warai log】[warid%d]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>AIStartOneWar开始战斗", warId)
  if g_WarAiInsList[warId] == nil then
    printLogDebug("war_ai", "【warai log】[warid%d]~~~~异常，没有战斗ai对象,不能AIStartOneWar", warId)
  end
  g_WarAiInsList[warId]:InitWar()
end
function AISetOneRoleAction(warId, roundNum, playerId, roleId, pos, actionDict)
  printLogDebug("war_ai", "【warai log】[warid%d]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>AISetOneRoleAction", warId, roundNum, playerId, roleId, pos, actionDict)
  if g_WarAiInsList[warId] == nil then
    printLogDebug("war_ai", "【warai log】[warid%d]~~~~异常，没有战斗ai对象,不能AISetOneRoleAction", warId)
    if net_wtog then
      net_wtog.tellSerToCancelWar(warId)
    end
    return
  end
  g_WarAiInsList[warId]:SetOneRoleAction(roundNum, playerId, roleId, pos, actionDict)
end
function AISetOnePlayerFinishPlayOneRound(warId, roundNum, playerId)
  printLogDebug("war_ai", "【warai log】[warid%d]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>AISetOnePlayerFinishPlayOneRound", warId, roundNum, playerId)
  if g_WarAiInsList[warId] == nil then
    printLogDebug("war_ai", "【warai log】[warid%d]~~~~异常，没有战斗ai对象,不能AISetOnePlayerFinishPlayOneRound", warId)
    if net_wtog then
      net_wtog.tellSerToCancelWar(warId)
    end
    return
  end
  g_WarAiInsList[warId]:SetOneplayerFinishPlayOneRound(roundNum, playerId)
end
function AIEndOneWar(warId)
  printLogDebug("war_ai", "【warai log】[warid%d]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>AIEndOneWar结束战斗，并且删除战斗ai对象", warId)
  if g_WarAiInsList[warId] == nil then
    printLogDebug("war_ai", "【warai log】[warid%d]~~~~异常，没有战斗ai对象,不能AIEndOneWar", warId)
  end
  printLogDebug("war_ai", "【warai log】[warid%d]AIEndOneWar", warId)
  g_WarAiInsList[warId] = nil
  if WAR_CODE_IS_SERVER ~= true then
  else
    g_DataMgr:delOneWarPlayers(warId)
  end
end
function AIForceEndWar(warId)
  printLogDebug("war_ai", "【warai log】[warid%d]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>AIForceEndWar强制结束战斗", warId)
  if g_WarAiInsList[warId] == nil then
    printLogDebug("war_ai", "【warai log】[warid%d]~~~~异常，没有战斗ai对象,不能AIForceEndWar", warId)
    AIEndOneWar(warId)
    return
  end
  g_WarAiInsList[warId]:ForceEndWar()
  AIEndOneWar(warId)
end
function AIDoOneRound(warId, roundParams)
  printLogDebug("war_ai", "【warai log】[warid%d]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>AIDoOneRound战斗开始一个新回合", warId)
  if g_WarAiInsList[warId] == nil then
    printLogDebug("war_ai", "【warai log】[warid%d]~~~~异常，没有战斗ai对象,不能AIDoOneRound", warId)
    return false
  end
  printLogDebug("war_ai", "【warai log】[warid%d]==========================================AIDoOneRound %d 回合==========================================", warId, g_WarAiInsList[warId].m_CurrRoundCnt + 1)
  g_WarAiInsList[warId]:DoOneRound(roundParams)
end
function AISetSeqData(warId, params)
  printLogDebug("war_ai", "【warai log】[warid%d]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>AISetSeqData战斗接受生成序列", warId)
  if g_WarAiInsList[warId] == nil then
    printLogDebug("war_ai", "【warai log】[warid%d]~~~~异常，没有战斗ai对象,不能AISetSeqData", warId)
    return
  end
  return g_WarAiInsList[warId]:SetSeqData(params)
end
function AISetBaseData(warId, warType, singleFlag, baseData, attackList, defendList, warTime)
  printLogDebug("war_ai", "【warai log】[warid%d]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>AISetBaseData初始战斗", warId)
  if singleFlag == true then
    local baseWarInfo = DeepCopyTable(baseData)
    StartWarWithBaseInfo(warId, warType, baseWarInfo, attackList, defendList, warTime)
  else
    net_wtog.tellPlayersToStartWar(warId, warType, attackList, defendList, baseData, warTime)
  end
end
function AISendRoundWarSeqList(warId, singleFlag, round, warSeqList, endWarData, warTime)
  printLogDebug("war_ai", "【warai log】[warid%d]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>AISendRoundWarSeqList发送战斗序列", warId)
  if singleFlag == true then
    setRoundWarSeqList(warId, round, warSeqList, endWarData, warTime)
  else
    net_wtog.tellPlayersToRunOneRound(warId, round, warSeqList, endWarData, warTime)
    if g_WarAiInsList[warId] == nil then
      printLogDebug("war_ai", "【warai log】[warid%d]~~~~异常，没有战斗ai对象,不能发送给观战的人1", warId)
      return
    end
    local watchData = g_WarAiInsList[warId]:GetPlayerWatchWar()
    for tPID, _ in pairs(watchData) do
      net_wtog.tellPlayersToRunOneRound(warId, round, warSeqList, endWarData, warTime, tPID)
    end
  end
end
function AISendOneRoleWarStateChange(warId, singleFlag, pos, warState)
  printLogDebug("war_ai", "【warai log】[warid%d]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>AISendOneRoleWarStateChange发送一个角色的状态转变 pos%d, warState%d", warId, pos, warState)
  if singleFlag == true then
    setWarRoleState(warId, pos, warState)
  else
    net_wtog.tellPlayersToSetPosState(warId, {
      {i_p = pos, i_t = warState}
    })
    if g_WarAiInsList[warId] == nil then
      printLogDebug("war_ai", "【warai log】[warid%d]~~~~异常，没有战斗ai对象,不能发送给观战的人2", warId)
      return
    end
    local watchData = g_WarAiInsList[warId]:GetPlayerWatchWar()
    for tPID, _ in pairs(watchData) do
      net_wtog.tellPlayersToSetPosState(warId, {
        {i_p = pos, i_t = warState}
      }, tPID)
    end
  end
end
function AISendRolesWarStateChange(warId, singleFlag, stateTable)
  printLogDebug("war_ai", "【warai log】[warid%d]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>AISendRolesWarStateChange发送一坨角色的状态转变 ", warId)
  if singleFlag == true then
    for _, data in pairs(stateTable) do
      local pos = data.i_p
      local state = data.i_t
      setWarRoleState(warId, pos, state)
    end
  else
    net_wtog.tellPlayersToSetPosState(warId, stateTable)
    if g_WarAiInsList[warId] == nil then
      printLogDebug("war_ai", "【warai log】[warid%d]~~~~异常，没有战斗ai对象,不能发送给观战的人3", warId)
      return
    end
    local watchData = g_WarAiInsList[warId]:GetPlayerWatchWar()
    for tPID, _ in pairs(watchData) do
      net_wtog.tellPlayersToSetPosState(warId, stateTable, tPID)
    end
  end
end
function AISendOneRoleEnterWatchWar(warId, watcherPlayerId, watcherData)
  printLogDebug("war_ai", "【warai log】[warid%d]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>AISendOneRoleEnterWatchWar发送一个玩家%d进入观战", warId, watcherPlayerId)
  if singleFlag == true then
  else
    if g_WarAiInsList[warId] == nil then
      printLogDebug("war_ai", "【warai log】[warid%d]~~~~异常，没有战斗ai对象,发送一个玩家进入观战", warId)
      return
    end
    local opPlayerData = g_WarAiInsList[warId]:GetAllPlayerID()
    for _, tempPlayerId in pairs(opPlayerData) do
      net_wtog.tellOnePlayerPlayerAEnterForWatch(tempPlayerId, warId, watcherData)
    end
    local watchData = g_WarAiInsList[warId]:GetPlayerWatchWar()
    for tPID, _ in pairs(watchData) do
      net_wtog.tellOnePlayerPlayerAEnterForWatch(tPID, warId, watcherData)
    end
  end
end
function AISendToOnePlayerOneRoleEnterWatchWar(warId, sendToPlayerID, watcherData)
  printLogDebug("war_ai", "【warai log】[warid%d]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>AISendToOnePlayerOneRoleEnterWatchWar发送一个玩家进入观战给一个玩家%d", warId, sendToPlayerID)
  if singleFlag == true then
  else
    if g_WarAiInsList[warId] == nil then
      printLogDebug("war_ai", "【warai log】[warid%d]~~~~异常，没有战斗ai对象,发送一个玩家进入观战给一个玩家", warId)
      return
    end
    net_wtog.tellOnePlayerPlayerAEnterForWatch(sendToPlayerID, warId, watcherData)
  end
end
function AISendOneRoleQuitWatchWar(warId, quitPlayerId)
  printLogDebug("war_ai", "【warai log】[warid%d]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>AISendOneRoleQuitWatchWar发送一个玩家%d退出观战", warId, quitPlayerId)
  if singleFlag == true then
  else
    if g_WarAiInsList[warId] == nil then
      printLogDebug("war_ai", "【warai log】[warid%d]~~~~异常，没有战斗ai对象,发送一个玩家退出观战", warId)
      return
    end
    local opPlayerData = g_WarAiInsList[warId]:GetAllPlayerID()
    for _, tempPlayerId in pairs(opPlayerData) do
      net_wtog.tellOnePlayerPlayerAQuitForWatch(tempPlayerId, warId, quitPlayerId)
    end
    local watchData = g_WarAiInsList[warId]:GetPlayerWatchWar()
    for tPID, _ in pairs(watchData) do
      net_wtog.tellOnePlayerPlayerAQuitForWatch(tPID, warId, quitPlayerId)
    end
  end
end
function AISendPlayerSetOneRound(warId, singleFlag, playerId, round, opData)
  printLogDebug("war_ai", "【warai log】[warid%d]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>AISendPlayerSetOneRound通知玩家开始设置回合round%d,playerId%d", warId, round, playerId)
  if singleFlag == true then
    setStartOneRound(warId, round, opData)
  else
    net_wtog.tellPlayersToSetOneRound(warId, round, playerId, opData)
  end
end
function AISendPlayerRunAwayMsg(warId, warType, playerId, hpMpData)
  printLogDebug("war_ai", "【warai log】[warid%d]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>AISendPlayerRunAwayMsg发送玩家%d逃跑信息", warId, playerId)
  if WAR_CODE_IS_SERVER ~= true then
  else
    if warType == WARTYPE_BpWAR then
      return
    end
    net_wtog.tellSerToQuitWar(playerId, warId)
    if hpMpData ~= nil then
      local data = {}
      data.warid = warId
      data.pid = playerId
      data.d = hpMpData
      net_wtog.recordRunAwayRoleHpAndMp(data)
    end
  end
end
function AISendUseDrugToSer(warId, singleFlag, playerId, drugTypeId, num)
  printLogDebug("war_ai", "【warai log】[warid%d]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>AISendUseDrugToSer发送玩家%d吃药信息", warId, playerId)
  if singleFlag == true then
    netsend.netwar.warUseDrug(warId, drugTypeId, num)
  else
    net_wtog.tellSerUseDrug(warId, playerId, drugTypeId, num)
  end
end
function AIChangePet(warId, warType, singleFlag, playerId, heroId, newPetId)
  printLogDebug("war_ai", "【warai log】[warid%d]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>AIChangePet告诉服务器战斗中更换宠物", warId)
  if singleFlag == true then
    netsend.netbaseptc.setEquipPet(heroId, newPetId)
  else
    net_wtog.tellSerChangePet(warId, playerId, newPetId)
  end
end
function AISubmitWarResult(warId, warType, singleFlag, warTypeData, endWarData)
  printLogDebug("war_ai", "【warai log】[warid%d]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>AISubmitWarResult发送战斗结果", warId)
  local warSkillPDict = {}
  for playerId, data in pairs(endWarData.SkillProficiencyDict) do
    warSkillPDict[playerId] = {}
    for sNo, pNum in pairs(data) do
      warSkillPDict[playerId][#warSkillPDict[playerId] + 1] = {i_snum = sNo, i_pnum = pNum}
    end
  end
  local petClose = {}
  for playerId, data in pairs(endWarData.petCloseDict) do
    petClose[playerId] = {}
    for petId, closeDelV in pairs(data) do
      petClose[playerId][#petClose[playerId] + 1] = {i_petid = petId, i_cnum = closeDelV}
    end
  end
  local warPet = {}
  for playerId, data in pairs(endWarData.GetExpPetList) do
    warPet[playerId] = {}
    for i, petID in pairs(data) do
      warPet[playerId][i] = {i_petid = petID}
    end
  end
  local starNum = 0
  local pvpFlag = IsPVPWarType(warType)
  if pvpFlag == true then
    local result = 0
    if endWarData.warResult == WARRESULT_DaPing then
      result = -1
    elseif endWarData.warResult == WARRESULT_ATTACK_WIN then
      result = 1
    else
      result = 0
    end
    if warType == WARTYPE_XueZhanShaChang then
      result = endWarData.starNum
    end
    if net_wtog then
      net_wtog.tellSerPVPWarResult(warId, warType, result)
    end
  elseif singleFlag == true then
    local onlyPlayerWarPet = {}
    for playerId, data in pairs(warPet) do
      onlyPlayerWarPet = data
      break
    end
    local onlyPlayerWarSkillPDict = {}
    for playerId, data in pairs(warSkillPDict) do
      onlyPlayerWarSkillPDict = data
      break
    end
    local onlyPlayerPetClose = {}
    for playerId, data in pairs(petClose) do
      onlyPlayerPetClose = data
      break
    end
    local warUseTime = endWarData.warUseTime
    if endWarData.warResult == WARRESULT_ATTACK_WIN then
      starNum = endWarData.starNum
      if starNum == 0 then
        starNum = 1
      end
      SubmitWarResult(warId, starNum, onlyPlayerWarPet, onlyPlayerWarSkillPDict, onlyPlayerPetClose, warUseTime)
    else
      SubmitWarResult(warId, starNum, onlyPlayerWarPet, onlyPlayerWarSkillPDict, onlyPlayerPetClose, warUseTime)
    end
  else
    local result = 0
    if warType == WARTYPE_FUBEN then
      result = endWarData.starNum
    elseif endWarData.warResult == WARRESULT_ATTACK_WIN then
      result = 1
    end
    local temp_T_data = {}
    for playerId, data in pairs(warSkillPDict) do
      if temp_T_data[playerId] == nil then
        temp_T_data[playerId] = {}
      end
      temp_T_data[playerId].t_skillp = warSkillPDict[playerId]
    end
    for playerId, data in pairs(petClose) do
      if temp_T_data[playerId] == nil then
        temp_T_data[playerId] = {}
      end
      temp_T_data[playerId].t_petc = petClose[playerId]
    end
    for playerId, data in pairs(warPet) do
      if temp_T_data[playerId] == nil then
        temp_T_data[playerId] = {}
      end
      temp_T_data[playerId].t_warpet = warPet[playerId]
    end
    local t_data = {}
    for playerId, data in pairs(temp_T_data) do
      local newData = data
      newData.i_playerid = playerId
      t_data[#t_data + 1] = newData
    end
    net_wtog.tellSerWarResult(warId, result, t_data)
  end
end
function AIUseSkillOnTarget(warId, userPos, targetPos, skillId, exPara)
  printLogDebug("war_ai", "【warai log】[warid%d]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>AIUseSkillOnTarget,使用技能", warId)
  if g_WarAiInsList[warId] == nil then
    printLogDebug("war_ai", "【warai log】[warid%d]~~~~异常，没有战斗ai对象,不能AIUseSkillOnTarget", warId)
    return
  end
  g_WarAiInsList[warId]:WarAiUseSkillOnTarget(userPos, targetPos, skillId, exPara)
end
function GetSettingTimer(warId, roundNum)
  printLogDebug("war_ai", "【warai log】[warid%d]GetSettingTimer设置定时器warId%d,roundNum%d", warId, warId, roundNum)
  local function f()
    local Wid = warId
    local r = roundNum
    if g_WarAiInsList[Wid] == nil then
      printLogDebug("war_ai", "【warai log】[warid%d]GetSettingTimer设置定时器warId%d,roundNum%d【error】", warId, warId, roundNum)
      return
    end
    g_WarAiInsList[Wid]:SettingTimesUp(r)
  end
  return f
end
function GetDisplayTimer(warId, roundNum)
  printLogDebug("war_ai", "【warai log】[warid%d]GetDisplayTimer设置定时器warId%d,roundNum%d", warId, warId, roundNum)
  local function f()
    local Wid = warId
    local r = roundNum
    if g_WarAiInsList[Wid] == nil then
      printLogDebug("war_ai", "【warai log】[warid%d]GetDisplayTimer设置定时器warId%d,roundNum%d【error】", warId, warId, roundNum)
      return
    end
    g_WarAiInsList[Wid]:DisplayTimesUp(r)
  end
  return f
end
function GetAutoDisplayTimer(warId, roundNum)
  printLogDebug("war_ai", "【warai log】[warid%d]GetAutoDisplayTimer设置定时器warId%d,roundNum%d", warId, warId, roundNum)
  local function f()
    local Wid = warId
    local r = roundNum
    if g_WarAiInsList[Wid] == nil then
      printLogDebug("war_ai", "【warai log】[warid%d]GetAutoDisplayTimer设置定时器warId%d,roundNum%d【error】", warId, warId, roundNum)
      return
    end
    g_WarAiInsList[Wid]:DisplayTimesUp(r)
  end
  return f
end
function ClearAllWatchData(watchWarPlayerId)
  printLogDebug("war_ai", "【warai log】ClearAllWatchData 清理玩家%d所有观战信息", watchWarPlayerId)
  if g_WarAiInsList ~= nil then
    for warId, warAIObj in pairs(g_WarAiInsList) do
      warAIObj:DelPlayerWatchWar(watchWarPlayerId)
    end
  end
end
if not CWarAI then
  CWarAI = class("CWarAI", CRoleFactory)
end
function CWarAI:ctor(warParams)
  printLogDebug("war_ai", "【warai log】[warid%d]create CWarAI开始", warParams.warID)
  CWarAI.super.ctor(self, {
    [tostring(LOGICTYPE_PET)] = CPetAI,
    [tostring(LOGICTYPE_HERO)] = CHeroAI,
    [tostring(LOGICTYPE_MONSTER)] = CMonsterAI
  })
  self.m_WarStartTimePoint = os.time()
  warParams = warParams or {}
  self.m_WarID = warParams.warID
  g_WarAiInsList[self.m_WarID] = self
  self.m_WarType = warParams.warType
  self.m_MaxRoundCnt = GetWarMaxRound(self.m_WarType)
  self.m_SingleFlag = warParams.singleFlag
  self.m_WarTypeData = warParams.warTypeData or {}
  self.m_CurrRoundCnt = 0
  self.m_WarBaseData = {}
  self.m_WarSeqData = {}
  self.m_HistoryData = {}
  self.m_WarRoleListID = 0
  self.m_Roles = {}
  self.m_AliveTeamers = {
    lt = {},
    rb = {}
  }
  self.m_TeamFlagDict = {
    [TEAM_ATTACK] = {},
    [TEAM_DEFEND] = {}
  }
  self.m_OffLinePlayerIdList = {}
  self.m_TellPlayerOffLineFlagList = {}
  self.m_WatchWarPlayerDict = {}
  self.m_TempPetData = {}
  self.m_WarPetList = {}
  self.m_RecordOldPetList = {}
  self.m_PetNumList = {}
  self.m_SkillProficiency = {}
  self.m_UseDrugDict = {}
  self.m_PetCloseDict = {}
  self.m_FightSeq = {}
  self.m_FightedPos = {}
  self.m_LastFightSeqIdx = 0
  self.m_IsBeforeRoundFlag = true
  self.m_SendToPlayersOpData = {}
  self.m_ProtectData = {}
  self.m_HuoDongData = {}
  self.m_AttackFirstUseMagicSkillHurtHp = 0
  self.m_DefendFirstUseMagicSkillHurtHp = 0
  self.m_AttackFirstUseMagicSkillHurtMp = 0
  self.m_DefendFirstUseMagicSkillHurtMp = 0
  self.m_DeadCallbackData = {}
  self.m_AttackFirstUseMagicSkillHuaWu = true
  self.m_DefendFirstUseMagicSkillHuaWu = true
  self.m_AttackZhaoYunMuYuDoubleFlag = true
  self.m_DefendZhaoYunMuYuDoubleFlag = true
  self.m_EndWarFlag = false
  self.m_OneRoundSetting = {}
  self.m_RunAwayPlayerIDListOneRound = {}
  self.m_RunAwayPlayerIDListOneWar = {}
  self.m_FinishDisplayPlayerIdList = {}
  self.m_StartWaitDisplayTimer = false
  self.m_AcceptActionRound = -1
  self.m_AcceptFinishRound = -1
  self.m_AcceptSettingTimesupRound = -1
  self.m_AcceptDisplayTimesupRound = -1
  self.m_ConfuseEscapeTimes = 0
  self.m_EndWarData = nil
  self.m_EndWarFlag_S = false
  self.m_RecordHpMpData = {}
  printLogDebug("war_ai", "【warai log】[warid%d]create CWarAI结束", self.m_WarID)
end
function CWarAI:getObjectByPos(pos)
  return self.m_Roles[pos]
end
function CWarAI:getMyAliveTeamerPos()
  return self.m_AliveTeamers.rb
end
function CWarAI:getEnemyAliveTeamerPos()
  return self.m_AliveTeamers.lt
end
function CWarAI:getHostileAliveTeamerPos(pos)
  if pos > DefineDefendPosNumberBase then
    return self.m_AliveTeamers.rb
  else
    return self.m_AliveTeamers.lt
  end
end
function CWarAI:getAlliesAliveTeamerPos(pos)
  if pos > DefineDefendPosNumberBase then
    return self.m_AliveTeamers.lt
  else
    return self.m_AliveTeamers.rb
  end
end
function CWarAI:newObject(playerId, objId, lTypeId, pos, copyProperties, warID)
  local lType = GetRoleObjType(lTypeId)
  local cls = self.m_Classes[tostring(lType)]
  if cls == nil then
    printLogDebug("war_ai", "创建类型[%s]的对象出错：找不到该类型的类", tostring(lType))
    return nil
  end
  local obj = cls.new(self.m_WarID, playerId, objId, lTypeId, pos, copyProperties, warID)
  if obj then
    self.m_Roles[pos] = obj
    obj:setPropertyChanagedListener(handler(self, self.ObjectPropertyChanged))
  end
  return obj
end
function CWarAI:CreateOneRole(pos, obj, teamFlag)
  printLogDebug("war_ai", "【warai log】[warid%d]CreateOneRole", self.m_WarID, pos)
  if obj == nil then
    printLogDebug("war_ai", "【warai log】[warid%d]error --CreateOneRol,传进来的obj为空", self.m_WarID, pos)
    return
  end
  if WAR_CODE_IS_SERVER ~= true then
  elseif obj:getType() == LOGICTYPE_HERO or obj:getType() == LOGICTYPE_PET then
    obj:CalculateProperty()
  end
  local oldRole = self.m_Roles[pos]
  if oldRole ~= nil then
    local oldPlayerId = oldRole:getPlayerId()
    local oldRoleId = oldRole:getObjId()
    local petObj = self:getTempPetObjById(oldPlayerId, oldRoleId)
    if petObj ~= nil then
      self:setTempPetObj(oldPlayerId, oldRole)
    end
  end
  local newRoleId = obj:getObjId()
  local newPlayerId = obj:getPlayerId()
  local role = self:newObject(newPlayerId, newRoleId, obj:getTypeId(), pos, obj:getProSerialization())
  local petObj = self:getTempPetObjById(newPlayerId, newRoleId)
  if petObj ~= nil then
    self:setHasWarPetObjFlag(newPlayerId, newRoleId, true)
  end
  role:setProperty(PROPERTY_TEAM, teamFlag)
  local teamerTable
  if teamFlag == TEAM_DEFEND then
    teamerTable = self.m_AliveTeamers.lt
  else
    teamerTable = self.m_AliveTeamers.rb
  end
  for i = 1, #teamerTable do
    if teamerTable[i] == pos then
      table.remove(teamerTable, i)
      break
    end
  end
  if teamFlag == TEAM_DEFEND then
    self.m_AliveTeamers.lt[#self.m_AliveTeamers.lt + 1] = pos
  else
    self.m_AliveTeamers.rb[#self.m_AliveTeamers.rb + 1] = pos
  end
  if self.m_TeamFlagDict[teamFlag][newPlayerId] == nil then
    self.m_TeamFlagDict[teamFlag][newPlayerId] = {}
  end
  self:CalculateSpeed(role)
  if self.m_TellPlayerOffLineFlagList[newPlayerId] == nil then
    self.m_TellPlayerOffLineFlagList[newPlayerId] = true
  end
end
function CWarAI:CreateNPCEnemy(warRoleListId)
  printLogDebug("war_ai", "【warai log】[warid%d]CreateNPCEnemy%d", self.m_WarID, warRoleListId)
  local posList = data_getWarPosList(warRoleListId)
  self.m_WarRoleListID = warRoleListId
  local tempRoleFactory = CRoleFactory.new()
  for pos, mstID in pairs(posList) do
    local playerId = FUBEN_PLAYERID
    local mst = tempRoleFactory:newObject(playerId, getInsId(LOGICTYPE_MONSTER), mstID, nil, self.m_WarID)
    local lv = data_getRoleProFromData(mst:getTypeId(), PROPERTY_MONSTERLEVEL)
    local levelMode = data_getRoleProFromData(mst:getTypeId(), PROPERTY_MLEVELMODE)
    if levelMode == MONSTER_LEVLEMODE_NORMAL then
    elseif levelMode == MONSTER_LEVLEMODE_ZHUOGUI then
      lv = self:GetZHUOGUILV() + lv
    elseif levelMode == MONSTER_LEVLEMODE_TIANTING then
      lv = self:GetTIANTINGLV() + lv
    elseif levelMode == MONSTER_LEVLEMODE_CAPTAIN then
      lv = self:GetCAPTAINLV() + lv
    end
    mst:setProperty(PROPERTY_ROLELEVEL, lv)
    mst:CalculateProperty()
    self:CreateOneRole(pos, mst, TEAM_DEFEND)
  end
end
function CWarAI:CreateOneNPCFriend(playerId, mstID, pos)
  printLogDebug("war_ai", "【warai log】[warid%d]CreateOneNPCFriend%d", self.m_WarID, playerId, mstType, pos)
  local playerId = playerId
  if playerId ~= nil then
    local tempRoleFactory = CRoleFactory.new()
    local mst = tempRoleFactory:newObject(playerId, getInsId(LOGICTYPE_MONSTER), mstID, nil, self.m_WarID)
    local lv = data_getRoleProFromData(mst:getTypeId(), PROPERTY_MONSTERLEVEL)
    mst:setProperty(PROPERTY_ROLELEVEL, lv)
    mst:CalculateProperty()
    self:CreateOneRole(pos, mst, TEAM_ATTACK)
  end
end
function CWarAI:GetNPCEnemyListID()
  return self.m_WarRoleListID
end
function CWarAI:GetIsNotOpPlayer(playerID)
  if playerID == FUBEN_PLAYERID then
    return true
  elseif self.m_WarType == WARTYPE_BIWU then
    for tempPlayerId, _ in pairs(self.m_TeamFlagDict[TEAM_DEFEND]) do
      if tempPlayerId == playerID then
        return true
      end
    end
  end
  return false
end
function CWarAI:GetAllPlayerID()
  local playerIDList = {}
  for _, data in pairs(self.m_TeamFlagDict) do
    for tempPlayerId, _ in pairs(data) do
      if self:GetIsNotOpPlayer(tempPlayerId) then
      else
        playerIDList[#playerIDList + 1] = tempPlayerId
      end
    end
  end
  return playerIDList
end
function CWarAI:GetMainHeroPosByPlayerID(playerID)
  local mainHeroPos
  for pos, role in pairs(self.m_Roles) do
    local rolePlayerId = role:getPlayerId()
    local rolePlayer = WarAIGetOnePlayerData(self.m_WarID, rolePlayerId)
    local roleId = role:getObjId()
    if rolePlayer ~= nil and rolePlayerId == playerID and roleId == rolePlayer:getMainHeroId() then
      mainHeroPos = pos
      break
    end
  end
  return mainHeroPos
end
function CWarAI:GetZHUOGUILV()
  local sLvList = {}
  local maxSLv = 0
  local pNum = 0
  local sumSLv = 0
  for playerId, _ in pairs(self.m_TeamFlagDict[TEAM_ATTACK]) do
    local heroPos = self:GetMainHeroPosByPlayerID(playerId)
    if heroPos ~= nil then
      local role = self.m_Roles[heroPos]
      if role ~= nil then
        local sLv = role:getProperty(PROPERTY_ROLELEVEL) + role:getProperty(PROPERTY_ZHUANSHENG) * 10
        sLvList[#sLvList + 1] = sLv
        if maxSLv < sLv then
          maxSLv = sLv
        end
        sumSLv = sumSLv + sLv
        pNum = pNum + 1
      end
    end
  end
  if pNum == 0 then
    printLogDebug("war_ai", "【warai log】[warid%d]GetZHUOGUILV异常~~~~pNum=0", self.m_WarID)
    return 0
  end
  local returnNum = math.floor((maxSLv + sumSLv / pNum) / 2)
  returnNum = math.floor(returnNum)
  return returnNum
end
function CWarAI:GetCAPTAINLV()
  local captainPlayerId
  if WAR_CODE_IS_SERVER ~= true then
    captainPlayerId = g_LocalPlayer:getPlayerId()
  else
    for playerId, _ in pairs(self.m_TeamFlagDict[TEAM_ATTACK]) do
      local rolePlayer = WarAIGetOnePlayerData(self.m_WarID, playerId)
      if rolePlayer.getIsCaptain and rolePlayer:getIsCaptain() then
        captainPlayerId = playerId
        break
      end
    end
  end
  local cpMainRolePos = self:GetMainHeroPosByPlayerID(captainPlayerId)
  if cpMainRolePos ~= nil then
    local cpMainRole = self.m_Roles[cpMainRolePos]
    if cpMainRole ~= nil then
      local captainLv = cpMainRole:getProperty(PROPERTY_ROLELEVEL)
      local captainZs = cpMainRole:getProperty(PROPERTY_ZHUANSHENG)
      return captainLv + captainZs * 10
    end
  end
  return 0
end
function CWarAI:GetTIANTINGLV()
  local sLvList = {}
  local maxSLv = 0
  local pNum = 0
  local sumSLv = 0
  for playerId, _ in pairs(self.m_TeamFlagDict[TEAM_ATTACK]) do
    local heroPos = self:GetMainHeroPosByPlayerID(playerId)
    if heroPos ~= nil then
      local role = self.m_Roles[heroPos]
      if role ~= nil then
        local sLv = role:getProperty(PROPERTY_ROLELEVEL) + role:getProperty(PROPERTY_ZHUANSHENG) * 10
        sLvList[#sLvList + 1] = sLv
        if maxSLv < sLv then
          maxSLv = sLv
        end
        sumSLv = sumSLv + sLv
        pNum = pNum + 1
      end
    end
  end
  if pNum == 0 then
    printLogDebug("war_ai", "【warai log】[warid%d]GetTIANTINGLV异常~~~~pNum=0", self.m_WarID)
    return 0
  end
  printLogDebug("war_ai", "【warai log】[warid%d]GetTIANTINGLV   maxSLv%d,sumSLv%d", self.m_WarID, maxSLv, sumSLv)
  local returnNum = math.floor((maxSLv + sumSLv / pNum) / 2)
  local tNum = self.m_WarTypeData.i_tNum or 0
  returnNum = returnNum - 10 + tNum * 4
  printLogDebug("war_ai", "【warai log】[warid%d]GetTIANTINGLV%d,tNum%d", self.m_WarID, returnNum, tNum)
  return returnNum
end
function CWarAI:GetWarResult()
  local result = WARRESULT_NONE
  local attackTeamDeadFlag = true
  local defendTeamDeadFlag = true
  for playerId, playerFlagData in pairs(self.m_TeamFlagDict[TEAM_ATTACK]) do
    if playerFlagData.alldeadFlag == false and playerFlagData.runawayFlag == false then
      attackTeamDeadFlag = false
      break
    end
  end
  for playerId, playerFlagData in pairs(self.m_TeamFlagDict[TEAM_DEFEND]) do
    if playerFlagData.alldeadFlag == false and playerFlagData.runawayFlag == false then
      defendTeamDeadFlag = false
      break
    end
  end
  if self.m_WarType == WARTYPE_BpWAR then
    for playerId, playerFlagData in pairs(self.m_TeamFlagDict[TEAM_ATTACK]) do
      if playerFlagData.runawayFlag == true then
        attackTeamDeadFlag = true
        break
      end
    end
    for playerId, playerFlagData in pairs(self.m_TeamFlagDict[TEAM_DEFEND]) do
      if playerFlagData.runawayFlag == true then
        defendTeamDeadFlag = true
        break
      end
    end
  end
  if self.m_WarType == WARTYPE_BaoHuChangE then
    local changE_Obj = self.m_Roles[PROTECTCHANGE_ChangeE_Pos]
    if changE_Obj == nil then
      return WARRESULT_ATTACK_LOSE
    elseif changE_Obj:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD then
      return WARRESULT_ATTACK_LOSE
    end
  end
  if IsAllDeadAsDaPingWarType(self.m_WarType) then
    if attackTeamDeadFlag and defendTeamDeadFlag then
      result = WARRESULT_DaPing
    elseif attackTeamDeadFlag then
      result = WARRESULT_ATTACK_LOSE
    elseif defendTeamDeadFlag then
      result = WARRESULT_ATTACK_WIN
    end
  elseif attackTeamDeadFlag then
    result = WARRESULT_ATTACK_LOSE
  elseif defendTeamDeadFlag then
    result = WARRESULT_ATTACK_WIN
  end
  return result
end
function CWarAI:SetOneRoleAction(roundNum, playerId, roleId, pos, actionDict)
  printLogDebug("war_ai", "【warai log】[warid%d]SetOneRoleAction playerId%d , roleId%d, pos%d", self.m_WarID, playerId, roleId, pos)
  if self.m_AcceptActionRound == -1 or self.m_AcceptActionRound ~= roundNum then
    printLogDebug("war_ai", "【warai log】[warid%d]SetOneRoleAction 当前需要设置的回合是%d, 设置的回合是%d ,对不上，直接无视", self.m_WarID, self.m_AcceptActionRound, roundNum)
    return
  end
  if not self:IsInWarPlayer(playerId) then
    printLogDebug("war_ai", "【warai log】[warid%d]SetOneRoleAction %d玩家不是在战斗的玩家 ,对不上，直接无视", self.m_WarID, playerId)
    return
  end
  local curRole = self.m_Roles[pos]
  if curRole == nil then
    printLogDebug("war_ai", "【warai log】[warid%d]SetOneRoleAction 角色数据对不上，ai里面%dpos的位置是空的", self.m_WarID, pos)
    return
  end
  local curPlayerId = curRole:getPlayerId()
  local curRoleId = curRole:getObjId()
  if playerId ~= curPlayerId or curRoleId ~= roleId then
    printLogDebug("war_ai", "【warai log】[warid%d]SetOneRoleAction 角色数据对不上，ai里面%dpos的位置是(玩家%d的角色%d),传进来的是(玩家%d的角色%d)", self.m_WarID, pos, curPlayerId, curRoleId, playerId, roleId)
    return
  end
  if actionDict == nil then
    printLogDebug("war_ai", "【warai log】[warid%d]SetOneRoleAction 操作为空，玩家%d的角色%d操作为空", self.m_WarID, playerId, roleId)
    return
  end
  self.m_OneRoundSetting[pos] = actionDict
  AISendOneRoleWarStateChange(self.m_WarID, self.m_SingleFlag, pos, ROLE_WAR_STATE_READY)
  local endRoundFlag = true
  for _, tempPlayerId in pairs(self:GetAllPlayerID()) do
    if self.m_OffLinePlayerIdList[tempPlayerId] ~= true then
      local setHeroPos = self:GetMainHeroPosByPlayerID(tempPlayerId)
      if setHeroPos ~= nil then
        local heroNeedSetFlag = false
        local role = self.m_Roles[setHeroPos]
        if role ~= nil and (role:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE or role:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD) then
          heroNeedSetFlag = true
        end
        local setPetPos = setHeroPos + DefineRelativePetAddPos
        local petNeedSetFlag = false
        local pet = self.m_Roles[setPetPos]
        if pet ~= nil and pet:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
          petNeedSetFlag = true
        end
        if setHeroPos ~= nil and heroNeedSetFlag == true and self.m_OneRoundSetting[setHeroPos] == nil or setPetPos ~= nil and petNeedSetFlag == true and self.m_OneRoundSetting[setPetPos] == nil then
          endRoundFlag = false
          break
        end
      end
    end
  end
  self:SetOfflinePlayerDefaultOperation()
  if endRoundFlag then
    printLogDebug("war_ai", "【warai log】[warid%d]SetOneRoleAction 之后，发现需要设置的，都设置完了", self.m_WarID)
    AIDoOneRound(self.m_WarID, self.m_OneRoundSetting)
  end
end
function CWarAI:SetOfflinePlayerDefaultOperation()
  for _, tempPlayerId in pairs(self:GetAllPlayerID()) do
    if self.m_OffLinePlayerIdList[tempPlayerId] == true then
      local setHeroPos = self:GetMainHeroPosByPlayerID(tempPlayerId)
      if setHeroPos ~= nil then
        local role = self.m_Roles[setHeroPos]
        if role ~= nil and self.m_OneRoundSetting[setHeroPos] == nil then
          if role:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
            local defaultOp = role:GetAIAutoOperationData()
            if defaultOp == nil then
              defaultOp = GetDefaultOperation(role:getTypeId(), role:getProperty(PROPERTY_GENDER), role:getProperty(PROPERTY_RACE))
            end
            defaultOp.timesupFlag = true
            self.m_OneRoundSetting[setHeroPos] = defaultOp
          else
            self.m_OneRoundSetting[setHeroPos] = {}
          end
        end
        local setPetPos = setHeroPos + DefineRelativePetAddPos
        local pet = self.m_Roles[setPetPos]
        if pet ~= nil and self.m_OneRoundSetting[setPetPos] == nil and pet:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
          local defaultOp = pet:GetAIAutoOperationData()
          if defaultOp == nil then
            defaultOp = GetDefaultOperation(pet:getTypeId(), pet:getProperty(PROPERTY_GENDER), pet:getProperty(PROPERTY_RACE))
          end
          defaultOp.timesupFlag = true
          self.m_OneRoundSetting[setPetPos] = defaultOp
        end
      end
    end
  end
end
function CWarAI:SetOneplayerFinishPlayOneRound(roundNum, playerId)
  printLogDebug("war_ai", "【warai log】[warid%d]SetOneplayerFinishPlayOneRound, roundNum%d, playerId%d ", self.m_WarID, roundNum, playerId)
  if self.m_AcceptFinishRound == -1 or self.m_AcceptFinishRound ~= roundNum then
    printLogDebug("war_ai", "【warai log】[warid%d]SetOneplayerFinishPlayOneRound 当前接受结束的回合是%d, 传进来播放完的回合是%d ,对不上，直接无视", self.m_WarID, self.m_AcceptFinishRound, roundNum)
    return
  end
  local isRunAway = false
  local isLastOne = false
  for _, data in pairs(self.m_TeamFlagDict) do
    local pData = data[playerId]
    if pData ~= nil and pData.runawayFlag == true then
      isRunAway = true
      break
    end
  end
  local isLastOne = true
  for _, data in pairs(self.m_TeamFlagDict) do
    for tempPID, pData in pairs(data) do
      if pData.runawayFlag ~= true and self.m_FinishDisplayPlayerIdList[tempPID] == nil and self.m_OffLinePlayerIdList[tempPID] ~= true and tempPID ~= FUBEN_PLAYERID then
        local opPlayerFlag = false
        for _, opPlayerID in pairs(self:GetAllPlayerID()) do
          if tempPID == opPlayerID then
            opPlayerFlag = true
            break
          end
        end
        if opPlayerFlag == true then
          isLastOne = false
          break
        end
      end
    end
  end
  if isRunAway and isLastOne then
    printLogDebug("war_ai", "【warai log】[warid%d]SetOneplayerFinishPlayOneRound,收到最后一个逃跑的人的表现结束包，直接结束", self.m_WarID)
    if self:SendEndWarData() then
      return
    end
  end
  if not self:IsInWarPlayer(playerId) then
    printLogDebug("war_ai", "【warai log】[warid%d]SetOneplayerFinishPlayOneRound %d玩家不是在战斗的玩家 ,对不上，直接无视", self.m_WarID, playerId)
    return
  end
  self.m_FinishDisplayPlayerIdList[playerId] = true
  if self.m_StartWaitDisplayTimer == false then
    self.m_StartWaitDisplayTimer = true
    local displayTimer = GetDisplayTimer(self.m_WarID, self.m_AcceptDisplayTimesupRound)
    if g_gametimer then
      g_gametimer:timeout(displayTimer, WaitDisplayTime + DelayTime, "displayTimer")
    end
    printLogDebug("war_ai", "【warai log】[warid%d]SetOneplayerFinishPlayOneRound,收到第一个表现完的包，看看是否要结束", self.m_WarID)
    if self:SendEndWarData() then
      return
    end
  end
  local allPlayerFinishDisplayFlag = true
  for _, data in pairs(self.m_TeamFlagDict) do
    for playerId, playerFlagData in pairs(data) do
      local opPlayerFlag = false
      for _, tempPlayerId in pairs(self:GetAllPlayerID()) do
        if playerId == tempPlayerId then
          opPlayerFlag = true
          break
        end
      end
      if playerFlagData.runawayFlag ~= true and opPlayerFlag == true and self.m_FinishDisplayPlayerIdList[playerId] == nil and self.m_OffLinePlayerIdList[playerId] ~= true and playerId ~= FUBEN_PLAYERID then
        allPlayerFinishDisplayFlag = false
        break
      end
    end
  end
  if allPlayerFinishDisplayFlag then
    self:DisplayTimesUp(roundNum)
  end
end
function CWarAI:DisplayTimesUp(roundNum)
  printLogDebug("war_ai", "【warai log】[warid%d]DisplayTimesUp, roundNum%d, ", self.m_WarID, roundNum)
  if self.m_AcceptDisplayTimesupRound == -1 or self.m_AcceptDisplayTimesupRound ~= roundNum then
    printLogDebug("war_ai", "【warai log】[warid%d]DisplayTimesUp 现在是在等待播放%d回合, 等待播放定时器回合%d的时间到了，可以不管", self.m_WarID, self.m_AcceptDisplayTimesupRound, roundNum)
    return
  end
  printLogDebug("war_ai", "【warai log】[warid%d]DisplayTimesUp,表现时间到，看看是否要结束", self.m_WarID)
  if self:SendEndWarData() then
    return
  end
  self.m_AcceptActionRound = roundNum + 1
  self.m_AcceptFinishRound = -1
  self.m_AcceptSettingTimesupRound = roundNum + 1
  self.m_AcceptDisplayTimesupRound = -1
  local endRoundFlag = true
  for _, tempPlayerId in pairs(self:GetAllPlayerID()) do
    if self.m_OffLinePlayerIdList[tempPlayerId] ~= true then
      local setHeroPos = self:GetMainHeroPosByPlayerID(tempPlayerId)
      if setHeroPos ~= nil then
        local heroNeedSetFlag = false
        local role = self.m_Roles[setHeroPos]
        if role ~= nil and (role:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE or role:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD) then
          heroNeedSetFlag = true
        end
        local setPetPos = setHeroPos + DefineRelativePetAddPos
        local petNeedSetFlag = false
        local pet = self.m_Roles[setPetPos]
        if pet ~= nil and pet:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
          petNeedSetFlag = true
        end
        if setHeroPos ~= nil and heroNeedSetFlag == true and self.m_OneRoundSetting[setHeroPos] == nil or setPetPos ~= nil and petNeedSetFlag == true and self.m_OneRoundSetting[setPetPos] == nil then
          endRoundFlag = false
          break
        end
      end
    end
  end
  self:SetOfflinePlayerDefaultOperation()
  if endRoundFlag then
    printLogDebug("war_ai", "【warai log】[warid%d]DisplayTimesUp 之后，发现没有需要操作的角色，直接开始下个回合", self.m_WarID)
    AIDoOneRound(self.m_WarID, self.m_OneRoundSetting)
  else
    self:SendAllWarState()
    for pId, _ in pairs(self.m_TeamFlagDict[TEAM_ATTACK]) do
      if pId ~= FUBEN_PLAYERID and self.m_TeamFlagDict[TEAM_ATTACK][pId].runawayFlag ~= true then
        local opData = self.m_SendToPlayersOpData[pId] or {}
        AISendPlayerSetOneRound(self.m_WarID, self.m_SingleFlag, pId, self.m_AcceptActionRound, opData)
      end
    end
    for pId, _ in pairs(self.m_TeamFlagDict[TEAM_DEFEND]) do
      if self.m_WarType ~= WARTYPE_BIWU and pId ~= FUBEN_PLAYERID and self.m_TeamFlagDict[TEAM_DEFEND][pId].runawayFlag ~= true then
        local opData = self.m_SendToPlayersOpData[pId] or {}
        AISendPlayerSetOneRound(self.m_WarID, self.m_SingleFlag, pId, self.m_AcceptActionRound, opData)
      end
    end
    local settingTimer = GetSettingTimer(self.m_WarID, self.m_AcceptSettingTimesupRound)
    if g_gametimer then
      g_gametimer:timeout(settingTimer, WaitSettingTime + DelayTime, "settingTimer")
    end
  end
end
function CWarAI:SettingTimesUp(roundNum)
  printLogDebug("war_ai", "【warai log】[warid%d]SettingTimesUp, roundNum%d, ", self.m_WarID, roundNum)
  if self.m_AcceptSettingTimesupRound == -1 or self.m_AcceptSettingTimesupRound ~= roundNum then
    printLogDebug("war_ai", "【warai log】[warid%d]SettingTimesUp 现在已经是%d回合了, 等待设置定时器回合%d的时间到了，可以不管", self.m_WarID, self.m_AcceptSettingTimesupRound, roundNum)
    return
  end
  for _, tempPlayerId in pairs(self:GetAllPlayerID()) do
    local setHeroPos = self:GetMainHeroPosByPlayerID(tempPlayerId)
    if setHeroPos ~= nil then
      local heroNeedSetFlag = false
      local role = self.m_Roles[setHeroPos]
      if role ~= nil then
        heroNeedSetFlag = true
      end
      local setPetPos = setHeroPos + DefineRelativePetAddPos
      local petNeedSetFlag = false
      local pet = self.m_Roles[setPetPos]
      if pet ~= nil and pet:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
        petNeedSetFlag = true
      end
      if setHeroPos ~= nil and heroNeedSetFlag == true and self.m_OneRoundSetting[setHeroPos] == nil then
        if role:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD then
          self.m_OneRoundSetting[setHeroPos] = {}
        else
          local defaultOp = role:GetAIAutoOperationData()
          if defaultOp == nil then
            defaultOp = GetDefaultOperation(role:getTypeId(), role:getProperty(PROPERTY_GENDER), role:getProperty(PROPERTY_RACE))
          end
          defaultOp.timesupFlag = true
          self.m_OneRoundSetting[setHeroPos] = defaultOp
        end
      end
      if setPetPos ~= nil and petNeedSetFlag == true and self.m_OneRoundSetting[setPetPos] == nil then
        local defaultOp = pet:GetAIAutoOperationData()
        if defaultOp == nil then
          defaultOp = GetDefaultOperation(pet:getTypeId(), pet:getProperty(PROPERTY_GENDER), pet:getProperty(PROPERTY_RACE))
        end
        defaultOp.timesupFlag = true
        self.m_OneRoundSetting[setPetPos] = defaultOp
      end
    end
  end
  printLogDebug("war_ai", "【warai log】[warid%d]SettingTimesUp 之后，开始回合", self.m_WarID)
  AIDoOneRound(self.m_WarID, self.m_OneRoundSetting)
end
function CWarAI:SettingSerDisplayTimer()
  printLogDebug("war_ai", "【warai log】[warid%d]SettingSerDisplayTimer, roundNum%d, ", self.m_WarID, self.m_AcceptDisplayTimesupRound)
  if g_gametimer then
    local allOffLine = true
    for _, tempPlayerId in pairs(self:GetAllPlayerID()) do
      if self.m_OffLinePlayerIdList[tempPlayerId] ~= true then
        if self.m_TeamFlagDict[TEAM_ATTACK][tempPlayerId] ~= nil then
          if self.m_TeamFlagDict[TEAM_ATTACK][tempPlayerId].runawayFlag ~= true then
            allOffLine = false
            break
          end
        elseif self.m_TeamFlagDict[TEAM_DEFEND][tempPlayerId] ~= nil then
          if self.m_TeamFlagDict[TEAM_DEFEND][tempPlayerId].runawayFlag ~= true then
            allOffLine = false
            break
          end
        else
          allOffLine = false
          break
        end
      end
    end
    local time = EndDisplayTime_AllOffLine + DelayTime
    if not allOffLine then
      time = EndDisplayTime_OnLine
    else
      time = EndDisplayTime_AllOffLine + DelayTime
    end
    printLogDebug("war_ai", "【warai log】[warid%d]SettingSerDisplayTimer, roundNum%d,time%d ", self.m_WarID, self.m_AcceptDisplayTimesupRound, time)
    if (self.m_AutoDisplayTimerTime == nil or time < self.m_AutoDisplayTimerTime) and self.m_AcceptDisplayTimesupRound and self.m_AcceptDisplayTimesupRound ~= -1 then
      local autoDisplayTimer = GetAutoDisplayTimer(self.m_WarID, self.m_AcceptDisplayTimesupRound)
      g_gametimer:timeout(autoDisplayTimer, time, "autoDisplayTimer")
      self.m_AutoDisplayTimerTime = time
    end
  end
end
function CWarAI:setPlayerIsOffLine(playerId, flag, tellOtherPlayerFlag)
  if tellOtherPlayerFlag == nil then
    tellOtherPlayerFlag = true
  end
  self.m_TellPlayerOffLineFlagList[playerId] = tellOtherPlayerFlag
  local inflag = false
  for _, tempPlayerID in pairs(self:GetAllPlayerID()) do
    if playerId == tempPlayerID then
      inflag = true
    end
  end
  if inflag == false then
    printLogDebug("war_ai", "【warai log】[warid%d]setPlayerIsOffLine,palyerId%d 不在这场战斗中，直接无视", self.m_WarID, playerId)
    return
  end
  local setHeroPos
  local heroNeedSetFlag = false
  local setPetPos
  local petNeedSetFlag = false
  for pos, role in pairs(self.m_Roles) do
    local rolePlayerId = role:getPlayerId()
    local rolePlayer = WarAIGetOnePlayerData(self.m_WarID, rolePlayerId)
    local roleId = role:getObjId()
    if rolePlayerId == playerId and rolePlayerId ~= FUBEN_PLAYERID and roleId == rolePlayer:getMainHeroId() then
      setHeroPos = pos
      if role:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE or role:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD then
        heroNeedSetFlag = true
      end
      break
    end
  end
  if setHeroPos ~= nil then
    setPetPos = setHeroPos + DefineRelativePetAddPos
    petNeedSetFlag = false
    local pet = self.m_Roles[setPetPos]
    if pet ~= nil and pet:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
      petNeedSetFlag = true
    end
  end
  if flag then
    printLogDebug("war_ai", "【warai log】[warid%d]setPlayerIsOffLine,palyerId%d 离线", self.m_WarID, playerId)
    self.m_OffLinePlayerIdList[playerId] = true
    if setHeroPos ~= nil and heroNeedSetFlag == true and tellOtherPlayerFlag then
      AISendOneRoleWarStateChange(self.m_WarID, self.m_SingleFlag, setHeroPos, ROLE_WAR_STATE_OFFLINE)
    end
    if setPetPos ~= nil and petNeedSetFlag == true and tellOtherPlayerFlag then
      AISendOneRoleWarStateChange(self.m_WarID, self.m_SingleFlag, setPetPos, ROLE_WAR_STATE_OFFLINE)
    end
    self:SettingSerDisplayTimer()
  else
    printLogDebug("war_ai", "【warai log】[warid%d]setPlayerIsOffLine,palyerId%d 再次上线", self.m_WarID, playerId)
    self.m_OffLinePlayerIdList[playerId] = nil
    if setHeroPos ~= nil and heroNeedSetFlag == true then
      AISendOneRoleWarStateChange(self.m_WarID, self.m_SingleFlag, setHeroPos, ROLE_WAR_STATE_SETTING)
    end
    if setPetPos ~= nil and petNeedSetFlag == true then
      AISendOneRoleWarStateChange(self.m_WarID, self.m_SingleFlag, setPetPos, ROLE_WAR_STATE_SETTING)
    end
    self:SendAllHistory(playerId)
  end
  local result = self:GetWarResult()
  if result == WARRESULT_ATTACK_WIN or result == WARRESULT_ATTACK_LOSE or result == WARRESULT_DaPing then
    local allOffLine = true
    for _, tempPlayerId in pairs(self:GetAllPlayerID()) do
      if self.m_OffLinePlayerIdList[tempPlayerId] ~= true then
        if self.m_TeamFlagDict[TEAM_ATTACK][tempPlayerId] ~= nil then
          if self.m_TeamFlagDict[TEAM_ATTACK][tempPlayerId].runawayFlag ~= true then
            allOffLine = false
            break
          end
        elseif self.m_TeamFlagDict[TEAM_DEFEND][tempPlayerId] ~= nil then
          if self.m_TeamFlagDict[TEAM_DEFEND][tempPlayerId].runawayFlag ~= true then
            allOffLine = false
            break
          end
        else
          allOffLine = false
          break
        end
      end
    end
    if allOffLine then
      printLogDebug("war_ai", "【warai log】[warid%d]有玩家断线，触发了，战斗结束(在表现阶段全部人断线才会这样)", self.m_WarID)
      self:EndWar()
      self.m_EndWarFlag_S = true
      self:DisplayTimesUp(self.m_AcceptDisplayTimesupRound)
      self:SettingTimesUp(self.m_AcceptSettingTimesupRound)
    end
  end
end
function CWarAI:SendAllWarState()
  printLogDebug("war_ai", "【warai log】[warid%d]SendAllWarState", self.m_WarID)
  local stateTable = {}
  for _, tempPlayerId in pairs(self:GetAllPlayerID()) do
    local setHeroPos = self:GetMainHeroPosByPlayerID(tempPlayerId)
    if setHeroPos ~= nil then
      local heroNeedSetFlag = false
      local role = self.m_Roles[setHeroPos]
      if role ~= nil and (role:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE or role:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD) then
        heroNeedSetFlag = true
      end
      local setPetPos = setHeroPos + DefineRelativePetAddPos
      local petNeedSetFlag = false
      local pet = self.m_Roles[setPetPos]
      if pet ~= nil and pet:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
        petNeedSetFlag = true
      end
      if setHeroPos ~= nil and heroNeedSetFlag == true then
        if self.m_OffLinePlayerIdList[tempPlayerId] == true and self.m_TellPlayerOffLineFlagList[tempPlayerId] then
          stateTable[#stateTable + 1] = {i_p = setHeroPos, i_t = ROLE_WAR_STATE_OFFLINE}
        else
          stateTable[#stateTable + 1] = {i_p = setHeroPos, i_t = ROLE_WAR_STATE_SETTING}
        end
      end
      if setPetPos ~= nil and petNeedSetFlag == true then
        if self.m_OffLinePlayerIdList[tempPlayerId] == true and self.m_TellPlayerOffLineFlagList[tempPlayerId] then
          stateTable[#stateTable + 1] = {i_p = setPetPos, i_t = ROLE_WAR_STATE_OFFLINE}
        else
          stateTable[#stateTable + 1] = {i_p = setPetPos, i_t = ROLE_WAR_STATE_SETTING}
        end
      end
    end
  end
  AISendRolesWarStateChange(self.m_WarID, self.m_SingleFlag, stateTable)
end
function CWarAI:RoleFuhuo(pos)
  printLogDebug("war_ai", "【warai log】[warid%d]RoleFuhuo   pos%d", self.m_WarID, pos)
  local hasInFlag = false
  local teamerTable = self:getAlliesAliveTeamerPos(pos)
  for i = 1, #teamerTable do
    if teamerTable[i] == pos then
      hasInFlag = true
      break
    end
  end
  if hasInFlag == false then
    teamerTable[#teamerTable + 1] = pos
  end
  local hasInFlag = false
  for i = 1, #self.m_FightSeq do
    if self.m_FightSeq[i] == pos then
      hasInFlag = true
      break
    end
  end
  if hasInFlag == false then
    self.m_FightSeq[#self.m_FightSeq + 1] = pos
  end
  self:ReSortSpeedAfterSpChanged()
  local oldRole = self.m_Roles[pos]
  local oldTeamFlag, oldPlayerId, oldRoleId
  if oldRole ~= nil then
    oldTeamFlag = oldRole:getProperty(PROPERTY_TEAM)
    oldPlayerId = oldRole:getPlayerId()
    oldRoleId = oldRole:getObjId()
  end
  if oldTeamFlag ~= nil then
    self.m_TeamFlagDict[oldTeamFlag][oldPlayerId].alldeadFlag = false
  end
end
function CWarAI:RoleHadDeadOrRunaway(pos, newDeadValue)
  printLogDebug("war_ai", "【warai log】[warid%d]RoleHadDeadOrRunaway   pos%d", self.m_WarID, pos)
  local oldRole = self.m_Roles[pos]
  local oldTeamFlag, oldPlayerId, oldRoleId
  if oldRole ~= nil then
    oldTeamFlag = oldRole:getProperty(PROPERTY_TEAM)
    oldPlayerId = oldRole:getPlayerId()
    oldRoleId = oldRole:getObjId()
    if newDeadValue == ROLESTATE_DEAD then
      g_SkillAI.clearAllBuffWhenRoleDie(self.m_WarID, pos)
    end
  end
  local teamerTable = self:getAlliesAliveTeamerPos(pos)
  for i = 1, #teamerTable do
    if teamerTable[i] == pos then
      table.remove(teamerTable, i)
      break
    end
  end
  if oldTeamFlag ~= nil then
    if newDeadValue == ROLESTATE_RUNAWAY then
      if oldPlayerId ~= FUBEN_PLAYERID then
        self.m_TeamFlagDict[oldTeamFlag][oldPlayerId].runawayFlag = true
      end
      local inflag = false
      for _, tempPlayerId in pairs(self.m_RunAwayPlayerIDListOneRound) do
        if tempPlayerId == oldPlayerId then
          inflag = true
          break
        end
      end
      if inflag == false then
        self.m_RunAwayPlayerIDListOneRound[#self.m_RunAwayPlayerIDListOneRound + 1] = oldPlayerId
      end
      inflag = false
      for _, tempPlayerId in pairs(self.m_RunAwayPlayerIDListOneWar) do
        if tempPlayerId == oldPlayerId then
          inflag = true
          break
        end
      end
      if inflag == false then
        self.m_RunAwayPlayerIDListOneWar[#self.m_RunAwayPlayerIDListOneWar + 1] = oldPlayerId
      end
    end
    self.m_TeamFlagDict[oldTeamFlag][oldPlayerId].alldeadFlag = true
    for i = 1, #teamerTable do
      local tempPos = teamerTable[i]
      local tempRole = self.m_Roles[tempPos]
      if tempRole:getPlayerId() == oldPlayerId then
        self.m_TeamFlagDict[oldTeamFlag][oldPlayerId].alldeadFlag = false
        break
      end
    end
  end
  if oldRole ~= nil then
    local petObj = self:getTempPetObjById(oldPlayerId, oldRoleId)
    if petObj ~= nil then
      self:setTempPetObj(oldPlayerId, oldRole)
      if newDeadValue == ROLESTATE_LEAVE then
        g_SkillAI.checkWhenPetLeave(self.m_WarID, pos, oldRole)
      elseif newDeadValue == ROLESTATE_RUNAWAY then
        g_SkillAI.checkWhenPetLeave(self.m_WarID, pos, oldRole)
      end
    end
  end
  if oldRole ~= nil and newDeadValue == ROLESTATE_DEAD then
    self.m_DeadCallbackData[#self.m_DeadCallbackData + 1] = {pos = pos, obj = oldRole}
  end
end
function CWarAI:GetCanConfuseEscape()
  return self.m_ConfuseEscapeTimes < 2
end
function CWarAI:MarkConfuseEscape()
  self.m_ConfuseEscapeTimes = self.m_ConfuseEscapeTimes + 1
end
function CWarAI:ChangeRole(pos, obj, teamFlag)
  printLogDebug("war_ai", "【warai log】[warid%d]ChangeRole", self.m_WarID)
  self:CreateOneRole(pos, obj, teamFlag)
  local hasPetPos = false
  for i = 1, #self.m_FightSeq do
    if self.m_FightSeq[i] == pos then
      hasPetPos = true
      break
    end
  end
  if hasPetPos == false then
    self.m_FightSeq[#self.m_FightSeq + 1] = pos
  end
  self.m_FightedPos[pos] = 1
  self:ReSortSpeedAfterSpChanged()
  self:DelProtectData(pos)
  printLogDebug("war_ai", "【warai log】[warid%d]ChangeRole标识位要设回来", self.m_WarID)
  self.m_TeamFlagDict[teamFlag][obj:getPlayerId()].alldeadFlag = false
end
function CWarAI:getFightPosSeq()
  local tempPosList = {}
  for i, pos in ipairs(self.m_FightSeq) do
    local role = self.m_Roles[pos]
    if role and role:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
      tempPosList[#tempPosList + 1] = pos
    end
  end
  return tempPosList
end
function CWarAI:getFightPosSeqWithDeadPos()
  local tempPosList = {}
  for i, pos in ipairs(self.m_FightSeq) do
    local role = self.m_Roles[pos]
    if role and (role:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE or role:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD) then
      tempPosList[#tempPosList + 1] = pos
    end
  end
  return tempPosList
end
function CWarAI:CalculateSpeed(role)
  if role then
    local sp = role:getProperty(PROPERTY_SP)
    local randomSp = role:getProperty(PROPERTY_RONDOMSP)
    local r
    if randomSp == 0 or randomSp == nil then
      r = math.random(90, 100)
      role:setProperty(PROPERTY_RONDOMSP, r)
    else
      r = randomSp
    end
    sp_ = math.floor(sp * r / 100)
    role:setMaxProperty(PROPERTY_SP, sp_)
  else
    return false
  end
end
function CWarAI:CalculateAllSpeed()
  self.m_FightSeq = {}
  for k, v in pairs(self.m_Roles) do
    if v:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE or v:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD and v:getType() == LOGICTYPE_HERO then
      self.m_FightSeq[#self.m_FightSeq + 1] = k
    end
  end
end
function CWarAI:SortSpeed()
  printLogDebug("war_ai", "【warai log】[warid%d]SortSpeed", self.m_WarID)
  local function compareSpeed(rolePos1, rolePos2)
    if rolePos1 == nil or rolePos2 == nil then
      return false
    end
    local role1 = self:getObjectByPos(rolePos1)
    local role2 = self:getObjectByPos(rolePos2)
    local sp1 = role1:getMaxProperty(PROPERTY_SP)
    local sp2 = role2:getMaxProperty(PROPERTY_SP)
    local t = role1:getTempProperty(PROPERTY_SP)
    local v = 0
    local sv = 0
    if t and t ~= 0 then
      for effectID, value in pairs(t) do
        if effectID == EFFECTTYPE_DEC_SPEED then
          sv = sv + value
        else
          v = v + value
        end
      end
      sp1 = sp1 * (1 + v) + sv
    end
    local t = role2:getTempProperty(PROPERTY_SP)
    local v = 0
    local sv = 0
    if t and t ~= 0 then
      for effectID, value in pairs(t) do
        if effectID == EFFECTTYPE_DEC_SPEED then
          sv = sv + value
        else
          v = v + value
        end
      end
      sp2 = sp2 * (1 + v) + sv
    end
    if sp1 == sp2 then
      return false
    else
      return sp1 > sp2
    end
  end
  table.sort(self.m_FightSeq, compareSpeed)
  self:PrintRoleSpeed()
end
function CWarAI:ReSortSpeedAfterSpChanged()
  printLogDebug("war_ai", "【warai log】[warid%d]ReSortSpeedAfterSpChanged", self.m_WarID)
  self:SortSpeed()
  self.m_LastFightSeqIdx = 0
end
function CWarAI:CalculateProtectData(actionPara)
  self.m_ProtectData = {}
  local tempRole = self:getObjectByPos(tempHeroPos)
  actionPara = actionPara or {}
  for pos, aData in pairs(actionPara) do
    if aData.targetPos ~= nil and aData.aiActionType == AI_ACTION_TYPE_PROTECT then
      local sameSide = pos > DefineDefendPosNumberBase == (aData.targetPos > DefineDefendPosNumberBase)
      if sameSide == true then
        self.m_ProtectData[pos] = aData.targetPos
      end
    end
  end
end
function CWarAI:DelProtectData(pos)
  self.m_ProtectData[pos] = nil
end
function CWarAI:GetProtectDataPos(targetPos)
  for _, pos in ipairs(self.m_FightSeq) do
    if self.m_ProtectData[pos] == targetPos then
      local roleObj = self:getObjectByPos(pos)
      if roleObj ~= nil and roleObj:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
        local confuseFlag = g_SkillAI.getIsConfuse(self.m_WarID, pos)
        local sleepFlag = g_SkillAI.getIsSleep(self.m_WarID, pos)
        local frozenFlag = g_SkillAI.getIsFrozen(self.m_WarID, pos)
        local fengmoFlag = g_SkillAI.getIsFengMo(self.m_WarID, pos)
        if not confuseFlag and not sleepFlag and not frozenFlag and not fengmoFlag then
          return pos
        end
      end
    end
  end
  return nil
end
function CWarAI:SetPlayerWatchWar(inWarPlayerId, watchWarPlayerId, watcherData)
  printLogDebug("war_ai", "【warai log】[warid%d]SetPlayerWatchWar 玩家%d观看玩家%d", self.m_WarID, watchWarPlayerId, inWarPlayerId)
  if not self:IsInWarPlayer(inWarPlayerId) then
    printLogDebug("war_ai", "【warai log】[warid%d]SetPlayerWatchWar %d玩家不在在战斗中,不让观看", self.m_WarID, inWarPlayerId)
    return
  end
  if self:IsInWarPlayer(watchWarPlayerId) then
    printLogDebug("war_ai", "【warai log】[warid%d]SetPlayerWatchWar %d玩家本身在战斗中,不让观看", self.m_WarID, watchWarPlayerId)
    return
  end
  if self:IsWatchingWarPlayer(watchWarPlayerId) then
    printLogDebug("war_ai", "【warai log】[warid%d]SetPlayerWatchWar %d玩家本身已经在观看战斗中,不让观看", self.m_WarID, watchWarPlayerId)
    return
  end
  ClearAllWatchData(watchWarPlayerId)
  self.m_WatchWarPlayerDict[watchWarPlayerId] = {inWarPlayerId, watcherData}
  self:SendAllHistoryForWatch(watchWarPlayerId)
  AISendOneRoleEnterWatchWar(self.m_WarID, watchWarPlayerId, watcherData)
end
function CWarAI:DelPlayerWatchWar(playerId)
  printLogDebug("war_ai", "【warai log】[warid%d]DelPlayerWatchWar", self.m_WarID, playerId)
  self.m_WatchWarPlayerDict[playerId] = nil
  AISendOneRoleQuitWatchWar(self.m_WarID, playerId)
end
function CWarAI:GetPlayerWatchWar()
  printLogDebug("war_ai", "【warai log】[warid%d]GetPlayerWatchWar", self.m_WarID)
  return self.m_WatchWarPlayerDict or {}
end
function CWarAI:IsInWarPlayer(playerId)
  local inflag = false
  for _, tempPlayerID in pairs(self:GetAllPlayerID()) do
    if playerId == tempPlayerID then
      inflag = true
    end
  end
  if inflag == true then
    if self.m_TeamFlagDict[TEAM_ATTACK][playerId] ~= nil and self.m_TeamFlagDict[TEAM_ATTACK][playerId].runawayFlag ~= true then
      return true
    elseif self.m_TeamFlagDict[TEAM_DEFEND][playerId] ~= nil and self.m_TeamFlagDict[TEAM_DEFEND][playerId].runawayFlag ~= true then
      return true
    end
  end
  return false
end
function CWarAI:IsWatchingWarPlayer(playerId)
  printLogDebug("war_ai", "【warai log】[warid%d]IsWatchingWarPlayer", self.m_WarID)
  local wList = self.m_WatchWarPlayerDict or {}
  for p, _ in pairs(wList) do
    if p == playerId then
      return true
    end
  end
  return false
end
function CWarAI:InitWar()
  local playerIdList = {}
  for _, data in pairs(self.m_TeamFlagDict) do
    for playerId, playerFlagData in pairs(data) do
      local addFlag = true
      for _, oldPlayerId in pairs(playerIdList) do
        if playerId == oldPlayerId then
          addFlag = false
          break
        end
      end
      if addFlag and playerId ~= FUBEN_PLAYERID and playerId ~= nil then
        playerIdList[#playerIdList + 1] = playerId
      end
      playerFlagData.alldeadFlag = false
      playerFlagData.runawayFlag = false
    end
  end
  self.m_TempPetData = {}
  self.m_WarPetList = {}
  self.m_RecordOldPetList = {}
  for _, playerID in pairs(playerIdList) do
    for pos, role in pairs(self.m_Roles) do
      local rolePlayerId = role:getPlayerId()
      local rolePlayer = WarAIGetOnePlayerData(self.m_WarID, rolePlayerId)
      local roleId = role:getObjId()
      if rolePlayerId == playerID and role:getType() == LOGICTYPE_HERO then
        local petPos = pos + DefineRelativePetAddPos
        local petObj = self.m_Roles[petPos]
        if petObj ~= nil and petObj:getType() == LOGICTYPE_PET then
          local petId = petObj:getObjId()
          if self.m_RecordOldPetList[playerID] == nil then
            self.m_RecordOldPetList[playerID] = {}
          end
          self.m_RecordOldPetList[playerID][roleId] = petId
          self:setHasWarPetObjFlag(playerID, petId, true)
        end
      end
    end
  end
  local allInitPetList = {}
  for _, playerId in pairs(playerIdList) do
    local player = WarAIGetOnePlayerData(self.m_WarID, playerId)
    local petIdList = player:getAllRoleIds(LOGICTYPE_PET) or {}
    for _, roleId in pairs(petIdList) do
      local curNum = self.m_PetNumList[playerId] or 0
      self.m_PetNumList[playerId] = curNum + 1
      local tempObj = player:getObjById(roleId)
      self:setTempPetObj(playerId, tempObj)
      if allInitPetList[playerId] == nil then
        allInitPetList[playerId] = {}
      end
      allInitPetList[playerId][roleId] = {}
      allInitPetList[playerId][roleId] = {}
      local skillData = tempObj:getSkills()
      for skillId, p in pairs(skillData) do
        if p > 0 then
          allInitPetList[playerId][roleId][skillId] = p
        end
      end
    end
  end
  self:AddExtraRoleWhenStart()
  local mainHeroSkillList = {}
  for _, playerId in pairs(playerIdList) do
    local player = WarAIGetOnePlayerData(self.m_WarID, playerId)
    local mainHero = player:getMainHero()
    if mainHero ~= nil then
      if mainHeroSkillList[playerId] == nil then
        mainHeroSkillList[playerId] = {}
      end
      local skillData = mainHero:getSkills()
      for skillId, p in pairs(skillData) do
        if p > 0 then
          mainHeroSkillList[playerId][skillId] = p
        end
      end
    end
  end
  local cpList = {}
  for _, playerId in pairs(playerIdList) do
    local player = WarAIGetOnePlayerData(self.m_WarID, playerId)
    if WAR_CODE_IS_SERVER ~= true then
      cpList[playerId] = g_LocalPlayer:getCatchPetSkillLv()
    else
      cpList[playerId] = player:GetCatchLv()
    end
  end
  for _, playerId in pairs(playerIdList) do
    self.m_UseDrugDict[playerId] = {}
    local player = WarAIGetOnePlayerData(self.m_WarID, playerId)
    local drugList = player:GetItemTypeList(ITEM_LARGE_TYPE_DRUG)
    local delDrugIdList = {}
    for _, newDrugObjId in pairs(drugList) do
      delDrugIdList[#delDrugIdList + 1] = newDrugObjId
      local newDrugObj = player:GetOneItem(newDrugObjId)
      local drugType = newDrugObj:getTypeId()
      if newDrugObj then
        local num = newDrugObj:getProperty(ITEM_PRO_NUM)
        if self.m_UseDrugDict[playerId][drugType] == nil then
          self.m_UseDrugDict[playerId][drugType] = num
        else
          self.m_UseDrugDict[playerId][drugType] = self.m_UseDrugDict[playerId][drugType] + num
        end
      end
    end
    local drugList = player:GetItemTypeList(ITEM_LARGE_TYPE_LIFEITEM)
    for _, newDrugObjId in pairs(drugList) do
      delDrugIdList[#delDrugIdList + 1] = newDrugObjId
      local newDrugObj = player:GetOneItem(newDrugObjId)
      local drugType = newDrugObj:getTypeId()
      if data_getLifeSkillType(drugType) == IETM_DEF_LIFESKILL_DRUG and newDrugObj then
        local num = newDrugObj:getProperty(ITEM_PRO_NUM)
        if self.m_UseDrugDict[playerId][drugType] == nil then
          self.m_UseDrugDict[playerId][drugType] = num
        else
          self.m_UseDrugDict[playerId][drugType] = self.m_UseDrugDict[playerId][drugType] + num
        end
      end
    end
    if WAR_CODE_IS_SERVER ~= true then
    else
      for _, itemId in pairs(delDrugIdList) do
        player:DelOneItem(itemId)
      end
    end
  end
  local tempRoles = {}
  for pos, obj in pairs(self.m_Roles) do
    local mFlag
    if obj:getIsMainHero() then
      mFlag = 1
    end
    local colorList = obj:getProperty(PROPERTY_RANCOLOR)
    if colorList == 0 or type(colorList) == "table" and #colorList == 0 or isListEqual(colorList, {
      0,
      0,
      0
    }) then
      colorList = nil
    end
    local bsType
    if WAR_CODE_IS_SERVER ~= true then
      if obj:getPlayerId() == g_LocalPlayer:getPlayerId() and pos == self:GetMainHeroPosByPlayerID(obj:getPlayerId()) then
        local localHeroBsType = g_LocalPlayer:getBianShenFuType()
        if localHeroBsType ~= 0 and localHeroBsType ~= nil then
          bsType = localHeroBsType
        end
      end
    elseif pos == self:GetMainHeroPosByPlayerID(obj:getPlayerId()) then
      local player = WarAIGetOnePlayerData(self.m_WarID, obj:getPlayerId())
      local pBsType = player:GetBsType()
      if pBsType ~= 0 and pBsType ~= nil then
        bsType = pBsType
      end
    end
    local op = data_getRoleShapOp(obj:getTypeId())
    if op == 0 or op == 255 then
      op = nil
    end
    tempRoles[pos] = {
      objId = obj:getObjId(),
      typeId = obj:getTypeId(),
      hp = obj:getProperty(PROPERTY_HP),
      maxHp = obj:getMaxProperty(PROPERTY_HP),
      mp = obj:getProperty(PROPERTY_MP),
      maxMp = obj:getMaxProperty(PROPERTY_MP),
      team = obj:getProperty(PROPERTY_TEAM),
      name = obj:getProperty(PROPERTY_NAME),
      playerId = obj:getPlayerId(),
      zs = obj:getProperty(PROPERTY_ZHUANSHENG),
      lv = obj:getProperty(PROPERTY_ROLELEVEL),
      mFlag = mFlag,
      hasND = obj:HasNeidanObj(),
      cList = colorList,
      bsType = bsType,
      op = op
    }
  end
  local xrA = g_SkillAI.getAttackXuanRenFlag(self.m_WarID)
  local xrD = g_SkillAI.getDefendXuanRenFlag(self.m_WarID)
  local yhA = g_SkillAI.getAttackYiHuanFlag(self.m_WarID)
  local yhD = g_SkillAI.getDefendYiHuanFlag(self.m_WarID)
  local sHpMp_att, sHpMp_def = g_SkillAI.getShowEnemyHpMpPosList(self.m_WarID, self.m_WarType)
  local sq = g_SkillAI.checkWhenWarBegin(self.m_WarID, self.m_WarType)
  local nList = {}
  for _, playerId in pairs(playerIdList) do
    local player = WarAIGetOnePlayerData(self.m_WarID, playerId)
    local mainHero = player:getMainHero()
    if mainHero ~= nil then
      local mainHeroZs = mainHero:getProperty(PROPERTY_ZHUANSHENG)
      if WAR_CODE_IS_SERVER ~= true then
        nList[playerId] = data_getMaxPetNum(mainHeroZs) + g_LocalPlayer:GetPetLimitNum()
      else
        nList[playerId] = data_getMaxPetNum(mainHeroZs) + player:GetPlayerCanAddPetNum()
      end
    end
  end
  local mList = {}
  for _, pos in pairs(DefineAttackHeroPosList) do
    local tempRole = self:getObjectByPos(pos)
    if tempRole ~= nil then
      local tempPlayerId = tempRole:getPlayerId()
      local blPos = self:GetBanLvPos(tempPlayerId)
      if blPos then
        mList[pos] = blPos
      end
    end
  end
  for _, pos in pairs(DefineDefendHeroPosList) do
    local tempRole = self:getObjectByPos(pos)
    if tempRole ~= nil then
      local tempPlayerId = tempRole:getPlayerId()
      local blPos = self:GetBanLvPos(tempPlayerId)
      if blPos then
        mList[pos] = blPos
      end
    end
  end
  self.m_WarBaseData = {
    warID = self.m_WarID,
    warType = self.m_WarType,
    roles = tempRoles,
    warTypeData = self.m_WarTypeData,
    singleWarFlag = self.m_SingleFlag,
    warFightID = self.m_WarRoleListID,
    pList = allInitPetList,
    mList = mList,
    nList = nList,
    sList = mainHeroSkillList,
    xrA = xrA,
    xrD = xrD,
    yhA = yhA,
    yhD = yhD,
    sHpMp_att = sHpMp_att,
    sHpMp_def = sHpMp_def,
    cpList = cpList,
    sq = sq,
    hdData = self.m_HuoDongData
  }
  local attackList = {}
  for playerId, _ in pairs(self.m_TeamFlagDict[TEAM_ATTACK]) do
    attackList[#attackList + 1] = playerId
  end
  local defendList = {}
  for playerId, _ in pairs(self.m_TeamFlagDict[TEAM_DEFEND]) do
    defendList[#defendList + 1] = playerId
  end
  local warTime = os.time()
  AISetBaseData(self.m_WarID, self.m_WarType, self.m_SingleFlag, self.m_WarBaseData, attackList, defendList, warTime)
  self:SetPlayersOpDataWhenEndRound()
  for pId, _ in pairs(self.m_TeamFlagDict[TEAM_ATTACK]) do
    if pId ~= FUBEN_PLAYERID and self.m_TeamFlagDict[TEAM_ATTACK][pId].runawayFlag ~= true then
      local opData = self.m_SendToPlayersOpData[pId] or {}
      AISendPlayerSetOneRound(self.m_WarID, self.m_SingleFlag, pId, 1, opData)
    end
  end
  for pId, _ in pairs(self.m_TeamFlagDict[TEAM_DEFEND]) do
    if self.m_WarType ~= WARTYPE_BIWU and pId ~= FUBEN_PLAYERID and self.m_TeamFlagDict[TEAM_DEFEND][pId].runawayFlag ~= true then
      local opData = self.m_SendToPlayersOpData[pId] or {}
      AISendPlayerSetOneRound(self.m_WarID, self.m_SingleFlag, pId, 1, opData)
    end
  end
  self:SaveHistory(0, {
    time = warTime,
    attackList = DeepCopyTable(attackList),
    defendList = DeepCopyTable(defendList),
    baseData = DeepCopyTable(self.m_WarBaseData)
  })
  self:SendAllWarState()
  self.m_AcceptActionRound = 1
  self.m_AcceptFinishRound = -1
  self.m_AcceptSettingTimesupRound = 1
  self.m_AcceptDisplayTimesupRound = -1
  local settingTimer = GetSettingTimer(self.m_WarID, self.m_AcceptSettingTimesupRound)
  if g_gametimer then
    g_gametimer:timeout(settingTimer, WaitSettingTime + DelayTime, "settingTimer")
  end
  local result = self:GetWarResult()
  if result == WARRESULT_ATTACK_WIN or result == WARRESULT_ATTACK_LOSE or result == WARRESULT_DaPing then
    printLogDebug("war_ai", "【warai log】[warid%d]开始的时候，战斗就结束了error，战斗结束", self.m_WarID)
    self:EndWar()
    self.m_EndWarFlag_S = true
    self:DisplayTimesUp(self.m_AcceptDisplayTimesupRound)
    self:SettingTimesUp(self.m_AcceptSettingTimesupRound)
  end
end
function CWarAI:EndWar()
  printLogDebug("war_ai", "【warai log】[warid%d]CWarAI:EndWar", self.m_WarID)
  self.m_EndWarFlag = true
end
function CWarAI:DoOneRound(actionPara)
  self.m_OneRoundSetting = {}
  self.m_RunAwayPlayerIDListOneRound = {}
  self.m_FinishDisplayPlayerIdList = {}
  self.m_StartWaitDisplayTimer = false
  printLogDebug("war_ai", "【warai log】[warid%d]DoOneRound", self.m_WarID)
  self:StartRound(actionPara)
  self:RoundAction(actionPara)
  self:AddExtraRoleWhenRountEnd()
  self:EndRound(actionPara)
end
function CWarAI:StartRound(actionPara)
  printLogDebug("war_ai", "【warai log】[warid%d]StartRound ", self.m_WarID)
  if self.m_EndWarFlag == true then
    printLogDebug("war_ai", "【warai log】[warid%d]-->表示战斗已经结束，不进行StartRound", self.m_WarID)
    return
  end
  self.m_CurrRoundCnt = self.m_CurrRoundCnt + 1
  if self.m_CurrRoundCnt > self.m_MaxRoundCnt then
    printLogDebug("war_ai", "【warai log】[warid%d]~~~~异常战斗超过最大的回合数", self.m_WarID)
    self:EndWar()
    self.m_ErrorEndFlag = true
    self.m_EndWarFlag_S = true
    return
  end
  self.m_DeadCallbackData = {}
  self.m_FightedPos = {}
  self.m_LastFightSeqIdx = 0
  self:CalculateAllSpeed()
  self:SortSpeed()
  self.m_AttackFirstUseMagicSkillHuaWu = true
  self.m_DefendFirstUseMagicSkillHuaWu = true
  self.m_IsBeforeRoundFlag = true
  self.m_IsNeedReCalculateSpeedInBeforeRound = false
  local liveListRandom = {}
  for _, pos in ipairs(self.m_FightSeq) do
    local role = self.m_Roles[pos]
    if role ~= nil then
      liveListRandom[#liveListRandom + 1] = {pos, role}
    end
  end
  self:SetPlayersAutoCatchPet(actionPara, liveListRandom)
  self:CalculateProtectData(actionPara)
  self:CheckStateBeforeRoundAction(actionPara, liveListRandom)
  self:CheckWarRoleDead()
  if self.m_IsNeedReCalculateSpeedInBeforeRound then
    self:ReSortSpeedAfterSpChanged()
  end
  self.m_IsBeforeRoundFlag = false
end
function CWarAI:CheckStateBeforeRoundAction(actionPara, liveListRandom)
  for _, info in pairs(liveListRandom) do
    local pos, role = info[1], info[2]
    local isDefence = false
    if role:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
      if actionPara[pos] ~= nil and actionPara[pos].aiActionType == AI_ACTION_TYPE_DEFEND and g_SkillAI.getIsConfuse(self.m_WarID, pos) ~= true and g_SkillAI.getIsFrozen(self.m_WarID, pos) ~= true and g_SkillAI.getIsSleep(self.m_WarID, pos) ~= true and g_SkillAI.getIsFengMo(self.m_WarID, pos) ~= true then
        isDefence = true
      end
      g_SkillAI.checkDefenceEffectStateBeforeRound(self.m_WarID, pos, isDefence)
    end
  end
  for _, info in pairs(liveListRandom) do
    local pos, role = info[1], info[2]
    if self.m_CurrRoundCnt == 1 and role:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
      g_SkillAI.checkWhenPetEnter(self.m_WarID, self.m_CurrRoundCnt, pos, {sf = 1})
    end
  end
  for _, info in pairs(liveListRandom) do
    local pos, role = info[1], info[2]
    if role:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
      g_SkillAI.checkAllShenBingXianQiBeforeRound(self.m_WarID, pos)
    end
  end
  for _, info in pairs(liveListRandom) do
    local pos, role = info[1], info[2]
    if role:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
      g_SkillAI.checkAllPetSkillBeforeRound(self.m_WarID, pos)
    end
  end
  local param = {}
  for _, info in pairs(liveListRandom) do
    local pos, role = info[1], info[2]
    if role:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
      g_SkillAI.checkAllPetSkillDamageBeforeRound(self.m_WarID, self.m_CurrRoundCnt, pos, param)
    end
  end
  for _, info in pairs(liveListRandom) do
    local pos, role = info[1], info[2]
    if role:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
      g_SkillAI.checkOtherSkillBeforeRound(self.m_WarID, self.m_CurrRoundCnt, pos)
    end
  end
  for _, info in pairs(liveListRandom) do
    local pos, role = info[1], info[2]
    if role:getType() == LOGICTYPE_MONSTER and role:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
      g_SkillAI.checkMonsterTeXingBeforeRound(self.m_WarID, self.m_CurrRoundCnt, pos)
    end
  end
  for _, info in pairs(liveListRandom) do
    local pos, role = info[1], info[2]
    if role:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
      g_SkillAI.checkAllEffectStateBeforeRound(self.m_WarID, self.m_CurrRoundCnt, pos)
    end
  end
  for pos, role in pairs(self.m_Roles) do
    if role:getType() == LOGICTYPE_HERO and role:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD then
      g_SkillAI.checkAllEffectStateBeforeRound(self.m_WarID, self.m_CurrRoundCnt, pos)
    end
  end
  g_SkillAI.checkAllEffectStateBeforeRoundCompleted(self.m_WarID)
end
function CWarAI:SetPlayersAutoCatchPet(actionPara, liveListRandom)
  local catchTaskPet = false
  if self.m_WarType == WARTYPE_GuaJi then
    printLogDebug("war_ai", "【warai log】[warid%d]开始判断是否要计算自动捕捉任务宠物", self.m_WarID)
    for playerId, _ in pairs(self.m_TeamFlagDict[TEAM_ATTACK]) do
      local player = WarAIGetOnePlayerData(self.m_WarID, playerId)
      local taskPetList = player:GetNeedCatchPetList()
      local taskPetType = taskPetList[1]
      local hasTaskPetFlag = false
      local taskPetPosList = {}
      for _, mstPos in pairs({
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
      }) do
        local tempMst = self.m_Roles[mstPos]
        if tempMst and tempMst:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
          local petTypeId = tempMst:getTypeId()
          local petsid = data_getPetIdByShape(data_getRoleShape(petTypeId))
          local petLv = tempMst:getProperty(PROPERTY_ROLELEVEL)
          if petsid == taskPetType and data_getPetTypeIsNormalShou(petsid) then
            printLogDebug("war_ai", "【warai log】[warid%d]有活着的任务宠物", self.m_WarID, mstPos, petTypeId, petsid, petLv)
            taskPetPosList[mstPos] = {
              petTypeId,
              petsid,
              petLv
            }
            hasTaskPetFlag = true
          end
        end
      end
      if hasTaskPetFlag then
        local changeToCatchFlag = false
        local mainHeroPos = self:GetMainHeroPosByPlayerID(playerId)
        local mainHero = self.m_Roles[mainHeroPos]
        printLogDebug("war_ai", "【warai log】[warid%d]判断玩家%d，pos%d是否要自动捕捉任务宠物", self.m_WarID, playerId, mainHeroPos)
        if mainHero:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
          local autoFlag = false
          if actionPara[mainHeroPos] ~= nil and actionPara[mainHeroPos].autoFlag then
            autoFlag = true
          end
          if autoFlag then
            printLogDebug("war_ai", "【warai log】[warid%d]判断玩家%d，pos%d是否自动战斗", self.m_WarID, playerId, mainHeroPos)
            local catchList = {}
            local mainHeroZs = mainHero:getProperty(PROPERTY_ZHUANSHENG)
            for mstPos, mstData in pairs(taskPetPosList) do
              local petTypeId = mstData[1]
              local petsid = mstData[2]
              local petLv = mstData[3]
              local needHl = _getCatchPetNeedHuoLi_Succeed(petsid, self:Get51HuoLiFlag())
              local needLV = data_Pet[petsid].OPENLV
              local _, cMp = data_getNpcCatchData(petTypeId)
              local needMP = math.max(math.floor((cMp + petLv) * (1 - math.pow(player:GetCatchLv(), 0.7) / 100)), 1)
              if needHl > player:GetHlValue() then
              elseif needMP > mainHero:getProperty(PROPERTY_MP) then
              elseif needLV > mainHero:getProperty(PROPERTY_ROLELEVEL) and mainHeroZs <= 0 then
              else
                printLogDebug("war_ai", "【warai log】[warid%d]判断玩家%d，pos%d可以自动捕捉%d", self.m_WarID, playerId, mainHeroPos, mstPos)
                catchList[#catchList + 1] = mstPos
              end
            end
            local petNumLimit = data_getMaxPetNum(mainHeroZs) + player:GetPlayerCanAddPetNum()
            local packageEnoughFlag = petNumLimit > self:GetPetNum(playerId)
            if #catchList >= 1 and packageEnoughFlag then
              printLogDebug("war_ai", "【warai log】[warid%d]判断玩家%d，pos%d，背包有位置", self.m_WarID, playerId, mainHeroPos)
              changeToCatchFlag = true
              catchList = RandomSortList(catchList)
              local catchPos = catchList[1]
              printLogDebug("war_ai", "【warai log】[warid%d]判断玩家%d，pos%d，修改成捕捉宠物%d", self.m_WarID, playerId, mainHeroPos, catchPos)
              actionPara[mainHeroPos] = {aiActionType = AI_ACTION_TYPE_CATCH, targetPos = catchPos}
              catchTaskPet = true
            end
          end
        end
        if changeToCatchFlag then
          for _, tempPos in ipairs({
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
          }) do
            if tempPos ~= mainHeroPos then
              local tempRole = self.m_Roles[tempPos]
              if tempRole and tempRole:getPlayerId() == playerId then
                actionPara[tempPos] = {aiActionType = AI_ACTION_TYPE_DEFEND}
              end
            end
          end
        end
      end
    end
  end
  if catchTaskPet == false and self.m_WarType == WARTYPE_GuaJi then
    printLogDebug("war_ai", "【warai log】[warid%d]开始判断是否要计算自动捕捉", self.m_WarID)
    local hasGJSHFlag = false
    local GJSHPosList = {}
    for _, mstPos in pairs({
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
    }) do
      local tempMst = self.m_Roles[mstPos]
      if tempMst and tempMst:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
        local petTypeId = tempMst:getTypeId()
        local petsid = data_getPetIdByShape(data_getRoleShape(petTypeId))
        local petLv = tempMst:getProperty(PROPERTY_ROLELEVEL)
        if data_getPetTypeIsGaoJiShouHu(petsid) then
          printLogDebug("war_ai", "【warai log】[warid%d]有活着的高级守护", self.m_WarID, mstPos, petTypeId, petsid, petLv)
          GJSHPosList[mstPos] = {
            petTypeId,
            petsid,
            petLv
          }
          hasGJSHFlag = true
        end
      end
    end
    if hasGJSHFlag then
      for playerId, _ in pairs(self.m_TeamFlagDict[TEAM_ATTACK]) do
        local changeToCatchFlag = false
        local player = WarAIGetOnePlayerData(self.m_WarID, playerId)
        local mainHeroPos = self:GetMainHeroPosByPlayerID(playerId)
        local mainHero = self.m_Roles[mainHeroPos]
        local showTips = 0
        printLogDebug("war_ai", "【warai log】[warid%d]判断玩家%d，pos%d是否要自动捕捉", self.m_WarID, playerId, mainHeroPos)
        if player:GetCatchLv() >= 0 and mainHero:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
          local autoFlag = false
          if actionPara[mainHeroPos] ~= nil and actionPara[mainHeroPos].autoFlag then
            autoFlag = true
          end
          if autoFlag then
            printLogDebug("war_ai", "【warai log】[warid%d]判断玩家%d，pos%d是否自动战斗", self.m_WarID, playerId, mainHeroPos)
            local catchList = {}
            local mainHeroZs = mainHero:getProperty(PROPERTY_ZHUANSHENG)
            for mstPos, mstData in pairs(GJSHPosList) do
              local petTypeId = mstData[1]
              local petsid = mstData[2]
              local petLv = mstData[3]
              local needHl = _getCatchPetNeedHuoLi_Succeed(petsid, self:Get51HuoLiFlag())
              local needLV = data_Pet[petsid].OPENLV
              local _, cMp = data_getNpcCatchData(petTypeId)
              local needMP = math.max(math.floor((cMp + petLv) * (1 - math.pow(player:GetCatchLv(), 0.7) / 100)), 1)
              if needHl > player:GetHlValue() then
                if showTips < SUBSEQTYPE_HL_LACK_NOTCATCH then
                  showTips = SUBSEQTYPE_HL_LACK_NOTCATCH
                end
              elseif needMP > mainHero:getProperty(PROPERTY_MP) then
                if showTips < SUBSEQTYPE_MP_LACK_NOTCATCH then
                  showTips = SUBSEQTYPE_MP_LACK_NOTCATCH
                end
              elseif needLV > mainHero:getProperty(PROPERTY_ROLELEVEL) and mainHeroZs <= 0 then
                if showTips < SUBSEQTYPE_LV_LACK_NOTCATCH then
                  showTips = SUBSEQTYPE_LV_LACK_NOTCATCH
                end
              else
                printLogDebug("war_ai", "【warai log】[warid%d]判断玩家%d，pos%d可以自动捕捉%d", self.m_WarID, playerId, mainHeroPos, mstPos)
                catchList[#catchList + 1] = mstPos
                showTips = 0
              end
            end
            local petNumLimit = data_getMaxPetNum(mainHeroZs) + player:GetPlayerCanAddPetNum()
            local packageEnoughFlag = petNumLimit > self:GetPetNum(playerId)
            if #catchList >= 1 then
              if packageEnoughFlag then
                printLogDebug("war_ai", "【warai log】[warid%d]判断玩家%d，pos%d，背包有位置", self.m_WarID, playerId, mainHeroPos)
                changeToCatchFlag = true
                catchList = RandomSortList(catchList)
                local catchPos = catchList[1]
                printLogDebug("war_ai", "【warai log】[warid%d]判断玩家%d，pos%d，修改成捕捉宠物%d", self.m_WarID, playerId, mainHeroPos, catchPos)
                actionPara[mainHeroPos] = {aiActionType = AI_ACTION_TYPE_CATCH, targetPos = catchPos}
              elseif showTips < SUBSEQTYPE_NUM_LACK_NOTCATCH then
                showTips = SUBSEQTYPE_NUM_LACK_NOTCATCH
              end
            end
          end
        end
        if changeToCatchFlag then
          for _, tempPos in ipairs({
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
          }) do
            if tempPos ~= mainHeroPos then
              local tempRole = self.m_Roles[tempPos]
              if tempRole and tempRole:getPlayerId() == playerId then
                actionPara[tempPos] = {aiActionType = AI_ACTION_TYPE_DEFEND}
              end
            end
          end
        elseif showTips ~= 0 then
          g_SkillAI.formatAndSendTipSequence(self.m_WarID, mainHeroPos, mainHero, nil, showTips)
        end
      end
    end
  end
  for _, info in pairs(liveListRandom) do
    local pos, role = info[1], info[2]
    local isDefence = false
    if role:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and actionPara[pos] ~= nil and actionPara[pos].aiActionType == AI_ACTION_TYPE_CATCH then
      local playerId = role:getPlayerId()
      for _, tempPos in ipairs({
        1,
        2,
        3,
        4,
        5
      }) do
        if tempPos ~= pos then
          local tempRole = self.m_Roles[tempPos]
          if tempRole and tempRole:getPlayerId() == playerId then
            actionPara[tempPos] = {aiActionType = AI_ACTION_TYPE_DEFEND}
          end
        end
      end
    end
  end
end
function CWarAI:RoundAction(actionPara)
  printLogDebug("war_ai", "【warai log】[warid%d]RoundAction ", self.m_WarID)
  if self.m_EndWarFlag == true then
    printLogDebug("war_ai", "【warai log】[warid%d]-->表示战斗已经结束，不进行RoundAction", self.m_WarID)
    return
  end
  if self.m_EndWarFlag == true then
    return
  end
  self.m_DeadCallbackData = {}
  if self.m_SingleFlag then
    local tempPlayerID
    for _, data in pairs(self.m_TeamFlagDict) do
      for playerId, playerFlagData in pairs(data) do
        if tempPlayerID == nil and playerId ~= FUBEN_PLAYERID then
          tempPlayerID = playerId
        end
      end
    end
    if tempPlayerID ~= nil then
      local tempHeroPos = self:GetMainHeroPosByPlayerID(tempPlayerID)
      if tempHeroPos ~= nil then
        local tempRole = self:getObjectByPos(tempHeroPos)
        if tempRole and tempRole:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE and actionPara and actionPara[tempHeroPos] ~= nil and actionPara[tempHeroPos].aiActionType == AI_ACTION_TYPE_RUNAWAY then
          printLogDebug("war_ai", "【warai log】[warid%d]-->单机逃跑特殊处理 角色%d手动战斗,开始", self.m_WarID, tempHeroPos)
          tempRole:ManualAction(tempHeroPos, actionPara[tempHeroPos])
          return
        end
      end
    end
  end
  self.m_LastFightSeqIdx = self.m_LastFightSeqIdx + 1
  local deadLoopFlag = 0
  local deadLoopNum = 100
  while self.m_LastFightSeqIdx <= #self.m_FightSeq do
    if deadLoopFlag == deadLoopNum then
      printLogDebug("war_ai", "【warai log】[warid%d]~~~~异常RoundAction死循环", self.m_WarID)
      self:EndWar()
      self.m_ErrorEndFlag = true
      self.m_EndWarFlag_S = true
      return
    else
      deadLoopFlag = deadLoopFlag + 1
    end
    if self.m_EndWarFlag == true then
      return
    end
    if self.m_LastFightSeqIdx == 0 then
      self.m_LastFightSeqIdx = 1
    end
    local pos = self.m_FightSeq[self.m_LastFightSeqIdx]
    if self.m_FightedPos[pos] == nil then
      self.m_DeadCallbackData = {}
      self:OneRoleAction(pos, actionPara)
      self.m_FightedPos[pos] = 1
      self:CheckWarRoleDead()
    end
    self.m_LastFightSeqIdx = self.m_LastFightSeqIdx + 1
  end
  g_SkillAI.checkPetSkillsAfterRound(self.m_WarID, self.m_WarType, self.m_CurrRoundCnt)
  self:CheckWarRoleDead()
  self:CheckRoleBuffWhenEndRound()
  self:SetPlayersOpDataWhenEndRound()
  return
end
function CWarAI:getHeroOpData(pId)
  local heroPos = self:GetMainHeroPosByPlayerID(pId)
  local heroObj = self.m_Roles[heroPos]
  local rID, opData
  if heroObj ~= nil then
    rID = heroObj:getObjId()
    for sID, p in pairs(heroObj:getSkills()) do
      if p > 0 then
        if g_SkillAI.checkUserMpOfSkill(self.m_WarID, heroPos, sID) == false then
          if opData == nil then
            opData = {}
          end
          if opData[sID] == nil then
            opData[sID] = {}
          end
          opData[sID].mp = 1
        end
        local cdValue = g_SkillAI.checkCDValueOfSkill(self.m_WarID, self.m_CurrRoundCnt + 1, heroPos, sID)
        if cdValue ~= true then
          if opData == nil then
            opData = {}
          end
          if opData[sID] == nil then
            opData[sID] = {}
          end
          opData[sID].cd = cdValue
        end
        if g_SkillAI.getOnceSkillUseFlag(self.m_WarID, heroPos, sID) == true then
          if opData == nil then
            opData = {}
          end
          if opData[sID] == nil then
            opData[sID] = {}
          end
          opData[sID].u = 1
        end
        if self:GetBanLvPos(pId) == nil and GetObjType(sID) == LOGICTYPE_MARRYSKILL then
          if opData == nil then
            opData = {}
          end
          if opData[sID] == nil then
            opData[sID] = {}
          end
          opData[sID].jh = 1
        end
        if g_SkillAI.checkSkillIsYiWang(heroObj, sID) then
          if opData == nil then
            opData = {}
          end
          if opData[sID] == nil then
            opData[sID] = {}
          end
          opData[sID].yw = 1
        end
      end
    end
    if g_SkillAI.checkSkillIsYiWang(heroObj, SKILLTYPE_USEDRUG) then
      if opData == nil then
        opData = {}
      end
      if opData[SKILLTYPE_USEDRUG] == nil then
        opData[SKILLTYPE_USEDRUG] = {}
      end
      opData[SKILLTYPE_USEDRUG].yw = 1
    end
  end
  return rID, opData
end
function CWarAI:getPetOpData(pId)
  local heroPos = self:GetMainHeroPosByPlayerID(pId)
  local petPos = heroPos + DefineRelativePetAddPos
  local petObj = self.m_Roles[petPos]
  local rID, opData
  if petObj ~= nil then
    rID = petObj:getObjId()
    local stolenList = g_SkillAI.getPetStolenSkillList(self.m_WarID, self.m_CurrRoundCnt + 1, petPos, self.m_WarType)
    local tempList = {}
    for sID, p in pairs(petObj:getSkills()) do
      tempList[sID] = p
    end
    for _, sID in pairs(stolenList) do
      tempList[sID] = 1
      if opData == nil then
        opData = {}
      end
      if opData[sID] == nil then
        opData[sID] = {}
      end
      opData[sID].st = 1
    end
    for sID, p in pairs(tempList) do
      if p > 0 then
        if g_SkillAI.checkUserHpOfSkill(self.m_WarID, petPos, sID) == false then
          if opData == nil then
            opData = {}
          end
          if opData[sID] == nil then
            opData[sID] = {}
          end
          opData[sID].hp = 1
        end
        if g_SkillAI.checkUserMpOfSkill(self.m_WarID, petPos, sID) == false then
          if opData == nil then
            opData = {}
          end
          if opData[sID] == nil then
            opData[sID] = {}
          end
          opData[sID].mp = 1
        end
        local cdValue = g_SkillAI.checkCDValueOfSkill(self.m_WarID, self.m_CurrRoundCnt + 1, petPos, sID)
        if cdValue ~= true then
          if opData == nil then
            opData = {}
          end
          if opData[sID] == nil then
            opData[sID] = {}
          end
          opData[sID].cd = cdValue
        end
        local proValue = g_SkillAI.checkNeedProsOfSkill(self.m_WarID, self.m_CurrRoundCnt + 1, petPos, sID)
        if proValue ~= true then
          if opData == nil then
            opData = {}
          end
          if opData[sID] == nil then
            opData[sID] = {}
          end
          opData[sID].pro = proValue
        end
        if g_SkillAI.getOnceSkillUseFlag(self.m_WarID, petPos, sID) == true then
          if opData == nil then
            opData = {}
          end
          if opData[sID] == nil then
            opData[sID] = {}
          end
          opData[sID].u = 1
        end
        local minRound = g_SkillAI.getSkillUseOfMinRoundFlag(self.m_WarID, petPos, sID)
        if minRound > 1 and minRound > self.m_CurrRoundCnt + 1 then
          if opData == nil then
            opData = {}
          end
          if opData[sID] == nil then
            opData[sID] = {}
          end
          opData[sID].mr = minRound
        end
        if g_SkillAI.checkSkillIsYiWang(petObj, sID) then
          if opData == nil then
            opData = {}
          end
          if opData[sID] == nil then
            opData[sID] = {}
          end
          opData[sID].yw = 1
        end
        if opData == nil then
          opData = {}
        end
        if opData[sID] == nil then
          opData[sID] = {}
        end
        opData[sID].p = p
      end
    end
    if g_SkillAI.checkSkillIsYiWang(petObj, SKILLTYPE_USEDRUG) then
      if opData == nil then
        opData = {}
      end
      if opData[SKILLTYPE_USEDRUG] == nil then
        opData[SKILLTYPE_USEDRUG] = {}
      end
      opData[SKILLTYPE_USEDRUG].yw = 1
    end
  end
  return rID, opData
end
function CWarAI:SetPlayersOpDataWhenEndRound()
  printLogDebug("war_ai", "【warai log】[warid%d]SetPlayersOpDataWhenEndRound", self.m_WarID)
  self.m_SendToPlayersOpData = {}
  for pId, _ in pairs(self.m_TeamFlagDict[TEAM_ATTACK]) do
    local tPData
    if pId ~= FUBEN_PLAYERID and self.m_TeamFlagDict[TEAM_ATTACK][pId].runawayFlag ~= true then
      local heroId, heroOpdata = self:getHeroOpData(pId)
      if heroId ~= nil then
        if tPData == nil then
          tPData = {}
        end
        tPData[heroId] = heroOpdata
      end
      local petId, petOpdata = self:getPetOpData(pId)
      if petId ~= nil then
        if tPData == nil then
          tPData = {}
        end
        tPData[petId] = petOpdata
      end
    end
    self.m_SendToPlayersOpData[pId] = tPData
  end
  for pId, _ in pairs(self.m_TeamFlagDict[TEAM_DEFEND]) do
    if self.m_WarType ~= WARTYPE_BIWU then
      local tPData
      if pId ~= FUBEN_PLAYERID and self.m_TeamFlagDict[TEAM_DEFEND][pId].runawayFlag ~= true then
        local heroId, heroOpdata = self:getHeroOpData(pId)
        if heroId ~= nil then
          if tPData == nil then
            tPData = {}
          end
          tPData[heroId] = heroOpdata
        end
        local petId, petOpdata = self:getPetOpData(pId)
        if petId ~= nil then
          if tPData == nil then
            tPData = {}
          end
          tPData[petId] = petOpdata
        end
      end
      self.m_SendToPlayersOpData[pId] = tPData
    end
  end
end
function CWarAI:CheckRoleBuffWhenEndRound()
  printLogDebug("war_ai", "【warai log】[warid%d]CheckRoleBuffWhenEndRound", self.m_WarID)
  if self.m_EndWarFlag == true then
    return
  end
  local liveListRandom = {}
  for _, pos in ipairs(self.m_FightSeq) do
    local role = self.m_Roles[pos]
    if role ~= nil then
      liveListRandom[#liveListRandom + 1] = {pos, role}
    end
  end
  for _, info in pairs(liveListRandom) do
    local pos, role = info[1], info[2]
    if role:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
      g_SkillAI.checkAllEffectStateAfterRound(self.m_WarID, pos)
    end
  end
  for pos, role in pairs(self.m_Roles) do
    if role:getType() == LOGICTYPE_HERO and role:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD then
      g_SkillAI.checkAllEffectStateAfterRound(self.m_WarID, pos)
    end
  end
end
function CWarAI:CheckWarRoleDead()
  printLogDebug("war_ai", "【warai log】[warid%d]CheckWarRoleDead", self.m_WarID)
  if self.m_EndWarFlag == true then
    return
  end
  for _, data in ipairs(self.m_DeadCallbackData) do
    if data ~= nil then
      local obj = data.obj
      local pos = data.pos
      if pos ~= nil and obj ~= nil and obj:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD then
        g_SkillAI.checkReliveWhenRoleIsDead(self.m_WarID, pos, obj)
        if obj:getProperty(PROPERTY_DEAD) == ROLESTATE_DEAD then
          g_SkillAI.checkWhenPetLeave(self.m_WarID, pos, obj)
          g_SkillAI.checkWhenRoleIsDead(self.m_WarID, pos, obj)
          local isPetFlag = obj:getType() == LOGICTYPE_PET
          local shanXianPetID = self:GetShanXianPetID(obj:getPlayerId())
          if isPetFlag and shanXianPetID ~= nil then
            local petObj = self:getTempPetObjById(obj:getPlayerId(), shanXianPetID)
            self:ChangeRole(pos, petObj, obj:getProperty(PROPERTY_TEAM))
            local op = data_getRoleShapOp(petObj:getTypeId())
            if op == 0 or op == 255 then
              op = nil
            end
            local param = {
              objId = petObj:getObjId(),
              typeId = petObj:getTypeId(),
              hp = petObj:getProperty(PROPERTY_HP),
              maxHp = petObj:getMaxProperty(PROPERTY_HP),
              mp = petObj:getProperty(PROPERTY_MP),
              maxMp = petObj:getMaxProperty(PROPERTY_MP),
              team = petObj:getProperty(PROPERTY_TEAM),
              name = petObj:getProperty(PROPERTY_NAME),
              playerId = petObj:getPlayerId(),
              zs = petObj:getProperty(PROPERTY_ZHUANSHENG),
              lv = petObj:getProperty(PROPERTY_ROLELEVEL),
              hasND = petObj:HasNeidanObj(),
              op = op
            }
            g_SkillAI.createPetShanXian(self.m_WarID, pos, param)
            g_SkillAI.checkWhenPetEnter(self.m_WarID, self.m_CurrRoundCnt, pos, {})
          end
        end
      end
    end
  end
  local result = self:GetWarResult()
  if result == WARRESULT_ATTACK_WIN or result == WARRESULT_ATTACK_LOSE or result == WARRESULT_DaPing then
    printLogDebug("war_ai", "【warai log】[warid%d]一方所有玩家逃跑或死光，战斗结束", self.m_WarID)
    self:EndWar()
  end
end
function CWarAI:OneRoleAction(pos, actionPara)
  printLogDebug("war_ai", "【warai log】[warid%d]OneRoleAction启动战斗:pos  %d", self.m_WarID, pos)
  local role = self:getObjectByPos(pos)
  if role == nil then
    printLogDebug("war_ai", "【warai log】[warid%d]~~~~异常角色为nil", self.m_WarID)
    return
  end
  if role:getType() == LOGICTYPE_HERO and actionPara and actionPara[pos] and actionPara[pos].aiActionType == AI_ACTION_TYPE_RUNAWAY then
    printLogDebug("war_ai", "【warai log】[warid%d]死亡状态下逃跑:pos  %d", self.m_WarID, pos)
    if self.m_WarType == WARTYPE_BpWAR then
      local rolePlayer = WarAIGetOnePlayerData(self.m_WarID, role:getPlayerId())
      if rolePlayer ~= nil and rolePlayer.getIsCaptain and rolePlayer:getIsCaptain() then
        role:ManualAction(pos, actionPara[pos])
        return
      end
      printLogDebug("war_ai", "【warai log】[warid%d](但是帮战下，队员不能逃跑)", self.m_WarID, pos)
    else
      role:ManualAction(pos, actionPara[pos])
      return
    end
  end
  if role:getProperty(PROPERTY_DEAD) ~= ROLESTATE_LIVE then
    printLogDebug("war_ai", "【warai log】[warid%d]~~~~异常角色死亡或者逃跑了", self.m_WarID)
    return
  end
  local needJudgeIsFrozen = true
  local needJudgeIsSleep = true
  local needJudgeIsConfuse = true
  local needJudgeIsFengMo = true
  local UseDrugFlag = false
  local UseQSSHFlag = false
  local UseYHJYFlag = false
  if actionPara ~= nil and actionPara[pos] ~= nil then
    if actionPara[pos].aiActionType == AI_ACTION_TYPE_USEDRUG then
      UseDrugFlag = true
    end
    if actionPara[pos].aiActionType == AI_ACTION_TYPE_USESKILL then
      if actionPara[pos].skillId == MARYYSKILL_QINGSHENSIHAI then
        UseQSSHFlag = true
      elseif actionPara[pos].skillId == SKILL_YIHUAJIEYU then
        UseYHJYFlag = true
      end
    end
  end
  if UseDrugFlag == true then
    needJudgeIsSleep = false
  end
  if UseQSSHFlag == true then
    needJudgeIsFrozen = false
    needJudgeIsSleep = false
    needJudgeIsConfuse = false
    needJudgeIsFengMo = false
  end
  if UseYHJYFlag == true then
    needJudgeIsFrozen = false
    needJudgeIsSleep = false
    needJudgeIsConfuse = false
  end
  if needJudgeIsFrozen and g_SkillAI.getIsFrozen(self.m_WarID, pos) then
    printLogDebug("war_ai", "【warai log】[warid%d]-->角色%d处于封印,轮空", self.m_WarID, pos)
    return
  end
  if needJudgeIsSleep and g_SkillAI.getIsSleep(self.m_WarID, pos) then
    printLogDebug("war_ai", "【warai log】[warid%d]-->角色%d处于昏睡中,轮空", self.m_WarID, pos)
    return
  end
  if needJudgeIsConfuse and g_SkillAI.getIsConfuse(self.m_WarID, pos) then
    role:ConfuseAttack()
    return
  end
  if needJudgeIsFengMo and g_SkillAI.getIsFengMo(self.m_WarID, pos) then
    local targetPos
    if actionPara and actionPara[pos] then
      targetPos = actionPara[pos].targetPos
    end
    role:FengMoAttack(targetPos)
    return
  end
  if actionPara and actionPara[pos] then
    printLogDebug("war_ai", "【warai log】[warid%d]-->角色%d手动战斗,开始", self.m_WarID, pos)
    if self.m_WarType == WARTYPE_BIWU and actionPara[pos].aiActionType == AI_ACTION_TYPE_USEDRUG then
      printLogDebug("war_ai", "【warai log】[warid%d]-->角色%d手动战斗(但是比武场不能吃药)", self.m_WarID, pos)
    elseif self.m_WarType == WARTYPE_BpWAR and actionPara[pos].aiActionType == AI_ACTION_TYPE_RUNAWAY then
      local rolePlayer = WarAIGetOnePlayerData(self.m_WarID, role:getPlayerId())
      if rolePlayer ~= nil and rolePlayer.getIsCaptain and rolePlayer:getIsCaptain() then
        role:ManualAction(pos, actionPara[pos])
        return
      end
      printLogDebug("war_ai", "【warai log】[warid%d]-->角色%d手动战斗(但是帮战，队员不能逃跑)", self.m_WarID, pos)
    else
      role:ManualAction(pos, actionPara[pos])
      return
    end
  end
  local t_playerId = role:getPlayerId()
  local t_roleId = role:getObjId()
  local t_player = WarAIGetOnePlayerData(self.m_WarID, t_playerId)
  if t_playerId ~= nil and t_roleId ~= nil and t_player ~= nil and self.m_WarType == WARTYPE_BIWU and t_roleId == t_player:getMainHeroId() then
    role:UseAIInBWC()
  else
    role:UseAI()
  end
end
function CWarAI:GetAttackDeadNumWhenEndWar()
  local deadRoleNum = 0
  for _, pos in pairs(DefineAttackHeroPosList) do
    local tempRole = self.m_Roles[pos]
    if tempRole ~= nil and tempRole:getProperty(PROPERTY_DEAD) ~= ROLESTATE_LIVE then
      deadRoleNum = deadRoleNum + 1
    end
  end
  for _, pos in pairs(DefineAttackPetPosList) do
    local tempRole = self.m_Roles[pos]
    if tempRole ~= nil and tempRole:getProperty(PROPERTY_DEAD) ~= ROLESTATE_LIVE then
      deadRoleNum = deadRoleNum + 1
    end
  end
  return deadRoleNum
end
function CWarAI:GetDefendDeadNumWhenEndWar()
  local deadRoleNum = 0
  for _, pos in pairs(DefineDefendHeroPosList) do
    local tempRole = self.m_Roles[pos]
    if tempRole ~= nil and tempRole:getProperty(PROPERTY_DEAD) ~= ROLESTATE_LIVE then
      deadRoleNum = deadRoleNum + 1
    end
  end
  for _, pos in pairs(DefineDefendPetPosList) do
    local tempRole = self.m_Roles[pos]
    if tempRole ~= nil and tempRole:getProperty(PROPERTY_DEAD) ~= ROLESTATE_LIVE then
      deadRoleNum = deadRoleNum + 1
    end
  end
  return deadRoleNum
end
function CWarAI:EndRound()
  printLogDebug("war_ai", "【warai log】[warid%d]==========>>> EndRound ", self.m_WarID)
  local roundSeq = DeepCopyTable(self.m_WarSeqData[self.m_CurrRoundCnt] or {})
  local warResult = self:GetWarResult()
  if warResult == WARRESULT_NONE and self.m_EndWarFlag == true then
    printLogDebug("war_ai", "【warai log error】[warid%d]==========>>> 其他原因导致的结束 ", self.m_WarID)
    warResult = WARRESULT_ATTACK_LOSE
    if IsMaxRoundAsDaPingWarType(self.m_WarType) then
      warResult = WARRESULT_DaPing
    end
  end
  local endWarData = {}
  if warResult ~= WARRESULT_NONE then
    local starNum = 0
    if self.m_WarType == WARTYPE_FUBEN and warResult == WARRESULT_ATTACK_WIN then
      local deadRoleNum = self:GetAttackDeadNumWhenEndWar()
      if deadRoleNum == 0 then
        starNum = 3
      elseif deadRoleNum == 1 then
        starNum = 2
      else
        starNum = 1
      end
    elseif self.m_WarType == WARTYPE_XueZhanShaChang then
      if warResult == WARRESULT_DaPing then
        starNum = 0
      elseif warResult == WARRESULT_ATTACK_WIN then
        local deadRoleNum = self:GetAttackDeadNumWhenEndWar()
        if deadRoleNum == 0 and self.m_CurrRoundCnt == 1 then
          starNum = 3
        elseif deadRoleNum > 3 or self.m_CurrRoundCnt > 9 then
          starNum = 1
        else
          starNum = 2
        end
      else
        local deadRoleNum = self:GetDefendDeadNumWhenEndWar()
        if deadRoleNum == 0 and self.m_CurrRoundCnt == 1 then
          starNum = -3
        elseif deadRoleNum > 3 or self.m_CurrRoundCnt > 9 then
          starNum = -1
        else
          starNum = -2
        end
      end
    end
    local petList = {}
    for _, pos in pairs(AllPetPosList) do
      local tempRole = self.m_Roles[pos]
      if tempRole ~= nil and tempRole:getPlayerId() ~= FUBEN_PLAYERID and tempRole:getProperty(PROPERTY_DEAD) ~= ROLESTATE_LEAVE then
        local playerId = tempRole:getPlayerId()
        local petId = tempRole:getObjId()
        if petList[playerId] ~= nil then
          petList[playerId][#petList[playerId] + 1] = petId
        else
          petList[playerId] = {petId}
        end
        local heroPos = self:GetMainHeroPosByPlayerID(playerId)
        if heroPos ~= nil then
          local heroRole = self.m_Roles[heroPos]
          if heroRole ~= nil and heroRole:getProperty(PROPERTY_DEAD) == ROLESTATE_LIVE then
            if warResult == WARRESULT_ATTACK_WIN and heroRole:getProperty(PROPERTY_TEAM) == TEAM_ATTACK then
              self:AddPetClose(playerId, petId, 5)
            elseif warResult == WARRESULT_ATTACK_LOSE and heroRole:getProperty(PROPERTY_TEAM) == TEAM_DEFEND then
              self:AddPetClose(playerId, petId, 5)
            end
          end
        end
      end
    end
    local copyPetList = DeepCopyTable(petList)
    local copySkillData = DeepCopyTable(self.m_SkillProficiency)
    local copyPetClose = DeepCopyTable(self.m_PetCloseDict)
    for _, playerId in pairs(self.m_RunAwayPlayerIDListOneWar) do
      copyPetList[playerId] = nil
      copySkillData[playerId] = nil
      copyPetClose[playerId] = nil
    end
    endWarData = {
      warResult = warResult,
      starNum = starNum,
      GetExpPetList = copyPetList,
      SkillProficiencyDict = copySkillData,
      petCloseDict = copyPetClose,
      singleWarFlag = self.m_SingleFlag,
      warUseTime = os.time() - self.m_WarStartTimePoint
    }
    self.m_EndWarData = DeepCopyTable(endWarData)
  else
    endWarData = {warResult = warResult, starNum = 0}
  end
  for _, pos in pairs(AllWarPosList) do
    self:RecordOneRoleHpAndMp(pos)
  end
  local warTime = os.time()
  AISendRoundWarSeqList(self.m_WarID, self.m_SingleFlag, self.m_CurrRoundCnt, roundSeq, endWarData, warTime)
  self:SaveHistory(self.m_CurrRoundCnt, {
    time = warTime,
    roundSeq = DeepCopyTable(roundSeq),
    endWarData = DeepCopyTable(endWarData)
  })
  self.m_AcceptActionRound = -1
  self.m_AcceptFinishRound = self.m_CurrRoundCnt
  self.m_AcceptSettingTimesupRound = -1
  self.m_AcceptDisplayTimesupRound = self.m_CurrRoundCnt
  self.m_AutoDisplayTimerTime = nil
  for _, tempPlayerId in pairs(self.m_RunAwayPlayerIDListOneRound) do
    local hpMpData
    if self.m_RecordHpMpData[tempPlayerId] ~= nil then
      hpMpData = {}
      for rId, info in pairs(self.m_RecordHpMpData[tempPlayerId]) do
        hpMpData[#hpMpData + 1] = {
          i_t = info.i_t,
          i_r = rId,
          i_hp = info.hp,
          i_mp = info.mp
        }
      end
    end
    AISendPlayerRunAwayMsg(self.m_WarID, self.m_WarType, tempPlayerId, hpMpData)
  end
  self:SettingSerDisplayTimer()
  if self.m_EndWarFlag_S == true and self:SendEndWarData() then
    return
  end
end
function CWarAI:RecordOneRoleHpAndMp(pos)
  printLogDebug("war_ai", "【warai log】[warid%d]RecordOneRoleHpAndMp%d", self.m_WarID, pos)
  local tempRole = self.m_Roles[pos]
  if tempRole ~= nil and tempRole:getPlayerId() ~= FUBEN_PLAYERID then
    local playerId = tempRole:getPlayerId()
    local roleId = tempRole:getObjId()
    printLogDebug("war_ai", "【warai log】[warid%d]RecordOneRoleHpAndMp %d %d", self.m_WarID, playerId, roleId)
    if self.m_RecordHpMpData[playerId] == nil then
      self.m_RecordHpMpData[playerId] = {}
    end
    local addHp, addMp = g_SkillAI.getTempLessenHpAndMp(tempRole)
    local hp = tempRole:getProperty(PROPERTY_HP) + addHp
    local mp = tempRole:getProperty(PROPERTY_MP) + addMp
    local i_t = 1
    if tempRole:getType() == LOGICTYPE_PET then
      i_t = 2
    end
    printLogDebug("war_ai", "【warai log】[warid%d]RecordOneRoleHpAndMp%d,%d,%d,%d", self.m_WarID, pos, hp, mp, i_t)
    if hp == 0 then
      hp = 1
    end
    if mp == 0 then
      mp = 1
    end
    self.m_RecordHpMpData[playerId][roleId] = {
      hp = hp,
      mp = mp,
      i_t = i_t
    }
  end
end
function CWarAI:SendEndWarData()
  local warResult = self:GetWarResult()
  printLogDebug("war_ai", "【warai log】[warid%d]-->SendEndWarData    %d", self.m_WarID, warResult)
  if self.m_ErrorEndFlag == true then
    printLogDebug("war_ai", "【warai log】[warid%d]-->SendEndWarData ErrorEndFlag 为true", self.m_WarID)
    warResult = WARRESULT_ATTACK_LOSE
    if IsMaxRoundAsDaPingWarType(self.m_WarType) then
      warResult = WARRESULT_DaPing
    end
  end
  if warResult ~= WARRESULT_NONE then
    local playerIdList = {}
    for _, data in pairs(self.m_TeamFlagDict) do
      for playerId, playerFlagData in pairs(data) do
        playerIdList[#playerIdList + 1] = playerId
      end
    end
    if self.m_EndWarData and IsNeedRecord_HP_MP(self.m_WarType) then
      local hpmpData = {}
      hpmpData.warid = self.m_WarID
      hpmpData.attackers = {}
      hpmpData.defensers = {}
      if warResult == WARRESULT_ATTACK_WIN then
        hpmpData.result = 1
      else
        hpmpData.result = 0
      end
      for pId, playerFlagData in pairs(self.m_TeamFlagDict[TEAM_ATTACK]) do
        if pId ~= FUBEN_PLAYERID and self.m_RecordHpMpData[pId] then
          local sendFlag = true
          if WAR_CODE_IS_SERVER and self.m_WarType ~= WARTYPE_BpWAR and playerFlagData.runawayFlag == true then
            sendFlag = false
          end
          if sendFlag == true then
            local tempData = {}
            tempData.pid = pId
            tempData.d = {}
            for rId, info in pairs(self.m_RecordHpMpData[pId]) do
              tempData.d[#tempData.d + 1] = {
                i_t = info.i_t,
                i_r = rId,
                i_hp = info.hp,
                i_mp = info.mp
              }
            end
            hpmpData.attackers[#hpmpData.attackers + 1] = tempData
          end
        end
      end
      for pId, playerFlagData in pairs(self.m_TeamFlagDict[TEAM_DEFEND]) do
        if pId ~= FUBEN_PLAYERID and self.m_RecordHpMpData[pId] then
          local sendFlag = true
          if WAR_CODE_IS_SERVER and self.m_WarType ~= WARTYPE_BpWAR and playerFlagData.runawayFlag == true then
            sendFlag = false
          end
          if sendFlag == true then
            local tempData = {}
            tempData.pid = pId
            tempData.d = {}
            for rId, info in pairs(self.m_RecordHpMpData[pId]) do
              tempData.d[#tempData.d + 1] = {
                i_t = info.i_t,
                i_r = rId,
                i_hp = info.hp,
                i_mp = info.mp
              }
            end
            hpmpData.defensers[#hpmpData.defensers + 1] = tempData
          end
        end
      end
      if WAR_CODE_IS_SERVER ~= true then
        netsend.netteamwar.recordRoleHpAndMp(hpmpData)
      else
        net_wtog.recordRoleHpAndMp(hpmpData)
      end
    end
    if self.m_EndWarData then
      AISubmitWarResult(self.m_WarID, self.m_WarType, self.m_SingleFlag, self.m_WarTypeData, self.m_EndWarData)
    end
    if not self.m_EndWarData or WAR_CODE_IS_SERVER ~= true then
    elseif self.m_WarType == WARTYPE_BIWU and net_wtog then
      local newHistoryData = DeepCopyTable(self.m_HistoryData)
      for i = 1, self.m_MaxRoundCnt do
        if newHistoryData[i] ~= nil then
          newHistoryData[i].r = i
        end
      end
      net_wtog.saveBWCHistoryData(self.m_WarID, newHistoryData)
    end
  end
  if self.m_EndWarFlag == true then
    printLogDebug("war_ai", "【warai log】[warid%d]-->EndRound表示回合已经结束（战斗也结束）", self.m_WarID, warResult)
    AIEndOneWar(self.m_WarID)
    return true
  else
    printLogDebug("war_ai", "【warai log】[warid%d]-->EndRound表示回合已经结束（战斗没有结束）", self.m_WarID, warResult)
    return false
  end
end
function CWarAI:GetCurRoundNum()
  return self.m_CurrRoundCnt
end
function CWarAI:SetOnePlayerAutoFightData(playerID)
  printLogDebug("war_ai", "【warai log】[warid%d]-->SetOnePlayerAutoFightData", self.m_WarID, playerID)
  local player = WarAIGetOnePlayerData(self.m_WarID, playerID)
  if player and player.GetPlayerAutoFightData then
    local autoData = player:GetPlayerAutoFightData()
    if autoData then
      for _, pos in pairs(AllWarPosList) do
        local role = self:getObjectByPos(pos)
        if role and role:getPlayerId() == playerID then
          for oid, aData in pairs(autoData) do
            if role:getObjId() == oid then
              local tempData = DeepCopyTable(aData)
              tempData.oid = nil
              role:SetAIAutoOperationData(tempData)
            end
          end
        end
      end
    end
  end
end
function CWarAI:ObjectPropertyChanged(obj, propertyType, changedType, value_new, value_old)
  if propertyType == PROPERTY_SP and changedType == PROPERTY_CHANGED_TEMP then
    printLogDebug("war_ai", "【warai log】[warid%d]角色速度temp改变了，需要重新计算", self.m_WarID)
    if self.m_IsBeforeRoundFlag == true then
      self.m_IsNeedReCalculateSpeedInBeforeRound = true
    else
      self:ReSortSpeedAfterSpChanged()
    end
  elseif propertyType == PROPERTY_SP and changedType == PROPERTY_CHANGED_NORMAL then
    printLogDebug("war_ai", "【warai log】[warid%d]角色速度normal改变了，需要重新计算", self.m_WarID)
    if self.m_IsBeforeRoundFlag == true then
      self.m_IsNeedReCalculateSpeedInBeforeRound = true
    else
      self:CalculateSpeed(obj)
      self:ReSortSpeedAfterSpChanged()
    end
  elseif propertyType == PROPERTY_DEAD then
    if value_new == ROLESTATE_DEAD or value_new == ROLESTATE_RUNAWAY or value_new == ROLESTATE_LEAVE then
      printLogDebug("war_ai", "【warai log】[warid%d]有角色死掉或者逃跑", self.m_WarID)
      local pos = obj:getWarPos()
      self:RoleHadDeadOrRunaway(pos, value_new)
    elseif value_new == ROLESTATE_LIVE then
      local pos = obj:getWarPos()
      self:RoleFuhuo(pos)
    end
  end
end
function CWarAI:RoleCatchPet(pos, targetPos, isSucceed)
  if WAR_CODE_IS_SERVER == true then
    local result = 0
    if isSucceed == true then
      result = 1
    end
    local role = self.m_Roles[pos]
    local tempRole = self.m_Roles[targetPos]
    if role and tempRole then
      local playerId = role:getPlayerId()
      local petTypeId = tempRole:getTypeId()
      local petsid = data_getPetIdByShape(data_getRoleShape(petTypeId))
      local player = WarAIGetOnePlayerData(self.m_WarID, playerId)
      if playerId and petsid then
        net_wtog.catchPetResult(self.m_WarID, playerId, petsid, result)
        if result == 1 then
          local curNum = self.m_PetNumList[playerId] or 0
          self.m_PetNumList[playerId] = curNum + 1
          if player then
            player:DelFromNeedCatchPetList(petsid)
          end
        end
      end
    end
  end
end
function CWarAI:GetPetNum(playerID)
  if WAR_CODE_IS_SERVER ~= true then
    local curPetIdList = g_LocalPlayer:getAllRoleIds(LOGICTYPE_PET) or {}
    return #curPetIdList
  else
    return self.m_PetNumList[playerID] or 0
  end
end
function CWarAI:GetShanXianPetID(playerID)
  printLogDebug("war_ai", "【warai log】[warid%d]获取是否随机到闪现宠物", self.m_WarID, playerID)
  if self.m_TempPetData[playerID] == nil then
    printLogDebug("war_ai", "【warai log】[warid%d]m_TempPetData为空", self.m_WarID, playerID)
    return nil
  end
  local player = WarAIGetOnePlayerData(self.m_WarID, playerID)
  if player == nil then
    printLogDebug("war_ai", "【warai log】[warid%d]player对象为空", self.m_WarID, playerID)
    return nil
  end
  local sxList = {}
  if WAR_CODE_IS_SERVER ~= true then
  else
    sxList = player:GetShanXianList()
  end
  for _, tempPetId in ipairs(sxList) do
    local petObj = self.m_TempPetData[playerID][tempPetId]
    if petObj then
      if self:getIsHasWarPet(playerID, tempPetId) == false then
        if self:getTempPetObjById(playerID, tempPetId) ~= nil then
          if petObj:petSkillIsActing(PETSKILL_GAOJIJISHIYU) then
            if math.random(0, 100) <= g_SkillAI.computePetSkill_GaoJiJiShiYu() * 100 then
              printLogDebug("war_ai", "【warai log】[warid%d]获取是否随机到普通闪现宠物,神出鬼没", self.m_WarID, playerID, tempPetId)
              do return tempPetId end
              break
            end
            printLogDebug("war_ai", "【warai log】[warid%d]获取是否随机到神出鬼没宠物,随机概率不足", self.m_WarID, playerID, tempPetId)
            break
          end
          if petObj:petSkillIsActing(PETSKILL_JISHIYU) then
            if math.random(0, 100) <= g_SkillAI.computePetSkill_JiShiYu() * 100 then
              printLogDebug("war_ai", "【warai log】[warid%d]获取是否随机到普通闪现宠物,普通闪现", self.m_WarID, playerID, tempPetId)
              do return tempPetId end
              break
            end
            printLogDebug("war_ai", "【warai log】[warid%d]获取是否随机到普通闪现宠物,随机概率不足", self.m_WarID, playerID, tempPetId)
            break
          end
          printLogDebug("war_ai", "【warai log】[warid%d]获取是否随机到闪现宠物,没有闪现技能", self.m_WarID, playerID, tempPetId)
          break
        else
          printLogDebug("war_ai", "【warai log】[warid%d]获取是否随机到闪现宠物,已经被放生,或者根本没有发数据过来", self.m_WarID, playerID, tempPetId)
        end
      else
        printLogDebug("war_ai", "【warai log】[warid%d]获取是否随机到闪现宠物,已经上过场", self.m_WarID, playerID, tempPetId)
      end
    else
      printLogDebug("war_ai", "【warai log】[warid%d]获取是否随机到闪现宠物,m_TempPetData里面宠物id为空", self.m_WarID, playerID, tempPetId)
    end
  end
  printLogDebug("war_ai", "【warai log】[warid%d]获取是否随机到闪现宠物,没有闪现", self.m_WarID, playerID)
  return nil
end
function CWarAI:SetSeqData(params)
  local tempTable = self.m_WarSeqData[self.m_CurrRoundCnt]
  if tempTable == nil then
    tempTable = {}
    self.m_WarSeqData[self.m_CurrRoundCnt] = tempTable
  end
  tempTable[#tempTable + 1] = params
end
function CWarAI:AddSkillProficiency(playerId, userPos, skillId)
  printLogDebug("war_ai", "【warai log】[warid%d]CWarAI:AddSkillProficiency  %d,%d,%d", self.m_WarID, playerId, userPos, skillId)
  local skillLogicType = GetObjType(skillId)
  if skillLogicType ~= LOGICTYPE_SKILL then
    printLogDebug("war_ai", "【warai log】[warid%d]CWarAI:AddSkillProficiency,普通技能才用熟练度增加", self.m_WarID)
    return
  end
  local pvpFlag = IsPVPWarType(self.m_WarType)
  if pvpFlag then
    printLogDebug("war_ai", "【warai log】[warid%d]CWarAI:AddSkillProficiency,pvp不加技能熟练度", self.m_WarID)
    return
  end
  local tempRole = self:getObjectByPos(userPos)
  if tempRole == nil then
    printLogDebug("war_ai", "【warai log】[warid%d]CWarAI:AddSkillProficiency,~~~~异常，主角不存在", self.m_WarID)
    return
  end
  local player = WarAIGetOnePlayerData(self.m_WarID, playerId)
  if player == nil then
    return
  end
  local roleId = tempRole:getObjId()
  if player:getMainHeroId() ~= roleId then
    return
  end
  local skillAttr = data_getSkillAttrStyle(skillId)
  local skillStep = data_getSkillStep(skillId)
  local skillTypeList = tempRole:getSkillTypeList()
  local skillAttrNum = 0
  if skillTypeList[1] == skillAttr then
    skillAttrNum = 1
  end
  if skillTypeList[2] == skillAttr then
    skillAttrNum = 2
  end
  if skillTypeList[3] == skillAttr then
    skillAttrNum = 3
  end
  if skillAttrNum == 0 then
    printLogDebug("war_ai", "【warai log】[warid%d]CWarAI:AddSkillProficiency,~~~~异常，pos主角不可能有%d技能", self.m_WarID, skillId)
    return
  end
  local sNo = (skillAttrNum - 1) * 5 + skillStep
  if self.m_SkillProficiency[playerId] == nil then
    self.m_SkillProficiency[playerId] = {}
  end
  if self.m_SkillProficiency[playerId][sNo] == nil then
    self.m_SkillProficiency[playerId][sNo] = 1
  else
    self.m_SkillProficiency[playerId][sNo] = self.m_SkillProficiency[playerId][sNo] + 1
  end
end
function CWarAI:DelOneDrug(playerId, useDrugTypeId)
  printLogDebug("war_ai", "【warai log】[warid%d]CWarAI:DelOneDrug  %d,%d", self.m_WarID, playerId, useDrugTypeId)
  if self.m_UseDrugDict[playerId] == nil then
    printLogDebug("war_ai", "【warai log】[warid%d]error 药品不够还吃(1)", self.m_WarID)
    return
  end
  if self.m_UseDrugDict[playerId][useDrugTypeId] == nil then
    printLogDebug("war_ai", "【warai log】[warid%d]error 药品不够还吃(2)", self.m_WarID)
    return
  end
  if self.m_UseDrugDict[playerId][useDrugTypeId] <= 0 then
    printLogDebug("war_ai", "【warai log】[warid%d]error 药品不够还吃(3)", self.m_WarID)
    return
  end
  self.m_UseDrugDict[playerId][useDrugTypeId] = self.m_UseDrugDict[playerId][useDrugTypeId] - 1
  AISendUseDrugToSer(self.m_WarID, self.m_SingleFlag, playerId, useDrugTypeId, 1)
end
function CWarAI:GetDrugNum(playerId, useDrugTypeId)
  printLogDebug("war_ai", "【warai log】[warid%d]CWarAI:GetDrugNum  %d,%d", self.m_WarID, playerId, useDrugTypeId)
  if self.m_UseDrugDict[playerId] == nil then
    return 0
  end
  if self.m_UseDrugDict[playerId][useDrugTypeId] ~= nil then
    return self.m_UseDrugDict[playerId][useDrugTypeId]
  else
    return 0
  end
end
function CWarAI:AddPetClose(playerId, petId, value)
  printLogDebug("war_ai", "【warai log】[warid%d]CWarAI:AddPetClose  %d,%d,%d", self.m_WarID, playerId, petId, value)
  local pveFlag = IsPVEWarType(self.m_WarType)
  if pveFlag == false then
    printLogDebug("war_ai", "【warai log】[warid%d]只有pve，宠物亲密度才会变化", self.m_WarID, self.m_WarType)
    return
  end
  if value <= 0 then
    printLogDebug("war_ai", "【warai log】[warid%d]宠物亲密度,暂时不能扣", self.m_WarID)
    return
  end
  if self.m_PetCloseDict[playerId] == nil then
    self.m_PetCloseDict[playerId] = {}
  end
  if self.m_PetCloseDict[playerId][petId] ~= nil then
    self.m_PetCloseDict[playerId][petId] = self.m_PetCloseDict[playerId][petId] + value
  else
    self.m_PetCloseDict[playerId][petId] = value
  end
end
function CWarAI:setTempPetObj(playerId, petObj)
  local roleId = petObj:getObjId()
  printLogDebug("war_ai", "【warai log】[warid%d]setTempPetObj    %d,  %d", self.m_WarID, playerId, roleId)
  local tempRoleFactory = CRoleFactory.new()
  local tempPetObj = tempRoleFactory:newObject(playerId, roleId, petObj:getTypeId(), petObj:getProSerialization(), self.m_WarID)
  if self.m_TempPetData[playerId] == nil then
    self.m_TempPetData[playerId] = {}
  end
  self.m_TempPetData[playerId][roleId] = tempPetObj
end
function CWarAI:getTempPetObjById(playerId, roleId)
  printLogDebug("war_ai", "【warai log】[warid%d]getTempPetObjById   %d,  %d", self.m_WarID, playerId, roleId)
  if self.m_TempPetData[playerId] == nil then
    return nil
  end
  return self.m_TempPetData[playerId][roleId]
end
function CWarAI:delTempPetObjById(playerId, roleId)
  printLogDebug("war_ai", "【warai log】[warid%d]delTempPetObjById   %d,  %d", self.m_WarID, playerId, roleId)
  if self.m_TempPetData[playerId] ~= nil then
    self.m_TempPetData[playerId][roleId] = nil
  end
  local curNum = self.m_PetNumList[playerId] or 0
  self.m_PetNumList[playerId] = math.max(0, curNum - 1)
end
function CWarAI:setHasWarPetObjFlag(playerId, roleId, flag)
  printLogDebug("war_ai", "【warai log】[warid%d]setHasWarPetObjFlag    %d,  %d", self.m_WarID, playerId, roleId)
  if self.m_WarPetList[playerId] == nil then
    self.m_WarPetList[playerId] = {}
  end
  self.m_WarPetList[playerId][roleId] = flag
end
function CWarAI:getIsHasWarPet(playerId, roleId)
  if self.m_WarPetList[playerId] == nil then
    return false
  end
  local isHasWarFlag = self.m_WarPetList[playerId][roleId] or false
  return isHasWarFlag
end
function CWarAI:ForceEndWar()
  printLogDebug("war_ai", "【warai log】[warid%d]ForceEndWar", self.m_WarID)
  for _, tempPlayerId in pairs(self:GetAllPlayerID()) do
    net_wtog.tellPlayersToEndWar(self.m_WarID, tempPlayerId)
  end
end
function CWarAI:SaveHistory(roundNum, data)
  printLogDebug("war_ai", "【warai log】[warid%d]SaveHistory,roundNum%d", self.m_WarID, roundNum)
  self.m_HistoryData[roundNum] = data
end
function CWarAI:SendAllHistory(playerId)
  printLogDebug("war_ai", "【warai log】[warid%d]SendAllHistory,playerId%d", self.m_WarID, playerId)
  local historyRdCnt = 0
  for _, _ in pairs(self.m_HistoryData) do
    historyRdCnt = historyRdCnt + 1
  end
  for i = 1, self.m_MaxRoundCnt do
    local tempData = self.m_HistoryData[i - 1]
    if tempData == nil then
      break
    elseif i == 1 then
      local baseWarData = DeepCopyTable(tempData.baseData)
      baseWarData.historyRdCnt = historyRdCnt - 1
      net_wtog.tellOnePlayerToStartWar(playerId, self.m_WarID, self.m_WarType, tempData.attackList, tempData.defendList, baseWarData, tempData.time)
    else
      net_wtog.tellOnePlayerToRunOneRound(playerId, self.m_WarID, i - 1, tempData.roundSeq, tempData.endWarData, tempData.time)
    end
  end
  local watchData = self:GetPlayerWatchWar()
  for _, tempData in pairs(watchData) do
    local watcherData = tempData[2]
    if watcherData ~= nil then
      AISendToOnePlayerOneRoleEnterWatchWar(self.m_WarID, playerId, watcherData)
    end
  end
end
function CWarAI:SendAllHistoryForWatch(playerId)
  printLogDebug("war_ai", "【warai log】[warid%d]SendAllHistoryForWatch,playerId%d", self.m_WarID, playerId)
  local i_watchPlayerId
  if self.m_WatchWarPlayerDict[playerId] ~= nil then
    i_watchPlayerId = self.m_WatchWarPlayerDict[playerId][1]
  end
  if i_watchPlayerId == nil then
    printLogDebug("war_ai", "【warai log】[warid%d]SendAllHistoryForWatch,playerId%d,没有观看的人", self.m_WarID, playerId)
    return
  end
  local historyRdCnt = 0
  for _, _ in pairs(self.m_HistoryData) do
    historyRdCnt = historyRdCnt + 1
  end
  for i = 1, self.m_MaxRoundCnt do
    local tempData = self.m_HistoryData[i - 1]
    if tempData == nil then
      break
    elseif i == 1 then
      local baseWarData = DeepCopyTable(tempData.baseData)
      baseWarData.historyRdCnt = historyRdCnt - 1
      net_wtog.tellOnePlayerToWatchWar(playerId, self.m_WarID, self.m_WarType, tempData.attackList, tempData.defendList, baseWarData, tempData.time, i_watchPlayerId)
    else
      net_wtog.tellOnePlayerToRunOneRoundForWatch(playerId, self.m_WarID, i - 1, tempData.roundSeq, tempData.endWarData, tempData.time)
    end
  end
  local watchData = self:GetPlayerWatchWar()
  for _, tempData in pairs(watchData) do
    local watcherData = tempData[2]
    if watcherData ~= nil then
      AISendToOnePlayerOneRoleEnterWatchWar(self.m_WarID, playerId, watcherData)
    end
  end
end
function CWarAI:GetWarType()
  return self.m_WarType
end
function CWarAI:WarAiUseSkillOnTarget(userPos, targetPos, skillId, exPara)
  g_SkillAI.useSkillOnTarget(self.m_WarID, self.m_CurrRoundCnt, userPos, targetPos, skillId, exPara)
end
function CWarAI:WarAiSetAttackFirstUseMagicSkillHpHurt(hurt)
  self.m_AttackFirstUseMagicSkillHurtHp = hurt
end
function CWarAI:WarAiSetDefendFirstUseMagicSkillHpHurt(hurt)
  self.m_DefendFirstUseMagicSkillHurtHp = hurt
end
function CWarAI:WarAiSetAttackFirstUseMagicSkillMpHurt(hurt)
  self.m_AttackFirstUseMagicSkillHurtMp = hurt
end
function CWarAI:WarAiSetDefendFirstUseMagicSkillMpHurt(hurt)
  self.m_DefendFirstUseMagicSkillHurtMp = hurt
end
function CWarAI:WarAiGetAttackFirstUseMagicSkillHpHurt(hurt)
  return self.m_AttackFirstUseMagicSkillHurtHp
end
function CWarAI:WarAiGetDefendFirstUseMagicSkillHpHurt(hurt)
  return self.m_DefendFirstUseMagicSkillHurtHp
end
function CWarAI:WarAiGetAttackFirstUseMagicSkillMpHurt(hurt)
  return self.m_AttackFirstUseMagicSkillHurtMp
end
function CWarAI:WarAiGetDefendFirstUseMagicSkillMpHurt(hurt)
  return self.m_DefendFirstUseMagicSkillHurtMp
end
function CWarAI:WarAiSetAttackFirstUseMagicSkillHuaWu(flag)
  self.m_AttackFirstUseMagicSkillHuaWu = flag
end
function CWarAI:WarAiSetDefendFirstUseMagicSkillHuaWu(flag)
  self.m_DefendFirstUseMagicSkillHuaWu = flag
end
function CWarAI:WarAiGetAttackFirstUseMagicSkillHuaWu()
  return self.m_AttackFirstUseMagicSkillHuaWu
end
function CWarAI:WarAiGetDefendFirstUseMagicSkillHuaWu()
  return self.m_DefendFirstUseMagicSkillHuaWu
end
function CWarAI:WarAiSetAttackZhaoYunMuYuFlag(flag)
  self.m_AttackZhaoYunMuYuDoubleFlag = flag
end
function CWarAI:WarAiSetDefendZhaoYunMuYuFlag(flag)
  self.m_DefendZhaoYunMuYuDoubleFlag = flag
end
function CWarAI:WarAiGetAttackZhaoYunMuYuFlag()
  return self.m_AttackZhaoYunMuYuDoubleFlag
end
function CWarAI:WarAiGetDefendZhaoYunMuYuFlag()
  return self.m_DefendZhaoYunMuYuDoubleFlag
end
function CWarAI:Set51HuoLiFlag(event51)
  printLogDebug("war_ai", "【warai log】[warid%d]Set51HuoLiValue", self.m_WarID, event51)
  self.m_HuoDongData.event51 = event51
end
function CWarAI:Get51HuoLiFlag()
  return self.m_HuoDongData.event51 == 1
end
function CWarAI:SetChengWeiData()
  printLogDebug("war_ai", "【warai log】[warid%d]SetChengWeiData", self.m_WarID)
  local pveFlag = IsPVEWarType(self.m_WarType)
  if pveFlag then
    local cwList = {}
    if WAR_CODE_IS_SERVER ~= true then
      local curId, endTime, isHide = g_LocalPlayer:getCurChengwei()
      if curId ~= nil then
        cwList[curId] = true
      end
    else
      for playerId, _ in pairs(self.m_TeamFlagDict[TEAM_ATTACK]) do
        local rolePlayer = WarAIGetOnePlayerData(self.m_WarID, playerId)
        if rolePlayer.GetChengWeiId then
          local cwId = rolePlayer:GetChengWeiId()
          if cwId ~= nil and cwId ~= 0 then
            cwList[cwId] = true
          end
        end
      end
    end
    local addProValueDict = {}
    for cwId, _ in pairs(cwList) do
      local d = data_Title[cwId]
      if d ~= nil then
        for k, v in pairs(d.AddKX or {}) do
          local pro = PROPERTIES_RANDOM_KANG[k]
          if pro ~= nil then
            local newV = math.max(v, addProValueDict[pro] or 0)
            addProValueDict[pro] = newV
          end
        end
        for k, v in pairs(d.AddFS or {}) do
          local pro = PROPERTIES_STRENGTHEN_MAGIC[k]
          if pro ~= nil then
            local newV = math.max(v, addProValueDict[pro] or 0)
            addProValueDict[pro] = newV
          end
        end
      end
    end
    for pro, addV in pairs(addProValueDict) do
      for playerId, _ in pairs(self.m_TeamFlagDict[TEAM_ATTACK]) do
        local mainRolePos = self:GetMainHeroPosByPlayerID(playerId)
        if mainRolePos ~= nil then
          local mainRole = self.m_Roles[mainRolePos]
          if mainRole ~= nil then
            if pro == PROPERTY_STRENGTHEN_MAGIC_XIXUE or pro == PROPERTY_KXIXUE then
              mainRole:setProperty(pro, mainRole:getProperty(pro) + addV)
            else
              mainRole:setProperty(pro, mainRole:getProperty(pro) + addV / 100)
            end
          end
        end
      end
    end
  end
end
function CWarAI:SetBanLvBeiDongData()
  printLogDebug("war_ai", "【warai log】[warid%d]SetBanLvBeiDongData", self.m_WarID)
  if WAR_CODE_IS_SERVER ~= true then
    return
  end
  local pveFlag = IsPVEWarType(self.m_WarType)
  if pveFlag then
    local tempPlayerIDList = {}
    for _, data in pairs(self.m_TeamFlagDict) do
      for playerId, playerFlagData in pairs(data) do
        tempPlayerIDList[#tempPlayerIDList + 1] = playerId
      end
    end
    for _, playerId in pairs(tempPlayerIDList) do
      local mainRolePos = self:GetMainHeroPosByPlayerID(playerId)
      local banLvPos = self:GetBanLvPos(playerId)
      if mainRolePos ~= nil and banLvPos ~= nil then
        local player = WarAIGetOnePlayerData(self.m_WarID, playerId)
        local mainRole = self.m_Roles[mainRolePos]
        if player ~= nil and mainRole ~= nil then
          local yhdValue = player:GetBanlvValue()
          if yhdValue >= (data_MarrySkill[MARRYSKILL_YUANQIYUCI].yhd or 0) then
            local pro = PROPERTY_FPCRIT
            mainRole:setProperty(pro, mainRole:getProperty(pro) + 0.1)
          end
          if yhdValue >= (data_MarrySkill[MARRYSKILL_BULIBUQI].yhd or 0) then
            local pro = PROPERTY_PSBL
            mainRole:setProperty(pro, mainRole:getProperty(pro) + 0.05)
          end
          if yhdValue >= (data_MarrySkill[MARRYSKILL_SHENGSIXIANGSUI].yhd or 0) then
            local pro = PROPERTY_KZHENSHE
            mainRole:setProperty(pro, mainRole:getProperty(pro) + 0.05)
          end
          if yhdValue >= (data_MarrySkill[MARRYSKILL_QINGSHENSIHAI].yhd or 0) then
            local pro = PROPERTY_PDEFEND
            mainRole:setProperty(pro, mainRole:getProperty(pro) + 0.05)
          end
        end
      end
    end
  end
end
function CWarAI:GetBanLvPos(pID)
  printLogDebug("war_ai", "【warai log】[warid%d]CWarAI:GetBanLvPos", self.m_WarID, pID)
  if WAR_CODE_IS_SERVER ~= true then
    return nil
  end
  local player = WarAIGetOnePlayerData(self.m_WarID, pID)
  if player == nil then
    return nil
  end
  local blID
  if WAR_CODE_IS_SERVER ~= true then
    if g_FriendsMgr then
      blID = g_FriendsMgr:getBanLvId()
    end
  else
    blID = player:GetBanlvID()
  end
  if blID == nil or blID == 0 then
    return nil
  end
  local blPlayer = WarAIGetOnePlayerData(self.m_WarID, blID)
  if blPlayer == nil then
    return nil
  end
  local myPos = self:GetMainHeroPosByPlayerID(pID)
  local blPos = self:GetMainHeroPosByPlayerID(blID)
  local sameSide = myPos > DefineDefendPosNumberBase == (blPos > DefineDefendPosNumberBase)
  if sameSide ~= true then
    return nil
  end
  printLogDebug("war_ai", "【warai log】[warid%d]CWarAI:GetBanLvPos返回", self.m_WarID, blPos)
  return blPos
end
function CWarAI:AddExtraRoleWhenStart()
  printLogDebug("war_ai", "【warai log】[warid%d]CWarAI:AddExtraRoleWhenStart", self.m_WarID)
  if self.m_WarType == WARTYPE_BaoHuChangE then
    local playerIdList = self:GetAllPlayerID()
    self:CreateOneNPCFriend(playerIdList[1], PROTECTCHANGE_ChangeE_Mst_ID, PROTECTCHANGE_ChangeE_Pos)
  end
end
function CWarAI:AddExtraRoleWhenRountEnd()
  printLogDebug("war_ai", "【warai log】[warid%d]CWarAI:AddExtraRoleWhenRountEnd", self.m_WarID)
  local result = self:GetWarResult()
  if self.m_WarType == WARTYPE_BaoHuChangE then
    local playerIdList = self:GetAllPlayerID()
    if self.m_CurrRoundCnt == PROTECTCHANGE_TianPengYuanShai_InWarRnt - 1 and playerIdList[1] ~= nil and result == WARRESULT_NONE then
      local pos = PROTECTCHANGE_TianPengYuanShai_Pos
      self:CreateOneNPCFriend(playerIdList[1], PROTECTCHANGE_TianPengYuanShai_Mst_ID, pos)
      local ZBJObj = self.m_Roles[pos]
      if ZBJObj ~= nil then
        local op = data_getRoleShapOp(ZBJObj:getTypeId())
        if op == 0 or op == 255 then
          op = nil
        end
        local param = {
          objId = ZBJObj:getObjId(),
          typeId = ZBJObj:getTypeId(),
          hp = ZBJObj:getProperty(PROPERTY_HP),
          maxHp = ZBJObj:getMaxProperty(PROPERTY_HP),
          mp = ZBJObj:getProperty(PROPERTY_MP),
          maxMp = ZBJObj:getMaxProperty(PROPERTY_MP),
          team = ZBJObj:getProperty(PROPERTY_TEAM),
          name = ZBJObj:getProperty(PROPERTY_NAME),
          playerId = ZBJObj:getPlayerId(),
          zs = ZBJObj:getProperty(PROPERTY_ZHUANSHENG),
          lv = ZBJObj:getProperty(PROPERTY_ROLELEVEL),
          hasND = ZBJObj:HasNeidanObj(),
          op = op
        }
        g_SkillAI.createAddOneMst(self.m_WarID, pos, param)
      end
    end
  end
end
function CWarAI:PrintAllRole()
  printLogDebug("war_ai", "【warai log】[warid%d]CWarAI:PrintAllRole", self.m_WarID)
  printLogDebug("war_ai", "【warai log】[warid%d]lt:", self.m_WarID)
  for i, v in ipairs(self.m_AliveTeamers.lt) do
    printLogDebug("war_ai", "【warai log】[warid%d]%d, %d, %s", self.m_WarID, i, v, self:getObjectByPos(v).__cname)
  end
  printLogDebug("war_ai", "【warai log】[warid%d]rb:", self.m_WarID)
  for i, v in ipairs(self.m_AliveTeamers.rb) do
    printLogDebug("war_ai", "【warai log】[warid%d]%d, %d, %s", self.m_WarID, i, v, self:getObjectByPos(v).__cname)
  end
end
function CWarAI:PrintRoleSpeed()
  printLogDebug("war_ai", "【warai log】[warid%d]CWarAI:PrintAllRoleSpeed", self.m_WarID)
  printLogDebug("war_ai", "【warai log】[warid%d]m_FightSeq:%s, %d", self.m_WarID, tostring(self.m_FightSeq), #self.m_FightSeq)
  for i, v in ipairs(self.m_FightSeq) do
    local role = self:getObjectByPos(v)
    if role ~= nil then
      printLogDebug("war_ai", "【warai log】[warid%d]pos %d, maxsp%d sp %d", self.m_WarID, v, role:getMaxProperty(PROPERTY_SP), role:getProperty(PROPERTY_SP))
    else
      printLogDebug("war_ai", "【warai log】[warid%d]pos %d,为空", self.m_WarID, v)
    end
  end
end
