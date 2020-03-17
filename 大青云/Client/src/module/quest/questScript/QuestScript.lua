--[[
任务脚本对象
lizhuangzhuang
2014年9月14日17:27:32
]]

_G.QuestScript = {}

QuestScript.StepClassMap = {
	['clickOpenFunc'] = QuestSSClickOpenFunc,
	["clickOpenUI"] = QuestSSClickOpenUI,
	['clickButton'] = QuestSSClickButton,
	['normal'] = QuestSSNormal
};

function QuestScript:new(cfg)
	local obj = {};
	for k,v in pairs(QuestScript) do
		if type(v) == "function" then
			obj[k] = v;
		end
	end
	obj.cfg = cfg;
	obj.currStep = nil;
	obj.currStepIndex = 0;--当前步骤
	return obj;
end

function QuestScript:InitSteps()
	self.steps = {};
	for i,stepCfg in ipairs(self.cfg.steps) do
		local step = nil;
		if QuestScript.StepClassMap[stepCfg.type] then
			step = QuestScript.StepClassMap[stepCfg.type]:new(stepCfg,self);
		else
			step = QuestScriptStep:new(stepCfg,self);
		end
		self.steps[i] = step;
	end
end

--创建步骤
function QuestScript:CreateStep(stepCfg)
	if QuestScript.StepClassMap[stepCfg.type] then
		return QuestScript.StepClassMap[stepCfg.type]:new(stepCfg,self);
	end
	return nil;
end

function QuestScript:GetName()
	return self.cfg.name;
end

--进入
function QuestScript:Enter()
	if self.currStepIndex > 0 then
		print("Error:QuestScript cannot re enter!!!");
		return;
	end
	if #self.cfg.steps < 1 then
		print("Error:QuestScript steps length is zero!!!");
		return;
	end
	local step = self:CreateStep(self.cfg.steps[1]);
	if not step then
		print("Error:QuestScript. Create step error!");
		return;
	end
	self.currStep = step;
	self.currStepIndex = 1;
	self:DoStopGuide();
	--启动失败,每隔3S重试一次
	if not self.currStep:Enter() then
		if self.reEenterKey then
			TimerManager:UnRegisterTimer(self.reEenterKey);
			self.reEenterKey = nil;
		end
		self.reEenterKey = TimerManager:RegisterTimer(function(count)
			if self.currStep:Enter() then
				TimerManager:UnRegisterTimer(self.reEenterKey);
				self.reEenterKey = nil;
				self:OnEnter();
			else
				if count == 30 then
					print("Error:QuestScript.脚本进入失败!!");
					self.reEenterKey = nil;
					self:DoRecoverGuide();
				end
			end
		end,500,30);
	else
		self:OnEnter();
	end
end

function QuestScript:OnEnter()
	if self.cfg and self.cfg.disableFuncKey then
		FuncOpenController:DisableFuncKey();
	end
	if self.cfg and self.cfg.log then
		ClickLog:Send(ClickLog.T_Guide_Step,self.cfg.name,1);
	end
end

function QuestScript:DoStopGuide()
	if self.cfg.stopQuestGuide then
		QuestGuideManager:StopGuide();
	end
end

function QuestScript:DoRecoverGuide()
	if self.cfg.stopQuestGuide then
		QuestGuideManager:RecoverGuide();
	end
	if self.cfg.disableFuncKey then
		FuncOpenController:EnableFuncKey();
	end
end

--下一步
function QuestScript:NextStep()
	if not self.currStep then
		print("Waring:QuestScript NextStep.Curr step is nil!!");
	end
	if self.currStep then
		self.currStep:Exit();
		self.currStep = nil;
	end
	--执行完毕
	if self.currStepIndex == #self.cfg.steps then
		QuestScriptManager:FinishQuest(self:GetName());
		return;
	end
	local step = self:CreateStep(self.cfg.steps[self.currStepIndex+1],self);
	if not step then
		print("Error:QuestScript. Create step error!");
		return;
	end
	self.currStep = step;
	self.currStepIndex = self.currStepIndex + 1;
	if self.cfg and self.cfg.log then
		ClickLog:Send(ClickLog.T_Guide_Step,self.cfg.name,self.currStepIndex);
	end
	self.currStep:Enter();
end

--打断指引
function QuestScript:Break()
	if not self.currStep then
		print("Waring:QuestScript Break.Curr step is nil!!");
		return;
	end
	self.currStep:Exit();
	self.currStep = nil;
	QuestScriptManager:FinishQuest(self:GetName());
end

--退出
function QuestScript:Exit()
	if self.reEenterKey then
		TimerManager:UnRegisterTimer(self.reEenterKey);
		self.reEenterKey = nil;
	end
	if self.currStep then
		self.currStep:Exit();
		self.currStep = nil;
	end
	self.currStepIndex = 0;
	self:DoRecoverGuide();
	self.cfg = nil;
end