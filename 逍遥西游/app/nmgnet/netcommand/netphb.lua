local netphb = {}
function netphb.setPHBRankInfo(param, ptc_main, ptc_sub)
  print("netphb.setPHBRankInfo:", param, ptc_main, ptc_sub)
  if param.ls_ranklist ~= nil then
    for _, data in pairs(param.ls_ranklist) do
      data.name = CheckStringIsLegal(data.name, true, REPLACECHAR_FOR_INVALIDNAME)
    end
  end
  g_PHBMgr:setPHBRankInfo(param.i_issue, param.i_t1, param.i_t2, param.ls_ranklist)
end
function netphb.setRankInfoFinish(param, ptc_main, ptc_sub)
  print("netphb.setRankInfoFinish:", param, ptc_main, ptc_sub)
  g_PHBMgr:setRankInfoFinish(param.i_issue, param.i_t1, param.i_t2)
end
function netphb.checkRankInfoIsOk(param, ptc_main, ptc_sub)
  print("netphb.checkRankInfoIsOk:", param, ptc_main, ptc_sub)
  g_PHBMgr:checkRankInfoIsOk(param.i_issue, param.i_t1, param.i_t2)
end
function netphb.setSelfRankInfo(param, ptc_main, ptc_sub)
  print("netphb.setSelfRankInfo:", param, ptc_main, ptc_sub)
  g_PHBMgr:setSelfRankInfo(param.i_t1, param.i_num, param.i_index)
end
return netphb
