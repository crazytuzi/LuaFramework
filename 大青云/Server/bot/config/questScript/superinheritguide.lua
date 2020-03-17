--[[
卓越传承引导
lizhuangzhuangzhuang
2015年5月8日11:41:20

*******************先不要 2015年5月29日17:39:40***********************
]]

QuestScriptCfg:Add(
{
	name = "superinheritguide",
	steps = {
		--点击炼化炉
		[1] = {
			type = "clickOpenFunc",
			funcId = 12,
			complete = function() return UIEquip:IsFullShow(); end,
			arrow = true,
			arrowPos = 1,
			arrowOffset = {x=0,y=-5},
		},
		
		--切到子标签
		[2] = {
			type = "clickOpenUI",
			button = function() return UIEquip:GetSuperInBtn(); end,
			complete = function() return UIEquipSuperDown:IsShow(); end,
			Break = function() return not UIEquip:IsShow(); end,
			arrow = true,
			arrowPos = 4,
			arrowOffset = {x=-5,y=0},
		},
		
		--提示选择背包里装备
		[3] = {
			type = "clickButton",
			button = function() return UIEquipSuperDown:GetSuperDownGuideItem(220000500); end,
			Break = function() return (not UIEquipSuperDown:IsShow()) or (not UIEquip:IsShow()) ; end,
			arrow = true,
			arrowPos = 1,
			arrowOffset = {x=0,y=-5},
			--txt = ""
		},
		
		--提示剥离
		[4] = {
			type = "clickButton",
			button = function() return UIEquipSuperDown:GetConfirmBtn(); end,
			Break = function() return (not UIEquipSuperDown:IsShow()) or (not UIEquip:IsShow()) ; end,
			arrow = true,
			arrowPos = 1,
			arrowOffset = {x=0,y=-5},
		},
		
		--提示点击铭刻
		[5] = {
			type = "clickButton",
			button = function() return UIEquipSuperDown:GetUpBtn(); end,
			Break = function() return (not UIEquipSuperDown:IsShow()) or (not UIEquip:IsShow()) ; end,
			arrow = true,
			arrowPos = 1,
			arrowOffset = {x=0,y=-5},
		},
		
		--点击身上空格子装备  
		[6] = {
			type = "clickButton",
			button = function() return UIEquipSuperDown:GetSuperUpGuideItem(220000501); end,
			Break = function() return (not UIEquipSuperDown:IsShow()) or (not UIEquip:IsShow()) ; end,
			arrow = true,
			arrowPos = 1,
			arrowOffset = {x=0,y=-5},
		},
		
		--提示点击铭刻按钮
		[7] = {
			type = "clickButton",
			button = function() return UIEquipSuperDown:GetConfirmBtn(); end,
			Break = function() return (not UIEquipSuperDown:IsShow()) or (not UIEquip:IsShow()) ; end,
			arrow = true,
			arrowPos = 1,
			arrowOffset = {x=0,y=-5},
		}
	}
});