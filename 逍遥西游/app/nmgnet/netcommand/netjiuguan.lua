local netjiuguan = {}
function netjiuguan.updateJiuguanOpenlist(param, ptc_main, ptc_sub)
  local openList = DeepCopyTable(param.t_l or {})
  local player = g_DataMgr:getPlayer()
  player:setJiuguanOpenList(openList)
  if g_MissionMgr and #openList > 0 then
    g_MissionMgr:GuideIdComplete(102)
  end
end
return netjiuguan
