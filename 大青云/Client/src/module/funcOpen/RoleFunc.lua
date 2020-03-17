--[[
角色功能
houxudong
2016年7月29日 0:15:23
]]

_G.RoleFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.Role,RoleFunc);

RoleFunc.timerKey = nil;

function RoleFunc:OnBtnInit()
	self:RegisterTimes()
	self:initRedPoint() 
end

function RoleFunc:RegisterTimes()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey)
		self.timerKey = nil;
	end
end

RoleFunc.roleLoader = nil;
function RoleFunc:initRedPoint()
	local width = self.button._width;
	self.timerKey = TimerManager:RegisterTimer(function()
		if RoleUtil:CheckIsHavePoint( ) or RoleUtil:GetBogeyPillList(false) or EquipUtil:IsHaveRelicCanLvUp() then
			PublicUtil:SetRedPoint(self.button,nil,1)
		else
			PublicUtil:SetRedPoint(self.button)
		end
	end,1000,0); 
end