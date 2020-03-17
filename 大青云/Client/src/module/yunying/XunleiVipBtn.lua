--[[
迅雷平台vip按钮
wangshuai
2015年11月12日09:50:04
]]

_G.XunleiVipBtn = BaseYunYingBtn:new();

YunYingBtnManager:RegisterBtnClass(YunYingConsts.BT_XunleiVip,XunleiVipBtn);

function XunleiVipBtn:GetStageBtnName()
	return "ButtonXunleiVip";
end

function XunleiVipBtn:IsShow()
	return Version:IsShowXunleiTQ()
end


function XunleiVipBtn:OnBtnClick()
	if XunleiVip:IsShow() then
		XunleiVip:Hide();
	else
		if self.button then
			XunleiVip.tweenStartPos = UIManager:PosLtoG(self.button,0,0);
		end
		XunleiVip:Show();
	end
end