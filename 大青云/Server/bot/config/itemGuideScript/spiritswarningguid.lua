--[[
灵兽警告
wangyanwei
]]

QuestScriptCfg:Add(
{
	name = "spiritswarningguid",
	steps = {
		[1] = {
			type = "normal",
			execute = function() FuncManager:OpenFunc(FuncConsts.Spirits); return true; end,
			complete = function() return MainSpiritsUI:IsFullShow(); end,
			Break = function() return false; end
		},
	}
})