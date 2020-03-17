--[[
神兵警告
wangyanwei
]]

QuestScriptCfg:Add(
{
	name = "mingyuwarningguid",
	steps = {
		[1] = {
			type = "normal",
			execute = function() FuncManager:OpenFunc(FuncConsts.MingYuDZZ); return true; end,
			complete = function() return MainMingYuUI:IsFullShow(); end,
			Break = function() return false; end
		},		
	}
})