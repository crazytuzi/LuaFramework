--[[
神兵警告
wangyanwei
]]

QuestScriptCfg:Add(
{
	name = "armorwarningguid",
	steps = {
		[1] = {
			type = "normal",
			execute = function() FuncManager:OpenFunc(FuncConsts.Armor); return true; end,
			complete = function() return MainArmorUI:IsFullShow(); end,
			Break = function() return false; end
		},		
	}
})