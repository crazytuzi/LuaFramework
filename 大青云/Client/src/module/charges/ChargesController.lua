

_G.ChargesController = setmetatable({},{__index=IController})

ChargesController.name = "ChargesController";

function ChargesController:OnEnterGame()
	local func = function () 
		if ChargesUtil:OnWarningPass(ChargesConsts.Spirits) then
			if not MainSpiritsUI:IsShow() then
				UIItemGuide:Open(20);
			end
		end
	end
	if ChargesUtil:OnWarningPass(ChargesConsts.MagicWeapon) then
		if not MainMagicWeaponUI:IsShow() then
			UIItemGuide:Open(22);
		end
	end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	self.timeKey = TimerManager:RegisterTimer(func,3600000);
	func();
end
