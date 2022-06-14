chatRecord = class("chatRecord");

function chatRecord:ctor()
	
	self.channel = enum.CHANNEL.CHANNEL_INVALID;
	self.chatType = enum.CHAT_TYPE.CHAT_TYPE_INVALID;
	self.playerID = -1;
	self.level = -1;
	self.icon = -1;
	self.talker = "";
	self.content = "";
	self.params = nil;
	self.guid = nil;
	self.time = 0;
	self.target = nil
	self.vip  = 0;
	self.miracle = 1;
end

function chatRecord:destory()

end

function chatRecord:setChannel(channel)
	self.channel = channel;
end

function chatRecord:getChannel()
	return self.channel;
end

function chatRecord:setChatType(chatType)
	self.chatType = chatType;
end

function chatRecord:getChatType()
	return self.chatType;
end

function chatRecord:setPlayerID(playerID)
	self.playerID = playerID;
end

function chatRecord:getPlayerID()
	return self.playerID;
end

function chatRecord:setIcon(icon)
	self.icon = icon;
end

function chatRecord:getIcon()
	return self.icon;
end

function chatRecord:setTalker(talker)
	self.talker = talker;
end

function chatRecord:getTalker()
	return self.talker;
end

function chatRecord:setVip(vip)
	self.vip = vip;
end

function chatRecord:getVip()
	return self.vip;
end


function chatRecord:setContent(content)
	self.content = content;
end

function chatRecord:getContent()
	
	if(enum.CHAT_TYPE.CHAT_TYPE_REPLAY ==	self.chatType ) then
		local replayInfo = self.content
		local names = string.split(replayInfo, "\t");
		
		local nameA = "";
		local nameB = "";
		if names then
			nameA = names[1] or "";
			nameB = names[2] or "";
		end
		
		contentText = "战斗录像【"..nameA.."】VS".."【"..nameB.."】";
		return contentText
	end
 
	return self.content;
end

function chatRecord:setParams(params)
	self.params = params;
	if(self.params)then
		self.target = self.params [1]
	end
end

function chatRecord:getParams()
	return self.params;
end

function chatRecord:setLevel(level)
	self.level = level;
end

function chatRecord:getLevel()
	return self.level;
end

function chatRecord:setGUID(guid)
	self.guid = guid;
end

function chatRecord:getGUID()
	return self.guid;
end

function chatRecord:setTime(time)
	self.time = time;
end

function chatRecord:getTime()
	return self.time;
end

function chatRecord:getTarget()
	return self.target;
end

function chatRecord:setMiracle(miracle)
	self.miracle = miracle;
end

function chatRecord:getMiracle()
	
	return self.miracle;
	
end


 		