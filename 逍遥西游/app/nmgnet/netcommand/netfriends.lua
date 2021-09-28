local netfriends = {}
function netfriends.setAllFriendsList(param, ptc_main, ptc_sub)
  print("netfriends.setAllFriendsList:", param, ptc_main, ptc_sub)
  local flist = {}
  for _, info in pairs(param) do
    local pid = info.i_pid
    print("netfriends.setAllFriendsList: 2 ", pid, ptc_main, ptc_sub)
    local d = {}
    d.name = CheckStringIsLegal(info.s_name, true, REPLACECHAR_FOR_INVALIDNAME)
    d.rtype = info.i_rtype
    d.level = info.i_lv
    d.zs = info.i_rbnum
    d.status = info.i_status
    d.time = info.i_time
    d.fValue = info.i_close
    d.pcnt = info.t_cnt
    d.new = info.i_n
    flist[pid] = d
  end
  g_FriendsMgr:setAllFriendsList(flist)
end
function netfriends.setFriend(param, ptc_main, ptc_sub)
  print("netfriends.setFriend:", param, ptc_main, ptc_sub)
  local pid = param.i_pid
  local d = {}
  d.name = CheckStringIsLegal(param.s_name, true, REPLACECHAR_FOR_INVALIDNAME)
  d.rtype = param.i_rtype
  d.level = param.i_lv
  d.zs = param.i_rbnum
  d.status = param.i_status
  d.time = param.i_time
  d.fValue = param.i_close
  d.pcnt = param.t_cnt
  g_FriendsMgr:setFriend(pid, d)
end
function netfriends.deleteFriend(param, ptc_main, ptc_sub)
  print("netfriends.deleteFriend:", param, ptc_main, ptc_sub)
  local pid = param.i_pid
  g_FriendsMgr:deleteFriend(pid)
end
function netfriends.findPlayerInfo(param, ptc_main, ptc_sub)
  print("netfriends.findPlayerInfo:", param, ptc_main, ptc_sub)
  local pid = param.i_pid
  local d = {}
  d.name = CheckStringIsLegal(param.s_name, true, REPLACECHAR_FOR_INVALIDNAME)
  d.rtype = param.i_rtype
  d.level = param.i_lv
  d.zs = param.i_rbnum
  d.status = param.i_status
  g_FriendsMgr:findPlayerInfo(pid, d)
end
function netfriends.receivePlayerInfo(param, ptc_main, ptc_sub)
  print("netfriends.receivePlayerInfo:", param, ptc_main, ptc_sub)
  local pid = param.i_pid
  local d = {}
  d.name = CheckStringIsLegal(param.s_name, true, REPLACECHAR_FOR_INVALIDNAME)
  d.rtype = param.i_rtype
  d.level = param.i_lv
  d.zs = param.i_rbnum
  d.status = param.i_status
  g_FriendsMgr:receivePlayerInfo(pid, d)
end
function netfriends.receiveFriendRequest(param, ptc_main, ptc_sub)
  print("netfriends.receiveFriendRequest:", param, ptc_main, ptc_sub)
  local pid = param.i_pid
  local d = {}
  d.name = CheckStringIsLegal(param.s_name, true, REPLACECHAR_FOR_INVALIDNAME)
  d.rtype = param.i_rtype
  d.level = param.i_lv
  d.zs = param.i_rbnum
  d.status = param.i_status
  d.time = param.i_time
  d.new = param.i_n
  g_FriendsMgr:receiveFriendRequest(pid, d)
end
function netfriends.clearFriendRequest(param, ptc_main, ptc_sub)
  print("netfriends.clearFriendRequest:", param, ptc_main, ptc_sub)
  g_FriendsMgr:receiveClearFriendRequest()
end
return netfriends
