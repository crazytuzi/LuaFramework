local netmission = {}
function netmission.accepted(param, ptc_main, ptc_sub)
  local missionId = param.i_tid
  g_MissionMgr:Server_MissionAccepted(missionId)
end
function netmission.completed(param, ptc_main, ptc_sub)
  local missionId = param.i_tid
  g_MissionMgr:Server_MissionCmp(missionId)
end
function netmission.updated(param, ptc_main, ptc_sub)
  local missionId = param.i_tid
  local pro = param.i_state
  local tar = param.t_tarnum or {}
  local data = {}
  for i, v in pairs(tar) do
    data[i] = v
  end
  g_MissionMgr:Server_MissionUpdated(missionId, pro, data)
end
function netmission.getCompletMid(param, ptc_main, ptc_sub)
  if param == nil then
    return
  end
  g_MissionMgr:setHasCompletMids(param)
end
function netmission.giveup(param, ptc_main, ptc_sub)
  local missionId = param.i_tid
  g_MissionMgr:Server_GiveUpMission(missionId)
end
function netmission.add_zhuagui_mission(param, ptc_main, ptc_sub)
  ZhuaGui.dataUpdate(param, nil, false, true)
end
function netmission.del_zhuagui_mission(param, ptc_main, ptc_sub)
  ZhuaGui.taskDel(param.taskid, param.type)
end
function netmission.update_zhuagui(param, ptc_main, ptc_sub)
  ZhuaGui.dataUpdate(param)
end
function netmission.reward_zhuagui(param, ptc_main, ptc_sub)
  ZhuaGui.reward(param)
end
function netmission.teamer_zhuagui(param, ptc_main, ptc_sub)
  if param then
    local task = param.task or {}
    local pid = param.pid
    local data = task[1]
    if data ~= nil or pid ~= nil then
      ZhuaGui.dataUpdate(data, pid)
    end
  end
end
function netmission.accept_result_zhuagui(param, ptc_main, ptc_sub)
  if param == nil then
    return
  end
  local result = param.result
  ZhuaGui.acceptStatus(result)
end
function netmission.update_shimen(param, ptc_main, ptc_sub)
  print(" 更新了师门任务  netmission.update_shimen  ")
  if param == nil then
    return
  end
  Shimen.update(param)
end
function netmission.del_shimen(param, ptc_main, ptc_sub)
  if param == nil then
    return
  end
  Shimen.delete(param.taskid)
end
function netmission.update_guiwang(param, ptc_main, ptc_sub)
  if param == nil then
    return
  end
  GuiWang.dataUpdate(param)
end
function netmission.del_guiwang(param, ptc_main, ptc_sub)
  if param == nil then
    return
  end
  GuiWang.taskDel(param.type, param.taskid)
end
function netmission.update_sanjielilian(param, ptc_main, ptc_sub)
  print("update_sanjielilian ==>.  ptc_main", ptc_main, ptc_sub)
  if param == nil then
    return
  end
  SanJieLiLian.dataUpdate(param)
end
function netmission.del_sanjielilian(param, ptc_main, ptc_sub)
  if param == nil then
    return
  end
  SanJieLiLian.taskDel(param.type, param.taskid)
end
function netmission.update_totem(param, ptc_main, ptc_sub)
  print(" 更新了帮派图腾任务  netmission.update_totem  ")
  if param == nil then
    return
  end
  BangPaiTotem.dataUpdate(param)
end
function netmission.del_bangpaitotem(param, ptc_main, ptc_sub)
  if param == nil then
    return
  end
  BangPaiTotem.taskDel(param.taskid)
end
function netmission.update_bangpaichumo(param, ptc_main, ptc_sub)
  print("协议更新了帮派除魔任务 ")
  if param == nil then
    return
  end
  BangPaiChuMo.dataUpdate(param)
end
function netmission.del_bangpaichumo(param, ptc_main, ptc_sub)
  param = param or {}
  BangPaiChuMo.deleteTask(param.taskid)
end
function netmission.update_bpPaoShang(param, ptc_main, ptc_sub)
  if param == nil then
    return
  end
  BangPaiPaoShang.dataUpdate(param)
end
function netmission.del_bpPaoShang(param, ptc_main, ptc_sub)
  if param == nil then
    return
  end
  BangPaiPaoShang.taskDel(param.taskid)
end
function netmission.update_bpAnZhan(param, ptc_main, ptc_sub)
  if param == nil then
    print(" param is nil  from P28 帮派暗战 ")
    return
  end
  BangPaiAnZhan.dataUpdate(param)
end
function netmission.del_bpAnZhan(param, ptc_main, ptc_sub)
  if param == nil then
    print(" param is nil  from P29 帮派暗战 ")
    return
  end
  BangPaiAnZhan.deleteTask(param.taskid)
end
function netmission.update_BaoTuMission(param, ptc_main, ptc_sub)
  if param == nil then
    print(" param is nil  from P30 找藏宝图 ")
    return
  end
  CDaTingCangBaoTu.updateBaoTuMission(param)
end
function netmission.del_BaoTuMission(param, ptc_main, ptc_sub)
  if param == nil then
    print(" param is nil  from P31 删除宝图任务 ")
    return
  end
  CDaTingCangBaoTu.delBaoTuMission(param)
end
function netmission.add_xiuluo_mission(param, ptc_main, ptc_sub)
  XiuLuo.dataUpdate(param, nil, false, true)
end
function netmission.del_xiuluo_mission(param, ptc_main, ptc_sub)
  XiuLuo.taskDel(param.taskid, param.type)
end
function netmission.getMissionCommitPet(param, ptc_main, ptc_sub)
  if param and g_MissionMgr then
    g_MissionMgr:ShowCommitPetView(param.type, param.taskid, param.lst)
  end
end
return netmission
