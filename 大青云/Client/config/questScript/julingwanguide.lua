--[[
聚灵碗功能引导
lizhuangzhuang
2015年5月29日12:31:50
]]

QuestScriptCfg:Add(
{
	name = "julingwanguide",
	stopQuestGuide = true,--停下来
	disableFuncKey = true,--屏蔽快捷键
	log = true,
	
	steps = {
		--聚灵碗UI
		[1] = {
			type = "normal",
			execute = function() 
				if not FuncManager:GetFuncIsOpen(FuncConsts.HuiZhang) then
					return false;
				end
				FuncManager:OpenFunc( FuncConsts.Homestead, true);
				return true; 
			end,
			complete = function() return UIHomesMainBuildView:IsFullShow(); end,
			Break = function() return false; end
		},
		
		--引导点击收益按钮
		--5秒后自动执行点击
		[2] = {
			type = "clickButton",
			button = function() return UIHomesMainBuildView:GetShouYiBtn(); end,
			Break = function() return not UIHomesMainBuildView:IsShow(); end,
			arrow = true,
			arrowPos = 2,
			arrowOffset = {x=0,y=0},
			text = "点击领取聚灵碗灵力收益",
			autoTime = 20000,
			autoTimeFunc = function() UIHomesMainBuildView:julingwanReward(); end,
			mask=true
		},
		
		--关闭UI
		[3] = {
			type = "normal",
			execute = function() UIHomesteadMainView:Hide(); return true; end,
			complete = function() return not UIHomesMainBuildView:IsShow(); end,
			Break = function() return false; end,
		},
		
		--领完之后，弹出剧情对话框【21】
		[4] = {
			type = "normal",
			execute = function() return true; end,
			complete = function() UIStoryDialog:PlayStoryDialog(21); return true; end,
			Break = function() return false; end,
		},
	}
});