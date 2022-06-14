 	
local building = include("buildingData");

local magicTowerData = class("magicTowerData",building);

function magicTowerData:ctor()
 magicTowerData.super.ctor(self)
 
 self.medicatePoint = 0;
end

function magicTowerData:getMedicatePoint()
	return self.medicatePoint;
end

function magicTowerData:getHammer()
	--print("magicTowerData");
	local magicTowerInfo = dataConfig.configs.MagicTowerConfig[self:getLevel()];
	return magicTowerInfo.hammer;
end

function magicTowerData:setMedicatePoint(medicatePoint)
	self.medicatePoint = medicatePoint;
end

function magicTowerData:getMagicTowerConfig()
	return dataConfig.configs.MagicTowerConfig[self:getLevel()];
end

function magicTowerData:getNextMagicTowerConfig()
	return dataConfig.configs.MagicTowerConfig[self:getLevel()+1];
end

function magicTowerData:isMaxLevel()
	return self:getLevel() == #dataConfig.configs.MagicTowerConfig;
end

function magicTowerData:isEnoughBaseLevel()
	
	local baseInfo = dataManager.mainBase;
	local baseLevel = baseInfo:getLevel();
	
	return baseLevel >= self:getMagicTowerConfig().levelLimit;

end

function magicTowerData:getConfig(level)
	level = level or self:getLevel();
	return dataConfig.configs.MagicTowerConfig[level];
end

function magicTowerData:isEnoughWood()
	local playerData = dataManager.playerData;

	local wood = playerData:getWood();

	return wood >= self:getMagicTowerConfig().lumberCost;

	
end

-- 当前的冥想点数
function magicTowerData:getNowMedicatePoint()
	
	local magicTowerInfo = dataConfig.configs.MagicTowerConfig[self:getLevel()];
	
	local lastPoint = self:getMedicatePoint();
	local lastTime = self:getGatherTime();
	local nowTime = dataManager.getServerTime();
	
	local nowPoint = lastPoint + math.floor((nowTime - lastTime)/60);
	local nowRemineTime = 60 - math.fmod((nowTime - lastTime), 60);
	local totalPoint = magicTowerInfo.meditationCostLimit;
	if nowPoint > totalPoint then
		nowPoint = totalPoint;
	end
	
	return nowPoint, nowRemineTime;
end

-- 当前可冥想次数
function magicTowerData:getNowMedicateTimes()
	
	local times = math.ceil(self:getNowMedicatePoint() / self:getNowCostPoint());
	if times <= 0 then
		times = 0;
	end
	
	return times;
end

-- 当前的冥想点数上限
function magicTowerData:getTotalMedicatePoint()

	local magicTowerInfo = dataConfig.configs.MagicTowerConfig[self:getLevel()];
	local totalPoint = magicTowerInfo.meditationCostLimit;
	return totalPoint;
end

-- 当前冥想需要的点数
function magicTowerData:getNowCostPoint()
	local magicTowerInfo = dataConfig.configs.MagicTowerConfig[self:getLevel()];
	return magicTowerInfo.meditationCost;
end

-- 当前满足冥想还需等待的时间
function magicTowerData:getWaitMedicateTime()
	local nowPoint, remineTime = self:getNowMedicatePoint();
	local costPoint = self:getNowCostPoint();
	
	if nowPoint > 0 then
		return -1;
	else
		local waitTime = (-nowPoint)*60 + remineTime;
		return waitTime;
	end
end

-- 当前冥想可以获得的技能数
function magicTowerData:getMediacateSkillCount()
	local magicTowerInfo = dataConfig.configs.MagicTowerConfig[self:getLevel()];
	return magicTowerInfo.candidateSkillNum;
end

-- 家园场景的提示
function magicTowerData:hasNotifyState()
	return self:getNowMedicateTimes() >= 1;
end

return magicTowerData;