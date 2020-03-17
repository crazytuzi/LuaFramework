--[[
灵兽技能引导
lizhuangzhuang
2015年5月29日12:37:48
]]

local t = 0;

QuestScriptCfg:Add(
{
	name = "lingshouskillguide",
	stopQuestGuide = true,--停下来
	disableFuncKey = true,
	log = true,
	
	steps = {
		[1] = {
			type = "normal",
			execute = function() t = GetCurTime();  return true; end,
			complete = function() 
				if t == 0 then
					t = GetCurTime();
				end
				return GetCurTime()-t > 1000; 
			end,
			Break = function() return false; end,
		},
		
		--检查剧情
		[2] = {
			type = "normal",
			execute = function() 
				t = 0;
				return true; 
			end,
			complete = function() t=0; return not StoryController:IsStorying(); end,
			Break = function() return false; end
		},
		--将技能层级提高,关闭多余UI
		[3] = {
			type = "normal",
			execute = function() return true; end,
			complete = function() 
							UIMainSkill:Top();
							UIMount:Hide();
							return true; 
						end,
			Break = function() return false; end
		},
	
		--引导点击灵兽切换
		[4] = {
			type = "clickButton",
			button = function() return UIMainSkill:GetWuhunBtn(); end,
			Break = function() return false; end,
			arrow = true,
			arrowPos = 1,
			arrowOffset = {x=0,y=0},
			text = "点击选择灵兽进行附身",
			autoTime = 10000,
			autoTimeFunc = function() UIMainSkill:OnBtnWuhunClick(); end,
			mask=true
		},
		
		--等待切换武魂打开
		[5] = {
			type = "normal",
			execute = function() return true; end,
			complete = function() return UIWuhunSwitch:IsShow() end,
			Break = function() return false; end,
		},
		
		--引导选择灵兽
		[6] = {
			type = "clickButton",
			button = function() return UIWuhunSwitch:GetWuhunItem(); end,
			Break = function() return not UIWuhunSwitch:IsShow() end,
			arrow = true,
			arrowPos = 1,
			arrowOffset = {x=0,y=0},
			text = "点击选择九幽雀进行附身",
			autoTime = 10000,
			autoTimeFunc = function() 
				UIWuhunSwitch:AutoSelectLinshou();
				UIWuhunSwitch:OnGuideClick();
				UIWuhunSwitch:Hide()
			end,
			mask=true
		},
		
		--附身完成后，弹出剧情对话框【22】
		[7] = {
			type = "normal",
			execute = function() return true; end,
			complete = function() UIStoryDialog:PlayStoryDialog(22); return true; end,
			Break = function() return false; end,
		},
		
		--等2S
		[8] = {
			type = "normal",
			execute = function() t = GetCurTime();  return true; end,
			complete = function() 
				if t == 0 then
					t = GetCurTime();
				end
				return GetCurTime()-t > 2000; 
			end,
			Break = function() return false; end,
		},
		--引导释放技能，提醒的时候有蒙板，点击1次后蒙板去掉，但是箭头还在
		
		
	}
});