--[[
搜狗平台vip按钮
wangshuai
2015年12月7日14:11:11
]]

_G.SougouVipBtn = BaseYunYingBtn:new();

YunYingBtnManager:RegisterBtnClass(YunYingConsts.BT_SougouVip,SougouVipBtn);

function SougouVipBtn:GetStageBtnName()
	return "ButtonSougouVip";
end

function SougouVipBtn:IsShow()
	return Version:IsSoGouShowVipBtn()
end


function SougouVipBtn:OnBtnClick()
	if UISougouVip:IsShow() then
		UISougouVip:Hide();
	else
		if self.button then
			UISougouVip.tweenStartPos = UIManager:PosLtoG(self.button,0,0);
		end
		UISougouVip:Show();
	end
end