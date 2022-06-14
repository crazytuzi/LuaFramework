guildPlayer = class("guildPlayer")

function guildPlayer:ctor()
	
	self.serverData = {};
	
end

function guildPlayer:destroy()
	
	self.serverData = nil;
	
end

function guildPlayer:init()
	
end

function guildPlayer:createByServerData(serverData)
	
	self.serverData = serverData;
	
end

function guildPlayer:getName()
	
	return self.serverData.name;
	
end

function guildPlayer:getLevel()
	
	return self.serverData.level;
	
end

function guildPlayer:getHeadIcon()
	
	return self.serverData.head;
	
end

function guildPlayer:getVip()
	
	return self.serverData.vip;
	
end

function guildPlayer:getJoinTime()
	
	return dataManager.getServerTime() - self.serverData.enterTime:GetUInt();
	
end

function guildPlayer:getWarScore()
	
	return self.serverData.warScore;
	
end

function guildPlayer:setWarScore(warScore)
	
	self.serverData.warScore = warScore;
	
end

function guildPlayer:canJoinGuildWar()
	
	local joinTime = self:getJoinTime();
	
	print(self:getID().." joinTime  "..joinTime);
	
	return joinTime >= 24 * 3600;
	
end

function guildPlayer:getRight()
	
	return self.serverData.property;
	
end

function guildPlayer:setRight(property)
	
	self.serverData.property = property;
	
end

function guildPlayer:getTitle()
	
	local zhanglao = enum.MEMBER_PROPERTY.MEMBER_PROPERTY_SET_WAR + 
										enum.MEMBER_PROPERTY.MEMBER_PROPERTY_NOTICE + 
										enum.MEMBER_PROPERTY.MEMBER_PROPERTY_ACCEPT_NEWER +
										enum.MEMBER_PROPERTY.MEMBER_PROPERTY_KICK_MEMBERS;
										
	local huizhang = enum.MEMBER_PROPERTY.MEMBER_PROPERTY_SET_WAR + 
										enum.MEMBER_PROPERTY.MEMBER_PROPERTY_NOTICE + 
										enum.MEMBER_PROPERTY.MEMBER_PROPERTY_ACCEPT_NEWER +
										enum.MEMBER_PROPERTY.MEMBER_PROPERTY_KICK_MEMBERS + 
										enum.MEMBER_PROPERTY.MEMBER_PROPERTY_APPOINT;
										
	if self.serverData.property == enum.MEMBER_PROPERTY.MEMBER_PROPERTY_NULL then
		
		return "会员";
		
	elseif self.serverData.property == zhanglao then
	
		return "长老";
		
	elseif self.serverData.property == huizhang then
	
		return "会长";
		
	end

end


function guildPlayer:isPresident()

	local huizhang = enum.MEMBER_PROPERTY.MEMBER_PROPERTY_SET_WAR + 
										enum.MEMBER_PROPERTY.MEMBER_PROPERTY_NOTICE + 
										enum.MEMBER_PROPERTY.MEMBER_PROPERTY_ACCEPT_NEWER +
										enum.MEMBER_PROPERTY.MEMBER_PROPERTY_KICK_MEMBERS + 
										enum.MEMBER_PROPERTY.MEMBER_PROPERTY_APPOINT;
	
	return self.serverData.property == huizhang;
	
end

function guildPlayer:isElders()

	local zhanglao = enum.MEMBER_PROPERTY.MEMBER_PROPERTY_SET_WAR + 
										enum.MEMBER_PROPERTY.MEMBER_PROPERTY_NOTICE + 
										enum.MEMBER_PROPERTY.MEMBER_PROPERTY_ACCEPT_NEWER +
										enum.MEMBER_PROPERTY.MEMBER_PROPERTY_KICK_MEMBERS;
										
	return self.serverData.property == zhanglao;					
end

function guildPlayer:isMember()
	
	return self.serverData.property == enum.MEMBER_PROPERTY.MEMBER_PROPERTY_NULL;
	
end

-- 上次登出时间,0表示在线，大于0的表示上次下线的时间
function guildPlayer:getLastLogoutTime()
	
	return self.serverData.lastOfflineTIme:GetUInt();
	
end

function guildPlayer:isOnline()
	
	return self:getLastLogoutTime() <= 0;
	
end

function guildPlayer:getOfflineTime()
	
	local time = dataManager.getServerTime() - self:getLastLogoutTime();
	
	return time;
	
end

function guildPlayer:leaveTooLong()
	
	local time = dataManager.getServerTime() - self:getLastLogoutTime();
	
	return (not self:isOnline()) and time > 24 * 3600 * 3;
	
end

function guildPlayer:getOnlineState()
	
	-- 根据离线时间判断
	if self:isOnline() then
		return "在线";
	end
	
	local time = dataManager.getServerTime() - self:getLastLogoutTime();
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
	
	return "离开"..src;
	
end

function guildPlayer:getID()
	
	return self.serverData.id;
	
end
