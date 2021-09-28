local netbangpai = {}
function netbangpai.setLocalBpInfo(param, ptc_main, ptc_sub)
  print("netbangpai.setLocalBpInfo:", param, ptc_main, ptc_sub)
  param.s_bpname = CheckStringIsLegal(param.s_bpname, true, REPLACECHAR_FOR_INVALIDNAME)
  g_BpMgr:SetLocalBpInfo(param)
end
function netbangpai.setTotalBpListInfo(param, ptc_main, ptc_sub)
  print("netbangpai.setTotalBpListInfo:", param, ptc_main, ptc_sub)
  local info = param.l_lst
  if info ~= nil then
    for _, data in pairs(info) do
      data.s_bpname = CheckStringIsLegal(data.s_bpname, true, REPLACECHAR_FOR_INVALIDNAME)
      data.s_leader = CheckStringIsLegal(data.s_leader, true, REPLACECHAR_FOR_INVALIDNAME)
    end
  end
  g_BpMgr:SetBpList(info)
end
function netbangpai.setBpTenet(param, ptc_main, ptc_sub)
  print("netbangpai.setBpTenet:", param, ptc_main, ptc_sub)
  local bpId = param.i_bpid
  local tenet = param.s_tenet
  g_BpMgr:SetBpTenet(bpId, tenet)
end
function netbangpai.setBpTotalAmout(param, ptc_main, ptc_sub)
  print("netbangpai.setBpTotalAmout:", param, ptc_main, ptc_sub)
  local bpNum = param.i_bpnum
  g_BpMgr:SetBpAmount(bpNum)
end
function netbangpai.setBpBaseInfo(param, ptc_main, ptc_sub)
  print("netbangpai.setBpBaseInfo:", param, ptc_main, ptc_sub)
  param.s_bpname = CheckStringIsLegal(param.s_bpname, true, REPLACECHAR_FOR_INVALIDNAME)
  param.s_leader = CheckStringIsLegal(param.s_leader, true, REPLACECHAR_FOR_INVALIDNAME)
  g_BpMgr:SetBpDetail(param)
end
function netbangpai.setBpMemberListInfo(param, ptc_main, ptc_sub)
  print("netbangpai.setBpMemberListInfo:", param, ptc_main, ptc_sub)
  local infoList = param.l_lst
  local flag = param.i_flag
  g_BpMgr:SetBpMemberList(infoList, flag)
end
function netbangpai.setBpRequestListInfo(param, ptc_main, ptc_sub)
  print("netbangpai.setBpRequestListInfo:", param, ptc_main, ptc_sub)
  local info = param.l_lst
  if info ~= nil then
    for _, data in pairs(info) do
      data.s_pname = CheckStringIsLegal(data.s_pname, true, REPLACECHAR_FOR_INVALIDNAME)
    end
  end
  g_BpMgr:SetBpRequestList(info)
end
function netbangpai.deleteBpRequest(param, ptc_main, ptc_sub)
  print("netbangpai.deleteBpRequest:", param, ptc_main, ptc_sub)
  local pid = param.i_pid
  g_BpMgr:DeleteBpRequest(pid)
end
function netbangpai.setBpRequestNum(param, ptc_main, ptc_sub)
  print("netbangpai.setBpRequestNum:", param, ptc_main, ptc_sub)
  local num = param.i_num
  g_BpMgr:SetBpRequestNum(num)
end
function netbangpai.setBpNotice(param, ptc_main, ptc_sub)
  print("netbangpai.setBpNotice:", param, ptc_main, ptc_sub)
  if param.l_lst ~= nil then
    for _, data in pairs(param.l_lst) do
      data.s_msg = CheckStringIsLegal(data.s_msg, true, REPLACECHAR_FOR_INVALIDMSG)
      data.s_name = CheckStringIsLegal(data.s_name, true, REPLACECHAR_FOR_INVALIDNAME)
    end
  end
  g_BpMgr:SetBpNotice(param.l_lst)
end
function netbangpai.newBpJoinRequest(param, ptc_main, ptc_sub)
  g_BpMgr:NewBpJoinRequest(true)
end
function netbangpai.setBpTotemInfo(param, ptc_main, ptc_sub)
  g_BpMgr:SetBpTotemInfo(param.i_bpid, param.i_totems)
end
function netbangpai.setBanwordTime(param, ptc_main, ptc_sub)
  print("netbangpai.setBanwordTime:", param, ptc_main, ptc_sub)
  g_BpMgr:SetBanwordTime(param.i_pid, param.i_banspeak)
end
function netbangpai.updateBpMemberInfo(param, ptc_main, ptc_sub)
  print("netbangpai.updateBpMemberInfo:", param, ptc_main, ptc_sub)
  param.name = CheckStringIsLegal(param.name, true, REPLACECHAR_FOR_INVALIDNAME)
  g_BpMgr:UpdateBpMemberInfo(param.pid, param)
end
function netbangpai.setBpPlaceNumInfo(param, ptc_main, ptc_sub)
  print("netbangpai.setBpPlaceNumInfo:", param, ptc_main, ptc_sub)
  g_BpMgr:SetBpPlaceNumInfo(param.l_lst)
end
function netbangpai.deleteNotice(param, ptc_main, ptc_sub)
  print("netbangpai.deleteNotice:", param, ptc_main, ptc_sub)
  g_BpMgr:DeleteNotice(param.i_id)
end
function netbangpai.deleteBpMember(param, ptc_main, ptc_sub)
  print("netbangpai.deleteBpMember:", param, ptc_main, ptc_sub)
  g_BpMgr:DeleteBpMember(param.i_pid)
end
function netbangpai.setTodayUnlockTotemTimes(param, ptc_main, ptc_sub)
  print("netbangpai.setTodayUnlockTotemTimes:", param, ptc_main, ptc_sub)
  g_BpMgr:SetTodayUnlockTotemTimes(param.i_unlockcnt)
end
function netbangpai.setTaskTokenInfo(param, ptc_main, ptc_sub)
  print("netbangpai.setTaskTokenInfo:", param, ptc_main, ptc_sub)
  BangPaiRenWuLing.dataUpdate(param)
end
function netbangpai.setTodayPaoShangTimes(param, ptc_main, ptc_sub)
  print("netbangpai.setTodayPaoShangTimes:", param, ptc_main, ptc_sub)
  g_BpMgr:SetTodayPaoShangTimes(param.i_cnt)
end
function netbangpai.setAllFuLeaderInfo(param, ptc_main, ptc_sub)
  print("netbangpai.setAllFuLeaderInfo:", param, ptc_main, ptc_sub)
  if param.l_lst ~= nil then
    for _, data in pairs(param.l_lst) do
      data.s_pname = CheckStringIsLegal(data.s_pname, true, REPLACECHAR_FOR_INVALIDNAME)
    end
  end
  g_BpMgr:SetAllFuLeaderInfo(param.l_lst)
end
function netbangpai.setBPHuoDongFlag(param, ptc_main, ptc_sub)
  print("netbangpai.setBPHuoDongFlag:", param, ptc_main, ptc_sub)
  for k, v in pairs(param) do
    print(k, v)
  end
  g_BpMgr:setBPHuoDongFlag(param)
end
function netbangpai.rejectBpLeader(param, ptc_main, ptc_sub)
  print("netbangpai.rejectBpLeader:", param, ptc_main, ptc_sub)
  g_BpMgr:rejectBpLeader(param.i_id, param.s_name)
end
function netbangpai.rejectBpLeaderProgress(param, ptc_main, ptc_sub)
  print("netbangpai.rejectBpLeaderProgress:", param, ptc_main, ptc_sub)
  g_BpMgr:rejectBpLeaderProgress(param.i_num, param.i_need)
end
function netbangpai.bpWarJoinTip(param, ptc_main, ptc_sub)
  print("netbangpai.bpWarJoinTip:", param, ptc_main, ptc_sub)
  g_BpMgr:bpWarJoinTip(param.show)
end
return netbangpai
