local netphb = {}
function netphb.requestPHBRankInfo(i_issue, i_index, bType, range)
  print("netphb.requestPHBRankInfo", i_issue, i_index, bType, range)
  NetSend({
    i_issue = i_issue,
    i_t1 = bType,
    i_t2 = range,
    i_index = i_index
  }, S2C_PHB, "P1")
end
function netphb.checkPHBRankInfoIsEffective(i_issue, bType, range)
  print("netphb.checkPHBRankInfoIsEffective", i_issue, bType, range)
  NetSend({
    i_issue = i_issue,
    i_t1 = bType,
    i_t2 = range
  }, S2C_PHB, "P2")
end
function netphb.requestPHBSelfData(bType)
  print("netphb.requestPHBSelfData", bType)
  NetSend({i_t1 = bType}, S2C_PHB, "P3")
end
return netphb
