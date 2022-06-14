chatData = class("chatData");

function chatData:ctor()
	self.records = {};
	
	self.lastSentTime = 0;
	self.privateList = {}  --私聊玩家列表
 
end

function chatData:destroy()
	
	for k,v in ipairs(self.records) do
		v:destory();
	end
	
	self.records = nil;
end

function chatData:addPriveChatList(playerId,info)
	
	if(playerId == nil)then
		return 
	end
	local newmsg = false 
	if(self.privateList[playerId])then
		newmsg = self.privateList[playerId].newMsg
	end
	self.privateList[playerId] = info
	self.privateList[playerId].newMsg = newmsg
end	


function chatData:delPriveChatList(playerId)
	if(playerId == nil)then
		return 
	end
	self.privateList[playerId] = nil
end	

function chatData:syncPriveChatList(playerId,bnewMsg)
	if(playerId == nil)then
		return 
	end
	self.privateList[playerId] = self.privateList[playerId] or {}
	self.privateList[playerId].newMsg = bnewMsg
end	


function chatData:hasPriveChatNewMsg( )
	 
	for i, v in pairs (self.privateList) do
		if(v and v.newMsg)then
			return true
		end
	end
	return false
end	



function chatData:getPriveChatList()
	
		 return self.privateList
end	


function chatData:hasUnreadPrivateMsg()
		for i,v in pairs (self.privateList) do
			if(v and v.newMsg)then
				return true
			end
		end
	return false
end


function chatData:addRecord(channel, chatType, playerID, level, icon, vip,talker, content, params, miracle)
	

	local record = chatRecord.new();
	
	record:setChannel(channel);
	record:setChatType(chatType);
	record:setPlayerID(playerID);
	record:setLevel(level);
	record:setIcon(icon);
	record:setTalker(talker);
	record:setVip(vip);
	record:setContent(content);
	record:setParams(params);
	record:setMiracle(miracle);
	
	local h, m, s = dataManager.getLocalTime();
	record:setTime({h = h, m = m, s = s});
 
	if(enum.CHANNEL.CHANNEL_FRIEND == channel)then
	
		if(playerID ~= dataManager.playerData:getPlayerId()  ) then
			self:addPriveChatList(playerID,{ name = talker,level =level, icon = icon})
			self:syncPriveChatList(playerID,true)
		end
	end
	
	table.insert(self.records, record);
	record:setGUID(#self.records);
	
	--[[
	if(enum.CHANNEL.CHANNEL_FRIEND == channel)then
		dataManager.buddyData:onFriendChatOnline(playerID,{content})
		return  record
	end
	]]--
	return record;
end

function chatData:askChat(channel, chatType, content, params)
	
	local nowTime = dataManager.getServerTime();
	
	if nowTime - self.lastSentTime < 5 then
		-- 发送间隔
		eventManager.dispatchEvent({name = global_event.TIP_INFO_SHOW,tip = "发送间隔不能少于5秒!"});
		
		return false;
	else
		sendAskChat(channel, chatType, content, params);
		
		self.lastSentTime = nowTime;
		
		return true;
	end
	
end

function chatData:getRecord()
	return self.records;
end



function chatData:getLastWorldRecord(nums)
	     nums  = nums or 1
		 local num = #self.records
		 local msg ={}
		 local iNum = 0
		 for i = num, 1,-1 do
			 if(self.records[i] and self.records[i]:getChannel() == enum.CHANNEL.CHANNEL_WORLD )then
				table.insert(msg,self.records[i])
				iNum = iNum+ 1
				if(iNum >= nums)then
					break
				end
			 end
		 end
		return msg
end

function chatData:getRecordByGUID(guid)
	for k,v in ipairs(self.records) do
		if v:getGUID() == guid then
			return v;
		end
	end
	
	return nil;
end

function chatData:NotifySystemMsg(text, wildCardParams, fly, channel )
	
	function format_NotifySystemMsg(_text,_wildCardParams)
		 
			--_wildCardParams={"天帝","4","闪电"} 
			str = string.format(text, unpack(_wildCardParams))
			return str
	end
	local str  = format_NotifySystemMsg(text,wildCardParams)	

	local record = dataManager.chatData:addRecord(channel, enum.CHAT_TYPE.CHAT_TYPE_NOTIFY, -1, -1, -1, 0,"系统", str, params);
	
	eventManager.dispatchEvent({name = global_event.CHATROOM_RECV_ONE_RECORD, channel = channel, record = record });
	
	if fly then
		eventManager.dispatchEvent({name = global_event.ANNOUNCEMENT_SHOW, record = record });
	end
	
end

function chatData:setClickPosition(pos)
	self.clickPosition = pos;
end

function chatData:getCilckPosition()
	return self.clickPosition;
end
