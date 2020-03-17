--[[
顺网超级会员
wangshuai
2015年11月12日17:44:31
]]

_G.ShunwangBtn = BaseYunYingBtn:new();

YunYingBtnManager:RegisterBtnClass(YunYingConsts.BT_ShunwangVip,ShunwangBtn);

function ShunwangBtn:GetStageBtnName()
	return "ButtonShunwangVip";
end

function ShunwangBtn:IsShow()
	return Version:IsShowSwjoyTQ()
end

function ShunwangBtn:OnBtnClick()
	if UIShunWangQQ:IsShow() then
		UIShunWangQQ:Hide();
	else
		if self.button then
			UIShunWangQQ.tweenStartPos = UIManager:PosLtoG(self.button,0,0);
		end
		UIShunWangQQ:Show();
	end
end