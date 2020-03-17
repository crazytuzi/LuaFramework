--[[
合成功能
houxudong
天气晴，稍有雾霾 ,-1 ~ 9摄氏度
2016年11月30日 18:12:36
]]

_G.HeChengFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.HeCheng,HeChengFunc);

HeChengFunc.timerKey = nil;


function HeChengFunc:OnBtnInit()
	self:RegisterTimes()
	self:InitRedPoint()
end

function HeChengFunc:RegisterTimes()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timekey)
		self.timekey = nil;
	end
end

function HeChengFunc:InitRedPoint()
	self.timerKey = TimerManager:RegisterTimer(function()
		if self.state ~= FuncConsts.State_Open then return end
		if HeChengUtil:CheckHechengCanDo() then
			self.button.redpointNum._visible = true;
		else
			self.button.redpointNum._visible = false;
		end
	end,1000,0)
end