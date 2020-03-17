--[[
任务脚本管理器
lizhuangzhuang
2014年9月14日15:44:53
]]

_G.QuestScriptManager = {};

--当前正在进行的任务脚本
QuestScriptManager.currQuestScript = nil;


--执行任务脚本
function QuestScriptManager:DoScript(name)
	if not QuestScriptCfg[name] then
		Debug("Error:没找找到任务脚本,name="..name);
		return;
	end
	if self.currQuestScript then
		print("Waring:当前任务脚本未完成,请检查!!!",self.currQuestScript:GetName());
		self.currQuestScript:Exit();
		self.currQuestScript = nil;
	end
	local cfg = QuestScriptCfg[name];
	self.currQuestScript = QuestScript:new(cfg)
	self.currQuestScript:Enter();
end

--脚本完成
function QuestScriptManager:FinishQuest(name)
	if not self.currQuestScript then
		return;
	end
	self.currQuestScript:Exit();
	self.currQuestScript = nil;
end
