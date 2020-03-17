--[[
灵阵警告
wangyanwei
]]

QuestScriptCfg:Add(
{
	name = "lingzhenwarningguid",
	steps = {
		[1] = {
			type = "normal",
			execute = function() FuncManager:OpenFunc(FuncConsts.Lingzhen); return true; end,
			complete = function() return UILingzhen:IsFullShow(); end,
			Break = function() return false; end
		},		
	}
})