guildApplyPlayer = class("guildApplyPlayer")

function guildApplyPlayer:ctor()
	
	self.serverData = {};
	
end

function guildApplyPlayer:destroy()
	
	self.serverData = nil;
	
end

function guildApplyPlayer:init()
	
end

function guildApplyPlayer:createByServerData(serverData)
	
	self.serverData = serverData;
	
end

function guildApplyPlayer:getName()
	
	return self.serverData.name;
	
end

function guildApplyPlayer:getLevel()
	
	return self.serverData.level;
	
end

function guildApplyPlayer:getHeadIcon()
	
	return self.serverData.head;
	
end

function guildApplyPlayer:getVip()
	
	return self.serverData.vip;
	
end

function guildApplyPlayer:getID()
	
	return self.serverData.id;
	
end

