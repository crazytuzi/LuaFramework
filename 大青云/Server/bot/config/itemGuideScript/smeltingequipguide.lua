--[[
物品使用引导--熔炼
wangyanwei
2015年10月11日, PM 04:41:51
]]

QuestScriptCfg:Add(
{
	name = "smeltingequipguide",
	steps = {
		[1] = {
			type = "normal",
			execute = function() FuncManager:OpenFunc(FuncConsts.Smelt); return true; end,
			complete = function() return UIEquipSmelting:IsFullShow(); end,
			Break = function() return false; end
		},
	}
});