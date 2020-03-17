--[[
物品使用引导--灵力
在主界面右下角弹出提醒UI，提醒玩家当前有灵力可以升星，点击后打开坐骑界面，箭头指向升阶按钮
zhangshuhui
2015年7月1日11:12:32
]]

QuestScriptCfg:Add(
{
	name = "mountxingguide",
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