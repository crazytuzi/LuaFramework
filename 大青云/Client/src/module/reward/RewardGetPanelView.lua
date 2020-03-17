--[[
通用领奖展示UI
lizhuangzhuang
2015年10月28日23:49:17
]]

_G.UIRewardGetPanel = BaseUI:new("UIRewardGetPanel");

UIRewardGetPanel.rewardList = nil;
UIRewardGetPanel.title = "";

function UIRewardGetPanel:Create()
	self:AddSWF("rewardGetPanel.swf",true,"top");
end

function UIRewardGetPanel:OnLoaded(objSwf)
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	objSwf.btnConfirm.click = function() self:OnBtnConfirmClick(); end
	RewardManager:RegisterListTips(objSwf.list);
end

function UIRewardGetPanel:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.txtTitle.htmlText = self.title or "";
	objSwf.txtDes.htmlText = StrConfig["bag62"];
	--
	
	-- trace(self.rewardList)
	
	
	if not self.rewardList then return; end
	local list = objSwf.list;
	list.dataProvider:cleanUp();
	list.dataProvider:push( unpack(self.rewardList) );
	list:invalidateData();
	list:scrollToIndex(0);
end

function UIRewardGetPanel:OnHide()
	self.rewardList = nil;
	self.title = "";
end

function UIRewardGetPanel:OnBtnCloseClick()
	self:Hide();
end

function UIRewardGetPanel:OnBtnConfirmClick()
	self:Hide();
end

function UIRewardGetPanel:Open(title,rewardStr,rewardList)
	if not title then return; end
	if not rewardStr or rewardStr=="" then
		if not rewardList then
			return;
		end
		self.rewardList = rewardList;
	else
		self.rewardList = RewardManager:Parse(rewardStr);
	end
	self.title = title;
	if self:IsShow() then
		self:OnShow();
	else
		self:Show();
	end
end