--[[
炼器功能

]]

_G.WarPrintFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.LianQi,WarPrintFunc);

WarPrintFunc.timerKey = nil;

function WarPrintFunc:OnBtnInit()
	self:RegisterTimes()
	self:initRedPoint()
end

function WarPrintFunc:RegisterTimes()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timekey)
		self.timekey = nil;
	end
end

WarPrintFunc.EquipCollectFuncLoader = nil;
function WarPrintFunc:initRedPoint()
	local width = self.button._width;
	self.timerKey = TimerManager:RegisterTimer(function()
		local func = FuncManager:GetFunc( FuncConsts.LianQi )
		local day = func:GetOpenDay()
		if func:GetDayState() == FuncConsts.State_OpenPrompt then
			self.button.disabled = true
			PublicUtil:SetFunPrompt(self.button, OpenFunByDayConst.showMingri, 0,day,FuncConsts.LianQi)
		elseif func:GetDayState() == FuncConsts.State_OpenClick then
			self.button.disabled = true
			PublicUtil:SetFunPrompt(self.button, OpenFunByDayConst.showJihuo, 0,0,FuncConsts.LianQi)
		elseif func:GetDayState() == FuncConsts.State_FunOpened then
			self.button.disabled = false
			PublicUtil:SetFunPrompt(self.button, OpenFunByDayConst.hideSlef, 0,0,FuncConsts.LianQi)
		end
	end,1000,0); 
end