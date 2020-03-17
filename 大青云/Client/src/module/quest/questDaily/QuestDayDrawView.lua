--[[
日环任务：抽奖界面          --现在改为在5,10,15环都放出固定奖励
2015年1月12日17:38:34
haohu
]]

_G.UIQuestDayDraw = BaseUI:new("UIQuestDayDraw");

UIQuestDayDraw.questDailyVO = nil;

function UIQuestDayDraw:Create()
	self:AddSWF("taskDayTotalRewardPanel.swf", true, "center");
	
end

function UIQuestDayDraw:OnLoaded( objSwf )
	objSwf.btnConfirm.click         = function() self:OnBtnConfirmClick(); end
	RewardManager:RegisterListTips( objSwf.list );
end

function UIQuestDayDraw:OnShow()
	-- WriteLog(LogType.Normal,true,'---------------------------UIQuestDayDraw:OnShow()')
	self:ShowRound();
	self:UpdateShow();
	self:StartTimer();
end

function UIQuestDayDraw:UpdateShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	-- 特效
	self:PlayEffect()
	-- 奖励
	local level = 0;
	level = MainPlayerModel.humanDetailInfo.eaLevel;
	local cfg = t_dailygroup[level];
	local rewardItemStr;
	if UIQuestDayReward.questDailyVORound==5 then
		rewardItemStr = cfg.reward_item5;
	elseif UIQuestDayReward.questDailyVORound==10 then
		rewardItemStr = cfg.reward_item10;
	elseif UIQuestDayReward.questDailyVORound==15 then
		rewardItemStr = cfg.reward_item15;
	elseif UIQuestDayReward.questDailyVORound==20 then
		rewardItemStr = cfg.reward_item;
	end
	-- WriteLog(LogType.Normal,true,'-------------------------UIQuestDayDraw--UpdateShow',UIQuestDayReward.questDailyVORound)
	local rewardList = RewardManager:Parse(rewardItemStr );
	local list = objSwf.list;
	list.dataProvider:cleanUp();
	for i = 1, #rewardList do
		list.dataProvider:push( rewardList[i] );
	end
	list:invalidateData();
end

function UIQuestDayDraw:PlayEffect()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.effBg:stopEffect()
	-- objSwf.effBg:playEffect(1)
end

function UIQuestDayDraw:ShowRound()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	-- local questVO = QuestModel:GetDailyQuest();
	-- if not questVO then return; end
	-- local round = questVO:GetRound()-1;
	-- WriteLog(LogType.Normal,true,'---------------------------在5,10,15环都放出固定奖励',UIQuestDayReward.questDailyVORound)
	if UIQuestDayReward.questDailyVORound==20 then
		objSwf.txtPrompt.htmlText = StrConfig['quest301'];
		return
	end
	objSwf.txtPrompt.htmlText = string.format( StrConfig['quest111'], UIQuestDayReward.questDailyVORound )
end

function UIQuestDayDraw:OnBtnConfirmClick()
	self:GetReward();
end

function UIQuestDayDraw:GetReward()
	QuestController:ReqDailyDrawConfirm(); -- 领奖确认
	self:Hide();
end
function UIQuestDayDraw:OnHide()
	self.questDailyVO = nil;
	QuestDayFlow:OnDailyDrawPanelClose();
	self:StopTimer();
end

local time;
local timerKey;
function UIQuestDayDraw:StartTimer()
	time = QuestConsts.QuestDailyRewardCountDown;
	local func = function() self:OnTimer(); end
	timerKey = TimerManager:RegisterTimer( func, 1000, 0 );
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.txtTime.htmlText = string.format( StrConfig['quest112'], time );
end

function UIQuestDayDraw:OnTimer()
	time = time - 1;
	if time <= 0 then
		self:OnTimeUp();
		return;
	end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.txtTime.htmlText = string.format( StrConfig['quest112'], time );
end

function UIQuestDayDraw:OnTimeUp()
	self:StopTimer();
	QuestController:ReqDailyDrawConfirm();
	self:Hide();
end

function UIQuestDayDraw:StopTimer()
	if timerKey then
		TimerManager:UnRegisterTimer( timerKey );
		timerKey = nil;
	end
end
