local duleMgr = class("duleMgr")
function duleMgr:ctor()
  self.m_Status = 0
  MessageEventExtend.extend(self)
  self:ListenMessage(MsgID_MapLoading)
end
function duleMgr:OnMessage(msgSID, ...)
  if msgSID == MsgID_MapLoading_Finished and g_MapMgr:IsInDuelMap() and self.m_Status == 2 then
    netsend.netactivity.getDuelMatchInfo()
  end
end
function duleMgr:allowDule(cdTime)
  ShowDuelRequest(cdTime)
end
function duleMgr:setDuleStatus(status)
  self.m_Status = status
  SendMessage(MsgID_Activity_DuelStatus, status)
end
function duleMgr:getDuleStatus()
  return self.m_Status
end
function duleMgr:isWaitingForDule()
  return self.m_Status ~= 0
end
function duleMgr:canJumpMap()
  if g_MapMgr:IsInDuelMap() then
    ShowNotifyTips("该地图无法使用传送功能（如需离开，请点击NPC传出生死擂台）")
    return false
  else
    return true
  end
end
function duleMgr:queryDulePlayerResult(pid, name)
  SendMessage(MsgID_Activity_DuelQueryInfo, pid, name)
end
function duleMgr:receiveDuleRequest(pid, name, tp, rt)
  CDuelResponse.new(pid, name, tp, rt)
end
function duleMgr:EnterDuleMap()
  local tInfo = data_CustomMapPos[17001]
  if tInfo and g_MapMgr then
    local mapId = tInfo.SceneID
    local pos = tInfo.JumpPos
    g_MapMgr:AutoRoute(mapId, {
      pos[1],
      pos[2]
    }, nil)
  end
end
function duleMgr:QuitDuleMap()
  netsend.netactivity.leaveDuelScene()
end
function duleMgr:setDuleMatchInfo(restTime, attackInfo, defendInfo)
  ShowDuelMatching(restTime, attackInfo, defendInfo)
end
function duleMgr:updateDuleReadyStatus(pid, ready)
  SendMessage(MsgID_Activity_DuelReady, pid, ready)
end
function duleMgr:newJoinPlayerToDuel(data)
  SendMessage(MsgID_Activity_DuelNewPlayer, data)
end
function duleMgr:playerQuitDuel(pid)
  SendMessage(MsgID_Activity_DuelPlayerQuit, pid)
end
function duleMgr:closeDuelMatchingDlg()
  CloseDuelMatching()
end
function duleMgr:Clear()
  if self.RemoveAllMessageListener then
    self:RemoveAllMessageListener()
  end
end
if g_DuleMgr then
  g_DuleMgr:Clear()
end
g_DuleMgr = duleMgr.new()
gamereset.registerResetFunc(function()
  if g_DuleMgr then
    g_DuleMgr:Clear()
  end
  g_DuleMgr = duleMgr.new()
end)
