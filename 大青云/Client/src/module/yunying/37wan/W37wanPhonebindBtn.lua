--[[
37wan手机绑定按钮
wangshuai
]]

_G.Button37WanPhone = BaseYunYingBtn:new();

YunYingBtnManager:RegisterBtnClass(YunYingConsts.BT_37wan,Button37WanPhone);

function Button37WanPhone:GetStageBtnName()
	return "Button37WanPhone";
end

function Button37WanPhone:IsShow()
	if Version:IsShowBindPhone() then 
		if YunYingController.LianYunPhone.type == 2 then 
			if YunYingController.LianYunPhone.value == 0 then 
				return true;
			end;
		end
	else
		return false;
	end;
end


function Button37WanPhone:OnBtnClick()
	if UI37WanPhone:IsShow() then
		UI37WanPhone:Hide();
	else
		if self.button then
			UI37WanPhone.tweenStartPos = UIManager:PosLtoG(self.button,0,0);
		end
		UI37WanPhone:Show();
	end
end