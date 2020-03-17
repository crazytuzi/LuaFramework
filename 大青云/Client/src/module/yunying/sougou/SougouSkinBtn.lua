--[[
搜狗平台皮肤
wangshuai
2015年12月7日14:16:39
]]

_G.SougouSkinBtn = BaseYunYingBtn:new();

YunYingBtnManager:RegisterBtnClass(YunYingConsts.BT_SougouSkin,SougouSkinBtn);

function SougouSkinBtn:GetStageBtnName()
	return "ButtonSougouSkin";
end

function SougouSkinBtn:IsShow()
	if YunYingController.SougouData.pifuReward then 
		--可领取状态
		return true;
	else
		return false;
	end;
end


function SougouSkinBtn:OnBtnClick()
	if Version:IsSoGouSkinLogin() then
		if YunYingController.SougouData.pifuReward then 
			YunYingController:GetSougouReward(2)
		end;
	else
		Version:SougouDownSkin()
	end;
end


function SougouSkinBtn:OnBtnInit()
	if self.button.initialized then
		if self.button.effect.initialized then
			local state = YunYingController.SougouData.pifuReward
			if state and Version:IsSoGouSkinLogin() then  
				self.button.effect:playEffect(0);
			else
				self.button.effect:stopEffect(0);
			end;
		else
			self.button.effect.init = function()
				local state = YunYingController.SougouData.pifuReward
				if state  and Version:IsSoGouSkinLogin() then  
					self.button.effect:playEffect(0);
				else
					self.button.effect:stopEffect(0);
				end;
			end
		end
	end
end