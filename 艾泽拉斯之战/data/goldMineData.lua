 	
local building = include("buildingData")

local goldMineDataClass = class("goldMineDataClass",building)

function goldMineDataClass:ctor()
 goldMineDataClass.super.ctor(self)
end 	

function goldMineDataClass.getConfigWithLevel(Level)
	return  dataConfig.configs.GoldMineConfig[Level]	
end 

function goldMineDataClass:getConfig(level)
	level = level or self:getLevel();
	return  goldMineDataClass.getConfigWithLevel(level)
end 

function goldMineDataClass:logic_tick(dt)
	goldMineDataClass.super.logic_tick(self,dt)
end

function goldMineDataClass:getHammer()
	--print("magicTowerData--------------1");
	return self:getConfig().hammer;
end

function goldMineDataClass:isEnoughBaseLevel()
	local baseData = dataManager.mainBase;
	local goldConfig = self:getConfig();
	return baseData:getLevel() >= goldConfig.levelLimit;
	
end

function goldMineDataClass:isEnoughWood()
	local playerData = dataManager.playerData;
	local goldConfig = self:getConfig();
	return playerData:getWood() >= goldConfig.lumberCost;
	
end

function goldMineDataClass:isMaxLevel()
	return self:getLevel() == #dataConfig.configs.GoldMineConfig;
end

function goldMineDataClass:getMaxOutputRadio()
	local playerData = dataManager.playerData;
	local vipLevel = playerData:getVipLevel();
	local vipInfo = dataConfig.configs.vipConfig[vipLevel];
	
	return vipInfo.maxGoldRatio;
end

function goldMineDataClass:calcReserves()

	local gtime = self:getGatherTime()
	local spaceTime = (dataManager.getServerTime()  - gtime) 
	if(spaceTime < 0)then
		spaceTime = 0
	end

  local capacity = self:getOutputPerHour() * global.getMaxGoldRatio();
	local num = math.floor(self:getReserves() + self:getOutputPerHour() * spaceTime/3600);

	if(num > capacity)then
		num = capacity 		
	end					
	return num,capacity		
end
	
function goldMineDataClass:hasNotifyState()
	local num, capacity = self:calcReserves();
	
	return num >= 0.8 * capacity;
end

function goldMineDataClass:gatherFullRemainTime()
	
	local num, capacity = self:calcReserves();
	
	return math.floor(3600 * (capacity - num) / self:getOutputPerHour());
end

-- 计算每小时的产量 九 零 一  起 玩 ww w .9  0 1 7 5. com
function goldMineDataClass:getOutputPerHour(level)
	
	local viplevel = dataManager.playerData:getVipLevel()
	
	return self:getConfig(level).output * dataConfig.configs.vipConfig[viplevel].goldRatio;
end
 
return goldMineDataClass