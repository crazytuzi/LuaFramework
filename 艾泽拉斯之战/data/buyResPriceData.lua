buyResPriceData = class("buyResPriceData")

-- 购买资源的数据从player身上拿出来
-- todo 老的购买没有
function buyResPriceData:ctor()
	
end

function buyResPriceData:destroy()
	
end

function buyResPriceData:init()
	
end

-- 得到当前已经购买资源的次数
function buyResPriceData:getBuyResourceTimes(resType, copyType, copyID, guildwarSpotIndex)
	
	if resType == enum.BUY_RESOURCE_TYPE.GOLD then
		return dataManager.playerData:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_GOLD_PURCHASE);
	elseif resType == enum.BUY_RESOURCE_TYPE.WOOD then
		return dataManager.playerData:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_LUMBER_PURCHASE);
	elseif resType == enum.BUY_RESOURCE_TYPE.VIGOR then
		return dataManager.playerData:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_VIGOR_PURCHASE);
	elseif resType == enum.BUY_RESOURCE_TYPE.RESET_COPY then
		
		if copyType == enum.ADVENTURE.ADVENTURE_NORMAL then
			return dataManager.playerData:getCounterArrayData(enum.COUNTER_ARRAY_TYPE.COUNTER_ARRAY_TYPE_STAGE_RESET,copyID);
		elseif copyType == enum.ADVENTURE.ADVENTURE_ELITE then
			return dataManager.playerData:getCounterArrayData(enum.COUNTER_ARRAY_TYPE.COUNTER_ARRAY_TYPE_ELITE_RESET,copyID);
		end
	
	elseif resType == enum.BUY_RESOURCE_TYPE.EXP then
		
		return dataManager.playerData:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_LOST_EXP_PURCHASE);
		
	elseif resType == enum.BUY_RESOURCE_TYPE.MAGIC then
		
		return dataManager.playerData:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_MAGIC_EXP_PURCHASE);

	elseif resType == enum.BUY_RESOURCE_TYPE.PLUNDER_TIMES then
		
		return dataManager.playerData:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_PLUNDER_TIMES_PURCHASE);
	
	elseif resType == enum.BUY_RESOURCE_TYPE.PROTECT_TIME then
	
		return 0;
	
	elseif resType == enum.BUY_RESOURCE_TYPE.GUILD_WAR_INSPIRE_ATTACK then
	
		return dataManager.playerData:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_GUILD_WAR_INSPIRE_COUNT);
		
	elseif resType == enum.BUY_RESOURCE_TYPE.GUILD_WAR_INSPIRE_DEFENCE then
		
		local spot = dataManager.guildWarData:getSpot(guildwarSpotIndex);
		
		return spot:getNowDefenceBuffCount();
		
	elseif resType == enum.BUY_RESOURCE_TYPE.GUILD_WAR_BATTLE then
	
		print("dataManager.playerData:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_GUILD_WAR_FIGHT_BUY_COUNT)")
		print(dataManager.playerData:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_GUILD_WAR_FIGHT_BUY_COUNT));
		
		return dataManager.playerData:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_GUILD_WAR_FIGHT_BUY_COUNT);
		
	end

end

-- 得到当前可购买资源的次数
function buyResPriceData:getCanBuyResourceTimes(resType, copyType, copyID, spotIndex)
	
	local maxTimes = self:getMaxBuyResourceTimes(resType);
	
	if maxTimes >= 0 then
		return maxTimes - self:getBuyResourceTimes(resType, copyType, copyID, spotIndex);
	else
		return -1;
	end
end

-- 得到当前购买资源的次数的上限
function buyResPriceData:getMaxBuyResourceTimes(resType)

	local vipInfo = dataConfig.configs.vipConfig[dataManager.playerData:getVipLevel()];
	if vipInfo then
		if resType == enum.BUY_RESOURCE_TYPE.GOLD then
			
			return vipInfo.buyGoldTimes;
			
		elseif resType == enum.BUY_RESOURCE_TYPE.WOOD then
			
			return vipInfo.buyLumberTimes;
		elseif resType == enum.BUY_RESOURCE_TYPE.VIGOR then
			
			return vipInfo.buyVigorTimes;
		elseif resType == enum.BUY_RESOURCE_TYPE.RESET_COPY then
			
			return vipInfo.resetTimes;
		
		elseif resType == enum.BUY_RESOURCE_TYPE.EXP then 
			
			return vipInfo.buyLostExpTimes;
			
		elseif resType == enum.BUY_RESOURCE_TYPE.MAGIC then
			
			return vipInfo.buyMagicExpTimes;
		
		elseif resType == enum.BUY_RESOURCE_TYPE.PLUNDER_TIMES then
			
			return math.huge;
			
		elseif resType == enum.BUY_RESOURCE_TYPE.PROTECT_TIME then	
			
			return math.huge;
		
		elseif resType == enum.BUY_RESOURCE_TYPE.GUILD_WAR_INSPIRE_ATTACK then
			
			return math.huge;
			
		elseif resType == enum.BUY_RESOURCE_TYPE.GUILD_WAR_INSPIRE_DEFENCE then
			
			return math.huge;
			
		elseif resType == enum.BUY_RESOURCE_TYPE.GUILD_WAR_BATTLE then
			
			return math.huge;
			
		end
		
	end
	
	return -1;
end

function buyResPriceData:isDiamondEnough(resType, copyType, copyID)
	local cost = self:getBuyResourceNeedDiamond(resType, copyType, copyID);
	return dataManager.playerData:getGem() >= cost;
end

-- 得到当前购买某个资源需要的钻石
function buyResPriceData:getBuyResourceNeedDiamond(resType, copyType, copyID, spotIndex)
	
	local buyTimes = self:getBuyResourceTimes(resType, copyType, copyID, spotIndex);
	
	local priceInfo = dataConfig.configs.priceConfig[buyTimes+1];

	local nowBuyPriceInfo = -1;

	if priceInfo then
		
		nowBuyPriceInfo = priceInfo;
		
	else
		if buyTimes+1 > #dataConfig.configs.priceConfig then
			nowBuyPriceInfo =  dataConfig.configs.priceConfig[#dataConfig.configs.priceConfig];
		else
			return -1;
		end
	end
	
	if resType == enum.BUY_RESOURCE_TYPE.GOLD then
		return nowBuyPriceInfo.gold;
	elseif resType == enum.BUY_RESOURCE_TYPE.WOOD then
		return nowBuyPriceInfo.lumber;
	elseif resType == enum.BUY_RESOURCE_TYPE.VIGOR then
		return nowBuyPriceInfo.vigor;
	elseif resType == enum.BUY_RESOURCE_TYPE.RESET_COPY then
		return nowBuyPriceInfo.resetStage;
		
	elseif resType == enum.BUY_RESOURCE_TYPE.EXP then 
			
		return nowBuyPriceInfo.lostExp;
			
	elseif resType == enum.BUY_RESOURCE_TYPE.MAGIC then
		
		return nowBuyPriceInfo.magicExp;
	
	elseif resType == enum.BUY_RESOURCE_TYPE.PLUNDER_TIMES then
	
		return nowBuyPriceInfo.resetPlunder;
	
	elseif resType == enum.BUY_RESOURCE_TYPE.PROTECT_TIME then
		
		return dataConfig.configs.ConfigConfig[0].purchaseProtectTimePrice;

	elseif resType == enum.BUY_RESOURCE_TYPE.GUILD_WAR_INSPIRE_ATTACK then
			
		return nowBuyPriceInfo.guildWarAtkWood;
		
	elseif resType == enum.BUY_RESOURCE_TYPE.GUILD_WAR_INSPIRE_DEFENCE then
		
		return nowBuyPriceInfo.guildWarDef;
		
	elseif resType == enum.BUY_RESOURCE_TYPE.GUILD_WAR_BATTLE then
			
		return nowBuyPriceInfo.guildWarTime;
			
	end
	
	return -1;
end

-- 可以购买的资源数量
function buyResPriceData:getCanBuyResourceNumber(resType)
	
	--print("buyResPriceData getCanBuyResourceNumber "..resType);
	
	local configInfo = dataConfig.configs.ConfigConfig[0];
	
	if resType == enum.BUY_RESOURCE_TYPE.GOLD then
		local output = dataManager.goldMineData:getConfig().output;
		return output * configInfo.diamondToGold;
	elseif resType == enum.BUY_RESOURCE_TYPE.WOOD then
		local output = dataManager.lumberMillData:getConfig().diamondToLumber;
		return output;
	elseif resType == enum.BUY_RESOURCE_TYPE.VIGOR then
		return configInfo.diamondToVigor;
	elseif resType == enum.BUY_RESOURCE_TYPE.RESET_COPY then
		return -1;
		
	elseif resType == enum.BUY_RESOURCE_TYPE.EXP then 
		
		local maxExpBuyOnce = dataConfig.configs.ConfigConfig[0].redeemExpCount;
		
		local lostExp = dataManager.playerData:getPlayerAttr(enum.PLAYER_ATTR.PLAYER_ATTR_LOST_EXP);
		
		local buyExp = maxExpBuyOnce;
		if lostExp < maxExpBuyOnce then
			buyExp = lostExp;
		end
		
		return buyExp;
			
	elseif resType == enum.BUY_RESOURCE_TYPE.MAGIC then
	
		return configInfo.diamondToMagicExp;
	
	elseif resType == enum.BUY_RESOURCE_TYPE.PLUNDER_TIMES then
	
		return "";
	
	elseif resType == enum.BUY_RESOURCE_TYPE.PROTECT_TIME then
		
		return formatTime(configInfo.purchaseProtectTime);

	elseif resType == enum.BUY_RESOURCE_TYPE.GUILD_WAR_INSPIRE_ATTACK then

		return dataManager.guildWarData:getAttackBuffBuyUnitCountPercent();
		
	elseif resType == enum.BUY_RESOURCE_TYPE.GUILD_WAR_INSPIRE_DEFENCE then
		
		return dataManager.guildWarData:getDenfenceBuffBuyUnitCountPercent();
		
	elseif resType == enum.BUY_RESOURCE_TYPE.GUILD_WAR_BATTLE then
	
		return "";
		
	end
	
	return -1;
end

