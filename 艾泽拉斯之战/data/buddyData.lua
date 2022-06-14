

 

local buddyPlayer = class("buddyPlayer")

function buddyPlayer:ctor()
	self.headicon = 0
	self.level = 0
	self.name = ""
	self.id = nil
	self.online = nil
	self.power = 0
	self.msgOffline = {}
	self.msgOnline = {}
	self.msgReadFlag = true
	
	self.unreadcount = 0
	self.sendToFlags = 0
	self.recvFromFlags=  0 -- 0 1 2 
	self.vip = 0
end 

function buddyPlayer:clearmsg()
	self.msgOffline = {}
	self.msgOnline = {}
end

function buddyPlayer:onmsgOffline(msg)
	table.insert(self.msgOffline,msg)
	self.msgReadFlag = false
	self.unreadcount =   self.unreadcount + 1
end


function buddyPlayer:onSelfSendMsg(msg)
	table.insert(self.msgOnline,msg)
	eventManager.dispatchEvent({name = global_event.SOCIALNETWORK_UPDATE_MSG, user = self.id  })
end

function buddyPlayer:syncStatus(status)
	local t =  status.lastLoginTime
	if(t) then
		if(type(t) == "userdata")then
			self.lastLoginTime = t:GetUInt()
		else
			self.lastLoginTime  = t	
		end	
		self.online = self.lastLoginTime <= 0
	end
 
	self.headicon = status.icon or self.headicon
	self.level = status.level  or  self.level 
	self.name = status.nickname or self.name
	self.sendToFlags =  status.sendFlag  or self.sendToFlags
	self.recvFromFlags =   status.recvFlag  or self.recvFromFlags
	self.vip = status.vip or self.vip
end
 

function buddyPlayer:onmsgOnline(msg)
	table.insert(self.msgOnline,msg)
	self.msgReadFlag = false
	self.unreadcount =   self.unreadcount + 1
end

function buddyPlayer:getsendToFreinedFlags( )
	return self.sendToFlags == 1
end


function buddyPlayer:getrecvFromFriendFlags( )
	return self.recvFromFlags == 1
end



function buddyPlayer:getMsgOnline( )
	return self.msgOnline
end

function buddyPlayer:getMsgOffline( )
	return self.msgOffline
end

function buddyPlayer:init(data)
	self.headicon = data['headID'] 
	self.level = data['level'] 
	self.name = data['nickname']
	self.id = data['friendID']
	self.vip = data['vip']
	self.miracle = data['miracle']
	
	self.power = 0
	
	local t = data['lastLoginTime']
	if(type(t) == "userdata")then
		self.lastLoginTime = t:GetUInt()
	else
		self.lastLoginTime  = t	
	end	
	self.online = self.lastLoginTime <= 0 
	self.msgCountOffline =  data['msgCount']
	self.msgOffline = {}
	self.msgOnline = {}
	self.sendToFlags =  data.sendFlag  
	self.recvFromFlags =   data.recvFlag  
	self.applyList ={}
end 

function buddyPlayer:getId()
	return self.id
end 


function buddyPlayer:getName()
	return self.name
end 

function buddyPlayer:getLevel()
	return self.level
end 

function buddyPlayer:getHeadIcon()
	return self.headicon
end 

function buddyPlayer:getHeadIconImage()
	return global.getHeadIcon(self:getHeadIcon());
end


function buddyPlayer:isOnline()
	return self.online == true
end 

function buddyPlayer:getBattlePower()
	return self.power
end 

function buddyPlayer:getMsgCountOffline()
	return self.msgCountOffline or 0
end 

function buddyPlayer:getOnlineStatus()
	if(self.online == true)then
		return "在线"
	end
	
	local time = dataManager.getServerTime() - self.lastLoginTime
	local hour = math.floor(time/3600);
	local min =  math.floor(math.fmod(time, 3600)/60);
	local sec = math.fmod(math.fmod(time, 3600), 60);
	local day = math.floor(hour/24);
	local week = math.floor(day/7);
	local month = math.floor(day/30);
	
	local src = "1分钟内"
	if(month > 12 )then
		src = "很久了"
	elseif(month > 1 )then
		src = month.."个月"
	elseif(week > 1 )then
		src = week.."周"
	elseif(day > 1 )then
		src = day.."天"
	elseif(hour > 1 )then
		src = hour.."小时"
	elseif(min > 1 )then
		src = min.."分钟"
	end	
	return    "离开"..src
end 


function buddyPlayer:getMsgReadFlag()
	return self.msgReadFlag
end 

function buddyPlayer:resetMsgReadFlag()
	  self.msgReadFlag = true
	  self.unreadcount = 0
end 

function buddyPlayer:getUnreadcount()
	   return self.unreadcount
end 



local buddyData = class("buddyData")

function buddyData:ctor()
	 self.buddyList = {}
	 self.applyList ={}
	 self.searchResultList ={}
	 self.newFriendly = nil
	 self.recommendList = {}
	 self.hasSendApply = {}
	 self.pkPlayerId = nil
	 self.askpkPlayerId  = false
	 self.curApplyPlayer = nil
end 	
function buddyData:setPkPlayer(id) 
	 self.pkPlayerId  = id
end	

function buddyData:getPkPlayer( ) 
	 return self.pkPlayerId  
end	

function buddyData:setAskPkPlayerDetail( b) 
	   self.askpkPlayerId  = b 
end	
function buddyData:getAskPkPlayerDetail( ) 
	   return self.askpkPlayerId  == true
end	

function buddyData:creates(friends) 
	 for i ,v in ipairs (friends) do
		local f = buddyPlayer.new()
		f:init(v)	
		self:AddBuddy(f)

	end
	
	if(self.newFriendly == false)then
		self.newFriendly = true
	end
	if(self.newFriendly == nil)then
		self.newFriendly = false
	end
	eventManager.dispatchEvent({name = global_event.SOCIALNETWORK_UPDATE})
	eventManager.dispatchEvent({name = global_event.FRIEND_UPDATE})	 
end	



function buddyData:createsRecommends(friendRecommends) 
	 for i ,v in ipairs (friendRecommends) do
		local f = buddyPlayer.new()
		f:init(v)	
		self:AddRecommandBuddy(f)
	end
	eventManager.dispatchEvent({name = global_event.SOCIALNETWORK_UPDATE})
	
end	



function buddyData:hasNewFriend() 
	return self.newFriendly == true
end


function buddyData:hasUnGetVigor() 
	for i,v in pairs (self.buddyList)	do
		if(v:getrecvFromFriendFlags())then
			return true
		end
	end
	return false
end

function buddyData:resetNewFriendflag() 
	  self.newFriendly = false
end

function buddyData:SyncFriendMessage(senderID,msg) 
	local f  = self.buddyList[ senderID ]
	if(f )then
		for i,v in ipairs (msg)	do
			f:onmsgOffline( {v['content'],senderID})
		end
		eventManager.dispatchEvent({name = global_event.SOCIALNETWORK_UPDATE_MSG, user = senderID })
		eventManager.dispatchEvent({name = global_event.FRIEND_UPDATE})	 
	else
		f  = self.buddyList[ self.msgOfflinetargetID ] 
		eventManager.dispatchEvent({name = global_event.SOCIALNETWORK_UPDATE_MSG, user = self.msgOfflinetargetID })
	end
end	


function buddyData:onFriendChatOnline(senderID,msg) 
	local f  = self.buddyList[ senderID ]
	if(f )then
		for i,v in ipairs (msg)	do
			f:onmsgOnline( {v,senderID} )
		end
		eventManager.dispatchEvent({name = global_event.SOCIALNETWORK_UPDATE_MSG, user = senderID })
		eventManager.dispatchEvent({name = global_event.FRIEND_UPDATE})	 
	end
	

end	
function buddyData:onSendapplyFriend(targetID) 
		 self.hasSendApply[targetID] = true
		 self.curApplyPlayer = targetID
		
		eventManager.dispatchEvent({name = global_event.SOCIALNETWORK_UPDATE, applySendedUpDate =true })
		eventManager.dispatchEvent({name = global_event.FRIEND_UPDATE})	
end

function buddyData:onReject( ) 
		if( self.curApplyPlayer)then
			self:delFriendApplicants(self.curApplyPlayer)
			self:delRecommandBuddyApply(self.curApplyPlayer)
		end
end

 

function buddyData:isSendApply(targetID) 
		return  self.hasSendApply[targetID] == true
end


function buddyData:SyncFriendApplicants(applys) 
	
	for i,v in pairs (applys)	do
		local ap = {}
		 ap.id =  v['applyID'] 
		 ap.headID =  v['headID']
		 ap.level =  v['level']
		 ap.nickname =  v['nickname']
		 ap.vip = v['vip']
		 ap.miracle = v['miracle']
		 self.applyList[ap.id] = ap
		
	end
	--eventManager.dispatchEvent({name = global_event.SOCIALNETWORK_UPDATE_APPLYLIST})
	eventManager.dispatchEvent({name = global_event.SOCIALNETWORK_UPDATE})
	eventManager.dispatchEvent({name = global_event.FRIEND_UPDATE})	 
end	


function buddyData:delFriendApplicants(applyID) 
	local change = false
	for i,v in pairs (self.applyList)	do
		 if(v.id == applyID)then
			self.applyList[i] = nil
			change = true
			break
		 end 
	end
	if(change)then
		eventManager.dispatchEvent({name = global_event.SOCIALNETWORK_UPDATE})
		eventManager.dispatchEvent({name = global_event.FRIEND_UPDATE})	 
	end
end	


function buddyData:delRecommandBuddyApply(applyID)
	 
	local change = false
	for i,v in pairs (self.recommendList)	do
		 if(v.id == applyID)then
			self.recommendList[i] = nil
			change = true
			break
		 end 
	end
	if(change)then
		eventManager.dispatchEvent({name = global_event.SOCIALNETWORK_UPDATE})
		eventManager.dispatchEvent({name = global_event.FRIEND_UPDATE})	 
	end
end 


function buddyData:SearchFriendResult(friends) 
	self.searchResultList ={}
	for i,v in pairs (friends)	do
		local ap = {}
		 ap.id =  v['id'] 
		 ap.headicon =  v['icon']
		 ap.name =  v['name']
		 ap.level =  v['level'] or 0 
		 ap.vip =  v['vip'] or 0
		 ap.miracle = v['miracle'] or 1
		 self.searchResultList[ap.id] = ap
	end
	--eventManager.dispatchEvent({name = global_event.SOCIALNETWORK_UPDATE_SEARCHRESULT})
	eventManager.dispatchEvent({name = global_event.SOCIALNETWORK_UPDATE})
	
	if(table.nums(friends) <=0 )then
		eventManager.dispatchEvent({name = global_event.WARNINGHINT_SHOW,tip = "玩家不存在或不在线"})
	end
 
end	
 
function buddyData:getSearchFriendList() 
	return self.searchResultList
end	

function buddyData:getApplicants() 
	return self.applyList
end	

function buddyData:AddBuddy(buddy)
	 self.buddyList[ (buddy:getId()) ] = buddy
	 self:delFriendApplicants(buddy:getId())
	 self:delRecommandBuddyApply(buddy:getId())
end 

function buddyData:isBuddy(buddy)
	  if(iskindof(buddy,"buddyPlayer") )then
			return self.buddyList[ (buddy:getId()) ] ~=nil
	 else
		return self.buddyList[ buddy] ~= nil
	end
end 

function buddyData:DestroyRecommend() 
		for i ,v in pairs ( self.recommendList)do
			 v = nil
		end
		 self.recommendList = {}
end	


function buddyData:getRecommend() 
	return self.recommendList
end	
function buddyData:AddRecommandBuddy(buddy)
	 self.recommendList[ (buddy:getId()) ] = buddy
	 self.hasSendApply[(buddy:getId())] = false
end 

function buddyData:DelBuddy(buddy)
		 
	 if(iskindof(buddy,"buddyPlayer") )then
		 self.buddyList[ (buddy:getId()) ] = nil
	 else
		self.buddyList[ buddy] = nil
	end
	eventManager.dispatchEvent({name = global_event.SOCIALNETWORK_UPDATE})
	eventManager.dispatchEvent({name = global_event.FRIEND_UPDATE})
end 

function buddyData:getBuddyNum()
	return table.nums(self.buddyList)
end 


function buddyData:getBuddyOnlineNum()
	local num = 0
	for i, v in pairs (self.buddyList)do
		if(v and v:isOnline())then
			num = num + 1
		end
	end
	return num
end 

function buddyData:getBuddyList()
	return  self.buddyList
end 
-- 添加好友
function buddyData:addFriends(targetID)
	sendFriendsOp(enum.FRIEND_OPCODE.FRIEND_OPCODE_ADD, targetID)
end 

-- 删除好友
function buddyData:delFriends(targetID)
	sendFriendsOp(enum.FRIEND_OPCODE.FRIEND_OPCODE_DEL, targetID)
end 


-- 拒绝好友申请
function buddyData:rejectFriends(targetID)
	sendFriendsOp(enum.FRIEND_OPCODE.FRIEND_OPCODE_REJECT, targetID)
end 

-- 查看好友留言
function buddyData:viewFriendMsg(targetID)
	--self.msgOfflinetargetID = targetID
	--sendFriendsOp(enum.FRIEND_OPCODE.FRIEND_OPCODE_MESSAGE, targetID)
end 

-- 申请好友
function buddyData:applyFriend(targetID)
	sendFriendsOp(enum.FRIEND_OPCODE.FRIEND_OPCODE_APPLY, targetID)
	---self:onSendapplyFriend(targetID)
end 

-- 查看申请列表
function buddyData:viewApplyList()
	sendFriendsOp(enum.FRIEND_OPCODE.FRIEND_OPCODE_VIEW_APPLY, -1)
end 


-- 推荐好友
function buddyData:viewRecommendList()
	self:DestroyRecommend()
	sendFriendsOp(enum.FRIEND_OPCODE.FRIEND_OPCODE_RECOMMEND, -1)
end 

-- 接受好友赠送
function buddyData:ReciveFriend(targetID)
	sendFriendsOp(enum.FRIEND_OPCODE.FRIEND_OPCODE_RECEIVE, targetID)
end 

--  赠送好友
function buddyData:presentFriend(targetID)
	sendFriendsOp(enum.FRIEND_OPCODE.FRIEND_OPCODE_PRESENTED, targetID)
end 
 
 
function buddyData:sendSearchFriend(content)
	 sendSearchFriend(content)
end 

function buddyData:askPkInfo(targetID)
	sendFriendsOp(enum.FRIEND_OPCODE.FRIEND_OPCODE_FIGHT, targetID)
end 
 

function buddyData:askServer()
	sendFriendsOp(enum.FRIEND_OPCODE.FRIEND_OPCODE_LOAD, -1)
end 

function buddyData:sendMsgToFriend(text,f)
	
	dataManager.chatData:askChat(enum.CHANNEL.CHANNEL_FRIEND,enum.CHAT_TYPE.CHAT_TYPE_TEXT, text,{f:getId()})
	f:onSelfSendMsg( {text,nil})
end 
 

function buddyData:calcFrinedHasTips() 
	
	local num = dataManager.playerData:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_FRIEND_VIGOR_RECEIVE_TIMES)
	local canGETVigor = false
	if (num < dataConfig.configs.ConfigConfig[0].friendsGetVigorTimes)then
		canGETVigor = true
	end	
	
	
	for i,v in pairs (self.buddyList)	do
		if(v:getMsgReadFlag() == false) then
			local count = 	v:getMsgCountOffline()
			if(count <= 0 )then
				count = v:getUnreadcount()
			end
			if(count >0 )then
				return true
			end
		end
		if(canGETVigor and v:getrecvFromFriendFlags())then
			return true
		end
	end
	return false or table.nums(self.applyList) > 0
end

function buddyData:syncFriendsStatus(friendID ,status)
	if(friendID == -99)then
		for i,v in pairs (self.buddyList)	do
			if(v)then
					v.sendToFlags =  0 
					v.recvFromFlags =   0 
			end
		end
	else
		local f =   self.buddyList[ friendID ] 
		if(f)then
			f:syncStatus(status)
		end
	end	
	
	eventManager.dispatchEvent({name = global_event.SOCIALNETWORK_UPDATE,updateStatusOnly = true})
	eventManager.dispatchEvent({name = global_event.FRIEND_UPDATE})
end


function buddyData:setSelBuddyId(id)
	self.selBuddyId = id
end	

function buddyData:OnSuccess(code)
		 if enum.SUCCESS_CODE.SUCCESS_FRIEND_REJECT == code then
			self:delFriendApplicants(self.selBuddyId)
			self:delRecommandBuddyApply(self.selBuddyId)
			eventManager.dispatchEvent({name = global_event.SOCIALNETWORK_UPDATE})
			eventManager.dispatchEvent({name = global_event.FRIEND_UPDATE})
		 elseif  enum.SUCCESS_CODE.SUCCESS_FRIEND_DELETE  == code  then
			 self:DelBuddy(self.selBuddyId)
		 end
end
 

return buddyData




