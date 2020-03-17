--[[
切换变身引导
jiayong
2016年9月26日
]]

local t = 0;

QuestScriptCfg:Add(
{
	name = "transforchangeguide",
	stopQuestGuide = true,
	disableFuncKey = true,
	log = true,
	
	steps = {
	
		--引导点击变身切换
		[1] = {
			type = "clickButton",
			button = function() return UIMainPageTianshen:GetTransforBtn(); end,
			Break = function() return false; end,
			arrow = true,
			arrowPos = 1,
			arrowOffset = {x=0,y=0},
			text = "点击开启天神",
			autoTime = 8000,
			autoTimeFunc = function() UIMainPageTianshen:OnTransforAreaClick(); end,
			mask=false   
		},
		
	}
});