local netguaji = {}
function netguaji.gotoGuajiMap(param, ptc_main, ptc_sub)
  print("netguaji.gotoGuajiMap:", param, ptc_main, ptc_sub)
  local mapId = param.sceneid
  if mapId ~= nil then
    SendMessage(MsgID_Scene_CanGotoGuajiMap, mapId)
  end
end
function netguaji.setGuajiState(param, ptc_main, ptc_sub)
  local state = param.state
  print("netguaji.setGuajiState:", state)
  g_LocalPlayer:setGuajiState(state)
  if state == GUAJI_STATE_ON then
    StartGuaJi()
  else
    StopGuaJi()
  end
end
function netguaji.setAutoAddBSD(param, ptc_main, ptc_sub)
  print("netguaji.setAutoAddBSD:", param, ptc_main, ptc_sub)
  local i = param.i
  g_LocalPlayer:setGuajiAutoAddBsd(i)
end
return netguaji
