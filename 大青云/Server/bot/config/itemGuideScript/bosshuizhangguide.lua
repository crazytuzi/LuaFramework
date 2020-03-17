--[[
boss徽章激活引导
haohu
2015年11月21日17:38:00
]]

QuestScriptCfg:Add(
{
	name = "bosshuizhangguide",
	steps = {
		[1] = {
			type = "normal",
			execute = function() FuncManager:OpenFunc(FuncConsts.BossHuizhang); return true; end,
			complete = function() return UIBossMedal:IsFullShow(); end,
			Break = function() return false; end
		},
	}
});