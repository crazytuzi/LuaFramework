-- ship class define
local ship = class("ship");

function ship:ctor(index)
	self.index = index;
	self.level = 0;
	self.actived = false;
	self.remouldLevel = 1;
end

function ship:release()
end

function ship:active()
	self.actived = true;
end

function ship:isActive()
	return self.actived;
end

function ship:setLevel(level)
	self.level = level;
end

function ship:getLevel()
	return self.level;
end

function ship:setRemouldLevel(level)
	self.remouldLevel = level;
end

function ship:getRemouldLevel()
	return self.remouldLevel;
end

function ship:calcUnitNumByCardType(cardType)
	local cardInstance = cardData.getCardInstance(cardType);
	if cardInstance and cardInstance:getConfig() then
		local unitInfo = cardInstance:getConfig();
		local shipInfo = self:getConfig();
		return math.floor(self:getSoldier() / unitInfo.food);
	else
		return 0;
	end
end

function ship:getConfig(level)
	level = level or self:getLevel();
	return dataConfig.configs.shipConfig[level];
end

function ship:getRemouldConfig(level)
	level = level or self:getRemouldLevel();
	
	return dataConfig.configs.remouldConfig[level];
end

function ship:isMaxRemouldLevel()
	return self:getRemouldLevel() == #dataConfig.configs.remouldConfig;
end

function ship:getSoldier(level)
	level = level or self:getLevel();
	
	local originSoldier = dataConfig.configs.shipConfig[level];
	if originSoldier == nil then
		originSoldier = 0;
	else
		originSoldier = originSoldier.soldier;
	end
	
	local remouldSoldier = 0;
	if self:getRemouldConfig() then
		remouldSoldier = self:getRemouldConfig().soldier;
	end
	
	local radio = dataManager.miracleData:getConfig().soldier * 0.001;
	
	return math.floor((originSoldier + remouldSoldier + dataManager.idolBuildData:getConfig().soldier)*(1+radio));
end

function ship:getActorName(level)
	level = level or self:getRemouldLevel();
	local remouldConfig = self:getRemouldConfig(level);
	if remouldConfig then
		return remouldConfig.actorName;
	else
		return "feichuan01.actor";
	end
end

function ship:isEnoughPlayerLevel()
	local level = dataManager.playerData:getLevel();
	local needLevel = self:getConfig().id + 1;
	return level >= needLevel;
end

function ship:isEnoughGood()
	local gold = dataManager.playerData:getGold();
	local needGold = self:getConfig().money;
	
	return gold >= needGold;
end

function ship:isEnoughWood()
	local wood = dataManager.playerData:getWood();
	local needWood = self:getConfig().wood;
	
	return wood >= needWood;
end

function ship:isEnoughItems()
	
	local needItem = self:getConfig().requireItem;
	local needItemCount = self:getConfig().retuireItemCount;
	
	for k,v in ipairs(needItem) do
		local itemInfo = itemManager.getConfig(v);
		if itemInfo then
			local itemCount = dataManager.bagData:getItemNums(enum.BAG_TYPE.BAG_TYPE_BAG, v);
			local needCount = needItemCount[k];

			return itemCount >= needCount;
		else
			return true;		
		end
	end


end

function ship:isEnoughRemouldItems()
	
	local needItem = self:getRemouldConfig().requireItem;
	local needItemCount = self:getRemouldConfig().retuireItemCount;
	
	local enoughItem = true;
	
	for k,v in ipairs(needItem) do
		local itemInfo = itemManager.getConfig(v);
		if itemInfo then
			local itemCount = dataManager.bagData:getItemNums(enum.BAG_TYPE.BAG_TYPE_BAG, v);
			local needCount = needItemCount[k];
			
			if itemCount < needCount then
				enoughItem = false;
			end
		end
	end
	
	return enoughItem;
end

function ship:isMaxLevel()
	local maxLevel = #dataConfig.configs.shipConfig;
	return self:getLevel() == maxLevel;
end

function ship:getEquipAttr(equipAttrEnum)
	-- 遍历身上所有的装备，计算出属性
	
	local equipAttrValue = 0;
	
	for i = enum.EQUIP_PART.EQUIP_PART_WEAPON,enum.EQUIP_PART.EQUIP_PART_COUNT -1 do	
		local itemInstance = dataManager.bagData:getItem(i, self.index);
		if itemInstance and itemInstance:isEquip() then		
			local equipAttr = itemInstance:getEquipAtt();
			for k,v in ipairs(equipAttr) do
				if v.attid == equipAttrEnum then
					equipAttrValue = equipAttrValue + v.attvalue;
				end
			end
		end
	end
	
	local extraValue = 0;
	local radio = 1.0;
	
	if equipAttrEnum == enum.EQUIP_ATTR.EQUIP_ATTR_ATTACK then
		
		extraValue = dataManager.idolBuildData:getConfig().shipAttrBase[1].attack;
		radio = dataManager.miracleData:getConfig().shipAttrRatio[1].attack * 0.001;
		
	elseif equipAttrEnum == enum.EQUIP_ATTR.EQUIP_ATTR_DEFENCE then
		
		extraValue = dataManager.idolBuildData:getConfig().shipAttrBase[1].defence;
		radio = dataManager.miracleData:getConfig().shipAttrRatio[1].defence * 0.001;
		
	elseif equipAttrEnum == enum.EQUIP_ATTR.EQUIP_ATTR_CRITICAL then
		
		extraValue = dataManager.idolBuildData:getConfig().shipAttrBase[1].critical;
		radio = dataManager.miracleData:getConfig().shipAttrRatio[1].critical * 0.001;
		
	elseif equipAttrEnum == enum.EQUIP_ATTR.EQUIP_ATTR_RESILIENCE then
		
		extraValue = dataManager.idolBuildData:getConfig().shipAttrBase[1].resilience;
		radio = dataManager.miracleData:getConfig().shipAttrRatio[1].resilience * 0.001;
		
	end
	
	
	return math.floor((equipAttrValue + extraValue) * ( 1 + radio));
end

-- 计算船上是否有更强的装备
function ship:hasEquippedStronger()
	if(self.index ~= nil)then	
		for i = enum.EQUIP_PART.EQUIP_PART_WEAPON, enum.EQUIP_PART.EQUIP_PART_COUNT -1 do
			local item = dataManager.bagData:getItem(i, self.index);
			local stronger = dataManager.bagData:hasEquippedStronger(item, i);
			if stronger then
				--print("hasEquippedStronger true index "..self.index);
				return true;
			end
		end
	end
	
	--print("hasEquippedStronger index "..self.index);
	return false;
end

-- ship class define end---------------------------------


shipData = {};

shipData.shiplist = {};

shipData.shipNumberIcon = {
	"set:ship.xml image:ship1",
	"set:ship.xml image:ship2",
	"set:ship.xml image:ship3",
	"set:ship.xml image:ship4",
	"set:ship.xml image:ship5",
	"set:ship.xml image:ship6",
};

function shipData.getShipInstance(shipIndex)
	return shipData.shiplist[shipIndex];
end

function shipData.init()
	
	-- 这里要根据玩家初始的数据初始化，应该是从服务器同步下来的
	-- 如果有新得到的船，要提供添加船的接口
	for i=1, 6 do
		shipData.shiplist[i] = ship.new(i);
	end
	
	--shipData.shiplist[1]:active();
	--shipData.shiplist[2]:active();
	--shipData.shiplist[3]:active();
	--shipData.shiplist[4]:active();
	--shipData.shiplist[5]:active();
	--shipData.shiplist[6]:active();
	--dump(shipData.shiplist);
end

function shipData.updateActiveShip()

	local shipNumLimit = dataConfig.configs.ConfigConfig[0].shipNumLevelLimit;
	
	local count = cardData.getOwnedCardCount();
	
	--if count > 6 then
	--	count = 6;
	--end
	
	for i = 1, 6 do
		
		local progressLimit = shipNumLimit[i];
		
		if dataManager.playerData:getAdventureNormalProcess() and dataManager.playerData:getAdventureNormalProcess() >= progressLimit and i <= count then
			shipData.shiplist[i]:active();
		end
		
	end
	
end

function shipData.destory()
	for i=1, 6 do
		shipData.shiplist[i]:release();
		shipData.shiplist[i] = nil;
	end
	
end

