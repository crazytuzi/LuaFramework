--[[
切换法宝引导
chenyujia
2016年5月16日
]]

local t = 0;

QuestScriptCfg:Add(
{
	name = "fabaochangeguide",
	stopQuestGuide = true,--停下来
	disableFuncKey = true,
	log = true,
	
	steps = {
	
		--引导点击法宝切换
		[1] = {
			type = "clickButton",
			button = function() return UIMainSkill:GetFabaoBtn(); end,
			Break = function() return false; end,
			arrow = true,
			arrowPos = 1,
			arrowOffset = {x=0,y=0},
			text = "点击选择切换的法宝",
			autoTime = 10000,
			autoTimeFunc = function() UIMainSkill:OnBtnFabaoClick(); end,
			mask=true
		},
		
		--等待切换法宝打开
		[2] = {
			type = "normal",
			execute = function() return true; end,
			complete = function() return UIFabaoSwitch:IsShow() end,
			Break = function() return false; end,
		},
		
		--引导选择法宝
		[3] = {
			type = "clickButton",
			button = function() return UIFabaoSwitch:GetItemBtn(); end,
			Break = function() return not UIFabaoSwitch:IsShow() end,
			arrow = true,
			arrowPos = 1,
			arrowOffset = {x=0,y=0},
			text = "点击法宝进行切换",
			autoTime = 10000,
			autoTimeFunc = function() 
				UIFabaoSwitch:ChangeFabao();
				UIFabaoSwitch:Hide()
			end,
			mask=true
		},
		
		--等2S
		-- [8] = {
		-- 	type = "normal",
		-- 	execute = function() t = GetCurTime();  return true; end,
		-- 	complete = function() 
		-- 		if t == 0 then
		-- 			t = GetCurTime();
		-- 		end
		-- 		return GetCurTime()-t > 2000; 
		-- 	end,
		-- 	Break = function() return false; end,
		-- },
	}
});