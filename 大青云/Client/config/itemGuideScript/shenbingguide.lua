--[[
神兵升阶引导
神兵熟练度满时提醒	在主界面右下角弹出提醒UI，提醒玩家当前有神兵可以升阶，点击后打开神兵及升阶界面，箭头指向升阶按钮
haohu
2015年5月6日21:26:41
]]

QuestScriptCfg:Add(
{
	name = "shenbingguide",
	steps = {
		[1] = {
			type = "normal",
			execute = function() FuncManager:OpenFunc(FuncConsts.MagicWeapon); return true; end,
			complete = function() return UIMagicWeapon:IsFullShow(); end,
			Break = function() return false; end
		},
		
		-- [2] = {
		-- 	type = "normal",
		-- 	execute = function() UIMagicWeapon:ShowLvlUpPanel(); return true; end,
		-- 	complete = function() return UIMagicWeaponLvlUp:IsShow(); end,
		-- 	Break = function() return not UIMagicWeapon:IsShow(); end,
		-- },
	
		-- [3] = {
			-- type = "clickButton",
			-- button = function() return UIMagicWeaponLvlUp:GetLvlUpBtn(); end,
			-- Break = function() return (not UIMagicWeapon:IsShow()) or (not UIMagicWeaponLvlUp:IsShow()); end,
			-- arrow = true,
			-- arrowPos = 1,
			-- arrowOffset = { x = 0, y = -5 },
		-- }
	}
});