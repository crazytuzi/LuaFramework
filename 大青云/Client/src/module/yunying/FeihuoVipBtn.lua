--[[
飞火平台vip按钮
wangshuai
2015年11月12日20:30:16
]]

_G.FeihuoBtn = BaseYunYingBtn:new();

YunYingBtnManager:RegisterBtnClass(YunYingConsts.BT_FeihuoVip,FeihuoBtn);

function FeihuoBtn:GetStageBtnName()
	return "ButtonFeihuoVip";
end

function FeihuoBtn:IsShow()
	return Version:IsShowFeiHuoTQ()
end


function FeihuoBtn:OnBtnClick()
	if UIFeihuoVIp:IsShow() then
		UIFeihuoVIp:Hide();
	else
		if self.button then
			UIFeihuoVIp.tweenStartPos = UIManager:PosLtoG(self.button,0,0);
		end
		UIFeihuoVIp:Show();
	end
end