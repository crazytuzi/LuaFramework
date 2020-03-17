--[[
炼化功能引导
lizhuangzhuang
2015年6月3日12:23:36
]]

QuestScriptCfg:Add(
{
	name = "refinfuncguide",
	stopQuestGuide = true,--停下来
	disableFuncKey = true,
	log = true,
	
	steps = {
		--打开炼化UI
		[1] = {
			type = "normal",
			execute = function() 
				if not FuncManager:GetFuncIsOpen(FuncConsts.EquipRefin) then
					return false;
				end
				FuncManager:OpenFunc(FuncConsts.EquipRefin); 
				return true; 
			end,
			complete = function() return UIRefinView:IsFullShow(); end,
			Break = function() return false; end
		},
		--指向强化箭头
		--5秒后自动执行点击
		[2] = {
			type = "clickButton",
			button = function() return UIRefinView:GetLvlUPBtn(); end,
			Break = function() return (not UIRefinView:IsShow()) or (not UIEquip:IsShow()) ; end,
			arrow = true,
			arrowPos = 2,
			arrowOffset = {x=0,y=0},
			text = "点击强化装备，提升战斗力",
			autoTime = 20000,
			autoTimeFunc = function() UIRefinView:AutoUplvl(); end,
			mask=true
		},
		[3] = {
			type = "clickButton",
			button = function() return UIRefinView:GetLvlUPBtn(); end,
			Break = function() return (not UIRefinView:IsShow()) or (not UIEquip:IsShow()) ; end,
			arrow = true,
			arrowPos = 2,
			arrowOffset = {x=0,y=0},
			text = "点我，不要停！",
			autoTime = 5000,
			autoTimeFunc = function() UIRefinView:AutoUplvl(); end,
			mask=true
		},
		[4] = {
			type = "clickButton",
			button = function() return UIRefinView:GetLvlUPBtn(); end,
			Break = function() return (not UIRefinView:IsShow()) or (not UIEquip:IsShow()) ; end,
			arrow = true,
			arrowPos = 2,
			arrowOffset = {x=0,y=0},
			text = "继续点，你可以的！",
			autoTime = 5000,
			autoTimeFunc = function() UIRefinView:AutoUplvl(); end,
			mask=true
		},
		[5] = {
			type = "clickButton",
			button = function() return UIEquip:GetCloseBtn(); end,
			Break = function() return (not UIRefinView:IsShow()) or (not UIEquip:IsShow()) ; end,
			arrow = true,
			arrowPos = 4,
			arrowOffset = {x=0,y=0},
			text = "灵力足够记得要经常来强化装备",
			autoTime = 5000,
			autoTimeFunc = function() UIEquip:OnBtnCloseClick(); end,
			mask=true
		},
	
	}
});	
	
	
	
	