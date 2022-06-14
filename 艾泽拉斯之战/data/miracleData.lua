miracleData = class("miracleData")

function miracleData:ctor()
		
end

function miracleData:destroy()
	
end

function miracleData:init()
	
end

function miracleData:getLevel()
	
	return dataManager.playerData:getPlayerAttr(enum.PLAYER_ATTR.PLAYER_ATTR_MIRACLE);
	
end

function miracleData:isMaxLevel()
	
	return self:getLevel() == #dataConfig.configs.miracleConfig;
	
end

function miracleData:getConfig(level)
	
	local buildlevel = level or self:getLevel();
	
	return dataConfig.configs.miracleConfig[buildlevel];
	
end

function miracleData:getUnitCountByRace(race)
	
	local star = self:getLevel();
	return cardData.getOwnedCardCountByRace(race, star);
	
end

function miracleData:getMaxRaceCount(race)
	
	return cardData.getMaxRaceCount(race);
	
end

-- 当前star数量
function miracleData:getCurrentUnitStar()
	
	local starCount = 0;
	
	for i=1, cardData.MAX_CARD_TYPE do
	
		local card = cardData.getCardInstance(i);
		
		if card:getStar() > 0 then
			starCount = starCount + card:getStar();
		end
		
	end
	
	return starCount;
end

-- 升级所需要的star数量
function miracleData:getNeedUnitStar()
	
	return self:getConfig().starCount;
	
end

-- 获得头像边框
function miracleData:getHeadFrame(level)
	
	local config = self:getConfig(level);
	
	return config.frameImage;
	
end

-- 获得军团品质边框
function miracleData:getUnitFrameByQuality()
	
	local level = self:getLevel();
	
	return itemManager.getImageWithStar(level);
	
end

-- 点击升级的处理
function miracleData:onHandleLevelUp()
	
	-- check unit count
	if not self:isEnoughUnit() then

		eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
			messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
			textInfo = "所需军团星级不足" });
					
		return;
	end
	
	-- check gold
	if not self:isEnoughGold() then
		
		eventManager.dispatchEvent({name = global_event.BUYRESOURCE_SHOW, source = "lackofresource", resType = enum.BUY_RESOURCE_TYPE.GOLD, copyType = -1, copyID = -1, });
		return;
	end
	
	-- check wood
	if not self:isEnoughWood() then
		
		eventManager.dispatchEvent({name = global_event.BUYRESOURCE_SHOW, source = "lackofresource", resType = enum.BUY_RESOURCE_TYPE.WOOD, copyType = -1, copyID = -1, });
		return;
	end
		
	sendUpgradeMiracle();
end

-- 是否有足够的军团星级
function miracleData:isEnoughUnit()
	
	--[[
	for i=0, 3 do
		
		if self:getUnitCountByRace(i) < self:getMaxRaceCount(i) then
		
			return false;
			
		end
	
	end
	--]]
	
	return self:getCurrentUnitStar() >= self:getNeedUnitStar();
end


-- 是否有足够的金币
function miracleData:isEnoughGold()
	
	return dataManager.playerData:getGold() >= self:getConfig().goldCost;
	
end

-- 是否有足够的木材
function miracleData:isEnoughWood()
	
	return dataManager.playerData:getWood() >= self:getConfig().lumberCost;
	
end
