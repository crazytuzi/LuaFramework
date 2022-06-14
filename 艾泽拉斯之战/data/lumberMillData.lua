 	
local building = include("buildingData")
local lumberMillDataClass = class("lumberMillDataClass",building)
function lumberMillDataClass:ctor()
	lumberMillDataClass.super.ctor(self)
end 	

function lumberMillDataClass.getConfigWithLevel(Level)
	return  dataConfig.configs.lumberMillConfig[Level]	
end 

function lumberMillDataClass:getConfig(level)
	level = level or self:getLevel();
	return  lumberMillDataClass.getConfigWithLevel(level)
end 

function lumberMillDataClass:logic_tick(dt)
		lumberMillDataClass.super.logic_tick(self,dt)
end	

function lumberMillDataClass:getHammer()
	--print("magicTowerData--------------2");
	return self:getConfig().hammer;
end

function lumberMillDataClass:isEnoughBaseLevel()
	local baseData = dataManager.mainBase;
	local woodConfig = self:getConfig();
	return baseData:getLevel() >= woodConfig.levelLimit;
	
end

function lumberMillDataClass:isEnoughWood()
	local playerData = dataManager.playerData;
	local woodConfig = self:getConfig();
	return playerData:getWood() >= woodConfig.lumberCost;
	
end

function lumberMillDataClass:isMaxLevel()
	return self:getLevel() == #dataConfig.configs.lumberMillConfig;
end

function lumberMillDataClass:getMaxOutputRadio()
	local playerData = dataManager.playerData;
	local vipLevel = playerData:getVipLevel();
	local vipInfo = dataConfig.configs.vipConfig[vipLevel];
	
	return vipInfo.maxLumberRatio;
end

function lumberMillDataClass:calcReserves()

	local gtime = self:getGatherTime()
	local spaceTime = (dataManager.getServerTime()  - gtime) 
	if(spaceTime < 0)then
		spaceTime = 0
	end
	
  local capacity =  global.getMaxLumberRatio()
	local data =  math.floor(self:getReserves() + 1 * spaceTime/global.lumberMillInterval)
	if(data > capacity)then
		data = capacity 		
	end					
	return data,capacity;
end

function lumberMillDataClass:hasNotifyState()
	local num, capacity = self:calcReserves();
	
	return num >= 0.8 * capacity;
end

function lumberMillDataClass:gatherFullRemainTime()

	local num, capacity = self:calcReserves();
	
	return math.floor( (capacity - num) * global.lumberMillInterval);
end


return lumberMillDataClass