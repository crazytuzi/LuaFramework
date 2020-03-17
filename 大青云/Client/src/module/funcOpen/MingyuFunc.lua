--[[
玉佩功能

]]

_G.MingYuFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.MingYuDZZ,MingYuFunc);

MingYuFunc.timerKey = nil;

function MingYuFunc:OnBtnInit()
	self:RegisterTimes()
	self:initRedPoint()
end

function MingYuFunc:RegisterTimes()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timekey)
		self.timekey = nil;
	end
end

MingYuFunc.EquipCollectFuncLoader = nil;
function MingYuFunc:initRedPoint()
	local width = self.button._width;
	self.timerKey = TimerManager:RegisterTimer(function()
		local func = FuncManager:GetFunc( FuncConsts.MingYuDZZ )
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
			PublicUtil:SetFunPrompt(self.button, OpenFunByDayConst.showMingri, 0,day,FuncConsts.MingYuDZZ)
		elseif func:GetDayState() == FuncConsts.State_OpenClick then
			self.button.disabled = true
			PublicUtil:SetFunPrompt(self.button, OpenFunByDayConst.showJihuo, 0,0,FuncConsts.MingYuDZZ)
		elseif func:GetDayState() == FuncConsts.State_FunOpened then
			self.button.disabled = false
			PublicUtil:SetFunPrompt(self.button, OpenFunByDayConst.hideSlef, 0,0,FuncConsts.MingYuDZZ)
		end
	end,1000,0); 
end

--功能开启时
function MingYuFunc:OnFuncOpen()
	if self:GetIsClickOpen() == 0 then
		UIMingYuShow:Show()
	end
end

function MingYuFunc:OnDayStateChange()
	if self:GetDayState() == FuncConsts.State_FunOpened then
		UIMingYuShow:Show()
	end
end

function MingYuFunc:CheckOperRedPoint()
	if UIMingYu:GetState() == 1 then
		return UIMingYuBagShortcut:CheckHasProficiencyItem();
	elseif UIMingYu:GetState() == 2 then
		return MingYuController:CheckLvlUpItemEnough();
	end
end