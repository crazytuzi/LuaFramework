--[[
	360特权加速奖励
	zhangshuhui
]]

_G.UIweishi360TeQuanQuickView = BaseUI:new("UIweishi360TeQuanQuickView")

function UIweishi360TeQuanQuickView:Create()
	self:AddSWF("youxi360TeQuanQuickReward.swf",true,"center")
end;

function UIweishi360TeQuanQuickView:OnLoaded(objSwf)
	objSwf.closebtn.click = function() self:Hide()end;
	objSwf.reward_mc.getreward_btn.click = function() self:GetCurDayQuickReward()end;
	RewardManager:RegisterListTips( objSwf.itemlist );
end;

function UIweishi360TeQuanQuickView:OpenPath()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	Version:Hd360Browse()
end;

function UIweishi360TeQuanQuickView:OnShow()
	self:ShowLIst();
end;

function UIweishi360TeQuanQuickView:OnHide()

end;

function UIweishi360TeQuanQuickView:ShowLIst()
	local objSwf = self.objSwf;
	local reward = t_consts[140];
	objSwf.reward_mc.getreward_btn.visible = false;
	objSwf.reward_mc.gettedreward_btn.visible = false;
	objSwf.reward_mc.effectgetreward._visible = false;
	if reward then
		local rewardStrList = {};
		if Weishi360Model:GetCurDayQuickReward() == 0 then
			rewardStrList = RewardManager:Parse(reward.param);
			objSwf.reward_mc.getreward_btn.visible = true;
			objSwf.reward_mc.effectgetreward._visible = true;
		else
			rewardStrList = RewardManager:ParseBlack(reward.param);
			objSwf.reward_mc.gettedreward_btn.visible = true;
		end
		objSwf.itemlist.dataProvider:cleanUp();
		objSwf.itemlist.dataProvider:push(unpack(rewardStrList));
		objSwf.itemlist:invalidateData();
	end
end;

--是否播放开启音效
function UIweishi360TeQuanQuickView:IsShowSound()
	return true;
end

function UIweishi360TeQuanQuickView:IsShowLoading()
	return true;
end

function UIweishi360TeQuanQuickView:GetCurDayQuickReward()
	WeishiController:ReqGetReward(3,0);
end
