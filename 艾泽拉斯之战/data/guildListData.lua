guildListData = class("guildListData")

guildListData.GUILD_COUNT_PER_PAGE = 6;

function guildListData:ctor()
	
	self.guildList = {};
	self.applyedGuild = {};
	
end

function guildListData:destroy()
	
	self.guildList = nil;
	
end

function guildListData:init()
	
end

function guildListData:onServerData(serverData)
	
	-- 排序 
	self.guildList = clone(serverData);
	
	table.sort(self.guildList, function(guildA, guildB) 
		
		return guildA.allLevel > guildB.allLevel;
		
	end);
	
end

-- 获得第n页的数据, pageNum 从1开始
function guildListData:getPageData(pageNum)

	local pageData = {};
	
	for i= 1 + (pageNum-1) * guildListData.GUILD_COUNT_PER_PAGE, pageNum * guildListData.GUILD_COUNT_PER_PAGE do
	
		local item = clone(self.guildList[i]);
		
		table.insert(pageData, item);
		
	end
	
	return pageData;
	
end

function guildListData:getTotalPageNum()
	
	if #self.guildList == 0 then
		return 1;
	else
		return math.ceil(#self.guildList / guildListData.GUILD_COUNT_PER_PAGE);
	end
end

-- 申请列表
function guildListData:setApplyedGuild(guilds)
	
	self.applyedGuild = guilds;
	
end

-- 是否已经申请过
function guildListData:isGuildApplyed(guildid)
	
	for k,v in pairs(self.applyedGuild) do
		if v == guildid then
			return true;
		end
	end
	
	return false;
end


--- user interface
function guildListData:onHandleApplyGuild(guildID)
	
	sendApplyGuild(guildID);
	sendGuildOp(enum.GUILD_OPCODE_TYPE.GUILD_OPCODE_TYPE_MY_APPLYS, 0);
	
end
