--[[
任务脚本Step:普通类型
lizhuangzhuang
2015年5月5日13:51:30
]]

_G.QuestSSNormal = setmetatable({},{__index=QuestScriptStep});

QuestSSNormal.timerID = nil;
QuestSSNormal.breakTimerKey = nil;

function QuestSSNormal:Enter()
	if not (self.cfg.execute and type(self.cfg.execute)=="function") then
		Debug("Error:Quest Script error.Cannot find execute function.");
		return false;
	end
	if not (self.cfg.complete and type(self.cfg.complete)=="function") then
		Debug("Error:Quest Script error.Cannot find complete function.");
		return false;
	end
	if not (self.cfg.Break and type(self.cfg.Break)=="function") then
		print("Error:Quest Script Error.Cannot find Break function");
		return false;
	end
	if self.cfg.complete() then
		self:Next();
		return true;
	end
	if self.timerID then
		TimerManager:UnRegisterTimer(self.timerID);
		self.timerID = nil;
	end
	self.timerID = TimerManager:RegisterTimer(function()
		if self.cfg.complete() then
			TimerManager:UnRegisterTimer(self.timerID);
			self.timerID = nil;
			self:Next();
		end
	end,10,0);
	local rst = self.cfg.execute();
	--打断监听
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
	return rst;
end


function QuestSSNormal:Exit()
	if self.timerID then
		TimerManager:UnRegisterTimer(self.timerID);
		self.timerID = nil;
	end
	if self.breakTimerKey then
		TimerManager:UnRegisterTimer(self.breakTimerKey);
		self.breakTimerKey = nil;
	end
end