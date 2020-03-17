--[[
    Created by IntelliJ IDEA.
    目标任务完成领奖界面
    User: Hongbin Yang
    Date: 2016/9/21
    Time: 14:26
   ]]


_G.MainQuestLvFinishedRewardView = BaseUI:new("MainQuestLvFinishedRewardView");

MainQuestLvFinishedRewardView.questId = 0;
MainQuestLvFinishedRewardView.title = "";
MainQuestLvFinishedRewardView.rewards = nil;
MainQuestLvFinishedRewardView.isGold = false;
function MainQuestLvFinishedRewardView:Create()
	self:AddSWF("mainPageTaskLvFinishedReward.swf", true, "bottom");
end

function MainQuestLvFinishedRewardView:InitView()
	local objSwf = self.objSwf;
	if not objSwf then return; end

	-- 界面加载完成后的
	objSwf.txtTitle.htmlText = self.title;

	self.objSwf.list.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	self.objSwf.list.itemRollOut = function () TipsManager:Hide(); end

	if self.rewards then
		objSwf.list.dataProvider:cleanUp()
		objSwf.list.dataProvider:push(unpack(self.rewards))
		objSwf.list:invalidateData()
	end

	local totalS = {self.objSwf.item1, self.objSwf.item2, self.objSwf.item3, self.objSwf.item4}
	UIDisplayUtil:HCenterLayout(#self.rewards, totalS, 64, 153, 63);
	totalS = nil;

end

function MainQuestLvFinishedRewardView:OnShow()
	if #self.args > 0 then
		self.questId = self.args[1];
		self.title = self.args[2];
		self.rewards = self.args[3];
		self.isGold = self.args[4];
	end
	self:UpdateView();

end

function MainQuestLvFinishedRewardView:Open(questid, title, rewards, isGold)
	self.questId = questid;
	self.title = title;
	self.rewards = rewards;
	self.isGold = isGold;
	if self:IsShow() then
		self:UpdateView();
	else
		self:Show(questid, title, rewards, isGold);
	end
end

local lv_Finished_reward_view_autoCloseTime = 3;
local lv_Finished_reward_view_autoCloseTimerKey = nil;
function MainQuestLvFinishedRewardView:UpdateView()
	self:InitView();
	self.objSwf.txtInfo.htmlText = string.format(StrConfig["mainmenucommon1"], lv_Finished_reward_view_autoCloseTime);
	--自动关闭
	if lv_Finished_reward_view_autoCloseTimerKey then
		TimerManager:UnRegisterTimer( lv_Finished_reward_view_autoCloseTimerKey );
		lv_Finished_reward_view_autoCloseTimerKey = nil;
	end
	lv_Finished_reward_view_autoCloseTimerKey = TimerManager:RegisterTimer(function(curTimes)
		if curTimes < lv_Finished_reward_view_autoCloseTime then
			self.objSwf.txtInfo.htmlText = string.format(StrConfig["mainmenucommon1"], lv_Finished_reward_view_autoCloseTime - curTimes);
		else
			self:OnBtnOKClick();
		end

	end, 1000, lv_Finished_reward_view_autoCloseTime)
end

function MainQuestLvFinishedRewardView:GetCfgPos()
	return UIMainLvQuestTitle.objSwf._x - self:GetWidth() + 91, UIMainLvQuestTitle.objSwf._y + 53;
end

--点击关闭按钮
function MainQuestLvFinishedRewardView:OnBtnOKClick()
	if self.objSwf and self.isGold then
		UICurrencyFlyView:Show(enAttrType.eaBindGold, {self.objSwf._x + 150, self.objSwf._y});
	end
	self:Hide();
end


function MainQuestLvFinishedRewardView:OnHide()
	self.rewards = nil;
	self.objSwf.list.dataProvider:cleanUp();
	self.objSwf.list:invalidateData();
	if lv_Finished_reward_view_autoCloseTimerKey then
		TimerManager:UnRegisterTimer( lv_Finished_reward_view_autoCloseTimerKey );
		lv_Finished_reward_view_autoCloseTimerKey = nil;
	end
end

function MainQuestLvFinishedRewardView:IsTween()
	return true;
end