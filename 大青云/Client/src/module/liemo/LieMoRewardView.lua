--[[
    Created by IntelliJ IDEA.
    
    User: Hongbin Yang
    Date: 2016/10/25
    Time: 17:30
   ]]


_G.LieMoRewardView = BaseUI:new("UILieMoRewardView");

LieMoRewardView.autoCloseTimerKey = nil;
LieMoRewardView.questId = 0;
LieMoRewardView.rewardList = 0;
LieMoRewardView.sendFinishQuest = false;
function LieMoRewardView:Create()
	self:AddSWF("liemoRewardPanel.swf", true, "center");
end

function LieMoRewardView:InitView(objSwf)
	-- 界面加载完成后的
	objSwf.btnConfirm.click = function() self:OnBtnOKClick() end
end

function LieMoRewardView:OnShow()
	if #self.args > 0 then
		self.questId = self.args[1]
		self.rewardList = self.args[2];
		self.sendFinishQuest = self.args[3];
	end
	self:InitView(self.objSwf);
	self:UpdateView();
end

function LieMoRewardView:UpdateView()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local rewardList = self.rewardList;
	if not rewardList then return; end
	objSwf.list.dataProvider:cleanUp();
	objSwf.list.dataProvider:push(unpack(rewardList));
	objSwf.list.itemRollOver = function(e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.list.itemRollOut = function() TipsManager:Hide(); end
	objSwf.list:invalidateData();
	--布局奖励显示
	local uiRewardItemList = { objSwf.item1, objSwf.item2, objSwf.item3, objSwf.item4 };
	UIDisplayUtil:HCenterLayout(#rewardList, uiRewardItemList, 64, 380, 160);
	uiRewardItemList = nil;

	local tempStr = "";
	--[[local questVO = QuestModel:GetTrunkQuest();
	if questVO and questVO:GetState()~=QuestConsts.State_CannotAccept then
		tempStr = StrConfig["quest938"];
	else
		tempStr = StrConfig["quest937"];
	end]]
	tempStr = StrConfig["quest937"];
	--自动关闭
	local sec = 20;
	objSwf.txtTime.htmlText = string.format(tempStr, sec);
	self.autoCloseTimerKey = TimerManager:RegisterTimer(function(curTimes)
		if curTimes >= sec then
			TimerManager:UnRegisterTimer(self.autoCloseTimerKey);
			self.autoCloseTimerKey = nil;
			self:OnBtnOKClick()
		end
		objSwf.txtTime.htmlText = string.format(tempStr, sec - curTimes);
	end, 1000, sec)
end

function LieMoRewardView:IsTween()
	return true;
end

function LieMoRewardView:IsShowSound()
	return true;
end

--点击关闭按钮
function LieMoRewardView:OnBtnOKClick()
	if self.sendFinishQuest then
		QuestController:FinishQuest(self.questId);

	end
	self:Hide();
end

function LieMoRewardView:OnHide()
	TimerManager:UnRegisterTimer(self.autoCloseTimerKey);
	self.autoCloseTimerKey = nil;
end