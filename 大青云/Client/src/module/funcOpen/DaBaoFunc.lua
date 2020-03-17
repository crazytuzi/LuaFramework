--[[
仙缘洞府特效
wangyanwei
2015年4月22日15:00:00
]]

_G.DaBaoFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.DaBaoMiJing,DaBaoFunc);



function DaBaoFunc:OnBtnInit()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey)
		self.timerKey = nil;
	end
	self.timerKey = TimerManager:RegisterTimer(function()
		if UIXianYuanCave.onLineTimeData and UIXianYuanCave.onLineTimeData ~= {} and UIXianYuanCave.onLineTimeData[ActivityConsts.T_DaBaoMiJing].timeNum <= 90 then
			PublicUtil:SetRedPoint(self.button)
		else
			PublicUtil:SetRedPoint(self.button,nil,2)
		end
	end,1000,0); 
end