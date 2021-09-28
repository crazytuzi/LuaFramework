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
local zhuaguiNpcId = 90007
function ZhuaGuaExtend(object)
  function object:ZhuaGuiInit()
    object._zg_taskId = 0
    object._zg_monsterLv = 0
    object._zg_mapInfo = nil
    object._zg_warId = 0
    object._zg_endTime = 0
    object._zg_circel = 1
    object._zg_state = 0
  end
  function object:getZhuaGuiShowMonsterId()
    if object._zg_taskId == 0 then
      return nil
    end
    local warData = data_WarRole[object._zg_warId]
    if warData then
      return warData.posList[10003]
    end
  end
  object:ZhuaGuiInit()
end
ZhuaGui = {}
ZhuaGui.curMapId = -1
ZhuaGui.monsterCreated = {}
ZhuaGui.m_boxId = nil
function ZhuaGui.DealServercircle(circle)
  return circle % ZhuaGui_MaxCircle + 1
end
function ZhuaGui.isNpc(npcId)
  return npcId == zhuaguiNpcId
end
function ZhuaGui.getAcceptMissionId()
  return talkId_accept
end
function ZhuaGui.CountUpdated(circle, pid)
  print("-->>ZhuaGui.CountUpdated:", circle, pid)
  if circle == nil then
    return
  end
  local player = g_DataMgr:getPlayer(pid)
  if player == nil then
    return nil
  end
  if circle ~= nil then
    player._zg_circel = ZhuaGui.DealServercircle(circle)
  end
  print("-->_zg_circel:", player._zg_circel)
  if player == g_LocalPlayer then
    SendMessage(MsgID_ZhuaGui_CountUpdate, cnt)
    g_MissionMgr:flushZhuaGuiCanAccept()
  end
  ZhuaGui.DetectOpenNpcViewWhenCountUpdate()
end
function ZhuaGui.GotoNpc()
  g_MapMgr:AutoRouteToNpc(zhuaguiNpcId, function(isSucceed)
    if isSucceed and CMainUIScene.Ins then
      CMainUIScene.Ins:ShowNormalNpcViewById(zhuaguiNpcId)
    end
  end)
end
function ZhuaGui.CanAccept()
  if g_LocalPlayer:isFunctionUnlock(OPEN_Func_Zhuagui) == false then
    return false
  end
  return true
end
function ZhuaGui.getCircel()
  return g_LocalPlayer._zg_circel
end
function ZhuaGui.reqAccept()
  if g_LocalPlayer._zg_taskId ~= 0 then
    print("===>>已经接了任务")
    return true
  end
  print("\n\n\t\tTODO:判断是否是队长并且队伍人数大于3\n")
  netsend.netmission.reqAcceptZhuaGui()
  return true
end
function ZhuaGui.dataUpdate(param, pid)
  local player = g_DataMgr:getPlayer(pid)
  if player == nil or param == nil then
    return
  end
  local taskid = param.taskid
  local monster_lv = param.monster_lv
  local warid = param.warid
  local lefttime = param.lefttime
  local circle = param.circle
  local state = param.state
  if taskid == nil then
    return
  end
  local oldtaskid = player._zg_taskId
  player._zg_taskId = taskid
  if monster_lv ~= nil then
    player._zg_monsterLv = monster_lv
  end
  local loc_id = param.loc_id
  local posData = data_CustomMapPos[loc_id]
  if posData == nil then
    printLog("ERROR", "抓鬼任务的位置出错")
    posData = data_CustomMapPos[1101]
  end
  if posData then
    player._zg_mapInfo = {
      posData.SceneID,
      posData.WarPos[1],
      posData.WarPos[2],
      posData.WarPos[3],
      posData.JumpPos[1],
      posData.JumpPos[2]
    }
  end
  if warid ~= nil then
    player._zg_warId = warid
  end
  if lefttime ~= nil then
    player._zg_endTime = g_DataMgr:getServerTime() + lefttime
  end
  if circle ~= nil then
    player._zg_circel = ZhuaGui.DealServercircle(circle)
    if 1 < player._zg_circel then
      g_MissionMgr:GuideIdComplete(GuideId_Zhuagui)
    end
  end
  if state ~= nil then
    player._zg_state = state
  end
  if player == g_LocalPlayer then
    ZhuaGui.detectEndTime(false)
    if state == 0 then
      player._zg_taskId = 0
      g_MissionMgr:flushZhuaGuiCanAccept()
    elseif state == 1 then
      local isNeedTrace = false
      if g_DataMgr:getIsSendFinished() then
        ZhuaGui.resetTalkId()
        g_MissionMgr:ShowDoubleExpSetView(data_Variables.CatchGhost_CostDp or 4, 1)
        if 0 < g_LocalPlayer:getIsFollowTeamCommon() then
          isNeedTrace = true
        end
      end
      g_MissionMgr:Server_MissionUpdated(ZhuaGui_MissionId, 0, nil)
      if isNeedTrace then
        g_MissionMgr:setAutoTraceMissionId(ZhuaGui_MissionId)
      end
    elseif state == 2 then
      g_MissionMgr:Server_MissionUpdated(ZhuaGui_MissionId, 1, nil)
    elseif state == 3 then
      AwardPrompt.ShowMissionCmp()
    end
    if oldtaskid == 0 and player._zg_taskId ~= 0 then
      g_MissionMgr:NewMission(ZhuaGui_MissionId)
    end
  end
  SendMessage(MsgID_ZhuaGui_DataUpdate, player:getPlayerId())
  ZhuaGui.flushCreateMonster()
  ZhuaGui.DetectOpenNpcViewWhenCountUpdate()
end
function ZhuaGui.resetTalkId()
  local _, monsterName = data_getRoleShapeAndName(g_LocalPlayer:getZhuaGuiShowMonsterId())
  local mapName = ""
  local mapId = g_LocalPlayer._zg_mapInfo[1]
  if mapId then
    local mapData = data_MapInfo[mapId]
    if mapData then
      mapName = mapData.name
    end
  end
  if mapName ~= nil and monsterName ~= nil then
    local shichen = s_shichen[math.random(1, #s_shichen)]
    local shike = s_shike[math.random(1, #s_shike)]
    local s = string.format("%s时%s刻逃出的%s，在%s附近徘徊，请前往超度", shichen, shike, monsterName, mapName)
    local tData = data_MissionTalk[talkId_accept]
    if tData and #tData > 0 then
      tData[1][2] = s
    end
  end
end
function ZhuaGui.taskDel(taskid, typ)
  local curCircle = g_LocalPlayer._zg_circel
  g_LocalPlayer._zg_taskId = 0
  ZhuaGui.flushCreateMonster()
  g_MissionMgr:delZhuaGui()
  SendMessage(MsgID_ZhuaGui_DataUpdate, g_LocalPlayer:getPlayerId())
  SendMessage(MsgID_Mission_Common)
  g_MissionMgr:flushZhuaGuiCanAccept()
  if typ == 1 then
    g_MissionMgr:GuideIdComplete(GuideId_Zhuagui)
    if ZhuaGui_MaxCircle == curCircle then
      ZhuaGui.IsFinishAllMission = true
    end
  end
end
function ZhuaGui.DetectOpenNpcViewWhenCountUpdate()
  if g_LocalPlayer._zg_circel == 1 and ZhuaGui.IsFinishAllMission and g_LocalPlayer:getIsFollowTeamCommon() > 0 then
    ZhuaGui.IsFinishAllMission = false
  end
end
function ZhuaGui.popConfirmView(msg)
  local autoConfirmTime, autoCancelTime
  local hideInWar = true
  local confirmBoxDlg = CPopWarning.new({
    title = "提示",
    text = msg,
    confirmFunc = function()
      ZhuaGui.GotoNpc()
    end,
    cancelText = "取消",
    confirmText = "确定",
    autoConfirmTime = autoConfirmTime,
    autoCancelTime = autoCancelTime,
    hideInWar = hideInWar
  })
  confirmBoxDlg:ShowCloseBtn(false)
end
function ZhuaGui.reward(param)
  if ZhuaGui.CanAccept() then
    local teamFollowStatus = g_LocalPlayer:getIsFollowTeam()
    if teamFollowStatus ~= 0 then
      ZhuaGui.GotoNpc()
    end
  end
  g_MissionMgr:GuideIdComplete(GuideId_Zhuagui)
end
function ZhuaGui.flushCreateMonster()
  printLog("ZhuaGui", "ZhuaGui.flushCreateMonster")
  local mapView = g_MapMgr:getMapViewIns()
  local mapId = g_MapMgr:getCurMapId()
  if mapView == nil then
    printLog("ZhuaGui", "mapView == nilKKKKKKKKKKKKKKKKKKKKKKKKK")
    return
  end
  local created = ZhuaGui.monsterCreated or {}
  if mapId ~= ZhuaGui.curMapId then
    ZhuaGui.curMapId = mapId
    created = {}
  end
  ZhuaGui.monsterCreated = {}
  local pids = {
    g_LocalPlayer:getPlayerId()
  }
  for i, pid in ipairs(pids) do
    local player = g_DataMgr:getPlayer(pid)
    print("ZhuaGui:", pid, player)
    if player then
      print("==>> player._zg_taskId:", player._zg_taskId)
    end
    if player and player._zg_taskId > 0 then
      local mapPos = player._zg_mapInfo or {}
      print("==>> player._zg_state:", player._zg_state, mapPos, #mapPos)
      print("--> mapPos[1] == mapId:", mapPos[1], mapId)
      if player._zg_state == 1 and mapPos[1] == mapId and player._zg_endTime > g_DataMgr:getServerTime() then
        local tempId = created[pid]
        if tempId ~= nil and mapView:getMonster(tempId) ~= nil then
          ZhuaGui.monsterCreated[pid] = created[pid]
          created[pid] = nil
        else
          local monsterTypeId = player:getZhuaGuiShowMonsterId()
          if monsterTypeId ~= nil then
            local monsterId = mapView:CreateMonster(monsterTypeId, {
              mapPos[2],
              mapPos[3]
            }, MapPosType_EditorGrid, mapPos[4], MapMonsterType_Zhuagui, pid)
            ZhuaGui.monsterCreated[pid] = monsterId
          end
          created[pid] = nil
        end
      end
    end
  end
  for pid, monsterId in pairs(created) do
    print("333333333333333333333333333333;", missionId)
    mapView:DeleteMonster(monsterId)
  end
end
function ZhuaGui.touchMoster(monsterTypeId, playerId)
  print("===>>ZhuaGui.touchMoster monsterTypeId, playerId:", monsterTypeId, playerId)
  local taskid = g_LocalPlayer._zg_taskId
  if taskid then
    netsend.netteamwar.requestZhuaguiWar(taskid)
  end
end
function ZhuaGui.TrackMission()
  if g_LocalPlayer._zg_taskId == 0 then
    return nil
  end
  if g_LocalPlayer._zg_state == 1 then
    local mapInfo = g_LocalPlayer._zg_mapInfo
    if mapInfo == nil or #mapInfo ~= 6 then
      return
    end
    local mapId = mapInfo[1]
    local gridPos = {
      mapInfo[2],
      mapInfo[3] + 1
    }
    local jumpPos = {
      mapInfo[5],
      mapInfo[6]
    }
    local route_cb = function(isSucceed)
      if isSucceed then
        ZhuaGui.touchMoster(g_LocalPlayer:getZhuaGuiShowMonsterId(), g_LocalPlayer:getPlayerId())
      end
    end
    g_MapMgr:AutoRoute(mapId, gridPos, route_cb, nil, nil, jumpPos, nil, RouteType_Monster)
  elseif g_LocalPlayer._zg_state == 2 then
    netsend.netmission.reqCommitZhuaGui(g_LocalPlayer._zg_taskId)
  end
end
function ZhuaGui.GiveUpMission()
  if g_LocalPlayer._zg_taskId == 0 then
    return nil
  end
  netsend.netmission.reqGiveupZhuaGui(g_LocalPlayer._zg_taskId)
  g_LocalPlayer._zg_taskId = 0
end
function ZhuaGui.acceptStatus(status)
  if status == 1 then
    getCurSceneView():ShowTalkView(500012, function()
    end)
  elseif status == 2 then
    ShowNotifyTips("需要队长才能接受任务")
  elseif status == 3 then
    getCurSceneView():ShowTalkView(500013, function()
    end)
  end
end
function ZhuaGui.detectEndTime(isSendMsg)
  if g_LocalPlayer._zg_taskId > 0 and g_LocalPlayer._zg_state >= 1 then
    local dt = g_LocalPlayer._zg_endTime - g_DataMgr:getServerTime()
    if dt < 0.5 then
      g_LocalPlayer._zg_taskId = 0
      g_LocalPlayer._zg_circel = 1
      if isSendMsg == true then
        g_MissionMgr:delZhuaGui()
        ZhuaGui.flushCreateMonster()
      end
    else
      return dt
    end
  end
  return nil
end
function ZhuaGui.Test()
  local param = {}
  param.taskid = 900
  param.monster_lv = 20
  param.scene = 8
  param.loc_war = {
    20,
    22,
    5
  }
  param.loc_jump = {31, 28}
  param.warid = 12001
  param.lefttime = 3600
  param.circle = 1
  param.state = 1
  ZhuaGui.dataUpdate(param, nil, true)
end
gamereset.registerResetFunc(function()
  ZhuaGui.curMapId = -1
  ZhuaGui.monsterCreated = {}
end)
