--[[
顺网会员奖励
wangshuai
2015年11月12日17:55:31
]]

_G.ShunwangRewBtn = BaseYunYingBtn:new();

YunYingBtnManager:RegisterBtnClass(YunYingConsts.BT_ShunwangReward,ShunwangRewBtn);

function ShunwangRewBtn:GetStageBtnName()
	return "ButtonShunwangRew";
end

function ShunwangRewBtn:IsShow()
	if Version:IsShowSwjoyVIP() then 
		return ShunwangModel:GetIsShowIcon()
	else
		return false;
	end;
end

function ShunwangRewBtn:OnBtnClick()
	if ShunwangReward:IsShow() then
		ShunwangReward:Hide();
	else
		if self.button then
			ShunwangReward.tweenStartPos = UIManager:PosLtoG(self.button,0,0);
		end
		ShunwangReward:Show();
	end
end