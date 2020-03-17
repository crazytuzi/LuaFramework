--[[
灵器升阶引导
灵器熟练度满时提醒	在主界面右下角弹出提醒UI，提醒玩家当前有灵器可以升阶，点击后打开灵器及升阶界面，箭头指向升阶按钮
haohu
2015年5月6日21:26:41
]]

QuestScriptCfg:Add(
{
	name = "lingqiguide",
	steps = {
		[1] = {
			type = "normal",
			execute = function() FuncManager:OpenFunc(FuncConsts.LingQi); return true; end,
			complete = function() return UILingQi:IsFullShow(); end,
			Break = function() return false; end
		},
		
		-- [2] = {
		-- 	type = "normal",
		-- 	execute = function() UILingQi:ShowLvlUpPanel(); return true; end,
		-- 	complete = function() return UILingQiLvlUp:IsShow(); end,
		-- 	Break = function() return not UILingQi:IsShow(); end,
		-- },
	
		-- [3] = {
			-- type = "clickButton",
			-- button = function() return UILingQiLvlUp:GetLvlUpBtn(); end,
			-- Break = function() return (not UILingQi:IsShow()) or (not UILingQiLvlUp:IsShow()); end,
			-- arrow = true,
			-- arrowPos = 1,
			-- arrowOffset = { x = 0, y = -5 },
		-- }
	}
});