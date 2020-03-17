--[[
锻造功能
houxudong
2016年7月29日 16:50:25
]]

_G.SmithingFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.Smithing,SmithingFunc);

SmithingFunc.timerKey = nil;

SmithingFunc.curRoleLvl = nil;
SmithingFunc.starCfg = nil;
SmithingFunc.gemCfg = nil;
SmithingFunc.washCfg = nil;
SmithingFunc.ringCfg = nil;
SmithingFunc.starOpenLevel = nil;
SmithingFunc.gemOpenLevel = nil;
SmithingFunc.washOpenLevel = nil;
SmithingFunc.ringOpenLevel = nil;
SmithingFunc.starCanCheck = nil;
SmithingFunc.gemCanCheck = nil;
SmithingFunc.washCanCheck = nil;
SmithingFunc.ringCanCheck = nil;
function SmithingFunc:OnBtnInit()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timekey)
		self.timekey = nil;
	end
	local width = self.button._width;
	self.timerKey = TimerManager:RegisterTimer(function()
		self.curRoleLvl = MainPlayerModel.humanDetailInfo.eaLevel -- 当前人物等级
		self.starCfg = t_funcOpen[30];  
		self.gemCfg  = t_funcOpen[33];  
		self.washCfg = t_funcOpen[109]; 
		self.ringCfg = t_funcOpen[111];
		self.starOpenLevel = self.starCfg.open_level
		self.gemOpenLevel = self.gemCfg.open_level
		self.washOpenLevel = self.washCfg.open_level
		self.ringOpenLevel = self.ringCfg.open_level
		self.starCanCheck = false;
		self.gemCanCheck = false;
		self.washCanCheck = false;
		self.ringCanCheck = false;
		if self.curRoleLvl >= self.starOpenLevel then
			self.starCanCheck = true
		end
		if self.curRoleLvl >= self.gemOpenLevel then
			self.gemCanCheck = true
		end
		if self.curRoleLvl >= self.washOpenLevel then
			self.washCanCheck = true
		end
		if self.curRoleLvl >= self.ringOpenLevel then
			self.ringCanCheck = true
		end
		if (EquipUtil:IsHaveEquipCanStarUp() and self.starCanCheck) or (EquipUtil:GetGemOperateValue() ~= 0 and self.gemCanCheck) or (EquipUtil:IsHaveEquipCanWash() and self.washCanCheck) or (EquipUtil:IsCanLvUpRing() and self.ringCanCheck) then
			PublicUtil:SetRedPoint(self.button, nil, 1)
		else
			PublicUtil:SetRedPoint(self.button, nil, 0)
		end
	end,1000,0); 
end