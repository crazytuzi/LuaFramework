--[[
	2015年6月15日, PM 06:03:47
	wangyanwei
	箱子奖励tip
]]

_G.UIDominateRouteTip = BaseUI:new('UIDominateRouteTip');

function UIDominateRouteTip:Create()
	self:AddSWF('dominateRouteBoxTip.swf',true,'top');
end

function UIDominateRouteTip:OnLoaded(objSwf)
	objSwf.tf1.text = UIStrConfig['dominateRoute501'];
	objSwf.tf2.text = UIStrConfig['dominateRoute502'];
end

function UIDominateRouteTip:OnShow()
	self:onResize();
	self:OnDrawRewardList();
end

function UIDominateRouteTip:onResize()
	self:UpdatePos();
end

function UIDominateRouteTip:UpdatePos()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local tipsDir = TipsConsts.Dir_RightDown;
	local tipsX, tipsY = TipsUtils:GetTipsPos( self:GetWidth(), self:GetHeight(), tipsDir, self.target );
	objSwf._x = tipsX;
	objSwf._y = tipsY;
end

function UIDominateRouteTip:OnDrawRewardList()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	local cfg = t_roadbox[self.rewardID];
	local rewardList = RewardManager:Parse(cfg.boxReward);
	objSwf.rewardList.dataProvider:cleanUp();
	objSwf.rewardList.dataProvider:push(unpack(rewardList));
	objSwf.rewardList:invalidateData();
end

UIDominateRouteTip.rewardID = 0;
function UIDominateRouteTip:Open(id)
	if not id then return end
	local cfg = t_roadbox[id];
	if not cfg then return end
	self.rewardID = id;
	if self:IsShow() then
		self:OnShow();
	else
		self:Show();
	end
end

function UIDominateRouteTip:OnHide()
	
end

function UIDominateRouteTip:HandleNotification(name,body)
	if name == NotifyConsts.StageMove then
		self:UpdatePos();
	end
end

function UIDominateRouteTip:ListNotificationInterests()
	return {
		NotifyConsts.StageMove,
	}
end