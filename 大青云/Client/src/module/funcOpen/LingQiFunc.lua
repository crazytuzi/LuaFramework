--[[
法宝功能

]]

_G.LingQiFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.LingQi,LingQiFunc);

LingQiFunc.timerKey = nil;

function LingQiFunc:OnBtnInit()
	self:RegisterTimes()
	self:initRedPoint()
end

function LingQiFunc:RegisterTimes()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timekey)
		self.timekey = nil;
	end
end

LingQiFunc.EquipCollectFuncLoader = nil;
function LingQiFunc:initRedPoint()
	local width = self.button._width;
	self.timerKey = TimerManager:RegisterTimer(function()
		local func = FuncManager:GetFunc( FuncConsts.LingQi )
		if func:GetFuncOpenState() then
			if self:CheckOperRedPoint() then
				PublicUtil:SetRedPoint(self.button, nil, 1,_,true)
			else
				PublicUtil:SetRedPoint(self.button, nil, 0)
			end
		else
			PublicUtil:SetRedPoint(self.button, nil, 0)   --这样做的目的是为了提高小红点的渲染层级
		end
		local day = func:GetOpenDay()
		if func:GetDayState() == FuncConsts.State_OpenPrompt then
			self.button.disabled = true
			PublicUtil:SetFunPrompt(self.button, OpenFunByDayConst.showMingri, 0,day,FuncConsts.LingQi)
		elseif func:GetDayState() == FuncConsts.State_OpenClick then
			self.button.disabled = true
			PublicUtil:SetFunPrompt(self.button, OpenFunByDayConst.showJihuo, 0,0,FuncConsts.LingQi)
		elseif func:GetDayState() == FuncConsts.State_FunOpened then
			self.button.disabled = false
			PublicUtil:SetFunPrompt(self.button, OpenFunByDayConst.hideSlef, 0,0,FuncConsts.LingQi)
		end
	end,1000,0); 
end

--功能开启时
function LingQiFunc:OnFuncOpen()
	if self:GetIsClickOpen() == 0 then
		UILingQiShow:Show()
	end
end

function LingQiFunc:OnDayStateChange()
	if self:GetDayState() == FuncConsts.State_FunOpened then
		UILingQiShow:Show()
	end
end

function LingQiFunc:CheckOperRedPoint()
	if UILingQi:GetState() == 1 then
		return UILingQiBagShortcut:CheckHasProficiencyItem();
	elseif UILingQi:GetState() == 2 then
		return LingQiController:CheckLvlUpItemEnough();
	end

end