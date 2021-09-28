local netfriends = {}
function netfriends.findPlayerById(i_pid)
  NetSend({i_pid = i_pid}, S2C_FRIENDS, "P1")
end
function netfriends.findPlayerByName(s_name)
  NetSend({s_name = s_name}, S2C_FRIENDS, "P2")
end
function netfriends.addFriend(i_pid)
  NetSend({i_pid = i_pid}, S2C_FRIENDS, "P3")
end
function netfriends.deleteFriend(i_pid)
  NetSend({i_pid = i_pid}, S2C_FRIENDS, "P4")
end
function netfriends.queryPlayerInfo(i_pid)
  NetSend({i_pid = i_pid}, S2C_FRIENDS, "P5")
end
function netfriends.onFriendListOpen()
  NetSend({}, S2C_FRIENDS, "P6")
end
function netfriends.agreeFriendRequest(i_pid)
  NetSend({i_pid = i_pid}, S2C_FRIENDS, "P7")
end
function netfriends.refuseFriendRequest(i_pid)
  NetSend({i_pid = i_pid}, S2C_FRIENDS, "P8")
end
function netfriends.clearFriendRequest()
  NetSend({}, S2C_FRIENDS, "P9")
end
return netfriends
