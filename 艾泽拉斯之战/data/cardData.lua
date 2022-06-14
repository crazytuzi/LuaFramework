cardData = {};
cardData.cardlist = {};
cardData.MAX_CARD_TYPE = table.maxn(dataConfig.configs.unitCompatableConfig);
cardData.starLevel = dataConfig.configs.ConfigConfig[0].startLevelTable;
cardData.oneCost = dataConfig.configs.ConfigConfig[0].drawOnceCost;
cardData.tenCost = dataConfig.configs.ConfigConfig[0].drawTentimesCost;

-- card class define
local card = class("card");

function card:ctor(cardType)
	self.cardType = cardType;
	self.exp = 0;
	self.unitID = cardType;
	self.star = 0;
	self.currentExp = 0;
	self.nextExp = 0;	
end

function card:init()
	self:setExp(0);
end

function card:release()
end

function card:getExp()
	return self.exp;
end

function card:getStar()
	return self.star;
end

function card:getCurrentExp()
	return self.currentExp;
end

function card:getNextExp()
	return self.nextExp;
end

function card:setExp(exp)
	
	local oldexp = self.exp;
	self.exp = exp;
		
	-- 计算星级
	local oldStar = self.star;
	
	
	if oldStar >= 1 and oldexp and (exp - oldexp) > 0 then
	
		local name = self:getConfig().name;
		-- 新获得提示
		local text = "^FFFF00获得[^FFFFFF"..name.."^FFFF00]碎片 X"..(exp - oldexp);
		eventManager.dispatchEvent({name =  global_event.WARNINGHINT_SHOW,tip =  text ,RESGET = true})
		-- 新获得提示	
	end	
		
	self.star = cardData.getStarByExp(exp);
		
	-- 计算unitID
	local oldUnitID = self.unitID;
	self.unitID = cardData.getUnitIDByTypeAndStar(self.cardType, self.star);
	
	local preExp = 0;
	--print("self.star   "..self.star);
	-- 当前碎片
	if self.star == 0 then
		preExp = 0;
	else
		preExp = cardData.starLevel[self.star];
	end
	
	self.currentExp = self.exp - preExp;
	
	-- 下一级的碎片
	if self:isMaxStar() then
		self.nextExp = 0;
	else
		self.nextExp = cardData.starLevel[self.star+1] - preExp;
	end
	
	print("self.nextExp  "..self.nextExp.." pre "..preExp);
	
	-- 刷新激活船的数量
	shipData.updateActiveShip();
		
end

function card:isMaxStar()
	return self.star == #cardData.starLevel;
end

function card:getConfig()
	return dataConfig.configs.unitConfig[self.unitID];
end

function card:getUnitID()
	return self.unitID;
end

function card:getConfig()
	return dataConfig.configs.unitConfig[self:getUnitID()];
end

function card:getNewGainedFlagInBag()

	local flag = dataManager.playerData:getCounterArrayData(enum.COUNTER_ARRAY_TYPE.COUNTER_ARRAY_TYPE_UNIT_VIEW_STAMP, self.cardType);
	
	return flag;
end

function card:getNewGainedFlagInBattle()
	
	local flag = dataManager.playerData:getCounterArrayData(enum.COUNTER_ARRAY_TYPE.COUNTER_ARRAY_TYPE_UNIT_JOIN_STAMP, self.cardType);
	
	return flag;
end

function card:setNewGainedFlagInBag()
	
	--dataManager.playerData:setCounterArrayData(enum.COUNTER_ARRAY_TYPE.COUNTER_ARRAY_TYPE_UNIT_VIEW_STAMP, self.cardType, true);
	
	sendViewStamp(enum.VIEW_STAMP_TYPE.VIEW_STAMP_TYPE_UNIT_VIEW, self.cardType);
end

function card:setNewGainedFlagInBattle()
	
	--dataManager.playerData:setCounterArrayData(enum.COUNTER_ARRAY_TYPE.COUNTER_ARRAY_TYPE_UNIT_JOIN_STAMP, self.cardType, true);
	
	sendViewStamp(enum.VIEW_STAMP_TYPE.VIEW_STAMP_TYPE_UNIT_JOIN, self.cardType);
end

-- card class define end---------------------------------

function cardData.init()
	
	for i=1, cardData.MAX_CARD_TYPE do
		cardData.cardlist[i] = card.new(i);
	end

	for i=1, cardData.MAX_CARD_TYPE do
		cardData.cardlist[i]:init();
	end

end

function cardData.destroy()
	for i=1, cardData.MAX_CARD_TYPE do
		cardData.cardlist[i]:delete();
	end
	
end

function cardData.getStarByExp(exp)
	-- 计算星级
	local star = #cardData.starLevel;
	
	for i=1, #cardData.starLevel do
		if exp < cardData.starLevel[i] then
			star = i-1;
			break;
		end
	end
	
	return star;
end

function cardData.getUnitIDByTypeAndStar(cardType, star)
	-- 计算unitID
	local unitID = -1;
	local unitIDArray = dataConfig.configs.unitCompatableConfig[cardType];
	if unitIDArray and unitIDArray.starLevel and unitIDArray.starLevel[star] then
		unitID = unitIDArray.starLevel[star];
	else
		--print("getUnitIDByTypeAndStar error!")
		unitID = cardType;
	end
	
	return unitID;
end

function cardData.getCardInstance(cardType)
	return cardData.cardlist[cardType];
end

function cardData.getConfigByTypeAndExp(cardType, exp)
	
	local star = cardData.getStarByExp(exp);
	local unitID = cardData.getUnitIDByTypeAndStar(cardType, star);
	
	return 	dataConfig.configs.unitConfig[unitID];
end

function cardData.getCardList()
	return cardData.cardlist
end

-- 大于1星的卡片的数量
function cardData.getOwnedCardCount()
	
	local count = 0;
	for i=1, cardData.MAX_CARD_TYPE do
		local card = cardData.getCardInstance(i);
		
		if card:getStar() > 0 then
			count = count + 1;
		end
		
	end
	
	return count;
end

-- 根据种族获得军团的数量
function cardData.getOwnedCardCountByRace(race, star)
	
	local count = 0;
	
	for i=1, cardData.MAX_CARD_TYPE do

		local card = cardData.getCardInstance(i);
		
		if card:getStar() >= star and card:getConfig().race == race then
			count = count + 1;
		end		
		
	end
	
	return count;
end

-- 根据种族获得最大的军团数量
function cardData.getMaxRaceCount(race)
		
	local count = 0;
	
	for k,v in pairs(dataConfig.configs.unitCompatableConfig) do
	
		local unitID = v.starLevel[1];
	
		local unitInfo = dataConfig.configs.unitConfig[unitID];
		
		if race == unitInfo.race then
			count = count + 1;
		end
	end

	return count;
	
end

-- 播放音效
function cardData.playVoiceByUnitID(id)
	if dataConfig.configs.unitConfig[id] and dataConfig.configs.unitConfig[id].voice then
		LORD.SoundSystem:Instance():playEffect(dataConfig.configs.unitConfig[id].voice);
	end
end

-- 设置看过的标志
function cardData.setNewGainedByRace(race)
	
	for i=1, cardData.MAX_CARD_TYPE do
		local card = cardData.getCardInstance(i);
		if card:getConfig().race == race and card:getNewGainedFlagInBag() > 0 then
			card:setNewGainedFlagInBag();
		end
	end
	
end

function cardData.getNewGainedCountByRace(race)
	local count = 0;
	for i=1, cardData.MAX_CARD_TYPE do
		local card = cardData.getCardInstance(i);
		if card:getConfig().race == race and card:getNewGainedFlagInBag() > 0 then
			count = count + 1;
		end
	end
	
	return count;
end

function cardData.setNewGainedByRaceInBattle(race)
	
	for i=1, cardData.MAX_CARD_TYPE do
		local card = cardData.getCardInstance(i);
		if card:getConfig().race == race and card:getNewGainedFlagInBattle() > 0 then
			card:setNewGainedFlagInBattle();
		end
	end
	
end

function cardData.getNewGainedCountByRaceInBattle(race)
	local count = 0;
	for i=1, cardData.MAX_CARD_TYPE do
		local card = cardData.getCardInstance(i);
		if card:getConfig().race == race and card:getNewGainedFlagInBattle() > 0 then
			count = count + 1;
		end
	end
	
	return count;
end

function cardData.isHaveNewGained()
	
	for i=1, cardData.MAX_CARD_TYPE do
		local card = cardData.getCardInstance(i);
		if card:getNewGainedFlagInBag() > 0 then
			return true;
		end
	end
	
	return false;
end

function cardData.getMaxStartedCard()
	
	function _cardSort(a, b)
		if a.star < b.star then
			return false;	
		elseif a.star > b.star then
			return true;
		else
			local temp1 = math.fmod(a.cardType, 18);
			local temp2 = math.fmod(b.cardType, 18);
			
			if temp1 < temp2 then
				return false;
			elseif temp1 > temp2 then
				return true;
			else
				
				return a.cardType >= b.cardType;
				
			end
		end
	end
	
	local list = {};
	
	for i=1, cardData.MAX_CARD_TYPE do
		local card = cardData.getCardInstance(i);
		
		if card:getStar() > 0 then
			
			table.insert(list, {
				['cardType'] = i,
				['star'] = card:getStar(),
			});
			
		end
		
	end
	
	table.sort(list, _cardSort);
	
	return list;
end
