--[[
日环任务流程管理器
2014年12月12日11:39:24
郝户
]]

_G.QuestDayFlow = {};

QuestDayFlow.drawTurn    = nil; -- 是否抽奖轮(完成的环为5的倍数) boolean
QuestDayFlow.drawClose   = nil; -- 是否已关闭抽奖面板 boolean
QuestDayFlow.rewardClose = nil; -- 是否已关闭奖励面板 boolean
QuestDayFlow.skipTurn    = nil; -- 本轮是否跳环出现 boolean
QuestDayFlow.skipClose   = nil; -- 跳环轮时，是否已关闭跳环奖励面板 boolean
QuestDayFlow.lastTurn    = nil; -- 是否最后一轮
QuestDayFlow.skipInfo    = nil; -- 本轮跳环奖励信息 table
QuestDayFlow.newDQ       = nil; -- 新收到的日环任务 table

function QuestDayFlow:Recover()
	self.drawTurn    = nil;
	self.drawClose   = nil;
	self.rewardClose = nil;
	self.skipTurn    = nil;
	self.skipClose   = nil;
	self.lastTurn    = nil;
	self.skipInfo    = nil;
	self.newDQ       = nil;
end

function QuestDayFlow:OnRewardPanelClose()
	self.rewardClose = true;
	self:CheckOpenNextPanel();
end

function QuestDayFlow:OnDailyQuestSkipRsv(skipInfo)
	self.skipInfo = skipInfo;
	self:CheckOpenNextPanel();
end

function QuestDayFlow:OnDQDrawNoticeRsv(draw)
	self.drawTurn = draw;
	self:CheckOpenNextPanel();
end

function QuestDayFlow:OnDQDrawResultRsv( index )
	-- 转盘转到的索引是跳环索引(4)
	self.skipTurn = index == QuestConsts.QuestDailyDrawSkipIndex;
end

function QuestDayFlow:OnDailyDrawPanelClose()
	self.drawClose = true;
	self:CheckOpenNextPanel();
end

function QuestDayFlow:OnNewDailyQuestRsv(dailyQuestVO)
	self.newDQ = dailyQuestVO;
	self:CheckOpenNextPanel();
end

function QuestDayFlow:OnSkipClose()
	self.skipClose = true;
	self:CheckOpenNextPanel();
end

function QuestDayFlow:CheckOpenNextPanel()
	self:CheckOpenDraw();
	self:CheckOpenSkipReward();
	self:CheckOpenNewQuest();
	self:CheckOpenDayReward();
end

function QuestDayFlow:CheckOpenDraw()
	if self.rewardClose and self.drawTurn then
		if not self.drawClose then
			-- 打开转盘
			-- WriteLog(LogType.Normal,true,'--------------------------QuestDayFlow：CheckOpenDraw')
			UIQuestDayDraw:Show();
		end
	end
end

function QuestDayFlow:CheckOpenSkipReward()
	if self.skipTurn == nil then return; end
	if self.drawClose and self.skipInfo then
		if not self.skipClose then
			-- 打开跳环奖励
			UIQuestDailySkipReward:Open(self.skipInfo);
		end
	end
end

function QuestDayFlow:CheckOpenNewQuest()
	if self.drawTurn == nil then
		return; 
	end
	if self.newDQ == nil then
		return;
	end
	if not QuestModel:GetDailyQuest() then
		return;
	end
	if not self.rewardClose then
		return;
	end
	if self.drawTurn and not self.skipTurn then
		if self.drawClose then
			-- 打开新一环任务追踪
			self:OpenQuestGuide();
			return;
		end
	end
	if self.skipTurn then
		if self.skipClose then
			-- 打开新一环任务追踪
			self:OpenQuestGuide();
			return;
		end
	end
	if self.drawTurn == false then
		if self.rewardClose then
			-- 打开新一环任务追踪
			self:OpenQuestGuide();
			return;
		end
	end
end

function QuestDayFlow:CheckOpenDayReward()
	if not self.lastTurn then
		return;
	end
	if not self.drawClose then
		return;
	end
	self:OpenQuestDayTotalReward();
	QuestModel:SetDQState( QuestConsts.QuestDailyStateFinish )
end

-- 打开日环任务追踪界面
function QuestDayFlow:OpenQuestGuide()
	local round = self.newDQ:GetRound();
	self:Recover();
	self.lastTurn = round == QuestConsts.QuestDailyNum;
	--如果地图不能传送
	local mapId = MainPlayerController:GetMapId();
	if not MapUtils:IsQuestDailyCanTeleportMap(mapId) then return; end

	--TODO 检查是否可以做主线了
	--[[local questVO = QuestModel:GetTrunkQuest();
	if questVO and questVO:GetState()~=QuestConsts.State_CannotAccept then
		QuestGuideManager:DoTrunkGuide();
		return;
	end
]]
	UIQuestDayGuide:Open()
end

-- 打开日环任务全部完成奖励界面
function QuestDayFlow:OpenQuestDayTotalReward()
	self:Recover();
	UIQuestDayTotalReward:Hide();
end