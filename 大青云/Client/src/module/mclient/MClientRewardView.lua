--[[
微端奖励面板
lizhuangzhuang
2015年5月14日15:01:08
]]

_G.UIMClientReward = BaseUI:new("UIMClientReward");

function UIMClientReward:Create()
	if Version:IsLianYun() then
		self:AddSWF("mclientRewardLianYun.swf",true,"center");
	else
		self:AddSWF("mclientReward.swf",true,"center");
	end
end

function UIMClientReward:OnLoaded(objSwf)
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	objSwf.btnDownload.click = function() self:OnBtnConfirmClick(); end
	objSwf.btnGetReward.click = function() self:OnBtnConfirmClick(); end
	objSwf.btnDownload.visible = false;
	objSwf.btnGetReward.visible = false;
	RewardManager:RegisterListTips(objSwf.rewardList);
end

function UIMClientReward:IsTween()
	return true;
end

function UIMClientReward:IsShowSound()
	return true;
end

function UIMClientReward:GetPanelType()
	return 1;
end

function UIMClientReward:OnShow()
	local objSwf = self.objSwf;
	local rewardList = RewardManager:Parse(t_consts[64].param);
	objSwf.rewardList.dataProvider:cleanUp();
	objSwf.rewardList.dataProvider:push(unpack(rewardList));
	objSwf.rewardList:invalidateData();
	local itemList = {};
	itemList[1] = objSwf.item1;
	itemList[2] = objSwf.item2;
	itemList[3] = objSwf.item3;
	itemList[4] = objSwf.item4;
	itemList[5] = objSwf.item5;
	UIDisplayUtil:HCenterLayout(#rewardList, itemList, 58, 830, 457);
	itemList = nil;
	--
	if _G.ismclient then
		objSwf.btnDownload.visible = false;
		objSwf.btnGetReward.visible = true;
	else
		objSwf.btnDownload.visible = true;
		objSwf.btnGetReward.visible = false;
	end
end

function UIMClientReward:OnBtnConfirmClick()
	if _G.ismclient then
		MClientController:GetReward();
	else
		Version:DownloadMClient();
		self:Hide();
	end
end

function UIMClientReward:OnBtnCloseClick()
	self:Hide();
end