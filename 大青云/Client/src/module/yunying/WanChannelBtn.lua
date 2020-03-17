--[[
	func:wan平台特殊渠道奖励功能按钮
	author:houxudong
	date:2016/12/15 11:04:36
]]

_G.WanChannelBtn = BaseYunYingBtn:new();

YunYingBtnManager:RegisterBtnClass(YunYingConsts.BT_WanChannelReward,WanChannelBtn);

function WanChannelBtn:GetStageBtnName()
	return "WanChannel";
end

function WanChannelBtn:IsShow()
	local playLv = MainPlayerModel.humanDetailInfo.eaLevel
	local cfg = t_consts[349]
	if not cfg or not cfg.val1 then return false end
	if playLv < toint(cfg.val1) then
		return false
	end
	if _G.GetServerTime() > _G.GetTimeByDate(2016, 12, 25, 23, 59, 59) then
		return false
	end
	if _G.isDebug then
		return true
	end
	if Version:IsShowWanChannelGame() then
		return Version:IsWeiShi()
	end
	return false
end


function WanChannelBtn:OnBtnClick()
	if wanChannelRewardView:IsShow() then
		wanChannelRewardView:Hide();
	else
		if self.button then
			wanChannelRewardView.tweenStartPos = UIManager:PosLtoG(self.button,0,0);
		end
		wanChannelRewardView:Show();
	end
end