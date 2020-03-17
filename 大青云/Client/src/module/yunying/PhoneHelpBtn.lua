--[[
	2016年1月19日, PM 12:40:21
	wangyanwei
	手机助手
]]
_G.PhoneHelpBtn = BaseYunYingBtn:new();

YunYingBtnManager:RegisterBtnClass(YunYingConsts.BT_PhoneHelp,PhoneHelpBtn);

function PhoneHelpBtn:GetStageBtnName()
	return "ButtonPhoneHelp";
end

function PhoneHelpBtn:IsShow()
	if not Version:IsShowPhoneApp() then return false; end
	return YunYingController.isShowPhoneHelp;
end

function PhoneHelpBtn:OnBtnClick()
	if UIPhoneHelp:IsShow() then
		UIPhoneHelp:Hide();
	else
		UIPhoneHelp:Show();
	end
end