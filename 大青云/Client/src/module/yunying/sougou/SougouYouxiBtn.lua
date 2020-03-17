--[[
搜狗平台游戏
wangshuai
2015年12月7日14:16:39
]]

_G.SougouYouxi = BaseYunYingBtn:new();

YunYingBtnManager:RegisterBtnClass(YunYingConsts.BT_SougouYouxi,SougouYouxi);

function SougouYouxi:GetStageBtnName()
	return "ButtonSougouYouxi";
end

function SougouYouxi:IsShow()
	if YunYingController.SougouData.youxiReward then 
		--可领取状态
		return true;
	else
		return false;
	end;
end


function SougouYouxi:OnBtnClick()
	if UISougouYouxi:IsShow() then
		UISougouYouxi:Hide();
	else
		if self.button then
			UISougouYouxi.tweenStartPos = UIManager:PosLtoG(self.button,0,0);
		end
		UISougouYouxi:Show();
	end
end	