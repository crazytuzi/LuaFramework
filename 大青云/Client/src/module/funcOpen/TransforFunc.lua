--[[
    天神
   ]]


_G.TransforFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.NewTianshen, TransforFunc);

function TransforFunc:OnFuncOpen()
	
end
function TransforFunc:SetState(state)
	if state == FuncConsts.State_Open then
		self:OnFuncOpen();
	end
	self.state = state;
end

function TransforFunc:OnBtnInit()
	self:RegisterTimes()
	self:InitRedPoint()
end

function TransforFunc:RegisterTimes()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timekey)
		self.timekey = nil;
	end
end

function TransforFunc:InitRedPoint()
	local width = self.button._width;
	self.timerKey = TimerManager:RegisterTimer(function()
		local canOpera = NewTianshenUtil:CheckTianShenCanOperation()
		if self.button.redPoint then 
			if canOpera then
				self.button.redPoint._visible = true
			else
				self.button.redPoint._visible = false
			end
		end
	end,1000,0); 
end
