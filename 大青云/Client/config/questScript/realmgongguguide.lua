--[[
境界巩固功能引导
lizhuangzhuang
2016年1月12日15:30:02
]]

QuestScriptCfg:Add(
{
	name = "realmgongguguide",
	stopQuestGuide = false,
	disableFuncKey = true,
	log = true,
	
	steps = {
		--箭头指向翻页按钮，点击1下后直接翻至可巩固境界的境界等级箭头文字：境界又有新玩法啦！
		[1] = {
			type = "clickButton",
			button = function() return UIRealmMainView:GetPreBtn(); end,
			Break = function() return not UIRealmMainView:IsShow(); end,
			arrow = true,
			arrowPos = 2,
			arrowOffset = {x=0,y=0},
			text = "境界又有新玩法啦！",
			-- autoTime = 20000,
			autoTime = 3000,
			autoTimeFunc = function() end,
			mask=true
		},
		--箭头指向当前可巩固的巩固等级页签，箭头文字：巩固境界可提升属性及增强境界压制效果
		[2] = {
			type = "normal",
			execute = function() end,
			complete = function() 
							UIRealmMainView:GotoGongGuPage();
							return true; 
						end,
			Break = function() return false; end
		},
		[3] = {
			type = "clickButton",
			button = function() return UIRealmMainView:GetCurrGongGuBtn(); end,
			Break = function() return not UIRealmMainView:IsShow(); end,
			arrow = true,
			arrowPos = 1,
			arrowOffset = {x=0,y=0},
			text = "巩固境界可提升属性及增强境界压制效果",
			-- autoTime = 20000,
			autoTime = 3000,
			autoTimeFunc = function() end,
			mask=true
		},
	}
});