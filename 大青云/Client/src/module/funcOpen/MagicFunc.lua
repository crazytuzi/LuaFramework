--[[
绝学功能
houxudong
2016年10月29日 04:42:29
]]

_G.MagicFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.MagicSkill,MagicFunc);

MagicFunc.timerKey = nil;


function MagicFunc:OnBtnInit()
	self:RegisterTimes()
	self:InitRedPoint()
end

function MagicFunc:RegisterTimes()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timekey)
		self.timekey = nil;
	end
end

function MagicFunc:InitRedPoint()
	local width = self.button._width;
	self.timerKey = TimerManager:RegisterTimer(function()
		if SkillUtil:CheckJuexueCanLvlUp() or SkillUtil:CheckXinfaCanLvlUp() then
			PublicUtil:SetRedPoint(self.button, nil, 1)
		else
			PublicUtil:SetRedPoint(self.button, nil, 0)
		end
	end,1000,0); 
end