--[[
圣翼功能
houxudong
2016年7月31日 02:20:20
]]

_G.WingHeChengFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.WingHeCheng,WingHeChengFunc);

WingHeChengFunc.timerKey = nil;

WingHeChengFunc.rideLoader = nil;
function WingHeChengFunc:OnBtnInit()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timekey)
		self.timekey = nil;
	end
	local width = self.button._width;
	self.timerKey = TimerManager:RegisterTimer(function()
		local curRoleLvl = MainPlayerModel.humanDetailInfo.eaLevel 
		local WingCfg = t_funcOpen[55];  
		local wingOpenLevel = WingCfg.open_level
		local wingCanCheck = false
		if curRoleLvl >= wingOpenLevel then
			wingCanCheck = true
		end
		if (HeChengUtil:WingCanHeChen( ) and wingCanCheck) or (HeChengUtil:WingCanQianghua( ) and wingCanCheck) then
			PublicUtil:SetRedPoint(self.button, nil, 1)
		else
			PublicUtil:SetRedPoint(self.button, nil, 0)
		end
	end,1000,0);
end