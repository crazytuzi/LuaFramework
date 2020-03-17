--[[
境界功能
houxudong
2016年10月28日 14:50:26
]]

_G.JingjieFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.Realm,JingjieFunc);

JingjieFunc.timerKey = nil;


function JingjieFunc:OnBtnInit()
	self:RegisterTimes()
	self:InitRedPoint()
end

function JingjieFunc:RegisterTimes()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timekey)
		self.timekey = nil;
	end
end

function JingjieFunc:InitRedPoint()
	self.timerKey = TimerManager:RegisterTimer(function()
		if RealmUtil:CheckCanOperation() then
			-- self.button.redpointNum._visible = true;
			PublicUtil:SetRedPoint(self.button, nil, 1)
		else
			PublicUtil:SetRedPoint(self.button, nil, 0)
			-- self.button.redpointNum._visible = false;
		end
	end,1000,0); 
end