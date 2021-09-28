function BangPaiTaskToken(object)
  function object:BangPaiTaskTokenInit()
    object._bptoken_taskId = {}
    object._bptoken_endTime = {}
  end
  object:BangPaiTaskTokenInit()
end
BangPaiRenWuLing = {}
function BangPaiRenWuLing.reqAcceptTaskToken(tokenType)
  g_BpMgr:send_publishTaskToken(tokenType)
end
function BangPaiRenWuLing.getTaskTokenId(tokenType)
  local taskId
  if tokenType == TASKTOKEN_MUJI then
    taskId = TaskToken_MuJi_MissionId
  elseif tokenType == TASKTOKEN_ANZHAN then
    taskId = TaskToken_AnZhan_MissionId
  elseif tokenType == TASKTOKEN_CHUMO then
    taskId = TaskToken_ChuMo_MissionId
  end
  return taskId
end
function BangPaiRenWuLing.dataUpdate(param)
  if param == nil then
    return
  end
  local player = g_LocalPlayer
  local tokenType = param.i_type
  local lefttime = param.i_lefttime
  local taskId = BangPaiRenWuLing.getTaskTokenId(tokenType)
  if taskId == nil then
    return
  end
  local oldtaskid = player._bptoken_taskId[taskId]
  player._bptoken_taskId[taskId] = true
  if lefttime ~= nil then
    player._bptoken_endTime[taskId] = g_DataMgr:getServerTime() + lefttime
  end
  BangPaiRenWuLing.detectEndTime(taskId, false)
  g_MissionMgr:Server_MissionUpdated(taskId, 0, nil)
  if oldtaskid ~= true then
    g_MissionMgr:NewMission(taskId)
  end
end
function BangPaiRenWuLing.TrackMission(taskId, NPCID)
  if g_LocalPlayer._bptoken_taskId[taskId] ~= true then
    return nil
  end
  local npcId = NPCID or 90019
  local function route_cb(isSucceed)
    if isSucceed and CMainUIScene.Ins then
      CMainUIScene.Ins:ShowNormalNpcViewById(npcId)
    end
  end
  g_MapMgr:AutoRouteToNpc(npcId, route_cb)
end
function BangPaiRenWuLing.detectEndTime(taskId, isSendMsg)
  if g_LocalPlayer._bptoken_taskId[taskId] == true then
    local dt = g_LocalPlayer._bptoken_endTime[taskId] - g_DataMgr:getServerTime()
    if dt < 0.5 then
      g_LocalPlayer._bptoken_taskId[taskId] = nil
      if isSendMsg == true then
        g_MissionMgr:delBangPaiTaskToken(taskId)
        SendMessage(MsgID_Mission_Common)
      end
    else
      return dt
    end
  end
  return nil
end
function BangPaiRenWuLing.clearAllTask()
  if g_LocalPlayer._bptoken_taskId then
    for taskId, _ in pairs(g_LocalPlayer._bptoken_taskId) do
      g_MissionMgr:delBangPaiTaskToken(taskId)
    end
    g_LocalPlayer._bptoken_taskId = {}
    SendMessage(MsgID_Mission_Common)
  end
end
