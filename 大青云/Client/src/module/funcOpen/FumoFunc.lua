--[[
伏魔功能
houxudong
2016年7月29日 15:55:25
]]

_G.FumoFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.Fumo,FumoFunc);

FumoFunc.timerKey = nil;

function FumoFunc:OnBtnInit()
	self:RegisterTimes()
	self:InitRedPoint()
end

function FumoFunc:RegisterTimes()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timekey)
		self.timekey = nil;
	end
end

function FumoFunc:InitRedPoint()
	local func = FuncManager:GetFunc( FuncConsts.Fumo )

	local width = self.button._width;
	self.timerKey = TimerManager:RegisterTimer(function()
		if func:GetFuncOpenState() then
			if FumoUtil:isCanUpMap() then
				-- PublicUtil:SetRedPoint(self.button, nil, 1)
				self.button.redpointNum._visible = true;
			else
				-- PublicUtil:SetRedPoint(self.button, nil, 0)
				self.button.redpointNum._visible = false;
			end
		end
		if func:GetDayState() == FuncConsts.State_OpenPrompt then
			-- WriteLog(LogType.Normal,true,'---------------------WarPrintFunc  State_OpenPrompt')
			-- self.button.disabled = true
			PublicUtil:SetFunPrompt(self.button, OpenFunByDayConst.showLv, 0,day,FuncConsts.Fumo)
		elseif func:GetDayState() == FuncConsts.State_OpenClick then
			-- self.button.disabled = true
			-- WriteLog(LogType.Normal,true,'---------------------WarPrintFunc State_OpenClick')
			PublicUtil:SetFunPrompt(self.button, OpenFunByDayConst.showJihuo, 0,0,FuncConsts.Fumo)
		elseif func:GetDayState() == FuncConsts.State_FunOpened then
			-- self.button.disabled = false
			-- WriteLog(LogType.Normal,true,'---------------------WarPrintFunc State_FunOpened')
			PublicUtil:SetFunPrompt(self.button, OpenFunByDayConst.hideSlef, 0,0,FuncConsts.Fumo)
		end
	end,1000,0); 
end