local s_shichen = {
  "子",
  "丑",
  "寅",
  "卯",
  "申",
  "酉",
  "戌",
  "亥",
  "辰",
  "巳",
  "午",
  "未"
}
local s_shike = {
  "一",
  "二",
  "三",
  "四",
  "五"
}
local talkId_accept = 500011
local guiwang_npcId = 90011
function GuiWangExtend(object)
  function object:GuiWangInit()
    object._gw_taskId = 0
    object._gw_monsterLv = 0
    object._gw_locId = nil
    object._gw_warId = 0
    object._gw_endTime = 0
    object._gw_circel = 1
    object._gw_state = 0
    GuiWang.m_boxId = nil
  end
  function object:getGuiWangWarId()
    return object._gw_warId
  end
  object:GuiWangInit()
end
GuiWang = {}
GuiWang.curMapId = -1
GuiWang.monsterCreated = {}
GuiWang.MissionDes = "去打败鬼王"
GuiWang.LastCompleteTime = 0
GuiWang.IsFinishAllMission = false
gamereset.registerResetFunc(function()
  GuiWang.curMapId = -1
  GuiWang.monsterCreated = {}
  GuiWang.MissionDes = "去打败鬼王"
end)
function GuiWang.DealServercircle(circle)
  return circle % GuiWang_MaxCircle + 1
end
function GuiWang.GotoNpc()
  g_MapMgr:AutoRouteToNpc(guiwang_npcId, function(isSucceed)
    if isSucceed and CMainUIScene.Ins then
      CMainUIScene.Ins:ShowNormalNpcViewById(guiwang_npcId)
    end
  end)
end
function GuiWang.isNpc(npcId)
  return npcId == guiwang_npcId
end
function GuiWang.CanAccept()
  if g_LocalPlayer:isFunctionUnlock(OPEN_Func_Guiwang) == false then
    return false
  end
  return true
end
function GuiWang.getCircel()
  return g_LocalPlayer._gw_circel
end
function GuiWang.TrackMission()
  print("GuiWang.TrackMission")
  if g_LocalPlayer._gw_taskId == 0 then
    print("g_LocalPlayer._gw_taskId:", g_LocalPlayer._gw_taskId)
    return nil
  end
  print("g_LocalPlayer._gw_state,g_LocalPlayer._gw_locId:", g_LocalPlayer._gw_state, g_LocalPlayer._gw_locId)
  if g_LocalPlayer._gw_state == 1 then
    local locId = g_LocalPlayer._gw_locId
    if locId == nil then
      return
    end
    local route_cb = function(isSucceed)
      if isSucceed then
        GuiWang.touchMoster()
      end
    end
    g_MapMgr:AutoRouteWithCustomId(locId, route_cb, true, RouteType_Monster)
  elseif g_LocalPlayer._gw_state == 2 then
    netsend.netmission.reqCommitByType(801, g_LocalPlayer._gw_taskId)
  end
end
function GuiWang.popConfirmView(msg)
  local autoConfirmTime, autoCancelTime
  local hideInWar = true
  local confirmBoxDlg = CPopWarning.new({
    title = "提示",
    text = msg,
    confirmFunc = function()
      GuiWang.GotoNpc()
    end,
    cancelText = "取消",
    confirmText = "确定",
    autoConfirmTime = autoConfirmTime,
    autoCancelTime = autoCancelTime,
    hideInWar = hideInWar
  })
  confirmBoxDlg:ShowCloseBtn(false)
end
function GuiWang.reqAccept()
  if g_LocalPlayer._gw_taskId ~= 0 then
    return true
  end
  netsend.netmission.reqAcceptByType(801)
  return true
end
function GuiWang.GiveUpMission()
  if g_LocalPlayer._gw_taskId == 0 then
    return nil
  end
  netsend.netmission.reqGiveupByType(801, g_LocalPlayer._gw_taskId)
end
function GuiWang.dataUpdate(param)
  if g_LocalPlayer == nil then
    printLog("ERROR", "鬼王任务更新没有找到本地玩家")
    return
  end
  local taskid = param.taskid
  local monster_lv = param.monster_lv
  local loc_id = param.loc_id
  local warid = param.warid
  local lefttime = param.lefttime
  local cnt = param.cnt
  local circle = param.circle
  local state = param.state
  if taskid == nil then
    printLog("ERROR", "鬼王任务更新的任务ID为nil")
    return
  end
  local oldtaskid = g_LocalPlayer._gw_taskId
  g_LocalPlayer._gw_taskId = taskid
  if monster_lv ~= nil then
    g_LocalPlayer._gw_monsterLv = monster_lv
  end
  if loc_id ~= nil then
    g_LocalPlayer._gw_locId = loc_id
  end
  if warid ~= nil then
    g_LocalPlayer._gw_warId = warid
  end
  if lefttime ~= nil then
    g_LocalPlayer._gw_endTime = g_DataMgr:getServerTime() + lefttime
  end
  if circle ~= nil then
    g_LocalPlayer._gw_circel = GuiWang.DealServercircle(circle)
  end
  if state ~= nil then
    g_LocalPlayer._gw_state = state
  end
  GuiWang.detectEndTime(false)
  if state == 0 then
    g_LocalPlayer._gw_taskId = 0
    g_MissionMgr:flushGuiwangCanAccept()
  elseif state == 1 then
    local isNeedTrace = false
    GuiWang.resetMissionDesAndTalk()
    if g_DataMgr:getIsSendFinished() and oldtaskid ~= g_LocalPlayer._gw_taskId then
      g_MissionMgr:ShowDoubleExpSetView(data_Variables.GhostKing_CostDp or 4, 3)
      g_MissionMgr:NewMission(GuiWang_MissionId)
      if 0 < g_LocalPlayer:getIsFollowTeamCommon() then
        isNeedTrace = true
      end
    end
    g_MissionMgr:Server_MissionUpdated(GuiWang_MissionId, 0, nil)
    if isNeedTrace then
      g_MissionMgr:setAutoTraceMissionId(GuiWang_MissionId)
    end
  elseif state == 2 then
    g_MissionMgr:Server_MissionUpdated(GuiWang_MissionId, 1, nil)
  elseif state == 3 then
    GuiWang.LastCompleteTime = g_DataMgr:getServerTime()
  end
  GuiWang.DetectOpenNpcViewWhenCountUpdate()
end
function GuiWang.taskDel(delType, taskid)
  local curCircle = g_LocalPlayer._gw_circel
  g_LocalPlayer._gw_taskId = 0
  g_MissionMgr:delGuiWang()
  if delType == 1 then
    AwardPrompt.ShowMissionCmp()
    GuiWang.LastCompleteTime = g_DataMgr:getServerTime()
  end
  SendMessage(MsgID_Mission_Common)
  g_MissionMgr:flushGuiwangCanAccept()
  if delType == 1 and GuiWang_MaxCircle == curCircle then
    GuiWang.IsFinishAllMission = true
  end
end
function GuiWang.DetectOpenNpcViewWhenCountUpdate()
  if g_LocalPlayer._gw_circel == 1 and GuiWang.IsFinishAllMission and g_LocalPlayer:getIsFollowTeamCommon() > 0 then
    GuiWang.IsFinishAllMission = false
  end
end
function GuiWang.touchMoster()
  print("===>>GuiWang.touchMoster")
  local taskid = g_LocalPlayer._gw_taskId
  if taskid then
    netsend.netteamwar.requestGuiwangWar(taskid)
  end
end
function GuiWang.CountUpdated(circle)
  print("-->>GuiWang.CountUpdated:", circle)
  if circle == nil then
    return
  end
  g_LocalPlayer._gw_circel = GuiWang.DealServercircle(circle)
  print("-->_gw_circel:", g_LocalPlayer._gw_circel)
  g_MissionMgr:flushGuiwangCanAccept()
  GuiWang.DetectOpenNpcViewWhenCountUpdate()
end
function GuiWang.detectEndTime(isSendMsg)
  if g_LocalPlayer._gw_taskId > 0 and g_LocalPlayer._gw_state >= 1 then
    local dt = g_LocalPlayer._gw_endTime - g_DataMgr:getServerTime()
    if dt < 0.5 then
      g_LocalPlayer._gw_taskId = 0
      g_LocalPlayer._gw_circel = 1
      if isSendMsg == true then
        g_MissionMgr:delGuiWang()
      end
    else
      return dt
    end
  end
  return nil
end
function GuiWang.resetMissionDesAndTalk()
  print([[


 resetMissionDesAndTalk -->g_LocalPlayer:getGuiWangWarId(  ):]], g_LocalPlayer:getGuiWangWarId())
  local roleTypeId, monsterName = data_getBossForWar(g_LocalPlayer:getGuiWangWarId())
  print("roleTypeId, monsterName:", roleTypeId, monsterName)
  print("--g_LocalPlayer._gw_locId:", g_LocalPlayer._gw_locId)
  local mapName = ""
  local d = data_CustomMapPos[g_LocalPlayer._gw_locId]
  print("d-->", d)
  if d == nil then
    return
  end
  local mapId = d.SceneID
  print("mapId->", mapId)
  if mapId then
    local mapData = data_MapInfo[mapId]
    dump(mapData, "mapData")
    if mapData then
      mapName = mapData.name
    end
  end
  if mapName ~= nil and monsterName ~= nil then
    local shichen = s_shichen[math.random(1, #s_shichen)]
    local shike = s_shike[math.random(1, #s_shike)]
    local s = string.format("鬼差报信,%s时%s刻%s在%s附近吸收天地灵气，三界正义之士正在前往讨伐，赶快前往收服吧", shichen, shike, monsterName, mapName)
    local tData = data_MissionTalk[talkId_accept]
    if tData and #tData > 0 then
      tData[1][2] = s
    end
    GuiWang.MissionDes = string.format("去#<Y>%s#打败#<Y>%s#", mapName, monsterName)
  end
end
function GuiWang.needCreateMonster()
  return g_LocalPlayer._gw_state == 1 and g_LocalPlayer._gw_locId ~= nil and g_LocalPlayer._gw_endTime > g_DataMgr:getServerTime()
end
