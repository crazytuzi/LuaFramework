--[[
宝甲功能

]]

_G.ArmorFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.Armor,ArmorFunc);

ArmorFunc.timerKey = nil;

function ArmorFunc:OnBtnInit()
	self:RegisterTimes()
	self:initRedPoint()
end

function ArmorFunc:RegisterTimes()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timekey)
		self.timekey = nil;
	end
end

function ArmorFunc:initRedPoint()
	local width = self.button._width;
	self.timerKey = TimerManager:RegisterTimer(function()
		local func = FuncManager:GetFunc( FuncConsts.Armor )
		local day = func:GetOpenDay()
		if func:GetFuncOpenState() then
			if self:CheckOperRedPoint() then
				PublicUtil:SetRedPoint(self.button, nil, 1)
			else
				PublicUtil:SetRedPoint(self.button)
			end
		else
			PublicUtil:SetRedPoint(self.button)
		end
		if func:GetDayState() == FuncConsts.State_OpenPrompt then
			self.button.disabled = true
			PublicUtil:SetFunPrompt(self.button, OpenFunByDayConst.showMingri, 0,day,FuncConsts.Armor)
		elseif func:GetDayState() == FuncConsts.State_OpenClick then
			self.button.disabled = true
			PublicUtil:SetFunPrompt(self.button, OpenFunByDayConst.showJihuo, 0,0,FuncConsts.Armor)
		elseif func:GetDayState() == FuncConsts.State_FunOpened then
			self.button.disabled = false
			PublicUtil:SetFunPrompt(self.button, OpenFunByDayConst.hideSlef, 0,0,FuncConsts.Armor)
		end
	end,1000,0); 
end

--功能开启时
function ArmorFunc:OnFuncOpen()
	if self:GetIsClickOpen() == 0 then
		UIArmorShow:Show()
	end
end

function ArmorFunc:OnDayStateChange()
	if self:GetDayState() == FuncConsts.State_FunOpened then
		UIArmorShow:Show()
	end
end

function ArmorFunc:CheckOperRedPoint()
	if UIArmor:GetState() == 1 then
		return UIArmorBagShortcut:CheckHasProficiencyItem();
	elseif UIArmor:GetState() == 2 then
		return ArmorController:CheckLvlUpItemEnough();
	end

end