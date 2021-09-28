local xzsc = class("xzscMgr")
function xzsc:ctor()
  self.m_Status = 2
end
function xzsc:setStatus(status)
  self.m_Status = status
  SendMessage(MsgID_Activity_XZSCStatus, status)
end
function xzsc:getStatus()
  return self.m_Status
end
function xzsc:showXZSCDlgWithBaseInfo(info)
  ShowXueZhanShaChangDlgWithBaseInfo(info)
end
function xzsc:setXZSCMathState(state, info, teamScore)
  if state == 1 then
    self.m_InfoCache = info
    self.m_TeamScoreCache = teamScore
    ShowXZSCMatchingDlg(info, teamScore)
  end
  SendMessage(MsgID_Activity_XZSCMatching, state, info, teamScore)
  if state ~= 1 then
    scheduler.performWithDelayGlobal(function()
      if g_CXZSCMatchingDlg == nil and self.m_Status == 1 and g_MapMgr:IsInXueZhanShaChangMap() and g_WarScene == nil then
        ShowXueZhanShaChangDlg()
      end
    end, 0.1)
  end
end
function xzsc:setXZSCEnemyInfo(info, teamScore)
  if g_CXZSCMatchingDlg == nil and self.m_InfoCache ~= nil and self.m_TeamScoreCache ~= nil then
    ShowXZSCMatchingDlg(self.m_InfoCache, self.m_TeamScoreCache)
  end
  SendMessage(MsgID_Activity_XZSCEnemyInfo, info, teamScore)
end
function xzsc:EnterXZSC()
  local follow = g_LocalPlayer:getIsFollowTeam()
  print("-->> EnterXZSC:", follow)
  if follow ~= 0 then
    local tInfo = data_CustomMapPos[15001]
    if tInfo then
      local mapId = tInfo.SceneID
      local pos = tInfo.JumpPos
      g_MapMgr:AutoRoute(mapId, {
        pos[1],
        pos[2]
      }, nil)
    end
  end
end
function xzsc:updateXZSC(info)
  SendMessage(MsgID_Activity_XZSCUpdateInfo, info)
end
function xzsc:closeXZSCMatching()
  CloseXZSCMatchingDlg()
end
return xzsc
