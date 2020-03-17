--[[
坐骑功能
houxudong
2016年7月31日 01:07:20
]]

_G.RideFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.Horse,RideFunc);

RideFunc.timerKey = nil;
function RideFunc:OnBtnInit()
	local width = self.button._width;
	self.timerKey = TimerManager:RegisterTimer(function()
		local curRoleLvl = MainPlayerModel.humanDetailInfo.eaLevel 
		local RideCfg = t_funcOpen[5];  
		local rideOpenLevel = RideCfg.open_level
		local rideCanCheck = false
		if curRoleLvl >= rideOpenLevel then
			rideCanCheck = true
		end
		if MountUtil:CheckCanLvUp( ) then
			PublicUtil:SetRedPoint(self.button, nil, 1,_,true)
		else
			PublicUtil:SetRedPoint(self.button)
		end
	end,1000,0);
end