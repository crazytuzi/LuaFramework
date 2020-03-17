--[[
星图功能
houxudong
2016年7月29日 0:15:23
]]

_G.XingtuFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.Xingtu,XingtuFunc);

XingtuFunc.timerKey = nil;


function XingtuFunc:OnBtnInit()
	self:RegisterTimes()
	self:InitRedPoint()
end

function XingtuFunc:RegisterTimes()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey)
		self.timerKey = nil;
	end
end

XingtuFunc.xingtuLoader = nil;
function XingtuFunc:InitRedPoint()
	local width = self.button._width;
	self.timerKey = TimerManager:RegisterTimer(function()
		if XingtuModel:IsHaveCanLvUp() then
			-- PublicUtil:SetRedPoint(self.button, nil, 1)
			self.button.redpointNum._visible = true;
		else
			-- PublicUtil:SetRedPoint(self.button, nil, 0)
			self.button.redpointNum._visible = false;
		end
	end,1000,0); 
end