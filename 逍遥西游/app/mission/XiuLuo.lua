local talkId_accept = 700151
function XiuLuoExtend(object)
  function object:XiuLuoInit()
    object._xl_taskId = 0
    object._xl_monsterLv = 0
    object._xl_mapInfo = nil
    object._xl_warId = 0
    object._xl_endTime = 0
    object._xl_circel = 1
    object._xl_count = 0
    object._xl_state = 0
  end
  function object:getXiuLuoShowMonsterId()
    if object._xl_taskId == 0 then
      return nil
    end
    local warData = data_WarRole[object._xl_warId]
    if warData then
      return warData.posList[10003]
    end
  end
  object:XiuLuoInit()
end
XiuLuo = {}
XiuLuo.curMapId = -1
XiuLuo.monsterCreated = {}
function XiuLuo.DealServercircle(circle)
  return circle % XiuLuo_MaxCircle + 1
end
function XiuLuo.isNpc(npcId)
  return npcId == NPC_XiuLuo_ID
end
function XiuLuo.CountUpdated(cnt, circle)
  local player = g_LocalPlayer
  if player == nil then
    return nil
  end
  if circle ~= nil then
    player._xl_circel = XiuLuo.DealServercircle(circle)
  end
  if player == g_LocalPlayer then
    g_MissionMgr:flushXiuLuoCanAccept()
  end
  player._xl_count = cnt or 1
end
function XiuLuo.GotoNpc()
  g_MapMgr:AutoRouteToNpc(NPC_XiuLuo_ID, function(isSucceed)
    if isSucceed and CMainUIScene.Ins then
      CMainUIScene.Ins:ShowNormalNpcViewById(NPC_XiuLuo_ID)
    end
  end)
end
function XiuLuo.CanAccept()
  if g_LocalPlayer:isFunctionUnlock(OPEN_Func_XiuLuo) == false then
    return false
  end
  return true
end
function XiuLuo.getCircel()
  return g_LocalPlayer._xl_circel
end
function XiuLuo.reqAccept()
  if g_LocalPlayer._xl_taskId ~= 0 then
    print("===>>已经接了任务")
    return true
  end
  print("\n\n\t\tTODO:判断是否是队长并且队伍人数大于3\n")
  netsend.netmission.reqAcceptXiuLuo()
  return true
end
function XiuLuo.dataUpdate(param, pid)
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
  local oldtaskid = player._xl_taskId
  player._xl_taskId = taskid
  if monster_lv ~= nil then
    player._xl_monsterLv = monster_lv
  end
  local loc_id = param.loc_id
  local posData = data_CustomMapPos[loc_id]
  if posData == nil then
    printLog("ERROR", "修罗任务的位置出错")
    posData = data_CustomMapPos[20002]
  end
  if posData then
    player._xl_mapInfo = {
      posData.SceneID,
      posData.WarPos[1],
      posData.WarPos[2],
      posData.WarPos[3],
      posData.JumpPos[1],
      posData.JumpPos[2]
    }
  end
  if warid ~= nil then
    player._xl_warId = warid
  end
  if lefttime ~= nil then
    player._xl_endTime = g_DataMgr:getServerTime() + lefttime
  end
  if circle ~= nil then
    player._xl_circel = XiuLuo.DealServercircle(circle)
  end
  if state ~= nil then
    player._xl_state = state
  end
  if player == g_LocalPlayer then
    XiuLuo.detectEndTime(false)
    if state == 0 then
      player._xl_taskId = 0
      g_MissionMgr:flushXiuLuoCanAccept()
    elseif state == 1 then
      local isNeedTrace = false
      if g_DataMgr:getIsSendFinished() then
        g_MissionMgr:ShowDoubleExpSetView(data_Variables.CatchGhost_CostDp or 4, 1)
        if 0 < g_LocalPlayer:getIsFollowTeamCommon() then
          isNeedTrace = true
        end
      end
      g_MissionMgr:Server_MissionUpdated(XiuLuo_MissionId, 0, nil)
      if isNeedTrace then
        g_MissionMgr:setAutoTraceMissionId(XiuLuo_MissionId)
      end
    elseif state == 2 then
      g_MissionMgr:Server_MissionUpdated(XiuLuo_MissionId, 1, nil)
    elseif state == 3 then
      AwardPrompt.ShowMissionCmp()
    end
    if oldtaskid == 0 and player._xl_taskId ~= 0 then
      g_MissionMgr:NewMission(XiuLuo_MissionId)
    end
  end
  XiuLuo.flushCreateMonster()
  g_MissionMgr:flushXiuLuoCanAccept()
  XiuLuo.DetectOpenNpcViewWhenCountUpdate()
end
function XiuLuo.resetTalkId()
  local s = string.format("少侠今日已消灭修罗#<G,>%d#次,当日超过#<G,>120#次后，经验会降低", g_LocalPlayer._xl_count)
  local tData = data_MissionTalk[talkId_accept]
  if tData and #tData > 0 then
    tData[1][2] = s
  end
end
function XiuLuo.taskDel(taskid, typ)
  local curCircle = g_LocalPlayer._xl_circel
  g_LocalPlayer._xl_taskId = 0
  g_LocalPlayer._xl_state = 0
  XiuLuo.flushCreateMonster()
  g_MissionMgr:delXiuLuo()
  SendMessage(MsgID_Mission_Common)
  g_MissionMgr:Server_GiveUpMission(XiuLuo_MissionId)
  g_MissionMgr:flushXiuLuoCanAccept()
  if typ == 1 then
    g_MissionMgr:GuideIdComplete(GuideId_XiuLuo)
    if XiuLuo_MaxCircle == curCircle then
      XiuLuo.IsFinishAllMission = true
    end
  elseif typ == 2 or typ == 3 then
    g_MissionMgr:FlushCanAcceptMission()
  end
  g_LocalPlayer._xl_circel = 1
end
function XiuLuo.DetectOpenNpcViewWhenCountUpdate()
  if g_LocalPlayer._xl_circel == 1 and XiuLuo.IsFinishAllMission and g_LocalPlayer:getIsFollowTeamCommon() > 0 then
    XiuLuo.IsFinishAllMission = false
  end
end
function XiuLuo.popConfirmView(msg)
  local autoConfirmTime, autoCancelTime
  local hideInWar = true
  local confirmBoxDlg = CPopWarning.new({
    title = "提示",
    text = msg,
    confirmFunc = function()
      XiuLuo.GotoNpc()
    end,
    cancelText = "取消",
    confirmText = "确定",
    autoConfirmTime = autoConfirmTime,
    autoCancelTime = autoCancelTime,
    hideInWar = hideInWar
  })
  confirmBoxDlg:ShowCloseBtn(false)
end
function XiuLuo.flushCreateMonster()
  printLog("XiuLuo", "XiuLuo.flushCreateMonster")
  local mapView = g_MapMgr:getMapViewIns()
  local mapId = g_MapMgr:getCurMapId()
  if mapView == nil then
    printLog("XiuLuo", "mapView == nil")
    return
  end
  local created = XiuLuo.monsterCreated or {}
  if mapId ~= XiuLuo.curMapId then
    XiuLuo.curMapId = mapId
    created = {}
  end
  XiuLuo.monsterCreated = {}
  local pids = {
    g_LocalPlayer:getPlayerId()
  }
  for i, pid in ipairs(pids) do
    local player = g_DataMgr:getPlayer(pid)
    print("XiuLuo:", pid, player)
    if player then
      print("==>> player._xl_taskId:", player._xl_taskId)
    end
    if player and player._xl_taskId > 0 then
      local mapPos = player._xl_mapInfo or {}
      print("==>> player._xl_state:", player._xl_state, mapPos, #mapPos)
      print("--> mapPos[1] == mapId:", mapPos[1], mapId)
      if player._xl_state == 1 and mapPos[1] == mapId and player._xl_endTime > g_DataMgr:getServerTime() then
        local tempId = created[pid]
        if tempId ~= nil and mapView:getMonster(tempId) ~= nil then
          XiuLuo.monsterCreated[pid] = created[pid]
          created[pid] = nil
        else
          local monsterTypeId = player:getXiuLuoShowMonsterId()
          if monsterTypeId ~= nil then
            local monsterId = mapView:CreateMonster(monsterTypeId, {
              mapPos[2],
              mapPos[3]
            }, MapPosType_EditorGrid, mapPos[4], MapMonsterType_XiuLuo, pid)
            XiuLuo.monsterCreated[pid] = monsterId
          end
          created[pid] = nil
        end
      end
    end
  end
  for pid, monsterId in pairs(created) do
    mapView:DeleteMonster(monsterId)
  end
end
function XiuLuo.touchMoster(monsterTypeId, playerId)
  print("===>>XiuLuo.touchMoster monsterTypeId, playerId:", monsterTypeId, playerId)
  local taskid = g_LocalPlayer._xl_taskId
  if taskid then
    netsend.netteamwar.requestXiuLuoWar(taskid)
  end
end
function XiuLuo.TrackMission()
  if g_LocalPlayer._xl_taskId == 0 then
    return nil
  end
  if g_LocalPlayer._xl_state == 1 then
    local mapInfo = g_LocalPlayer._xl_mapInfo
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
        XiuLuo.touchMoster(g_LocalPlayer:getXiuLuoShowMonsterId(), g_LocalPlayer:getPlayerId())
      end
    end
    g_MapMgr:AutoRoute(mapId, gridPos, route_cb, nil, nil, jumpPos, nil, RouteType_Monster)
  elseif g_LocalPlayer._xl_state == 2 then
    netsend.netmission.reqCommitXiuLuo(g_LocalPlayer._xl_taskId)
  end
end
function XiuLuo.GiveUpMission()
  if g_LocalPlayer._xl_taskId == 0 then
    return nil
  end
  netsend.netmission.reqGiveupXiuLuo(g_LocalPlayer._xl_taskId)
  g_LocalPlayer._xl_taskId = 0
end
function XiuLuo.detectEndTime(isSendMsg)
  if g_LocalPlayer._xl_taskId > 0 and g_LocalPlayer._xl_state >= 1 then
    local dt = g_LocalPlayer._xl_endTime - g_DataMgr:getServerTime()
    if dt < 0.5 then
      g_LocalPlayer._xl_taskId = 0
      if isSendMsg == true then
        g_MissionMgr:delXiuLuo()
        XiuLuo.flushCreateMonster()
      end
    else
      return dt
    end
  end
  return nil
end
gamereset.registerResetFunc(function()
  XiuLuo.curMapId = -1
  XiuLuo.monsterCreated = {}
end)
