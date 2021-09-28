local netpvp = {}
function netpvp.requestPvpBaseInfo()
  NetSend({}, S2C_PVP, "P1")
end
function netpvp.requestNewEnemy()
  NetSend({}, S2C_PVP, "P2")
end
function netpvp.requestPvpFight(i_pid, i_rank)
  NetSend({i_pid = i_pid, i_rank = i_rank}, S2C_PVP, "P3")
end
function netpvp.requestPvpRankInfo(i_issue, i_index)
  NetSend({i_issue = i_issue, i_index = i_index}, S2C_PVP, "P4")
end
function netpvp.checkPvpRankInfoIsEffective(i_issue)
  NetSend({i_issue = i_issue}, S2C_PVP, "P5")
end
function netpvp.buyBWCNum()
  NetSend({}, S2C_PVP, "P6")
end
function netpvp.watchBWCBaseHistoryData(wID)
  NetSend({i_w = wID}, S2C_PVP, "P7")
end
function netpvp.watchBWCHistoryRoundData(wID, rID)
  NetSend({i_w = wID, i_h = rID}, S2C_PVP, "P8")
end
function netpvp.BWCReFight(pID)
  NetSend({i_pid = pID}, S2C_PVP, "P9")
end
return netpvp
