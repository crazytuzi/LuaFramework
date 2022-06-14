function FriendsStatusHandler( __optional_flag__, friendID, icon, level, vip,nickname, lastLoginTime,sendFlag, recvFlag)
		dataManager.buddyData:syncFriendsStatus(friendID ,{lastLoginTime = lastLoginTime,icon = icon,level = level,nickname = nickname ,sendFlag = sendFlag,recvFlag = recvFlag,vip = vip})
end
