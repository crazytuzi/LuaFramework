--[[
任务脚本的每一步
lizhuangzhuang
2014年9月14日17:28:29
]]

_G.QuestScriptStep = {};

function QuestScriptStep:new(cfg,questScript)
	local obj = setmetatable({},{__index=self});
	obj.cfg = cfg;
	obj.questScript = questScript;
	return obj;
end

function QuestScriptStep:Enter()

end

function QuestScriptStep:Next()
	if self.questScript then
		self.questScript:NextStep();
	end
end

function QuestScriptStep:Exit()

end