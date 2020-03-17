--[[
物品使用引导--坐骑升阶石
在主界面右下角弹出提醒UI，提醒玩家当前有坐骑升阶石可以升阶，点击后打开坐骑界面，箭头指向升阶按钮
zhangshuhui
2015年5月5日21:12:32
]]

QuestScriptCfg:Add(
{
	name = "mountguide",
	steps = {
		[1] = {
			type = "normal",
			execute = function() FuncManager:OpenFunc(FuncConsts.Horse); return true; end,
			complete = function() return UIMount:IsFullShow(); end,
			Break = function() return false; end
		},
		
		
	
		-- [3] = {
			-- type = "clickButton",
			-- button = function() return UIMountLevelUp:GetJinJieBtn(); end,
			-- Break = function() return (not UIMountBasic:IsShow()) or (not UIMountLevelUp:IsShow()) ; end,
			-- arrow = true,
			-- arrowPos = 1,
			-- arrowOffset = {x=0,y=-5},
		-- }
	}
});