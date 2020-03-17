--[[
    Created by IntelliJ IDEA.
    
    User: Hongbin Yang
    Date: 2016/10/25
    Time: 17:30
   ]]


_G.AgoraRewardView = BaseUI:new("UIAgoraRewardView");

AgoraRewardView.autoCloseTimerKey = nil;
AgoraRewardView.questId = 0;
AgoraRewardView.rewardStr = 0;
function AgoraRewardView:Create()
	self:AddSWF("agoraRewardPanel.swf", true, "center");
end

function AgoraRewardView:InitView(objSwf)
	-- 界面加载完成后的
	objSwf.btnConfirm.click = function() self:OnBtnOKClick() end
end

function AgoraRewardView:OnShow()
	if #self.args > 0 then
		self.questId = self.args[1]
		self.rewardStr = self.args[2];
	end
	self:InitView(self.objSwf);
	self:UpdateView();
end

function AgoraRewardView:UpdateView()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local rewardStr = self.rewardStr;
	--判断是否加入20环奖励
	if AgoraModel:GetDayLeftCount() <= 0 then
		rewardStr = rewardStr .. "#" .. t_questagora_consts[1].reward;
		objSwf.allDoneTitle._visible = true;
	else
		objSwf.allDoneTitle._visible = false;
	end
	local rewardList = RewardManager:Parse(rewardStr);
	objSwf.list.dataProvider:cleanUp();
	objSwf.list.dataProvider:push(unpack(rewardList));
	objSwf.list.itemRollOver = function(e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.list.itemRollOut = function() TipsManager:Hide(); end
	objSwf.list:invalidateData();
	--布局奖励显示
	-- local uiRewardItemList = { objSwf.item1, objSwf.item2, objSwf.item3 };
	-- UIDisplayUtil:HCenterLayout(#rewardList, uiRewardItemList, 64, 380, 160);
	-- uiRewardItemList = nil;
	-- 王琦娜注释掉奖励物品自动根据物品数量自动居中的功能，因为龙哥说保持奖励物品数量不变，所以不用搞自动居中的功能。

	--自动关闭
	local sec = 20;
	local str = "";
	if AgoraModel.auto and AgoraModel:GetDayLeftCount() > 0 then
		str = StrConfig["quest941"]
	else
		str = StrConfig["quest940"]
	end
	objSwf.txtTime.htmlText = string.format(str, sec);
	self.autoCloseTimerKey = TimerManager:RegisterTimer(function(curTimes)
		if curTimes >= sec then
			TimerManager:UnRegisterTimer(self.autoCloseTimerKey);
			self.autoCloseTimerKey = nil;
			self:OnBtnOKClick()
		end
		objSwf.txtTime.htmlText = string.format(str, sec - curTimes);
	end, 1000, sec)
end

function AgoraRewardView:IsTween()
	return true;
end

function AgoraRewardView:IsShowSound()
	return true;
end

--点击关闭按钮
function AgoraRewardView:OnBtnOKClick()
	self:Hide();
	AgoraController:DoNext();
end

function AgoraRewardView:OnHide()
	self.agoraRewardID = 0;
	TimerManager:UnRegisterTimer(self.autoCloseTimerKey);
	self.autoCloseTimerKey = nil;
end