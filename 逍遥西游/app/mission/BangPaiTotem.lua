function BangPaiTotemExtend(object)
  function object:BangPaiTotemInit()
    object._bptotem_taskId = 0
    object._bptotem_mapInfo = nil
    object._bptotem_warId = 0
    object._bptotem_endTime = 0
    object._bptotem_state = 0
    object._bptotem_id = 0
    object._bptotem_locid = 0
  end
  function object:getBangPaiTotemMonsterId()
    if object._bptotem_taskId == 0 then
      return nil
    end
    local warData = data_WarRole[object._bptotem_warId]
    if warData then
      return warData.posList[10003]
    end
  end
  function object:getBangPaiTotemId()
    return object._bptotem_id
  end
  function object:getBangPaiTotemLocId()
    return object._bptotem_locid
  end
  object:BangPaiTotemInit()
end
BangPaiTotem = {}
BangPaiTotem.curMapId = -1
BangPaiTotem.monsterCreated = {}
function BangPaiTotem.reqAcceptTotem(totemId)
  if g_LocalPlayer._bptotem_taskId ~= 0 then
    ShowNotifyTips("你已有解开图腾的任务，不能重复接受")
    return false
  end
  netsend.netmission.reqAcceptByType(1001, {totemid = totemId})
  return true
end
function BangPaiTotem.CanAccept()
  return true
end
function BangPaiTotem.dataUpdate(param, pid, isSendMsg)
  local player = g_DataMgr:getPlayer(pid)
  if player == nil or param == nil then
    return
  end
  local taskid = param.taskid
  local warid = param.warid
  local lefttime = param.lefttime
  local state = param.state
  local loc_id = param.loc_id
  local totemid = param.totemid
  if taskid == nil then
    return
  end
  local oldtaskid = player._bptotem_taskId
  player._bptotem_taskId = taskid
  local posData = data_CustomMapPos[loc_id]
  if posData == nil then
    printLog("ERROR", "帮派图腾任务的位置出错")
    posData = data_CustomMapPos[1101]
  end
  if posData then
    player._bptotem_mapInfo = {
      posData.SceneID,
      posData.WarPos[1],
      posData.WarPos[2],
      posData.WarPos[3],
      posData.JumpPos[1],
      posData.JumpPos[2]
    }
  end
  if warid ~= nil then
    player._bptotem_warId = warid
  end
  if lefttime ~= nil then
    player._bptotem_endTime = g_DataMgr:getServerTime() + lefttime
  end
  if state ~= nil then
    player._bptotem_state = state
  end
  if totemid ~= nil then
    player._bptotem_id = totemid
  end
  if loc_id ~= nil then
    player._bptotem_locid = loc_id
  end
  BangPaiTotem.detectEndTime(false)
  if state == 0 then
    player._bptotem_taskId = 0
    g_MissionMgr:flushBangPaiTotemCanAccept()
  elseif state == 1 then
    g_MissionMgr:Server_MissionUpdated(Totem_MissionId, 0, nil)
  elseif state == 2 then
    g_MissionMgr:Server_MissionUpdated(Totem_MissionId, 1, nil)
  elseif state == 3 then
  end
  if oldtaskid == 0 and player._bptotem_taskId ~= 0 then
    g_MissionMgr:NewMission(Totem_MissionId)
  end
  BangPaiTotem.flushCreateMonster()
end
function BangPaiTotem.taskDel(taskid)
  g_LocalPlayer._bptotem_taskId = 0
  g_MissionMgr:delBangPaiTotem()
  SendMessage(MsgID_Mission_Common)
  BangPaiTotem.flushCreateMonster()
end
function BangPaiTotem.giveTotemTask()
  netsend.netmission.reqGiveupByType(1001, g_LocalPlayer._bptotem_taskId)
end
function BangPaiTotem.flushCreateMonster()
  printLog("BangPaiTotem", "BangPaiTotem.flushCreateMonster")
  local mapView = g_MapMgr:getMapViewIns()
  local mapId = g_MapMgr:getCurMapId()
  if mapView == nil then
    printLog("BangPaiTotem", "mapView == nil")
    return
  end
  local created = BangPaiTotem.monsterCreated or {}
  if mapId ~= BangPaiTotem.curMapId then
    BangPaiTotem.curMapId = mapId
    created = {}
  end
  BangPaiTotem.monsterCreated = {}
  if g_LocalPlayer and g_LocalPlayer._bptotem_taskId > 0 then
    local pid = g_LocalPlayer:getPlayerId()
    local mapPos = g_LocalPlayer._bptotem_mapInfo or {}
    if g_LocalPlayer._bptotem_state == 1 and mapPos[1] == mapId and g_LocalPlayer._bptotem_endTime > g_DataMgr:getServerTime() then
      local tempId = created[pid]
      if tempId ~= nil and mapView:getMonster(tempId) ~= nil then
        BangPaiTotem.monsterCreated[pid] = created[pid]
        created[pid] = nil
      else
        local monsterTypeId = g_LocalPlayer:getBangPaiTotemMonsterId()
        if monsterTypeId ~= nil then
          local monsterId = mapView:CreateMonster(monsterTypeId, {
            mapPos[2],
            mapPos[3]
          }, MapPosType_EditorGrid, mapPos[4], MapMonsterType_Totem, pid)
          BangPaiTotem.monsterCreated[pid] = monsterId
        end
        created[pid] = nil
      end
    end
  end
  for pid, monsterId in pairs(created) do
    mapView:DeleteMonster(monsterId)
  end
end
function BangPaiTotem.touchMoster(monsterTypeId)
  print("===>>BangPaiTotem.touchMoster")
  if not g_BpMgr:getLocalPlayerIsLeader() then
    ShowNotifyTips("你不是帮主，无法开启战斗。")
    return
  end
  local teamId = g_TeamMgr:getLocalPlayerTeamId()
  local teamInfo = g_TeamMgr:getTeamInfo(teamId)
  if teamId == 0 or #teamInfo < 5 then
    ShowNotifyTips("图腾战神均是罕世凶戻，若想降服，请召齐五位帮派成员助阵。")
    return
  end
  for _, pid in pairs(teamInfo) do
    if g_TeamMgr:getPlayerTeamState(pid) ~= TEAMSTATE_FOLLOW then
      ShowNotifyTips("图腾战神均是罕世凶戻，若想降服，请召齐五位帮派成员助阵。")
      return
    end
  end
  local taskid = g_LocalPlayer._bptotem_taskId
  if taskid then
    netsend.netteamwar.requestBangPaiTotemWar(taskid)
  end
end
function BangPaiTotem.TrackMission()
  if g_LocalPlayer._bptotem_taskId == 0 then
    return nil
  end
  if g_LocalPlayer._bptotem_state == 1 then
    local mapInfo = g_LocalPlayer._bptotem_mapInfo
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
        BangPaiTotem.touchMoster(g_LocalPlayer:getBangPaiTotemMonsterId())
      end
    end
    g_MapMgr:AutoRoute(mapId, gridPos, route_cb, nil, nil, jumpPos, nil, RouteType_Monster)
  end
end
function BangPaiTotem.detectEndTime(isSendMsg)
  if g_LocalPlayer._bptotem_taskId > 0 and g_LocalPlayer._bptotem_state >= 1 then
    local dt = g_LocalPlayer._bptotem_endTime - g_DataMgr:getServerTime()
    if dt < 0.5 then
      g_LocalPlayer._bptotem_taskId = 0
      if isSendMsg == true then
        g_MissionMgr:delBangPaiTotem()
        BangPaiTotem.flushCreateMonster()
      end
    else
      return dt
    end
  end
  return nil
end
gamereset.registerResetFunc(function()
  BangPaiTotem.curMapId = -1
  BangPaiTotem.monsterCreated = {}
end)
