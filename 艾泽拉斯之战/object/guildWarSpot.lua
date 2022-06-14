guildWarSpot = class("guildWarSpot")

function guildWarSpot:ctor(index)
	
	self.index = index;
	self.basicInfo = {
		id = -1,
		inspireCount = 0,
		name = "",
		status = 0,
	};
	
	self.step = 1;
	
	self.players = {};
	self.hpPercent = {};
	self.fighting = {};
	
end

function guildWarSpot:destroy()

end

function guildWarSpot:init()
	
end

-- 是否是自己的据点
function guildWarSpot:isMy()
	
	return self:getOwnerGuildID() == dataManager.guildData:getMyGuildID();
	
end

-- 设置服务器相关信息
function guildWarSpot:setSpotBasicInfo(info)
	
	self.basicInfo = clone(info);

end

function guildWarSpot:setSpotDetailInfo(step, fighting, inspireCount, precent, players)
	
	self.step = step + 1;
	self.basicInfo.inspireCount = inspireCount;
	self.hpPercent = clone(precent);
	self.players = clone(players);
	
	for k, v in ipairs(self.players) do
		
		if v.name == "" then
			v.name = "守护者";
		end
		
	end
	
	self.fighting = clone(fighting);
end

-- 设置服务器相关信息end

-- 总体概况图的信息
-- 据点拥有者
function guildWarSpot:getSpotOwnerName()
	
	if self.basicInfo.name == "" then
		return "无";
	else
		return self.basicInfo.name;
	end
	
end

-- 据点拥有者id
function guildWarSpot:getOwnerGuildID()
	
	return self.basicInfo.id;
	
end

-- 名称
function guildWarSpot:getSpotName()
	
	return self:getConfig().name;
	
end

-- 
function guildWarSpot:isCanAttack()
	
	--print("self.basicInfo.status "..self.basicInfo.status);
	return self.basicInfo.status == 0;
	
end

-- 
function guildWarSpot:getConfig()

	return dataConfig.configs.guildWarConfig[self.index];
	
end

-- 积分奖励
function guildWarSpot:getGuildWinReward()
	
	return self:getConfig().gwScore[1];
	
end

function guildWarSpot:getGuildLoseReward()

	return self:getConfig().gwScore[2];
	
end

function guildWarSpot:getGuildBreakReward()
	
	return self:getConfig().gwScore[3];
	
end

-- 获取当前防守鼓舞次数
function guildWarSpot:getNowDefenceBuffCount()
	
	return self.basicInfo.inspireCount;
	
end

function guildWarSpot:getNowDefenceAddUnitCount()
	
	return math.floor(self:getNowDefenceBuffCount() * dataManager.guildWarData:getDenfenceBuffBuyUnitCountPercent());
	
end

-- 获取当前梯队的index
function guildWarSpot:getCurrentStageIndex()
	
	return self.step;
	
end

-- 剩余梯队
function guildWarSpot:getRemainStage()
	
	return self:getMaxStageIndex() - self:getCurrentStageIndex() + 1;
	
end


-- 获取最大stage index
function guildWarSpot:getMaxStageIndex()
	
	return 3;
	
end

-- 获取守军数量 
function guildWarSpot:getDefencePlayerCount()
	
	return #self.players;
	
end

function guildWarSpot:getDefencePlayer(index)

	return self.players[index];
	
end

function guildWarSpot:getHpPercent(index)
	
	return self.hpPercent[index] * 0.01;
	
end

function guildWarSpot:getHpPercentText(index)
	
	local percent = self.hpPercent[index];
	
	return string.format("%02d%%", percent);
	
end

function guildWarSpot:isFighting(index)
	
	return self.fighting[index] == 1;
	
end
