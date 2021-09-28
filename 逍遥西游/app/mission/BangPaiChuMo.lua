BangPaiChuMo = {}
BangPaiChuMo_MissionId = 40002
BangPaiChuMo_LEFTTIME = 1800
function BangPaiChuMo.init()
  BangPaiChuMo.taskid_ = -1
  BangPaiChuMo.state_ = 0
  BangPaiChuMo.loc_id_ = -1
  BangPaiChuMo.bossid_ = -1
  BangPaiChuMo.lefttime_ = 0
  BangPaiChuMo.warid_ = 0
  BangPaiChuMo.isAccepted = false
  BangPaiChuMo.hadCommint = false
  BangPaiChuMo.serviceState = true
  BangPaiChuMo.MissionId = -1
  BangPaiChuMo.createMonsterId = {}
  BangPaiChuMo.curMapId = -1
  BangPaiChuMo.setIsAccept(false)
  BangPaiChuMo.endTime = 0
  BangPaiChuMo.haveTalk = false
end
function BangPaiChuMo.flushServiceState(boolValue)
  BangPaiChuMo.serviceState = boolValue or false
end
function BangPaiChuMo.getServiceState()
  return BangPaiChuMo.serviceState or false
end
function BangPaiChuMo.getMissionState()
  return BangPaiChuMo.state_
end
function BangPaiChuMo.getIsAccepted()
  return BangPaiChuMo.isAccepted or false
end
function BangPaiChuMo.getNpcId()
  return 90019
end
function BangPaiChuMo.setIsAccept(boolV)
  boolV = boolV or false
  BangPaiChuMo.isAccepted = boolV
end
function BangPaiChuMo.getAcceptedStatus()
  local status = BangPaiChuMo.state_
  if status == 1 then
    return MapRoleStatus_TaskNotComplete
  elseif status == 2 or status == 3 then
    return MapRoleStatus_TaskCanCommit
  end
  return nil
end
function BangPaiChuMo.getCanAcceptChuMo()
  if g_BpMgr:getOpenChuMoFlag() ~= true or g_LocalPlayer:isNpcOptionUnlock(1057) == false or g_BpMgr:localPlayerHasBangPai() == false or BangPaiChuMo.serviceState == false then
    BangPaiChuMo.ChuMoServiceState = false
  else
    BangPaiChuMo.ChuMoServiceState = true
  end
  return BangPaiChuMo.ChuMoServiceState
end
function BangPaiChuMo.setCanAcceptChuMo(boolV)
  boolV = boolV or false
  BangPaiChuMo.ChuMoServiceState = boolV
end
function BangPaiChuMo.getLevelLimited()
  if g_LocalPlayer:isNpcOptionUnlock(1057) == false then
    BangPaiChuMo.m_levelLimited = false
  end
  return BangPaiChuMo.m_levelLimited or false
end
function BangPaiChuMo.setLevelLimited(boolV)
  boolV = boolV or false
  BangPaiChuMo.m_levelLimited = boolV
end
function BangPaiChuMo.getUnLockLevel()
  local item = data_NpcTypeInfo[1057] or {}
  return item.zs, item.lv
end
function BangPaiChuMo.gotoNpc()
  local NpcId = BangPaiChuMo.getNpcId()
  if NpcId then
    g_MapMgr:AutoRouteToNpc(NpcId, function(isSucceed)
      if isSucceed and CMainUIScene.Ins then
        CMainUIScene.Ins:ShowNormalNpcViewById(NpcId)
      end
    end)
  end
end
function BangPaiChuMo.dataUpdate(param)
  param = param or {}
  print("============= 刷新了帮派除魔的任务 =========")
  for k, v in pairs(param) do
    print(k, v)
  end
  if param.taskid then
    BangPaiChuMo.taskid_ = param.taskid
  end
  if param.state then
    BangPaiChuMo.state_ = param.state
  end
  if param.loc_id then
    BangPaiChuMo.loc_id_ = tonumber(param.loc_id)
  end
  if param.bossid then
    BangPaiChuMo.bossid_ = param.bossid
  end
  if param.lefttime then
    BangPaiChuMo.lefttime_ = param.lefttime
    BangPaiChuMo.endTime = BangPaiChuMo.lefttime_ + g_DataMgr:getServerTime()
  end
  if param.warid then
    BangPaiChuMo.warid_ = param.warid
  end
  if param.state == 1 or param.state == 2 then
    BangPaiChuMo.hadCommint = false
    BangPaiChuMo.setIsAccept(true)
    BangPaiChuMo.flushAcceptedDate()
    BangPaiChuMo.detectEndTime(false)
    if param.new == true and param.state == 1 and param.lefttime == BangPaiChuMo_LEFTTIME and BangPaiChuMo.haveTalk == false then
      BangPaiChuMo.haveTalk = true
      getCurSceneView():ShowTalkView(701621, function()
      end, BangPaiChuMo_MissionId)
    end
    BangPaiChuMo.serviceState = false
  elseif param.state == 3 then
    BangPaiChuMo.setIsAccept(false)
  end
  BangPaiChuMo.flushCreateMonster()
end
function BangPaiChuMo.flushAcceptedDate()
  if BangPaiChuMo.taskid_ then
    BangPaiChuMo.MissionId = 40002
    local bpmtb = data_Mission_BangPai[BangPaiChuMo.MissionId]
    local mapData = data_CustomMapPos[BangPaiChuMo.loc_id_]
    if bpmtb == nil then
      print(" 帮派除魔 没填导表吧 ？", bpmtb == nil)
      return
    end
    local dst1 = bpmtb.dst1
    if mapData then
      dst1.data = {
        mapData.SceneID,
        mapData.WarPos[1],
        mapData.WarPos[2],
        mapData.WarPos[3],
        mapData.JumpPos[1],
        mapData.JumpPos[2]
      }
      local mapinfo = data_MapInfo[mapData.SceneID] or {}
      local mapName = mapinfo.name or ""
      local monsterName = ""
      local mtb = data_Org_ChumoTask[BangPaiChuMo.bossid_] or {}
      monsterName = mtb.Name or ""
      dst1.des = string.format("去#<Y,>%s#消灭#<Y,>%s#", mapName, monsterName)
      local talkitem = data_MissionTalk[701621]
      if talkitem and talkitem[1] then
        talkitem[1][2] = string.format("#<Y,>%s#正在#<Y,>%s#处释放魔气，欲将百姓魔化。情况紧急，特招募有志之士前去讨伐！", monsterName, mapName)
      end
    end
    local missionPro = 0
    if BangPaiChuMo.state_ == 2 then
      missionPro = 1
    end
    g_MissionMgr:Server_MissionUpdated(BangPaiChuMo.MissionId, missionPro, {})
  end
end
function BangPaiChuMo.deleteTask(delType, taskid)
  print("帮派除魔任务  服务器通知删除  ", BangPaiChuMo.hadCommint, BangPaiChuMo.state_)
  BangPaiChuMo.setIsAccept(false)
  if BangPaiChuMo.MissionId ~= -1 then
    if BangPaiChuMo.hadCommint == true then
      BangPaiChuMo.serviceState = false
    elseif (BangPaiChuMo.state_ == 1 or BangPaiChuMo.state_ == 2) and BangPaiChuMo.hadCommint ~= true then
      BangPaiChuMo.serviceState = true
    end
    g_MissionMgr:Server_GiveUpMission(BangPaiChuMo.MissionId)
    BangPaiChuMo.taskid_ = -1
    BangPaiChuMo.flushCreateMonster()
    BangPaiChuMo.MissionId = -1
    BangPaiChuMo.haveTalk = false
    BangPaiChuMo.state_ = 0
  end
end
function BangPaiChuMo.getChuMoMission(iftalk)
  local mainHeroIns = g_LocalPlayer:getMainHero()
  if mainHeroIns == nil then
    print("找不到英雄")
    return
  end
  BangPaiChuMo.reqAccept()
end
function BangPaiChuMo.reqAccept()
  print("帮派除魔任务 请求接收 ")
  netsend.netmission.reqAcceptByType(1002)
end
function BangPaiChuMo.reqFinish()
  print("帮派除魔任务 请求完成 ")
  if BangPaiChuMo.taskid_ ~= nil and BangPaiChuMo.taskid_ >= 0 then
    netsend.netmission.reqFinishByType(1002, BangPaiChuMo.taskid_)
  end
end
function BangPaiChuMo.reqCommit()
  print("帮派除魔任务 请求递交 ", BangPaiChuMo.taskid_, BangPaiChuMo.state_)
  if BangPaiChuMo.taskid_ ~= nil and BangPaiChuMo.taskid_ > -1 then
    if BangPaiChuMo.state_ == 2 then
      BangPaiChuMo.hadCommint = true
      getCurSceneView():ShowTalkView(701622, function()
        netsend.netmission.reqCommitByType(1002, BangPaiChuMo.taskid_)
      end, BangPaiChuMo.MissionId)
    else
      netsend.netmission.reqCommitByType(1002, BangPaiChuMo.taskid_)
    end
  elseif BangPaiChuMo.taskid_ == -1 then
  end
end
function BangPaiChuMo.reqGaveUp()
  if BangPaiChuMo.taskid_ ~= nil and BangPaiChuMo.taskid_ >= 0 then
    BangPaiChuMo.setIsAccept(false)
    netsend.netmission.reqGiveupByType(1002, BangPaiChuMo.taskid_)
  end
end
function BangPaiChuMo.TrackMission(missionid)
  local bpmtb = data_Mission_BangPai[BangPaiChuMo.MissionId]
  if bpmtb == nil then
    return
  end
  local dst1 = bpmtb.dst1
  local mapInfo = dst1.data
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
      BangPaiChuMo.TouchMoster()
    end
  end
  g_MapMgr:AutoRoute(mapId, gridPos, route_cb, nil, nil, jumpPos, nil, RouteType_Monster)
end
function BangPaiChuMo.TouchMoster()
  print(" 点击怪物 ===>>BangPaiTotem.touchMoster")
  if not g_BpMgr:localPlayerHasBangPai() then
    ShowNotifyTips("请你先加入帮派.")
    return
  end
  netsend.netteamwar.requestBangPaiChuMo(BangPaiChuMo.taskid_)
end
function BangPaiChuMo.flushCreateMonster()
  local mapView = g_MapMgr:getMapViewIns()
  local mapId = g_MapMgr:getCurMapId()
  if mapView == nil then
    printLog("BangPaiChuMo", "mapView == nil")
    return
  end
  local pid = g_LocalPlayer:getPlayerId()
  local createid = BangPaiChuMo.createMonsterId or {}
  if mapId ~= BangPaiChuMo.curMapId then
    BangPaiChuMo.curMapId = mapId
    createid = {}
  end
  BangPaiChuMo.createMonsterId = {}
  local bpmtb = data_Mission_BangPai[BangPaiChuMo.MissionId]
  if bpmtb == nil then
    return
  end
  local dst1 = bpmtb.dst1
  local mapPos = dst1.data or {}
  if BangPaiChuMo.state_ == 1 and mapPos[1] == mapId and BangPaiChuMo.endTime > g_DataMgr:getServerTime() then
    local tempId = createid[pid]
    local mmid = mapView:getMonster(tempId)
    if tempId and mapView:getMonster(tempId) ~= nil then
      BangPaiChuMo.createMonsterId[pid] = createid[pid]
      createid[pid] = nil
    else
      if createid[pid] and BangPaiChuMo.taskid_ >= 0 then
        createid[pid] = nil
      end
      print("222222222222222222222222 ", mapPos[4], g_LocalPlayer:getPlayerId())
      local monsterTypeId = BangPaiChuMo.bossid_
      if monsterTypeId ~= nil then
        local monsterId = mapView:CreateMonster(monsterTypeId, {
          mapPos[2],
          mapPos[3]
        }, MapPosType_EditorGrid, mapPos[4], MapMonsterType_ChuMo, pid)
        BangPaiChuMo.createMonsterId[pid] = monsterId
      end
    end
  end
  for k, v in pairs(createid) do
    mapView:DeleteMonster(v)
  end
  if BangPaiChuMo.taskid_ < 0 then
    for k, v in pairs(BangPaiChuMo.createMonsterId) do
      mapView:DeleteMonster(v)
      BangPaiChuMo.createMonsterId[k] = nil
    end
  end
end
function BangPaiChuMo.detectEndTime(isSendMsg)
  if BangPaiChuMo.taskid_ >= 0 and BangPaiChuMo.state_ == 1 then
    local dt = BangPaiChuMo.endTime - g_DataMgr:getServerTime()
    if dt < 0.5 then
      BangPaiChuMo.taskid_ = -1
      if isSendMsg == true then
        g_MissionMgr:delBangPaiChuMo()
        BangPaiChuMo.flushCreateMonster()
        BangPaiChuMo.init()
        BangPaiChuMo.setIsAccept(false)
        BangPaiChuMo.serviceState = true
        g_MissionMgr:FlushCanAcceptMission()
      end
    else
      return dt
    end
  end
  return nil
end
BangPaiChuMo.init()
gamereset.registerResetFunc(function()
  BangPaiChuMo.init()
end)
