--[[
日环任务vo
2014年12月9日11:16:47
郝户
]]

_G.QuestLieMoVO = setmetatable({}, { __index = QuestVO });

QuestLieMoVO.starLvl = nil; -- 星级
QuestLieMoVO.round = nil; -- 环数
QuestLieMoVO.multiple = nil; -- 奖励暴击(倍率)
QuestLieMoVO.teleportConfirmUID = nil; -- 传送确认

function QuestLieMoVO:OnAdded()
	if self:GetRound() <= QuestLieMoConsts:GetLieMoDayNum() then
		QuestModel:SetLMState(QuestLieMoConsts.QuestLieMoStateGoing);
	end
	--	QuestDayFlow:OnNewDailyQuestRsv(self);
end

function QuestLieMoVO:OnFinished()
	if self:GetRound() == QuestLieMoConsts:GetLieMoDayNum() then
		--		UIQuestDayMultipleOption:Hide()
		QuestGuideManager:OnLieMoFinish()
	end
end

--- [[ 去掉日环传送提醒后版本
function QuestLieMoVO:OnContentClick()
	--	UIQuestDayGuide:Hide()
	local state = self:GetState()
	if state == QuestConsts.State_Going then
		self:ToTargetPos(false);
		return
	end
	self:Proceed()
end

function QuestLieMoVO:ToTargetPos(isTeleport)
	if isTeleport then
		if self:GetState() ~= QuestConsts.State_Going then
			return;
		end
		--传送
		local fee, itemId, freeVip = MapConsts:GetTeleportCostInfo()

		-- 判断免费使用的vip等级, 满足直接传
		if freeVip and freeVip == 1 then
			self:Teleport()
			return
		end
		-- 次数不足，步行
		if MapModel:GetFreeTeleportTime() <= 0 then
			self:DoGoal()
			return
		end
		-- 在附近，步行
		if self:IsNearby() then
			self:DoGoal()
			return
		end
		self:Teleport();
	else
		--使用步行
		self:DoGoal()
	end
end


function QuestLieMoVO:IsNearby()
	local point = self:GetTeleportPos()
	if not point then
		return;
	end
	return MapController:IsNearby(point.mapId, point.x, point.y)
end

-- 去掉日环传送提醒前版本
--[[  去掉日环传送提醒 2015年8月13日16:10:46
function QuestLieMoVO:OnContentClick()
	local state = self:GetState()
	if state == QuestConsts.State_Going then
		local teleportDoGoal = function(selected)
			self:Teleport()
			self.teleportConfirmUID = nil
			self:StopTeleportTimer()
			if type(selected) == "boolean" then
				QuestModel.noDqTeleportComfirm = selected;
			end
		end
		local runDoGoal = function()
			self:DoGoal()
			self.teleportConfirmUID = nil
			self:StopTeleportTimer()
		end
		local fee, itemId, freeVip = MapConsts:GetTeleportCostInfo()
		-- 判断免费使用的vip等级
		if MainPlayerModel.humanDetailInfo.eaVIPLevel >= freeVip then
			teleportDoGoal()
			return
		end
		if MapModel:GetFreeTeleportTime() <= 0 then
			runDoGoal()
			return
		end
		-- 在附近
		if self:IsNearby() then
			runDoGoal()
			return
		end
		-- 设置了不提醒
		if QuestModel.noDqTeleportComfirm then
			teleportDoGoal()
			return
		end
		self:OpenTeleportConfirm( teleportDoGoal, runDoGoal )
		return
	end
	self:Proceed()
end

function QuestLieMoVO:OpenTeleportConfirm( confirmFunc, cancelFunc )
	-- 已打开状态
	self:CloseTeleportConfirm()
	local content = string.format( StrConfig['quest802'], MapModel:GetFreeTeleportTime() )
	self.teleportConfirmUID = UIConfirmWithNoTip:Open( content, confirmFunc, cancelFunc,
		StrConfig['quest803'], StrConfig['quest804'], nil, true )
	self:StartTeleportTimer( cancelFunc )
end

function QuestLieMoVO:CloseTeleportConfirm()
	if self.teleportConfirmUID then
		UIConfirmWithNoTip:Close( self.teleportConfirmUID )
		self.teleportConfirmUID = nil
		self:StopTeleportTimer()
	end
end

function QuestLieMoVO:StartTeleportTimer(cb)
	if self.teleportTimerKey then return end
	self.teleportTimerKey = TimerManager:RegisterTimer( cb, 15000, 1)
end

function QuestLieMoVO:StopTeleportTimer()
	if self.teleportTimerKey then
		TimerManager:UnRegisterTimer(self.teleportTimerKey)
		self.teleportTimerKey = nil
	end
end
--]]


-- 任务星级
function QuestLieMoVO:GetStarLvl()
	return self.starLvl;
end

-- 升满星(5)
function QuestLieMoVO:FullStar()
	self.starLvl = QuestConsts.QuestDailyMaxStar
end

-- 任务环数
function QuestLieMoVO:GetRound()
	return self.round;
end

function QuestLieMoVO:IsNeedStarPrompt()
	local myLevel = MainPlayerModel.humanDetailInfo.eaLevel
	local inRightLevel = QuestConsts:GetTrunkBreakLevel() <= myLevel and myLevel < QuestConsts.AutoLevel
	return inRightLevel and self.starLvl < QuestConsts.QuestDailyMaxStar
end

-- 任务奖励暴击
function QuestLieMoVO:GetMultiple()
	return self.multiple;
end

-- 是否抽奖
function QuestLieMoVO:DrawWhenEnd()
	--	for _, round in pairs( QuestConsts.QuestDailyDrawRounds ) do
	--		if round == self.round then
	--			return true;
	--		end
	--	end
	return false;
end

-- 日环单环奖励
function QuestLieMoVO:GetRewards()
	local questId = self:GetId();
	--	local star = self:GetStarLvl();
	local star = 1;
	if star < 1 or star > QuestConsts.QuestDailyMaxStar then
		Error("dailyquest star error")
		return {};
	end
	local cfg = self:GetCfg();
	if not cfg then return end
	local starAddition = 1 + cfg["additionStar" .. star] / 100;
	if not starAddition then
		Error("additionStar" .. star .. "word is expected in config table 't_dailyquest', quest id:" .. questId);
		return
	end
	local rewardToInt = function(num)
		return toint(num, 0.5);
	end
	local rewardExp = rewardToInt(cfg.expReward * starAddition)
	local rewardMoney = rewardToInt(cfg.moneyReward * starAddition)
	local rewardZhenqi = rewardToInt(cfg.zhenqiReward * starAddition)
	local itemReward = cfg.itemReward
	return rewardExp, rewardMoney, rewardZhenqi, itemReward;
end

function QuestLieMoVO:ParseFlag(flag)
	self.round = bit.rshift(flag, 16);
	self.starLvl = bit.band(bit.rshift(flag, 8), 255);
	self.multiple = bit.band(flag, 255);
	Debug(string.format("Daily quest：round:%s, star:%s, times:%s", self.round, self.starLvl, self.multiple));
end

--获取任务配表
function QuestLieMoVO:GetCfg()
	if not t_todayquest[self.id] then
		Debug('error:cannot find daily quest in table.id:' .. self.id);
		return nil;
	end
	return t_todayquest[self.id];
end

--任务类型
function QuestLieMoVO:GetType()
	return QuestConsts.Type_LieMo
end

-- 是否可传送
function QuestLieMoVO:CanTeleport()
	local state = self:GetState()
	if state == QuestConsts.State_Going then
		local goal = self:GetGoal()
		return goal ~= nil and goal:CanTeleport()
	end
	return false
end

function QuestLieMoVO:GetTeleportType()
	return MapConsts.Teleport_LieMo -- 猎魔传送
end

--[[
-- 独有节点数组(在内容节点之下)
function QuestLieMoVO:CreateLowerNodes()
	-- 日环任务星级节点
	local node = QuestNodeDQStar:new()
	node:SetContent( self )
	return { node }
end
]]

--获取快捷任务任务标题文本
function QuestLieMoVO:GetTitleLabel()
	local state = self:GetState();
	local cfg = self:GetCfg();
	local lblFormat = "<font size='" .. QuestColor.TITLE_FONTSIZE .. "' color='" .. QuestColor.TITLE_COLOR .. "'>   %s</font>%s%s"; -- 中间的空格是留给任务图标的
	local round = self:GetRound();
	local leftTimes = string.format(StrConfig["quest912"], QuestLieMoConsts:GetLieMoDayNum() - (round-1));
	local drawIndicator = self:DrawWhenEnd() and StrConfig['quest1'] or "";
	return string.format(lblFormat, cfg.name, leftTimes, drawIndicator);
end

function QuestLieMoVO:GetShowRewards()
	local rewardExp, rewardMoney, rewardZhenqi, itemReward = self:GetRewards()
	local rewards = {};
	if rewardExp and rewardExp > 0 then
		table.push(rewards, enAttrType.eaExp .. "," .. rewardExp)
	end
	if rewardMoney and rewardMoney > 0 then
		table.push(rewards, enAttrType.eaBindGold .. "," .. rewardMoney)
	end
	--	if rewardZhenqi and rewardZhenqi > 0 then
	--		table.push(rewards, rewardZhenqi)
	--	end
	if itemReward and itemReward ~= "" then
		table.push(rewards, itemReward)
	end
	if #rewards > 0 then
		return RewardManager:Parse(table.concat(rewards, "#"));
	end
end

function QuestLieMoVO:ShowTips()
	local list = self:GetShowRewards();
	if not list then return; end
	local cfg = self:GetCfg();
	UIQuestTips:Show(cfg.name, list);
end

function QuestLieMoVO:OnTitleClick()
	UILieMoView:Open();
end

function QuestLieMoVO:GetPlayRefresh()
	return false;
end

function QuestLieMoVO:SetState( state, showRefresh )
	local lastState = self.state;
	if self.state ~= state then
		self.state = state;
		for i,goalVO in pairs(self.goalList) do
			goalVO:OnStateChange();
		end
		self.playRefresh = showRefresh == nil and true or showRefresh
		self:OnStateChange();
		if lastState == QuestConsts.State_UnAccept and state == QuestConsts.State_Going then
			QuestGuideManager:DoTaoFaGuide();
		end
	end
end
