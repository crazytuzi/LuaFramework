idolBuildData = class("idolBuildData")

function idolBuildData:ctor()
	
	self.primalCount = {};
	
	self.primalCount[enum.PRIMAL_TYPE.PRIMAL_TYPE_PRIMAL_LIFE] = 0;
	self.primalCount[enum.PRIMAL_TYPE.PRIMAL_TYPE_PRIMAL_MANA] = 0;
	self.primalCount[enum.PRIMAL_TYPE.PRIMAL_TYPE_PRIMAL_FIRE] = 0;
	self.primalCount[enum.PRIMAL_TYPE.PRIMAL_TYPE_PRIMAL_VOID] = 0;

	self.plunderTargets = {};
	
	self.revengeSummary = {};
	
	self.lastReadRevengeTime = 0;
	
end

function idolBuildData:destroy()
	
end

function idolBuildData:init()
	
end

function idolBuildData:getLevel()

	return dataManager.playerData:getPlayerAttr(enum.PLAYER_ATTR.PLAYER_ATTR_IDOL);
	
end

-- 建筑是否满级
function idolBuildData:isMaxLevel()
	
	return self:getLevel() >= dataConfig.configs.ConfigConfig[0].idolMaxLevel;
	
end

-- 得到表格数据
function idolBuildData:getConfig(level)
	
	local buildLevel = level or self:getLevel();
	
	return dataConfig.configs.idolStatueConfig[buildLevel];
	
end

-- 设置资源数量
function idolBuildData:setPrimalItemCount(primalType, count)
	
	local oldCount = self.primalCount[primalType];
	local changeCount = count - oldCount;
	
	local itemInfo = self:getPrimalItemInfo(primalType);
	if changeCount > 0 then
		-- 新获得提示
		local text = "^FFFF00获得材料[^FFFFFF"..itemInfo.name.."^FFFF00] X"..changeCount;
		eventManager.dispatchEvent({name =  global_event.WARNINGHINT_SHOW,tip =  text ,RESGET = true})
	end
	
	self.primalCount[primalType] = count;
	
end

-- 得到玩家当前的4个资源数量
function idolBuildData:getPrimalItemCount(primalType)
	
	return self.primalCount[primalType];
	
end

-- 抢夺的备选玩家的列表, 每次抢夺的时候向服务器获取
function idolBuildData:getPlunderTargets()
	
	return self.plunderTargets;
	
end

-- 
function idolBuildData:setPlunderTargets(plunderTargets)
	
	self.plunderTargets = clone(plunderTargets);
	
	-- 设置难度
	for k, v in ipairs(self.plunderTargets) do
		
		v.difficulty = k-1;
		
	end
	
end

-- 获取剩余抢夺次数
function idolBuildData:getReminePlunderTimes()
	
	local plunderTimes = dataManager.playerData:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_PLUNDER_TIMES);
	
	return self:getMaxPlunderTimes() - plunderTimes;
	
end

-- 获取最大抢夺次数
function idolBuildData:getMaxPlunderTimes()

	return dataConfig.configs.ConfigConfig[0].plunderTimes;
	
end

-- 获取下次重置抢夺次数的时间
function idolBuildData:getNextRefreshPlunderTimesTime()

		 local t = 	dataConfig.configs.ConfigConfig[0].pvpOfflineRefleshTimes

		 local h, m, s = dataManager.getLocalTime();
		 local nowSecondAfterZeroClock = h * 60 * 60 + m * 60 + s;
		 
		 local newConfig = {};
		 table.insert(newConfig, dataConfig.configs.ConfigConfig[0].playerRefleshTime);
		 
		 for k, v in ipairs(t) do
		 	table.insert(newConfig, v);
		 end
		 
		 local resultKey = -1;
		 for k, v in ipairs(newConfig) do
		 	
		 	local hour, minute = stringToTime(v);
		 	local secondAfterZeroClock = hour * 60 * 60 + minute * 60;
		 	
		 	if nowSecondAfterZeroClock < secondAfterZeroClock then
		 		resultKey = k;
		 		break;
		 	end
		 	
		 end
		 
		 if resultKey == -1 then
		 	resultKey = 1;
		 end
		 
		 return newConfig[resultKey];
		 	
end

-- 活动被抢夺的保护时间
function idolBuildData:getRemainProtectTime()
	
	local plunderTime = dataManager.playerData:getTimeAttr(enum.PLAYER_ATTR64.PLAYER_ATTR64_PLUNDER_TIME);
	
	local remainTime = plunderTime - dataManager.getServerTime();
	
	if remainTime < 0 then
		remainTime = 0;
	end
	
	return remainTime;
end


-- 点击抢夺,清理本地的
function idolBuildData:onClickPlunder(primalType)
	
	-- check times
	-- 不够的话弹出购买界面
	if self:getReminePlunderTimes() <= 0 then
		
		eventManager.dispatchEvent({name = global_event.BUYRESOURCE_SHOW, source = "userclick", 
						resType = enum.BUY_RESOURCE_TYPE.PLUNDER_TIMES,});
									
		return;
	end
	
	-- check protect time
	-- 如果在保护时间内，提示“发起抢夺会使您脱离保护状态，是否继续？”
	if self:getRemainProtectTime() > 0 then
		
		eventManager.dispatchEvent( {name = global_event.CONFIRM_SHOW, callBack = function() 
			-- callback
			self:onClickPlunderConfirm(primalType);
			
		end,text = "发起抢夺会使您脱离保护状态，是否继续？" });
		
		return;	
	end
		
	self:onClickPlunderConfirm(primalType);
	
end

-- 获取抢夺时候的资源类型
function idolBuildData:getPlunderType()
	
	return self.clickPlunderType;
	
end

function idolBuildData:onClickPlunderConfirm(primalType)
	
	-- 请求之前先清理数据
	self:onClearClickPlunderType();
	
	sendAskPlunderTarget(primalType);
	
	self.clickPlunderType = primalType;
	
end

-- 点击换一批
function idolBuildData:onClickRefeshPlunder()
	
	-- 点击换一批
	if self.clickPlunderType then
		sendAskPlunderTarget(self.clickPlunderType);
	end
	
end

-- 清理上次的点击类型
function idolBuildData:onClearClickPlunderType()
	
	self.clickPlunderType = nil;
	
	self.plunderTargets = {};
		
end

-- 得到当前选中的敌方的信息
function idolBuildData:getCurrentSelectTargetInfo()
	return self.selectTargetInfo;
end

function idolBuildData:setCurrentSelectTargetInfo(targetInfo)

	self.selectTargetInfo = targetInfo;
	
end

------------------复仇相关---------------------
-- 
function idolBuildData:updateRevengeSummary(revengers)
	
	--[==[
	[[
		-- 数据库ID
			data['dbid'] = networkengine:parseInt();
		-- 是否异步
			data['async'] = networkengine:parseBool();
		-- 仇家id
			data['enemyID'] = networkengine:parseInt();
		-- 仇家名
			local strlength = networkengine:parseInt();
		if strlength > 0 then
				data['enemyName'] = networkengine:parseString(strlength);
		else
				data['enemyName'] = "";
		end
		-- 仇家等级
			data['enemyLevel'] = networkengine:parseInt();
		-- 仇家战力
			data['enemyPwoer'] = networkengine:parseInt();
		-- 仇家图标
			data['enemyIcon'] = networkengine:parseInt();
		-- 被抢的资源类型
			data['primalType'] = networkengine:parseInt();
		-- 抢劫发生的时间
			data['time'] = networkengine:parseUInt64();
		-- 是否新事件
			data['isNew'] = networkengine:parseBool();	
	]]
	--]==]
	
	-- 第一次登陆会发
	-- 变化了也会更新
		
	self.revengeSummary = clone(revengers);
	
	table.sort(self.revengeSummary, function(a, b)
		
		return a.time:GetUInt() > b.time:GetUInt();
		
	end);
end
	
-- 获取复仇的列表信息
function idolBuildData:getRevengeSummary()
	
	return self.revengeSummary;
	
end

-- 设置上次看复仇列表的时间
function idolBuildData:setLastReadRevengeTime(time)
	
	self.lastReadRevengeTime = time;
	
	fio.writeIni("idol", "lastReadRevengeTime", tostring(self.lastReadRevengeTime), global.getUserConfigFileName());
	
end

-- 
function idolBuildData:isNeedRevenge()
	
	
	for k,v in ipairs(self.revengeSummary) do
		if v.time:GetUInt() >= self.lastReadRevengeTime then
			return true;
		end
	end
	
	return false;
	
end

-- 设置成已读
function idolBuildData:setRevengeReaded()
	
	self:setLastReadRevengeTime(dataManager.getServerTime());
			
end

-- 是否可以升级和未读的复仇信息
function idolBuildData:hasNotifyState()
	
	return self:idCanLevelup() or self:isNeedRevenge();
	
end

-- 点击复仇
function idolBuildData:onClickRevenge(dbid)

	-- check times
	-- 不够的话弹出购买界面
	if self:getReminePlunderTimes() <= 0 then
		
		eventManager.dispatchEvent({name = global_event.BUYRESOURCE_SHOW, source = "userclick", 
						resType = enum.BUY_RESOURCE_TYPE.PLUNDER_TIMES,});
									
		return;
	end
	
	-- check protect time
	-- 如果在保护时间内，提示“发起抢夺会使您脱离保护状态，是否继续？”
	if self:getRemainProtectTime() > 0 then
		
		eventManager.dispatchEvent( {name = global_event.CONFIRM_SHOW, callBack = function() 
			
			-- callback
			self:onClickRevengeConfirm(dbid);
			
		end,text = "发起抢夺会使您脱离保护状态，是否继续？" });
		
		return;
	end
		
	self:onClickRevengeConfirm(dbid);
	
end

function idolBuildData:onClickRevengeConfirm(dbid)
	
	self:onClearClickPlunderType();
	
	self.selectTargetInfo = {};
	self.selectTargetInfo.dbid = dbid;
	
	sendAskRevengeTarget(dbid);
		
end

-- 真正的复仇开战
function idolBuildData:onRevengeEnterBattlePrepare(primalType)
		
	self.selectTargetInfo.primalType = primalType;
	
	global.changeGameState(function() 		
		
		sceneManager.closeScene();
		
		eventManager.dispatchEvent({name = global_event.IDOLSTATUSROB_HIDE});
		eventManager.dispatchEvent({name = global_event.IDOLSTATUS_HIDE});
		eventManager.dispatchEvent({name = global_event.REVENGEPLUNDERLIST_HIDE});
		eventManager.dispatchEvent({name = global_event.ROBREVENGECHOICE_HIDE});
		
		game.EnterProcess(game.GAME_STATE_BATTLE_PREPARE, { battleType = enum.BATTLE_TYPE.BATTLE_TYPE_REVENGE, 
				planType = enum.PLAN_TYPE.PLAN_TYPE_PVE });
				
	end);
		
end

-- check protect time
function idolBuildData:checkPlunderProtectTime()
	
	--[[
	local targetInfo = self:getCurrentSelectTargetInfo();
	-- check protect time
	local remainProtectTime = targetInfo.plunderTime:GetUInt() - dataManager.getServerTime();
	if remainProtectTime > 0 then
		
		eventManager.dispatchEvent({name = global_event.TIP_INFO_SHOW,tip = "该玩家正在保护时间内，无法抢夺"});
		return false;
	end
	--]]
	
	return true;
end

function idolBuildData:checkPlunderItems()
	
	--[[
	local targetInfo = self:getCurrentSelectTargetInfo();
	-- check item
	if self.clickPlunderType and targetInfo.primals[self.clickPlunderType+1] <= 0 then
		
		eventManager.dispatchEvent({name = global_event.TIP_INFO_SHOW,tip = "该玩家目前没有可抢夺的物品"});
		return false;
	end
	--]]
	
	return true;
end

-- 进入掠夺的战斗准备界面
function idolBuildData:onEnterBattlePrepare(difficulty)
		
	local targetInfo = nil;
	for k,v in ipairs(self.plunderTargets) do
		if v.difficulty == difficulty then
			targetInfo = clone(v);
			break;		
		end
	end
	
	self:setCurrentSelectTargetInfo(targetInfo);
	
	-- check protect time
	if not self:checkPlunderProtectTime() then
		return;
	end
	
	-- check item
	if not self:checkPlunderItems() then
		return;
	end
	
	global.changeGameState(function() 		
		
		sceneManager.closeScene();
		
		eventManager.dispatchEvent({name = global_event.IDOLSTATUSROB_HIDE});
		eventManager.dispatchEvent({name = global_event.IDOLSTATUS_HIDE});

		
		game.EnterProcess(game.GAME_STATE_BATTLE_PREPARE, { battleType = enum.BATTLE_TYPE.BATTLE_TYPE_PLUNDER, 
				planType = enum.PLAN_TYPE.PLAN_TYPE_PVE });
				
	end);
			
end

-- 设置奖励信息
function idolBuildData:setRewardInfo(rewardInfo)
	
	self.rewardInfo = clone(rewardInfo);
	
end

-- 清楚奖励信息
function idolBuildData:clearRewardInfo()
	
	self.rewardInfo = nil;
	
end

-- 获取物品信息
function idolBuildData:getPrimalItemInfo(primalType)
	
	local id = primalType + 1;
	
	return dataConfig.configs.itemPrimalInfoConfig[id];

end

-- 获取item信息
function idolBuildData:getRewardPrimalItem()

	if self.rewardInfo then
		
		for k,v in pairs(self.rewardInfo) do
			
			if v.type == enum.REWARD_TYPE.REWARD_TYPE_PRIMAL and v.count > 0 then
				return self:getPrimalItemInfo(v.id);
			end
		end
		
	end
	
	return nil;
end

-- 金币信息
function idolBuildData:getRewardGold()

	if self.rewardInfo then
		
		for k,v in pairs(self.rewardInfo) do
			
			if v.type == enum.REWARD_TYPE.REWARD_TYPE_MONEY and v.count > 0 and v.id == enum.MONEY_TYPE.MONEY_TYPE_GOLD then
				return v.count;
			end
		end
		
	end
	
	return 0;	
end

-- 荣誉信息
function idolBuildData:getRewardHonor()

	if self.rewardInfo then
		
		for k,v in pairs(self.rewardInfo) do
			
			if v.type == enum.REWARD_TYPE.REWARD_TYPE_MONEY and v.count > 0 and v.id == enum.MONEY_TYPE.MONEY_TYPE_HONOR then
				return v.count;
			end
		end
		
	end
	
	return 0;	
end


-- rob success get item
function idolBuildData:isRobItemSuccess()
	
	if self.rewardInfo then
		
		for k,v in pairs(self.rewardInfo) do
			
			if v.type == enum.REWARD_TYPE.REWARD_TYPE_PRIMAL and v.count > 0 then
				return true;
			end
		end
		
	end
	
	return false;
end

-- 开战的处理
function idolBuildData:onRunBattle()
	
	-- check protect time
	if not self:checkPlunderProtectTime() then
		return false;
	end
	
	-- check item
	if not self:checkPlunderItems() then
		return false;
	end
	
	return true;
end

-- 升级的处理
function idolBuildData:onClickEnterIdolLevelup()
	
	if self:isMaxLevel() then
	
		eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
			messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
			textInfo = "您的神像已经满级，真不可思议......" });
		return
		
	end
	
	eventManager.dispatchEvent({name = global_event.IDOLSTATUS_ONENTER_LEVEL_UP});
	eventManager.dispatchEvent({name = global_event.IDOLSTATUSLEVELUP_SHOW});
	
end

-- 确认升级
function idolBuildData:onClickLevelupConfirm()
	
	--触发引导
	eventManager.dispatchEvent({name = global_event.GUIDE_ON_IDOLSTATUSLEVELUP_LEVELUP}) 
	--
	
	if self:isMaxLevel() then
	
		eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
			messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
			textInfo = "您的神像已经满级，真不可思议......" });
		return
		
	end
	
	-- check item
	if not self:isEnoughItem() then
		
		eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
			messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
			textInfo = "升级材料不足" });
					
		return;
	end
	
	if not self:isEnoughGold() then
		eventManager.dispatchEvent({name = global_event.BUYRESOURCE_SHOW, source = "lackofresource", resType = enum.BUY_RESOURCE_TYPE.GOLD, copyType = -1, copyID = -1, });
		return;
	end
	
	if not self:isEnoughWood() then
		eventManager.dispatchEvent({name = global_event.BUYRESOURCE_SHOW, source = "lackofresource", resType = enum.BUY_RESOURCE_TYPE.WOOD, copyType = -1, copyID = -1, });
		return;
	end
	
	sendUpgradeIdol();
end

function idolBuildData:isEnoughItem()
	
	local idolConfig = self:getConfig();
	
	for i=1, 4 do

		local itemCount = self:getPrimalItemCount(i-1);
		local needCount = idolConfig.retuireItemCount;
		
		if itemCount < needCount then
			return false;
		end
		
	end
	
	return true;
end

function idolBuildData:isEnoughGold()
	
	local idolConfig = self:getConfig();
	local gold = dataManager.playerData:getGold();
	
	return gold >= idolConfig.goldCost;
end

function idolBuildData:isEnoughWood()

	local idolConfig = self:getConfig();
	local wood = dataManager.playerData:getWood();
	
	return wood >= idolConfig.lumberCost;
	
end

-- 是否可以升级
function idolBuildData:idCanLevelup()
	
	return not self:isMaxLevel() and self:isEnoughItem() and self:isEnoughGold() and self:isEnoughWood();
	
end
