local netpvp = {}
function netpvp.setPvpBaseInfo(param, ptc_main, ptc_sub)
  print("netpvp.setPvpBaseInfo:", param, ptc_main, ptc_sub)
  if param.ls_enemy ~= nil then
    for _, data in pairs(param.ls_enemy) do
      data.s_name = CheckStringIsLegal(data.s_name, true, REPLACECHAR_FOR_INVALIDNAME)
    end
  end
  if param.ls_log ~= nil then
    for _, data in pairs(param.ls_log) do
      data.s_name = CheckStringIsLegal(data.s_name, true, REPLACECHAR_FOR_INVALIDNAME)
    end
  end
  g_PvpMgr:setPvpBaseInfo(param)
end
function netpvp.setPvpRankInfo(param, ptc_main, ptc_sub)
  print("netpvp.setPvpRankInfo:", param, ptc_main, ptc_sub)
  if param.ls_ranklist ~= nil then
    for _, data in pairs(param.ls_ranklist) do
      data.s_name = CheckStringIsLegal(data.s_name, true, REPLACECHAR_FOR_INVALIDNAME)
    end
  end
  g_PvpMgr:setPvpRankInfo(param.i_issue, param.ls_ranklist)
end
function netpvp.setRankInfoFinish(param, ptc_main, ptc_sub)
  print("netpvp.setRankInfoFinish:", param, ptc_main, ptc_sub)
  g_PvpMgr:setRankInfoFinish(param.i_issue)
end
function netpvp.checkRankInfoIsOk(param, ptc_main, ptc_sub)
  print("netpvp.checkRankInfoIsOk:", param, ptc_main, ptc_sub)
  g_PvpMgr:checkRankInfoIsOk(param.i_issue)
end
function netpvp.setBuyBWCNum(param, ptc_main, ptc_sub)
  print("netpvp.setBuyBWCNum:", param, ptc_main, ptc_sub)
  g_PvpMgr:setBuyBWCNum(param.i_num)
  g_PvpMgr:setBWCFightNum(param.i_chance)
end
function netpvp.watchBWCWarning(param, ptc_main, ptc_sub)
  print("netpvp.watchBWCWarning:", param, ptc_main, ptc_sub)
  if g_WarScene and g_WarScene:getWarID() == param.i_w then
    QuitWarSceneAndBackToPreScene()
    ShowNotifyTips("录像数据已过期")
  end
end
function netpvp.watchBWCGetBaseData(param, ptc_main, ptc_sub)
  print("netpvp.watchBWCGetBaseData:", param, ptc_main, ptc_sub)
  local warInfo = param
  StartWarWithBaseInfo_Review(warInfo)
end
function netpvp.watchBWCGetRoundData(param, ptc_main, ptc_sub)
  print("netpvp.watchBWCGetRoundData:", param, ptc_main, ptc_sub)
  if g_WarScene and g_WarScene:getWarID() == param.i_w then
    setRoundWarSeqList(param.i_w, param.r, param.roundSeq, param.endWarData, param.time, false)
  end
end
return netpvp
