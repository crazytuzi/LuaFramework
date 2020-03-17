--[[
飞火手机绑定按钮
wangshuai
2015年12月9日21:27:56
]]

_G.FeihuoPhoneBtn = BaseYunYingBtn:new();

YunYingBtnManager:RegisterBtnClass(YunYingConsts.BT_FeihuoPhone,FeihuoPhoneBtn);

function FeihuoPhoneBtn:GetStageBtnName()
	return "ButtonFeihuoPhone";
end

function FeihuoPhoneBtn:IsShow()
	if Version:IsShowFeihuoPhoneBind() then 
		if YunYingController.LianYunPhone.type == 1 then 
			if YunYingController.LianYunPhone.value == 0 then 
				return true;
			end;
		end
	else
		return false;
	end;
end


function FeihuoPhoneBtn:OnBtnClick()
	Version:FeihuoPhoneBind()
end