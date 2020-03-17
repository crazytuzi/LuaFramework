--[[ 
搜狗游戏
wangshuai
2015年12月7日15:17:39
]]

_G.UISougouYouxi = BaseUI:new("UISougouYouxi")

function UISougouYouxi:Create()
	self:AddSWF("yunyingSougouYouxipanel.swf",true,'center')
end;

function UISougouYouxi:OnLoaded(objSwf)
	objSwf.closebtn.click = function() self:Hide()end;
	RewardManager:RegisterListTips(objSwf.item1.list);
	objSwf.item1.btn.click = function() self:OnGetRewardClick()end;
	objSwf.goDownYouxi.click = function() self:OnDownYouxi()end;
end;

function UISougouYouxi:OnShow()
	self:ShowReward();
end;

function UISougouYouxi:OnHide()

end;

function UISougouYouxi:OnDownYouxi()
	Version:SouGouDownGameBox()
end;

function UISougouYouxi:ShowReward()
	local objSwf = self.objSwf;
	local cfg = t_consts[163];
	if not cfg then return end;
	local rewardList = RewardManager:Parse(cfg.param)
	objSwf.item1.list.dataProvider:cleanUp();
	objSwf.item1.list.dataProvider:push(unpack(rewardList));
	objSwf.item1.list:invalidateData();
end;

function UISougouYouxi:OnGetRewardClick()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	if Version:IsSoGouGameBoxLogin() then 
		YunYingController:GetSougouReward(1)
	else
		FloatManager:AddNormal(StrConfig["yunying023"]);
	end;	
end;



