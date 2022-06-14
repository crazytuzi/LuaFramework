guildWarData = class("guildWarData")

include("guildWarSpot")

function guildWarData:ctor()
	
	self.guildWarSpots = {};

	self.selectSpot = -1;
	self.selectPlayerIndex = -1;

	self.resultType = -1;
	self.battleStep = -1;
		
	self.playerInGuard = {};
	
	self.guildRankInfo = {};
	
end

function guildWarData:destroy()
	
end

-- 设置排行榜的信息
function guildWarData:setRankData(guilds)

	--[[
-- 公会id
	data['id'] = networkengine:parseInt();
-- 公会名称
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['name'] = networkengine:parseString(strlength);
else
		data['name'] = "";
end
-- 会长头像
	data['createrHead'] = networkengine:parseInt();
-- 当前积分
	data['warScore'] = networkengine:parseInt();
	
	--]]
		
	self.guildRankInfo = guilds;
	
end

function guildWarData:getRankData()
	
	return self.guildRankInfo;
	
end

function guildWarData:init()
	
	-- 初始化所有的据点信息
	self.guildWarSpots = {};
	
	for k,v in ipairs(dataConfig.configs.guildWarConfig) do
		
		local spot = guildWarSpot.new(k);
		
		table.insert(self.guildWarSpots, spot);
		
	end
	
end

function guildWarData:setBattleResult(resultType, battleStep)
	
	self.resultType = resultType;
	self.battleStep = battleStep;
	
end

function guildWarData:getBattleResultType()
	
	return self.resultType;
	
end

function guildWarData:getSelectSpotIndex()
	
	return self.selectSpot;
	
end

function guildWarData:getSelectPlayerIndex()
	
	return self.selectPlayerIndex;
	
end

function guildWarData:getSelectSpot()

	return self:getSpot(self:getSelectSpotIndex());
end


function guildWarData:getCurrentSelectTargetInfo()
	
	local spot = self:getSpot(self:getSelectSpotIndex());
	local playerData = spot:getDefencePlayer(self:getSelectPlayerIndex());
	
	return playerData;
	
end

-- 据点的基本信息
function guildWarData:initSpotInfoFromServerData(postsInfo)
	
	for k,v in ipairs(postsInfo) do
		
		local spot = self:getSpot(k);
		spot:setSpotBasicInfo(v);
		
	end
	
end

-- 设置防守中的玩家数据
function guildWarData:setPlayerInGuard(players)
	
	self.playerInGuard = clone(players);
	
end

function guildWarData:isPlayerInGuard(id)
	
	for k,v in pairs(self.playerInGuard) do
		
		if id == v then
			return true;
		end
		
	end
	
	return false;
		
end


-- 获取据点 index from 1 start
function guildWarData:getSpot(index)
	
	return self.guildWarSpots[index];
	
end

-- 玩家自己是否可以开战, 加入公会24小时以上
function guildWarData:canJoinGuildWar()
	
	local myGuildData = dataManager.guildData:getPlayerByID(dataManager.playerData:getPlayerId());
	
	return myGuildData and myGuildData:canJoinGuildWar();
	
end

-- 是否在开放时段
function guildWarData:isOpen()
	
	return global.isInTimeLimit(dataConfig.configs.ConfigConfig[0].guildWarBegin, dataConfig.configs.ConfigConfig[0].guildWarFinish);
	
end

-- 是否达到开服天数
function guildWarData:isActive()
	
	return dataManager.getServerOpenDay() + 1 >= dataConfig.configs.ConfigConfig[0].guildWarOpenDays;
	
end


-- 获取剩余挑战次数
function guildWarData:getRemainBattleTimes()
	
	return self:getMaxBattleTimes() - dataManager.playerData:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_GUILD_WAR_FIGHT_COUNT);
	
end

-- 获取最大挑战次数
function guildWarData:getMaxBattleTimes()
	
	return dataConfig.configs.ConfigConfig[0].guildMaxFightCount;
	
end

-- 获取当前的进攻buff
function guildWarData:getNowAttackBuffCount()
	
	return dataManager.playerData:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_GUILD_WAR_INSPIRE_COUNT);
	
end

-- 获取每次购买进攻buff的军团增加的数量百分比
function guildWarData:getAttackBuffBuyUnitCountPercent()
	
	--return string.format("%.0f%%", dataConfig.configs.ConfigConfig[0].guildWarBuffAtk * 0.01);
	
	return dataConfig.configs.ConfigConfig[0].guildWarBuffAtk * 0.01;
	
end

function guildWarData:getDenfenceBuffBuyUnitCountPercent()
	
	--return string.format("%.0f%%", dataConfig.configs.ConfigConfig[0].guildWarBuffDef * 0.01);
	
	return dataConfig.configs.ConfigConfig[0].guildWarBuffAtk * 0.01;
	
end

-- 获得当前进攻军团百分比
function guildWarData:getNowAttackUnitPercent()
	
	return self:getNowAttackBuffCount() * self:getAttackBuffBuyUnitCountPercent();
	
end

function guildWarData:getMaxInspireTime()
	
	return dataConfig.configs.ConfigConfig[0].guildWarInspireTime;
	
end

function guildWarData:getRewardInfo()

	local t ={};
	local index = 0;
	
	for k, reward in ipairs (dataConfig.configs.guildWarRankConfig)do
		index = index +1
		t[index] = t[index]  or {}
		t[index].rank = reward.rank
		for i,v in ipairs 	(reward.rewardType) do
			table.insert(t[index] ,dataManager.playerData:getRewardInfo(v, reward.rewardID[i], reward.rewardCount[i]))
		end
	end
	
	return t;
	
end

-- user inter face --------------------------------------------
-- 从入口进入公会战地图
function guildWarData:onHandleEnterGuildWarMap()
	
	if not self:isActive() then

		eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
			messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
			textInfo ="公会战未开启" });
					
		return;
	end
	
	eventManager.dispatchEvent({name = global_event.GUILDWAR_SHOW});
	sendAskGuildWarInfo();
	
	if not self:isOpen() and dataManager.guildData:isCanEditDefencePlan() then
		
		sendAskGuildWarPlans(0);
		
	end
	
end

-- 点击具体的某个据点
function guildWarData:onHandleClickSpot(spotIndex)
	
	local spot = self:getSpot(spotIndex);
	if not spot:isCanAttack() and not spot:isMy() then

		eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
			messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
			textInfo ="该战区刚刚被攻占，正处于休战中" });
					
		return;
	end
	
	eventManager.dispatchEvent({name = global_event.GUILDWARINFO_SHOW, spotIndex = spotIndex });
	sendAskGuildWarPost(spotIndex-1);
	
end

-- 点击进攻，进入具体的守军信息
function guildWarData:onHandleClickAttackAskDefenceInfo(spotIndex)
	
	local spot = self:getSpot(spotIndex);
	if spot:isMy() then
		return;
	end
	
	eventManager.dispatchEvent({name = global_event.GUILDWARLIST_SHOW, spotIndex = spotIndex, showType = "attack" });
	
end

-- 点击布阵
function guildWarData:onHandleClickEditDefence(spotIndex)
	
	eventManager.dispatchEvent({name = global_event.GUILDWARLIST_SHOW, spotIndex = spotIndex, showType = "edit" });
	
end

-- 查看布阵
function guildWarData:onHandleClickCheckDefence(spotIndex)
	
	eventManager.dispatchEvent({name = global_event.GUILDWARLIST_SHOW, spotIndex = spotIndex, showType = "check" });
	
end

-- 鼓舞
function guildWarData:onHandleClickInspire(spotIndex)
	
	-- 如果是会长，并且是自己据点，是防守鼓舞
	
	-- 其他的是进攻鼓舞
	local spot = self:getSpot(spotIndex);
	if dataManager.guildData:isMyselfPrecident() and spot:isMy() then
		sendGuildWarInspire(1, spotIndex-1);
	else
		sendGuildWarInspire(0, spotIndex-1);
	end
	
end


-- 点击具体的守军开战
function guildWarData:onHandleClickDefencePlayer(spotIndex, playerIndex)
	
	local spot = self:getSpot(spotIndex);
	
	if spot:isFighting(playerIndex) then
		
		eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
			messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
			textInfo ="该守军正在和其他玩家交战" });
					
		return;
	end
	
	-- 检查能否开战
	if not self:canJoinGuildWar() then

		eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
			messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
			textInfo ="加入公会24小时以上才能参加公会战" });
					
		return;
		
	end
	
	-- 检查次数
	if self:getRemainBattleTimes() <= 0 then
		
		-- 次数不够
		eventManager.dispatchEvent({name = global_event.BUYRESOURCE_SHOW, source = "userclick", 
						resType = enum.BUY_RESOURCE_TYPE.GUILD_WAR_BATTLE,});		
		
		return;
	end
	
	self.selectSpot = spotIndex;
	self.selectPlayerIndex = playerIndex;
	
	global.changeGameState(function()
	
		sceneManager.closeScene();
		eventManager.dispatchEvent({name = global_event.MAIN_UI_CLOSE});
		eventManager.dispatchEvent({name = global_event.GUILDCREATE_HIDE});
		eventManager.dispatchEvent({name = global_event.GUILDWAR_HIDE});
		eventManager.dispatchEvent({name = global_event.GUILDWARINFO_HIDE});
		eventManager.dispatchEvent({name = global_event.GUILDWARLIST_HIDE});
		
		game.EnterProcess(game.GAME_STATE_BATTLE_PREPARE, { battleType = enum.BATTLE_TYPE.BATTLE_TYPE_GUILDWAR, 
				planType = enum.PLAN_TYPE.PLAN_TYPE_PVE });			
	end);
				
end

-- 结算界面点击返回
function guildWarData:onBattleOverBackToMain()
	
	sceneManager.battlePlayer():QuitBattle();
	
	
end

--编辑防守阵容
function guildWarData:onGuildPlanEditAdd(spotIndex, playerID)
	
	sendGuildWarPlan(spotIndex-1, playerID, 1);
	
end

function guildWarData:onGuildPlanEditRemove(spotIndex, playerID)
	
	sendGuildWarPlan(spotIndex-1, playerID, 0);
	
end
