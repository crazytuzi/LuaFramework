--[[
360特权按钮
wangshuai
]]

_G.Weishi360 = BaseYunYingBtn:new();

YunYingBtnManager:RegisterBtnClass(YunYingConsts.BT_Wishi360,Weishi360);

function Weishi360:GetStageBtnName()
	return "Weishi360";
end

function Weishi360:IsShow()
	return WeishiController.isShowWeishiState
end


function Weishi360:OnBtnClick()
	if UIWeishi360:IsShow() then
		UIWeishi360:Hide();
	else
		if self.button then
			UIWeishi360.tweenStartPos = UIManager:PosLtoG(self.button,0,0);
		end
		UIWeishi360:Show();
	end
end