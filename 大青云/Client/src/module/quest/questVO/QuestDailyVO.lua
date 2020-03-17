--[[
日环任务vo
2014年12月9日11:16:47
郝户
]]

_G.QuestDailyVO = setmetatable( {}, {__index = QuestVO} );

QuestDailyVO.starLvl  = nil; -- 星级
QuestDailyVO.round    = nil; -- 环数
QuestDailyVO.multiple = nil; -- 奖励暴击(倍率)
QuestDailyVO.teleportConfirmUID = nil; -- 传送确认

function QuestDailyVO:OnAdded()
	if self:GetRound() <= QuestConsts.QuestDailyNum then
		QuestModel:SetDQState( QuestConsts.QuestDailyStateGoing );
	end
	QuestDayFlow:OnNewDailyQuestRsv(self);
end

function QuestDailyVO:OnFinished()
	if self:GetRound() == QuestConsts.QuestDailyNum then
		UIQuestDayMultipleOption:Hide()
	end
end

---[[ 去掉日环传送提醒后版本
function QuestDailyVO:OnContentClick()
	UIQuestDayGuide:Hide()
	local state = self:GetState()
	if state == QuestConsts.State_Going then
		self:ToTargetPos(false);
		return
	end
	self:Proceed()
end

function QuestDailyVO:ToTargetPos(isTeleport)
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


function QuestDailyVO:IsNearby()
	local point = self:GetTeleportPos()
	if not point then
		return;
	end
	return MapController:IsNearby( point.mapId, point.x, point.y )
end

-- 去掉日环传送提醒前版本
--[[  去掉日环传送提醒 2015年8月13日16:10:46
function QuestDailyVO:OnContentClick()
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

function QuestDailyVO:OpenTeleportConfirm( confirmFunc, cancelFunc )
	-- 已打开状态
	self:CloseTeleportConfirm()
	local content = string.format( StrConfig['quest802'], MapModel:GetFreeTeleportTime() )
	self.teleportConfirmUID = UIConfirmWithNoTip:Open( content, confirmFunc, cancelFunc,
		StrConfig['quest803'], StrConfig['quest804'], nil, true )
	self:StartTeleportTimer( cancelFunc )
end

function QuestDailyVO:CloseTeleportConfirm()
	if self.teleportConfirmUID then
		UIConfirmWithNoTip:Close( self.teleportConfirmUID )
		self.teleportConfirmUID = nil
		self:StopTeleportTimer()
	end
end

function QuestDailyVO:StartTeleportTimer(cb)
	if self.teleportTimerKey then return end
	self.teleportTimerKey = TimerManager:RegisterTimer( cb, 15000, 1)
end

function QuestDailyVO:StopTeleportTimer()
	if self.teleportTimerKey then
		TimerManager:UnRegisterTimer(self.teleportTimerKey)
		self.teleportTimerKey = nil
	end
end
--]]


-- 任务星级
function QuestDailyVO:GetStarLvl()
	return self.starLvl;
end

-- 升满星(5)
function QuestDailyVO:FullStar()
	self.starLvl = QuestConsts.QuestDailyMaxStar
end

-- 任务环数
function QuestDailyVO:GetRound()
	return self.round;
end

function QuestDailyVO:IsNeedStarPrompt()
	local myLevel = MainPlayerModel.humanDetailInfo.eaLevel
	local inRightLevel = QuestConsts:GetTrunkBreakLevel() <= myLevel and myLevel < QuestConsts.AutoLevel
	return inRightLevel and self.starLvl < QuestConsts.QuestDailyMaxStar
end

-- 任务奖励暴击
function QuestDailyVO:GetMultiple()
	return self.multiple;
end

-- 是否抽奖
function QuestDailyVO:DrawWhenEnd()
	for _, round in pairs( QuestConsts.QuestDailyDrawRounds ) do
		if round == self.round then
			return true;
		end
	end
	return false;
end

-- 日环单环奖励
function QuestDailyVO:GetRewards()
	local questId = self:GetId();
	local star = self:GetStarLvl();
	if star < 1 or star > QuestConsts.QuestDailyMaxStar then
		Error("dailyquest star error")
		return {};
	end
	local cfg = self:GetCfg();
	if not cfg then return end
	local starAddition = 1 + cfg["additionStar"..star] / 100;
	if not starAddition then
		Error( "additionStar"..star.."word is expected in config table 't_dailyquest', quest id:"..questId );
		return
	end
	local rewardToInt = function(num)
		return toint( num, 0.5 );
	end
	local rewardExp    = rewardToInt( cfg.expReward * starAddition )
	local rewardMoney  = rewardToInt( cfg.moneyReward * starAddition )
	local rewardZhenqi = rewardToInt( cfg.zhenqiReward * starAddition )
	local itemReward = cfg.itemReward
	local jingyuan = rewardToInt( cfg.jingyuan * starAddition )
	return rewardExp, rewardMoney, rewardZhenqi, itemReward, jingyuan;
end

function QuestDailyVO:ParseFlag( flag )
	self.round = bit.rshift( flag, 16 );
	self.starLvl = bit.band( bit.rshift( flag, 8 ), 255 );
	self.multiple = bit.band( flag, 255 );
	Debug( string.format( "Daily quest：round:%s, star:%s, times:%s", self.round, self.starLvl, self.multiple ) );
end

--获取任务配表
function QuestDailyVO:GetCfg()
	if not t_dailyquest[self.id] then
		Debug('error:cannot find daily quest in table.id:'..self.id);
		return nil;
	end
	return t_dailyquest[self.id];
end

--任务类型
function QuestDailyVO:GetType()
	return QuestConsts.Type_Day
end

-- 是否可传送
function QuestDailyVO:CanTeleport()
	local state = self:GetState()
	if state == QuestConsts.State_Going then
		local goal = self:GetGoal()
		return goal ~= nil and goal:CanTeleport()
	end
	return false
end

function QuestDailyVO:GetTeleportType()
	return MapConsts.Teleport_DailyQuest -- 日环传送
end

-- 独有节点数组(在内容节点之下)
function QuestDailyVO:CreateLowerNodes()
	-- 日环任务星级节点
	local node = QuestNodeDQStar:new()
	node:SetContent( self )
	return { node }
end

--获取快捷任务任务标题文本
function QuestDailyVO:GetTitleLabel()
	local state = self:GetState();
	local cfg = self:GetCfg();
	local lblFormat = "<font size='"..QuestColor.TITLE_FONTSIZE.."' color='"..QuestColor.TITLE_COLOR.."'>   %s</font>%s%s"; -- 中间的空格是留给任务图标的
	local round = self:GetRound();
	local leftTimes = string.format(StrConfig["quest912"], QuestConsts.QuestDailyNum - round);
	local drawIndicator = self:DrawWhenEnd() and StrConfig['quest1']  or "";
	return string.format( lblFormat, cfg.name, leftTimes, drawIndicator );
end

function QuestDailyVO:ShowTips()
	UIQuestDayTips:Show()
end

function QuestDailyVO:GetPlayRefresh()
	return false;
end

function QuestDailyVO:OnTitleClick()
	UIQuest:Open( self:GetType())
end