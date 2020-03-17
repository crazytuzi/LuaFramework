
--[[
神兵功能

]]

_G.MagicWeaponFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.MagicWeapon,MagicWeaponFunc);

MagicWeaponFunc.timerKey = nil;

function MagicWeaponFunc:OnBtnInit()
	self:RegisterTimes()
	self:initRedPoint()
end

function MagicWeaponFunc:RegisterTimes()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timekey)
		self.timekey = nil;
	end
end

function MagicWeaponFunc:initRedPoint()
	local width = self.button._width;
	self.timerKey = TimerManager:RegisterTimer(function()
		local func = FuncManager:GetFunc( FuncConsts.MagicWeapon )
		local day = func:GetOpenDay()
		if func:GetFuncOpenState() then
			if self:CheckOperRedPoint() then
				PublicUtil:SetRedPoint(self.button, nil, 1,_,true)
			else
				PublicUtil:SetRedPoint(self.button)
			end
		else
			PublicUtil:SetRedPoint(self.button)
		end
		if func:GetDayState() == FuncConsts.State_OpenPrompt then
			self.button.disabled = true
			PublicUtil:SetFunPrompt(self.button, OpenFunByDayConst.showMingri, 0,day,FuncConsts.MagicWeapon)
		elseif func:GetDayState() == FuncConsts.State_OpenClick then
			self.button.disabled = true
			PublicUtil:SetFunPrompt(self.button, OpenFunByDayConst.showJihuo, 0,0,FuncConsts.MagicWeapon)
		elseif func:GetDayState() == FuncConsts.State_FunOpened then
			self.button.disabled = false
			PublicUtil:SetFunPrompt(self.button, OpenFunByDayConst.hideSlef, 0,0,FuncConsts.MagicWeapon)
		end
	end,1000,0); 
end

--功能开启时
function MagicWeaponFunc:OnFuncOpen()
	if self:GetIsClickOpen() == 0 then
		UIMagicWeaponShow:Show()
	end
end

function MagicWeaponFunc:OnDayStateChange()
	if self:GetDayState() == FuncConsts.State_FunOpened then
		UIMagicWeaponShow:Show()
	end
end

function MagicWeaponFunc:CheckOperRedPoint()
	if UIMagicWeapon:GetState() == 1 then
		return UIMagicWeaponBagShortcut:CheckHasProficiencyItem();
	elseif UIMagicWeapon:GetState() == 2 then
		return MagicWeaponController:CheckLvlUpItemEnough();
	end

end