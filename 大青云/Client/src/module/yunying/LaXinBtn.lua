--[[
老拉新 按钮
haohu
2015年12月21日15:39:51
]]

_G.LaXinBtn = BaseYunYingBtn:new();

YunYingBtnManager:RegisterBtnClass(YunYingConsts.BT_YXLaXin, LaXinBtn);

function LaXinBtn:GetStageBtnName()
	return "ButtonLaXin";
end

function LaXinBtn:IsShow()
	return Version:IsYXLaXin()
end

function LaXinBtn:OnBtnClick()
	if UILaXin:IsShow() then
		UILaXin:Hide();
	else
		if self.button then
			UILaXin.tweenStartPos = UIManager:PosLtoG(self.button,0,0);
		end
		UILaXin:Show();
	end
end

-- function LaXinBtn:OnBtnInit()
-- 	if self.button.initialized then
-- 		if self.button.effect.initialized then
-- 			self.button.effect:playEffect(0);
-- 		else
-- 			self.button.effect.init = function()
-- 				self.button.effect:playEffect(0);
-- 			end
-- 		end
-- 	end
-- end