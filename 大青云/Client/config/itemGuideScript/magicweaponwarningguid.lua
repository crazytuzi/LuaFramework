--[[
神兵警告
wangyanwei
]]

QuestScriptCfg:Add(
{
	name = "magicweaponwarningguid",
	steps = {
		[1] = {
			type = "normal",
			execute = function() FuncManager:OpenFunc(FuncConsts.MagicWeapon); return true; end,
			complete = function() return MainMagicWeaponUI:IsFullShow(); end,
			Break = function() return false; end
		},		
	}
})