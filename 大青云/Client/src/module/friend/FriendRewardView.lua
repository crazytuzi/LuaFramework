--[[
好友升级奖励
lizhuangzhuang
2015年6月1日16:54:09
]]

_G.UIFriendReward = BaseUI:new("UIFriendReward");

UIFriendReward.timerKey = nil;
UIFriendReward.list = nil;

function UIFriendReward:Create()
	self:AddSWF("friendReward.swf",true,"center");
end

function UIFriendReward:OnLoaded(objSwf)
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	RewardManager:RegisterListTips( objSwf.rewardList );
	objSwf.btnGet.click = function() self:OnBtnGetClick(); end
end

function UIFriendReward:Open(list)
	if not list then return; end
	if self.list then
		for i,vo in ipairs(list) do
			table.push(self.list,vo);
		end
	else
		self.list = list;
	end
	if self:IsShow() then
		self:OnShow();
	else
		self:Show();
	end
end

function UIFriendReward:OnShow()
	local objSwf = self.objSwf;
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end
	local doShowTime = function(time)
		objSwf.tfInfo.htmlText = string.format(StrConfig['friend501'],time);
	end
	self.timerKey = TimerManager:RegisterTimer(function(count)
		if count == 3 then
			self.timerKey = nil;
			self:DoGetReward();
			self:Hide();
		else
			doShowTime(3-count);
		end
	end,1000,3);
	doShowTime(3);
	--
	local exp = 0;
	local gold = 0;
	for i,vo in ipairs(self.list) do
		local cfg = t_lvup[vo.level];
		if cfg then
			exp = exp + cfg.friend_exp;
			gold = gold + cfg.friend_gold;
		end
	end
	objSwf.tfTotal.htmlText = string.format(StrConfig['friend502'],#self.list);
	local rewardList = RewardManager:Parse(enAttrType.eaExp..","..exp , enAttrType.eaBindGold..","..gold);
	objSwf.rewardList.dataProvider:cleanUp();
	objSwf.rewardList.dataProvider:push( unpack(rewardList) );
	objSwf.rewardList:invalidateData();
end

function UIFriendReward:OnHide()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end
	self.list = nil;
end

--领奖
function UIFriendReward:DoGetReward()
	FriendController:GetFriendReward();
end

function UIFriendReward:OnBtnGetClick()
	self:DoGetReward();
	self:Hide();
end

function UIFriendReward:OnBtnCloseClick()
	self:DoGetReward();
	self:Hide();
end