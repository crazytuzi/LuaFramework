local netbox = {}
function netbox.updateBoxState(param, ptc_main, ptc_sub)
  local i_nlnum = param.i_nlnum
  local i_nlt = param.i_nlt
  local i_slnum = param.i_slnum
  local i_slt = param.i_slt
  local player = g_DataMgr:getPlayer()
  player:setBoxData(i_nlnum, i_nlt, i_slnum, i_slt)
end
function netbox.openNormalBoxResult(param, ptc_main, ptc_sub)
  local t_box = param.t_box
  print("打开普通宝箱")
  local num = 0
  for _, _ in pairs(t_box) do
    num = num + 1
  end
  if num == 1 then
    CPopBoxResult.new(BoxResultType_Normal, t_box)
  else
    CPopBoxResult.new(BoxResultType_NormalTen, t_box)
  end
  if g_MissionMgr then
    g_MissionMgr:GuideIdComplete(101)
  end
end
function netbox.openSuperBoxResult(param, ptc_main, ptc_sub)
  local t_box = param.t_box
  print("打开卓越宝箱")
  local num = 0
  for _, _ in pairs(t_box) do
    num = num + 1
  end
  if num == 1 then
    CPopBoxResult.new(BoxResultType_Super, t_box)
  else
    CPopBoxResult.new(BoxResultType_SuperTen, t_box)
  end
  if g_MissionMgr then
    g_MissionMgr:GuideIdComplete(101)
  end
end
return netbox
