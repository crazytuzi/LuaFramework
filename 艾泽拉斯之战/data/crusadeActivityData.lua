crusadeActivityData = class("crusadeActivityData")

function crusadeActivityData:ctor()
	
end

function crusadeActivityData:destroy()
	
end

function crusadeActivityData:init()
	
	-- back up stage config info
	self.backupStageConfig = {};	
	local stageCount = #dataConfig.configs.crusadeLevelConfig;
	
	for i=1, stageCount do
		
		-- 由于其他地方引用的都是stageConfig中的信息, 
		-- 所以这里奖励，和阵容信息都是直接修改config里的
		-- 那么初始化的时候需要把默认的内容保存下来
		local stageID = dataConfig.configs.crusadeLevelConfig[i].crusadeStage;
		local stageInfo = clone(dataConfig.configs.stageConfig[stageID]);
		
		table.insert(self.backupStageConfig, stageInfo);
	end
	
end

function crusadeActivityData:getStageDefaultConfig(index)
	
	return self.backupStageConfig[index];
	
end

-- 得到当前关卡索引，1开始
function crusadeActivityData:getCurrentStageIndex()
	return dataManager.playerData:getPlayerAttr(enum.PLAYER_ATTR.PLAYER_ATTR_CRUSADE_PROGRESS) + 2;
end

function crusadeActivityData:getCurrentStageID()
	
	return dataConfig.configs.crusadeLevelConfig[self:getCurrentStageIndex()].crusadeStage;
	
end

-- 更新关卡信息, 从服务器消息
function crusadeActivityData:updateStageInfo(stageIndex)
	
	local stageID = dataConfig.configs.crusadeLevelConfig[stageIndex].crusadeStage;
	local stageInfo = dataConfig.configs.stageConfig[stageID];
	
	-- 用服务器数据更新表格数据
	
end


-- ui 相关接口
function crusadeActivityData:isStageCanBattle(stageIndex)
	
	return self:getCurrentStageIndex() == stageIndex;
	
end

function crusadeActivityData:isStageFinish(stageIndex)
	
	return stageIndex < self:getCurrentStageIndex();

end

function crusadeActivityData:isStageNotActive(stageIndex)

	return stageIndex > self:getCurrentStageIndex();
	
end

-- 完成了所有的关卡
function crusadeActivityData:isStageOver()

	return self:getCurrentStageIndex() > #dataConfig.configs.crusadeLevelConfig;
	
end

-- 获取显示信息
function crusadeActivityData:getStageInfo(stageIndex)
	
	local stageID = dataConfig.configs.crusadeLevelConfig[stageIndex].crusadeStage;
	local stageInfo = dataConfig.configs.stageConfig[stageID];
	
	return stageInfo;
	
end

function crusadeActivityData:getStageKingFigureImage(stageIndex)

	local imagelist = {
		[1] = "rolebig6.png";
		[2] = "rolebig14.png";
		[3] = "rolebig3.png";
		[4] = "rolebig1.png";
		[5] = "rolebig2.png";
		[6] = "rolebig7.png";
		[7] = "rolebig18.png";
		[8] = "rolebig5.png";
	};
	
	return imagelist[stageIndex];
end

function crusadeActivityData:getStageName(stageIndex)

	local namelist = {
		[1] = "先遣营地";
		[2] = "缝合场";
		[3] = "尤顿海姆";
		[4] = "暗影穹顶";
		[5] = "钢铁车间";
		[6] = "瘟疫实验室";
		[7] = "冰龙巢穴";
		[8] = "寒冰王座";
	};
	
	return namelist[stageIndex];
end

function crusadeActivityData:getStageNPCName(stageIndex)

	local namelist = {
		[1] = "瓦里安";
		[2] = "萨尔";
		[3] = "戴林";
		[4] = "达里安";
		[5] = "迦罗娜";
		[6] = "希尔瓦娜斯";
		[7] = "乌瑟尔";
		[8] = "弗丁";
	};
	
	return namelist[stageIndex];
end

-- 
function crusadeActivityData:setStageInfo(stageIndex, units, kingInfo)
	
	local stageInfo = self:getStageInfo(stageIndex);
	
	local shipAttrBase = {};
	local unitsID = {};
	local unitCount = {};
	local positionsX = {};
	local positionsY = {};
	local magics = {};
	local magicLevels = {};
	local intelligence = kingInfo.intelligence;
	local heroLevel = kingInfo.level;
	local mp = kingInfo.maxMP;
	
	for k,v in ipairs(units) do
		shipAttrBase[k] = clone(v.shipAttr);
		unitsID[k] = v.id;
		unitCount[k] = v.count;
		positionsX[k] = v.position.x;
		positionsY[k] = v.position.y;
		
	end
	
	for k,v in ipairs(kingInfo.magics) do
		magics[k] = v.id;
		magicLevels[k] = v.level;
	end
	
	stageInfo.shipAttrBase = shipAttrBase;
	stageInfo.units = unitsID;
	stageInfo.unitCount = unitCount;
	stageInfo.positionsX = positionsX;
	stageInfo.positionsY = positionsY;
	stageInfo.magics = magics;
	stageInfo.magicLevels = magicLevels;
	stageInfo.intelligence = intelligence;
	stageInfo.heroLevel = heroLevel;
	stageInfo.mp = mp;
	
	--dump(stageInfo);
end

-- 设置远征活动的奖励信息
function crusadeActivityData:setRewardInfo(stageIndex, rewardsInfo)
	
	local stageInfo = self:getStageInfo(stageIndex);
	
	stageInfo.rewardType = {};
	stageInfo.rewardID = {};
	stageInfo.rewardCount = {};
	
	if rewardsInfo then

		for k,v in ipairs(rewardsInfo) do
			
			table.insert(stageInfo.rewardType, v.rewardType);
			table.insert(stageInfo.rewardID, v.rewardID);
			table.insert(stageInfo.rewardCount, v.rewardCount);
			
		end
	
	end
	
	-- 加上物品的奖励，从表格读取
	local rewardsType = dataConfig.configs.ConfigConfig[0].crusadeExtraRewardType;
	local rewardsID = dataConfig.configs.ConfigConfig[0].crusadeExtraRewardID;
	local rewardsCount = dataConfig.configs.ConfigConfig[0].crusadeExtraRewardCount;
	
	for k,v in ipairs(rewardsType) do
		
			table.insert(stageInfo.rewardType, v);
			table.insert(stageInfo.rewardID, rewardsID[k]);
			table.insert(stageInfo.rewardCount, rewardsCount[k]);
					
	end
	
end
