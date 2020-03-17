--[[
	灵光封魔TIPS
	2015年6月1日, PM 03:38:11
	wangyanwei
]]
_G.UITimeDungeinTips = BaseUI:new('UITimeDungeinTips');

function UITimeDungeinTips:Create()
	self:AddSWF('timeDungeoTip.swf',true,'center');
end

function UITimeDungeinTips:OnLoaded(objSwf)
	-- objSwf
	objSwf.actName.text = UIStrConfig['timeDungeon201'];
	objSwf.tfTime.text = t_monkeytime[1].opentime;
	objSwf.desc.text = UIStrConfig['timeDungeon202'];
	objSwf.rewardName.text = UIStrConfig['timeDungeon203'];
end

function UITimeDungeinTips:OnShow()
	self:UpdatePos();
	self:OnShowReward();
end

function UITimeDungeinTips:onResize()
	self:UpdatePos();
end

function UITimeDungeinTips:UpdatePos()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local tipsDir = TipsConsts.Dir_RightDown;
	local tipsX, tipsY = TipsUtils:GetTipsPos( self:GetWidth(), self:GetHeight(), tipsDir, self.target );
	objSwf._x = tipsX;
	objSwf._y = tipsY;
end

function UITimeDungeinTips:GetWidth()
	return 312
end

function UITimeDungeinTips:GetHeight()
	return 188
end

function UITimeDungeinTips:OnShowReward()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = t_monkeytime[1];
	local rewardList = RewardManager:Parse(cfg.firstReward);
	objSwf.rewardlist.dataProvider:cleanUp();
	objSwf.rewardlist.dataProvider:push(unpack(rewardList));
	objSwf.rewardlist:invalidateData();
end

function UITimeDungeinTips:HandleNotification(name,body)
	if name == NotifyConsts.StageMove then
		self:UpdatePos();
	end
end

function UITimeDungeinTips:ListNotificationInterests()
	return {
		NotifyConsts.StageMove,
	}
end