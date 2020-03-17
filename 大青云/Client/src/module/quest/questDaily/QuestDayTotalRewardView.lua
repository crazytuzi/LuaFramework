--[[
日环全部完成每日奖励
2015年4月10日16:20:32
haohu
]]

_G.UIQuestDayTotalReward = BaseUI:new("UIQuestDayTotalReward");

function UIQuestDayTotalReward:Create()
	self:AddSWF("taskDayTotalRewardPanel.swf", true, "center");
end

function UIQuestDayTotalReward:OnLoaded(objSwf)
	objSwf.btnConfirm.click = function() self:OnBtnConfirmClick(); end
	RewardManager:RegisterListTips(objSwf.list);
	objSwf.txtPrompt.htmlText = StrConfig['quest301'];
end

function UIQuestDayTotalReward:OnShow()
	self:UpdateShow();
	self:StartTimer();
end

function UIQuestDayTotalReward:OnHide()
	self:StopTimer();
end

function UIQuestDayTotalReward:UpdateShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	-- 特效
	self:PlayEffect()
	-- 奖励
	local rewardList = QuestUtil:GetQuestDayRewardProvider();
	local list = objSwf.list;
	list.dataProvider:cleanUp();
	for i = 1, #rewardList do
		list.dataProvider:push(rewardList[i]);
	end
	list:invalidateData();

	--居中
	local items = {
		objSwf.item1,
		objSwf.item2,
		objSwf.item3,
		objSwf.item4,
		objSwf.item5,
		objSwf.item6
	}
	UIDisplayUtil:HCenterLayout(#rewardList, items, 64, 283, 174);
	items = nil;
end

function UIQuestDayTotalReward:PlayEffect()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.effBg:stopEffect()
	-- objSwf.effBg:playEffect(1)
end

function UIQuestDayTotalReward:OnBtnConfirmClick()
	self:Hide();
end

local time;
local timerKey;
function UIQuestDayTotalReward:StartTimer()
	time = QuestConsts.QuestDailyRewardCountDown;
	local func = function() self:OnTimer(); end
	timerKey = TimerManager:RegisterTimer(func, 1000, 0);
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.txtTime.htmlText = string.format(StrConfig['quest112'], time);
end

function UIQuestDayTotalReward:OnTimer()
	time = time - 1;
	if time <= 0 then
		self:OnTimeUp();
		return;
	end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.txtTime.htmlText = string.format(StrConfig['quest112'], time);
end

function UIQuestDayTotalReward:OnTimeUp()
	self:StopTimer();
	self:Hide();
end

function UIQuestDayTotalReward:StopTimer()
	if timerKey then
		TimerManager:UnRegisterTimer(timerKey);
		timerKey = nil;
	end
end
