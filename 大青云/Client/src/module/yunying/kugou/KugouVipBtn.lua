--[[
酷狗超级会员
haohu
2015年12月18日12:09:15
]]

_G.KugouBtn = BaseYunYingBtn:new();

YunYingBtnManager:RegisterBtnClass(YunYingConsts.BT_KugouVip, KugouBtn);

function KugouBtn:GetStageBtnName()
	return "ButtonKugouVip";
end

function KugouBtn:IsShow()
	return Version:IsShowKugouVip()
end

function KugouBtn:OnBtnClick()
	if UIKugouVip:IsShow() then
		UIKugouVip:Hide();
	else
		if self.button then
			UIKugouVip.tweenStartPos = UIManager:PosLtoG(self.button,0,0);
		end
		UIKugouVip:Show();
	end
end