--[[
任务脚本Step:点击按钮开启功能
lizhuangzhuang
2015年2月28日15:43:44
]]

_G.QuestSSClickOpenFunc = setmetatable({},{__index=QuestScriptStep});

QuestSSClickOpenFunc.waitTimerKey = nil;

function QuestSSClickOpenFunc:Enter()
	if self.cfg.complete and type(self.cfg.complete)=="function" then
		if self.cfg.complete() then
			self:Next();
			return true;
		end
	end
	local func = FuncManager:GetFunc(self.cfg.funcId);
	if not func then return false; end
	if not func.button then return false; end
	--画箭头
	if self.cfg.arrow then
		UIFuncGuide:Open({
			type = UIFuncGuide.Type_FuncGuide,
			showtype = UIFuncGuide.ST_Public,
			getButton = func.button,
			pos = self.cfg.arrowPos,
			offset = self.cfg.arrowOffset,
			btnMask = self.cfg.mask
		});
	end
	--检测完成条件
	if self.waitTimerKey then
		TimerManager:UnRegisterTimer(self.waitTimerKey);
		self.waitTimerKey = nil;
	end
	self.waitTimerKey = TimerManager:RegisterTimer(function()
		if self.cfg.complete() then
			TimerManager:UnRegisterTimer(self.waitTimerKey);
			self.waitTimerKey = nil;
			self:Next();
		end
	end,20,0);
	return true;
end

function QuestSSClickOpenFunc:Exit()
	if self.waitTimerKey then
		TimerManager:UnRegisterTimer(self.waitTimerKey);
		self.waitTimerKey = nil;
	end
	if self.cfg and self.cfg.arrow then
		UIFuncGuide:Close(UIFuncGuide.Type_FuncGuide);
	end
	self.cfg = nil;
end