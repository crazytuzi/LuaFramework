--[[
任务脚本Step:点击按钮,打开UI
lizhuangzhuang
2014年9月15日16:01:31
]]

_G.QuestSSClickOpenUI = setmetatable({},{__index=QuestScriptStep});


QuestSSClickOpenUI.button = nil;
QuestSSClickOpenUI.waitTimerKey = nil;
QuestSSClickOpenUI.breakTimerKey = nil;

function QuestSSClickOpenUI:Enter()
	if self.cfg.complete and type(self.cfg.complete)=="function" then
		if self.cfg.complete() then
			self:Next();
			return true;
		end
	end
	if not (self.cfg.button and type(self.cfg.button)=="function") then
		print("Error:Quest Script Error.Cannot find button function");
		return false;
	end
	if not (self.cfg.Break and type(self.cfg.Break)=="function") then
		print("Error:Quest Script Error.Cannot find Break function");
		return false;
	end
	self.button = self.cfg.button();
	if self.cfg.arrow then
		UIFuncGuide:Open({
			type = UIFuncGuide.Type_FuncGuide,
			showtype = UIFuncGuide.ST_Public,
			getButton = self.button,
			pos = self.cfg.arrowPos,
			offset = self.cfg.arrowOffset,
			btnMask = self.cfg.mask
		});
	end
	--检测完成
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
	--监听UI关闭,做打断处理
	if self.breakTimerKey then
		TimerManager:UnRegisterTimer(self.breakTimerKey);
		self.breakTimerKey = nil;
	end
	self.breakTimerKey = TimerManager:RegisterTimer(function()
		if self.cfg.Break() then
			TimerManager:UnRegisterTimer(self.breakTimerKey);
			self.breakTimerKey = nil;
			self.questScript:Break();
		end
	end,20,0);
	return true;
end

function QuestSSClickOpenUI:Exit()
	if self.waitTimerKey then
		TimerManager:UnRegisterTimer(self.waitTimerKey);
		self.waitTimerKey = nil;
	end
	if self.breakTimerKey then
		TimerManager:UnRegisterTimer(self.breakTimerKey);
		self.breakTimerKey = nil;
	end
	if self.cfg.arrow then
		UIFuncGuide:Close(UIFuncGuide.Type_FuncGuide);
	end
	self.button = nil;
end
