--[[
噬魂，击杀精英怪
wangshuai
]]

QuestScriptCfg:Add(
{
	name = "lingshouguide",
	steps = {
		[1] = {
			type = "normal",
			execute = function() FuncManager:OpenFunc(FuncConsts.FaBao); return true; end,
			complete = function() return UIzhanshou:IsFullShow(); end,
			Break = function() return false; end
		},		
	}
})