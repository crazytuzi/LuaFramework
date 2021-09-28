local leitai = class("leitaiMgr")
function leitai:ctor()
  self.m_Status = 2
end
function leitai:setStatus(status)
  self.m_Status = status
  SendMessage(MsgID_Activity_LeiTaiStatus, status)
end
function leitai:getStatus()
  return self.m_Status
end
function leitai:showLeiWangZhengBaDlgWithBaseInfo(info)
  ShowLeiWangZhengBaDlgWithBaseInfo(info)
end
function leitai:updateLWZBInfo(info)
  SendMessage(MsgID_Activity_LeiTaiUpdateReward, info)
end
function leitai:updateLWZBRank(info)
  SendMessage(MsgID_Activity_LeiTaiUpdateRankInfo, info)
end
function leitai:setLWZBMathState(info)
  local state = info.state
  ShowLBZBMatchingDlg(state)
  SendMessage(MsgID_Activity_LeiTaiMatching, state)
end
function leitai:setLWZBEnemyInfo(info)
  SendMessage(MsgID_Activity_LeiTaiEnemyInfo, info)
end
return leitai
