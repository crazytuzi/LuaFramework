--[[
迅雷平台手机按钮
wangshuai
2015年11月20日09:50:04
]]

_G.XunleiPhone = BaseYunYingBtn:new();

YunYingBtnManager:RegisterBtnClass(YunYingConsts.BT_XunleiPhone,XunleiPhone);

function XunleiPhone:GetStageBtnName()
	return "ButtonXunleiPhone";
end

function XunleiPhone:IsShow()
	if Version:IsShowXunleiPhone() then 
		if YunYingController.xunleiRewardState == 0 then 
			return true;
		end;
	end;
	return false;
end


function XunleiPhone:OnBtnClick()
	Version:OpenXunleiPhoneBind()
end