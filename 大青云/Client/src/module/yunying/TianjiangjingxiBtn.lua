--[[
老拉新 按钮
haohu
2015年12月21日15:39:51
]]

_G.TianJiangJingXi = BaseYunYingBtn:new();

YunYingBtnManager:RegisterBtnClass(YunYingConsts.BT_YXTianjiang, TianJiangJingXi);

function TianJiangJingXi:GetStageBtnName()
	return "wanTianJiangjx";
end

function TianJiangJingXi:IsShow()
	return Version:IsShowTianJiangjingxi()
end

function TianJiangJingXi:OnBtnClick()
	Version:IsShowTianJiangjingxiUrl()
end

-- function TianJiangJingXi:OnBtnInit()
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