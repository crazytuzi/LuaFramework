--[[
噬魂，击杀精英怪
wangshuai
]]

QuestScriptCfg:Add(
{
	name = "shihunguide",
	steps = {
		[1] = {
			type = "normal",
			execute = function() FuncManager:OpenFunc(FuncConsts.ShiHun); return true; end,
			complete = function() return UIShihun:IsFullShow(); end,
			Break = function() return false; end
		},
		[2] = {
			type = "normal",
			execute = function()  return true; end,
			complete = function() UIShihun:SetMonster(); return true end,
			Break = function() return not UIShihun:IsShow(); end,
		},
	}
})