 	
local building = include("buildingData")

local mainBaseDataClass = class("mainBaseDataClass",building)

local MAIN_BASE_FOOD = "MAIN_BASE_FOOD";

function mainBaseDataClass:ctor()
 mainBaseDataClass.super.ctor(self)
end 	

function mainBaseDataClass:init()
	mainBaseDataClass.super.init(self);
	
	self:setFood(0);
	
	self.currentIncident = nil;
	self.currentIncidentIndex = -1;
	self.stageAwardRandom1 = {};
	self.stageAwardRandom2 = {};
	self.win = false;
	
	self.incidents = {};
end

function mainBaseDataClass:setFood(food)
	self.att:setAttr(MAIN_BASE_FOOD, food);
end

function mainBaseDataClass:getFood()
	return self.att:getAttr(MAIN_BASE_FOOD);
end

function mainBaseDataClass:getTotalHammer()
	return dataManager.goldMineData:getHammer() + dataManager.lumberMillData:getHammer() + dataManager.magicTower:getHammer();
end

function mainBaseDataClass:getConfig(level)
	level = level or self:getLevel();
	return dataConfig.configs.MainBaseConfig[level];
end

function mainBaseDataClass:isMaxLevel()
	return self:getLevel() == #dataConfig.configs.MainBaseConfig;
end

function mainBaseDataClass:isEnoughWood()
	local requireWood = self:getConfig().lumberCost;
	local player = dataManager.playerData;
	
	return player:getWood() >= requireWood;
end

function mainBaseDataClass:isEnoughHammer()
	local requireHammer = self:getConfig().hammerRequire;
	
	return self:getTotalHammer() >= requireHammer;
end

function mainBaseDataClass:isEnoughPlayerLevel()
	local player = dataManager.playerData;
	
	return player:getLevel() >= self:getConfig().heroLevel;
end

function mainBaseDataClass:getLingDiCount(level)
	local config = self:getConfig(level);
	local count = 0;
	for k,v in ipairs(config.home) do
		if v > 0 then
			count = count + 1;
		end
	end
	
	return count;
end

function mainBaseDataClass:getLingDiMaxCount(level)
	local config = self:getConfig(level);
	return #config.home;
end

function mainBaseDataClass:isLingDiActive(index)
	local config = self:getConfig(level);

	for k,v in ipairs(config.home) do
		if v > 0 and k == index then
			return true;
		end
	end
	
	return false;
end

-- 获得已经激活的领地个数
function mainBaseDataClass:getActiveLingDiCount()
	local count = 0;
	for k, v in pairs(self.incidents) do
		if self:isLingDiActive(k) then
			count = count + 1;
		end
	end
	
	return count;
end

function mainBaseDataClass:getRemineIncidentTime(index)

	local nextIncidentTime = 0;
	if self.incidents[index] and self.incidents[index].nextTime then
		nextIncidentTime = self.incidents[index].nextTime:GetUInt();
	end
	
	local nowserverTime = dataManager.getServerTime();
	local remainTime = nextIncidentTime - math.floor(nowserverTime);
	
	if remainTime < 0 then
		remainTime = 0;
	end
	
	return remainTime;
end

-- 返回还没有刷新的倒计时中最小的一个
-- 如果已经满了，index返回的是-1
function mainBaseDataClass:getWholeIncidentRemainTime()
	

	-- 从剩余时间大于0的里面找一个最小的返回，并且是没刷新的
	-- 没有的话返回-1

	
	local minRemainTime = math.huge;
	local minIndex = -1;
	
	

	for k,v in pairs(self.incidents) do
		
		if self:isLingDiActive(k) then
			local remineTime = self:getRemineIncidentTime(k);
			
			if remineTime < minRemainTime and self:getIncidentPosition(k) < 0 then
				minRemainTime = remineTime;
				minIndex = k;
			end
		end
		
	end
	
	--print("minRemainTime "..minRemainTime);	
	--print("minIndex "..minIndex);	
	
	return minRemainTime, minIndex;

end

function mainBaseDataClass:getPlayerIncidentIndex(index)
	if self.incidents[index] and self.incidents[index].eventID then
		return self.incidents[index].eventID;
	else
		return -1;
	end
end

-- 判断是不是有可以打的领地事件
function mainBaseDataClass:hasCanDoIncident()
	
	for k,v in pairs(self.incidents) do
		
		if self:isLingDiActive(k) and self:getIncidentPosition(k) >= 0 then

			return true;
			
		end
		
	end
	
	return false;
	
end

-- 获取当前可以打的事件最靠前的一个关卡
function mainBaseDataClass:getFirstCanDoIncidentPosition()
	
	local firstPos = math.huge;
	local setflag = false;
	
	for k,v in pairs(self.incidents) do
		
		local position = self:getIncidentPosition(k);
		
		if self:isLingDiActive(k) and  position >= 0 then
		
			if position < firstPos then
				
				firstPos = position;
				
				setflag = true;
			end
			
		end
		
	end
	
	if setflag then
		
		return firstPos;
		
	else
		
		return -1;
		
	end
	
end

-- 获取领地事件的据点信息
-- position +1 就是advertureid
function mainBaseDataClass:getIncidentPoint(index)
	local position = self:getIncidentPosition(index);
	if position >= 0 and dataConfig.configs.AdventureConfig[position+1] then
		return dataConfig.configs.AdventureConfig[position+1].point;
	else
		return -1;
	end	
end

-- 获取领地事件的位置信息
function mainBaseDataClass:getIncidentPosition(index)
	if self.incidents[index] and self.incidents[index].position then
		return self.incidents[index].position;
	else
		return -1;
	end
end

-- 判断某个位置是否有领地事件
function mainBaseDataClass:getIncidentIndexByPosition(pos)
	for k,v in pairs(self.incidents) do
		if v.position == pos then
			return k;
		end
	end
	
	return -1;
end

-- sync设置
function mainBaseDataClass:setIncidentInfo(index, incidentInfo)
	self.incidents[index] = incidentInfo;
end

function mainBaseDataClass:handleIncident(index, eventID)

	self.currentIncident = dataConfig.configs.IncidentConfig[eventID];
	self.currentIncidentIndex = index;
	
	if self.currentIncident then
		eventManager.dispatchEvent({name = global_event.DIALOGUE_SHOW, dialogueType = "incident", dialogueID = self.currentIncident.dialogueId });
	end
end

-- 清理信息
function mainBaseDataClass:clearIncidentInfo()
	self.currentIncident = nil;
	self.currentIncidentIndex = -1;
	self.stageAwardRandom1 = {};
	self.stageAwardRandom2 = {};
	self.win = false;
end

-- 获得领地的index
function mainBaseDataClass:getCurrentIncidentIndex()
	return self.currentIncidentIndex;
end

-- 就是表格数据里的结构
function mainBaseDataClass:getCurrentIncidentInfo()
	return self.currentIncident;
end

-- 对话结束
function mainBaseDataClass:onEndIncidentDialogue()
	if not self.currentIncident then
		return;
	end
	
	if self.currentIncident.stageId > 0 then
		-- 进入战斗准备界面
		
		global.changeGameState(function() 
			eventManager.dispatchEvent({name = global_event.MAIN_UI_CLOSE});
			eventManager.dispatchEvent({name = global_event.INSTANCEINFOR_HIDE});
			game.EnterProcess(game.GAME_STATE_BATTLE_PREPARE, { battleType = enum.BATTLE_TYPE.BATTLE_TYPE_INCIDENT, 
							planType = enum.PLAN_TYPE.PLAN_TYPE_PVE});		
		end);
	else
		-- 直接领奖
		self:claimAward();
		
		layout = layoutManager.getUI("instanceinfor");
		if layout and layout._view then
			layout._view:SetVisible(true);
		end
			
	end
	
end

-- 领奖
function mainBaseDataClass:claimAward()
	eventManager.dispatchEvent({name = global_event.BASEAWARD_SHOW, incidentConfig = self.currentIncident,
							gold = self:getIncidentAwardGold(), wood = self:getIncidentAwardWood(),
							items = self:getIncidentAwardItems() });
							
	self:clearIncidentInfo();
end

-- 
function mainBaseDataClass:getCurrentIncidentStageID()
	
	if self.currentIncident then
		--return self.currentIncident.stageId;
		--print("self.currentIncidentIndex "..self.currentIncidentIndex);
		if self.currentIncident.condition ~= enum.INCIDENT_CONDITION.INCIDENT_CONDITION_INVALID then
			return dataConfig.configs.AdventureConfig[self:getIncidentPosition( self.currentIncidentIndex + 1) + 1].limit[enum.ADVENTURE.ADVENTURE_NORMAL+1].stageID;
		else
			return self.currentIncident.stageId;
		end
	else
		return -1;
	end
	
end

-- 获取当前领地的奖励信息
function mainBaseDataClass:getIncidentAwardGold()
	if self.currentIncident then
		for k,v in ipairs(self.currentIncident.rewardType) do
			if v == enum.REWARD_TYPE.REWARD_TYPE_MONEY and
				self.currentIncident.rewardID[k] == enum.MONEY_TYPE.MONEY_TYPE_GOLD and
				self.currentIncident.rewardCount[k] then
				
				return self.currentIncident.rewardCount[k];
			end
		end
	else
		return 0;
	end
end

function mainBaseDataClass:getIncidentAwardWood()
	if self.currentIncident then
		for k,v in ipairs(self.currentIncident.rewardType) do
			if v == enum.REWARD_TYPE.REWARD_TYPE_MONEY and
				self.currentIncident.rewardID[k] == enum.MONEY_TYPE.MONEY_TYPE_LUMBER and
				self.currentIncident.rewardCount[k] then
				
				return self.currentIncident.rewardCount[k];
			end
		end
	else
		return 0;
	end
end

function mainBaseDataClass:getIncidentAwardItems()
	local itemsAward = {};
	
	if self.currentIncident then
		for k,v in ipairs(self.currentIncident.rewardType) do
			if v == enum.REWARD_TYPE.REWARD_TYPE_ITEM and
				self.currentIncident.rewardID[k] and
				self.currentIncident.rewardCount[k] then
				
				local itemConfigInfo = itemManager.getConfig(self.currentIncident.rewardID[k]);
				if itemConfigInfo then
					local itemInfo = {
						['id'] = self.currentIncident.rewardID[k],
						['icon'] = itemConfigInfo.icon,
						['count'] = self.currentIncident.rewardCount[k],
					};
					
					table.insert(itemsAward, itemInfo);				
				end
			end
		end
	end
	
	return itemsAward;
end

function mainBaseDataClass:setStageWin(win)
	self.win = win;
end

function mainBaseDataClass:isStageWin()
	return self.win;
end

-- 家园场景的提示
function mainBaseDataClass:hasNotifyState()
	local notify = false;
	local incidentCount = self:getLingDiMaxCount();
	for i=1, incidentCount do
		local remainTime = self:getRemineIncidentTime(i);
		local incidentIndex = self:getPlayerIncidentIndex(i);		
		if self:isLingDiActive(i) and (remainTime <= 0 or incidentIndex > 0) then
			notify = true;
			break;
		end
	end
	
	return notify;
end


-- 判断领地事件是否能开战
function mainBaseDataClass:canRunBattle()
	local incidentIndex = self:getCurrentIncidentIndex();
	local incidentInfo = self:getCurrentIncidentInfo();
	
	if incidentInfo == nil then
		return false;
	end
	
	-- 先把所有的config信息都拿出来
	local unitInfoList = {};
	for k, v in pairs(shipData.shiplist) do
		local cardType = PLAN_CONFIG.getShipCardType(k);
		local cardInstance = cardData.getCardInstance(cardType);
		if cardInstance then
			unitInfoList[k] = cardInstance:getConfig();
		end
	end
	
	local conditionParam = 0;
	
	if enum.INCIDENT_CONDITION.INCIDENT_CONDITION_HUMS == incidentInfo.condition then
		
		for k,v in pairs(unitInfoList) do
			
			if v.race == enum.RACE.RACE_HUMAN then
				conditionParam = conditionParam + 1;
			end
		end
		
	elseif enum.INCIDENT_CONDITION.INCIDENT_CONDITION_ORGS == incidentInfo.condition then

		for k,v in pairs(unitInfoList) do
			
			if v.race == enum.RACE.RACE_ORCS then
				conditionParam = conditionParam + 1;
			end
		end
			
	elseif enum.INCIDENT_CONDITION.INCIDENT_CONDITION_NES == incidentInfo.condition then

		for k,v in pairs(unitInfoList) do
			
			if v.race == enum.RACE.RACE_DARK_NIGHT then
				conditionParam = conditionParam + 1;
			end
		end
			
	elseif enum.INCIDENT_CONDITION.INCIDENT_CONDITION_UDS == incidentInfo.condition then

		for k,v in pairs(unitInfoList) do
			
			if v.race == enum.RACE.RACE_UNDEAD then
				conditionParam = conditionParam + 1;
			end
		end
			
	elseif enum.INCIDENT_CONDITION.INCIDENT_CONDITION_REMOTES == incidentInfo.condition then

		for k,v in pairs(unitInfoList) do
			
			if v.isRange == true then
				conditionParam = conditionParam + 1;
			end
		end
			
	elseif enum.INCIDENT_CONDITION.INCIDENT_CONDITION_CLOSE_COMBATS == incidentInfo.condition then

		for k,v in pairs(unitInfoList) do
			
			if v.isRange == false then
				conditionParam = conditionParam + 1;
			end
		end
			
	elseif enum.INCIDENT_CONDITION.INCIDENT_CONDITION_FLYINGS == incidentInfo.condition then

		for k,v in pairs(unitInfoList) do
			
			if v.moveType == enum.MOVE_TYPE.MOVE_TYPE_FLY then
				conditionParam = conditionParam + 1;
			end
		end
			
	elseif enum.INCIDENT_CONDITION.INCIDENT_CONDITION_FEMALE == incidentInfo.condition then

		for k,v in pairs(unitInfoList) do
			
			if v.sex == 0 then
				conditionParam = conditionParam + 1;
			end
		end
			
	elseif enum.INCIDENT_CONDITION.INCIDENT_CONDITION_MAGICIAN == incidentInfo.condition then

		for k,v in pairs(unitInfoList) do
			
			if v.damageType == enum.DAMAGE_TYPE.DAMAGE_TYPE_MAGIC then
				conditionParam = conditionParam + 1;
			end
		end
			
	elseif enum.INCIDENT_CONDITION.INCIDENT_CONDITION_PHYSICS == incidentInfo.condition then

		for k,v in pairs(unitInfoList) do
			
			if v.damageType == enum.DAMAGE_TYPE.DAMAGE_TYPE_PHYSIC then
				conditionParam = conditionParam + 1;
			end
		end
	
	else
		return true;		
	end
	
	print("conditionParam "..conditionParam);
	
	if incidentInfo.compare == enum.INCIDENT_COMPARE.INCIDENT_COMPARE_LARGE then
		
		return conditionParam > incidentInfo.argument;
		
	elseif incidentInfo.compare == enum.INCIDENT_COMPARE.INCIDENT_COMPARE_LARGEEQUAL then
		
		return conditionParam >= incidentInfo.argument;
		
	elseif incidentInfo.compare == enum.INCIDENT_COMPARE.INCIDENT_COMPARE_LESS then
	
		return conditionParam < incidentInfo.argument;
		
	elseif incidentInfo.compare == enum.INCIDENT_COMPARE.INCIDENT_COMPARE_LESSEQUAL then
	
		return conditionParam <= incidentInfo.argument;
		
	elseif incidentInfo.compare == enum.INCIDENT_COMPARE.INCIDENT_COMPARE_EQUAL then
	
		return conditionParam == incidentInfo.argument;
		
	elseif incidentInfo.compare == enum.INCIDENT_COMPARE.INCIDENT_COMPARE_NOTEQUAL then
		
		return conditionParam ~= incidentInfo.argument;
		
	end
	
	
	return true;
end


return mainBaseDataClass
