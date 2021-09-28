local netbangpaiwar = {}
function netbangpaiwar.setBpWarState(param, ptc_main, ptc_sub)
  print("netbangpaiwar.setBpWarState:", param, ptc_main, ptc_sub)
  g_BpWarMgr:receive_setBpWarState(param.state)
end
function netbangpaiwar.setSignUpState(param, ptc_main, ptc_sub)
  print("netbangpaiwar.setSignUpState:", param, ptc_main, ptc_sub)
  g_BpWarMgr:receive_setSignUpState(param.state)
end
function netbangpaiwar.updateBpWarInfo(param, ptc_main, ptc_sub)
  print("netbangpaiwar.updateBpWarInfo:", param, ptc_main, ptc_sub)
  if param.attacker ~= nil then
    param.attacker.orgname = CheckStringIsLegal(param.attacker.orgname, true, REPLACECHAR_FOR_INVALIDNAME)
  end
  if param.defenser ~= nil then
    param.defenser.orgname = CheckStringIsLegal(param.defenser.orgname, true, REPLACECHAR_FOR_INVALIDNAME)
  end
  g_BpWarMgr:receive_updateBpWarInfo(param)
end
function netbangpaiwar.setBpWarSummarize(param, ptc_main, ptc_sub)
  print("netbangpaiwar.setBpWarSummarize:", param, ptc_main, ptc_sub)
  if param.ranks ~= nil then
    for _, data in pairs(param.ranks) do
      data.teamname = CheckStringIsLegal(data.teamname, true, REPLACECHAR_FOR_INVALIDNAME)
    end
  end
  g_BpWarMgr:receive_setBpWarSummarize(param.ranks)
end
function netbangpaiwar.setBpWarResult(param, ptc_main, ptc_sub)
  print("netbangpaiwar.setBpWarResult:", param, ptc_main, ptc_sub)
  g_BpWarMgr:receive_setBpWarResult(param)
end
function netbangpaiwar.setBpWarTreasureResult(param, ptc_main, ptc_sub)
  print("netbangpaiwar.setBpWarTreasureResult:", param, ptc_main, ptc_sub)
  ShowMapTreasureResult(param)
end
function netbangpaiwar.setBpWarCountDown(param, ptc_main, ptc_sub)
  print("netbangpaiwar.setBpWarCountDown:", param, ptc_main, ptc_sub)
  g_BpWarMgr:receive_setTimeCountDown(param.secs)
end
function netbangpaiwar.setBpWarProtectCountDown(param, ptc_main, ptc_sub)
  print("netbangpaiwar.setBpWarProtectCountDown:", param, ptc_main, ptc_sub)
  g_BpWarMgr:receive_setProtectTimeCountDown(param.secs)
end
return netbangpaiwar
