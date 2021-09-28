local yzdd = class("yzddMgr")
function yzdd:ctor()
  self.m_Status = 2
  self.m_MatchingState = 0
end
function yzdd:setStatus(status)
  self.m_Status = status
  if self.m_Status ~= 1 then
    self.m_MatchingState = 0
  end
  SendMessage(MsgID_Activity_YZDDStatus, status)
end
function yzdd:getStatus()
  return self.m_Status
end
function yzdd:canJumpMap()
  if self.m_Status == 1 and g_MapMgr:IsInYiZhanDaoDiMap() then
    local dlg = CPopWarning.new({
      title = "提示",
      text = "正处于一战到底活动副本中，离开地图后就无法再次进入了，你确定要退出活动吗？",
      confirmFunc = handler(self, self._jumpMap),
      confirmText = "确定",
      cancelText = "取消"
    })
    dlg:ShowCloseBtn(false)
    return false
  else
    print("------>>>>yzdd:canJumpMap:", self.m_Status, g_MapMgr:IsInYiZhanDaoDiMap())
    return true
  end
end
function yzdd:_jumpMap()
  netsend.netactivity.sendQuitYZDD()
end
function yzdd:showYZDDDlgWithBaseInfo(info)
  ShowYZDDDlgWithBaseInfo(info)
end
function yzdd:updateYZDDInfo(info)
  SendMessage(MsgID_Activity_YZDDUpdateInfo, info)
end
function yzdd:updateYZDDRank(info)
  SendMessage(MsgID_Activity_YZDDUpdateRankInfo, info)
end
function yzdd:setYZDDMathState(info)
  local state = info.state
  self.m_MatchingState = state
  local txt = self:checkNeedMatchingTip()
  if txt ~= nil then
    ShowNotifyTips(txt)
    ShowDownNotifyViews(txt, true)
  end
  SendMessage(MsgID_Activity_YZDDMatching, state)
end
function yzdd:setYZDDEnemyInfo(info)
  SendMessage(MsgID_Activity_YZDDEnemyInfo, info)
end
function yzdd:checkNeedMatchingTip()
  if self:isMatching() then
    return "正在自动匹配一战到底对手中,请稍等..."
  else
    return nil
  end
end
function yzdd:isMatching()
  return self.m_Status == 1 and self.m_MatchingState == 1 and g_MapMgr:IsInYiZhanDaoDiMap()
end
return yzdd
