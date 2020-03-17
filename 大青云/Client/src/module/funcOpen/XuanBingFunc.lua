--[[
神炉功能
houxudong
2016年7月29日 0:15:23
]]

_G.XuanBingFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.XuanBing,XuanBingFunc);

XuanBingFunc.timerKey = nil;


function XuanBingFunc:OnBtnInit()
	self:RegisterTimes( );
	self:InitRedPoint()
end

function XuanBingFunc:RegisterTimes()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timekey)
		self.timekey = nil;
	end
end

function XuanBingFunc:InitRedPoint()
	self.timerKey = TimerManager:RegisterTimer(function()
		if StoveController:IsCanProgress(StovePanelView.XUANBING) or StoveController:IsCanProgress(StovePanelView.BAOJIA) 
		or StoveController:IsCanProgress(StovePanelView.MINGYU)  then
			PublicUtil:SetRedPoint(self.button, nil,1)
		else
			PublicUtil:SetRedPoint(self.button, nil,0)
		end
	end,1000,0); 
end