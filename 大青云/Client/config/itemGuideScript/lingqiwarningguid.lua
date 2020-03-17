--[[
神兵警告
wangyanwei
]]

QuestScriptCfg:Add(
{
	name = "lingqiwarningguid",
	steps = {
		[1] = {
			type = "normal",
			execute = function() FuncManager:OpenFunc(FuncConsts.LingQi); return true; end,
			complete = function() return MainLingQiUI:IsFullShow(); end,
			Break = function() return false; end
		},		
	}
})