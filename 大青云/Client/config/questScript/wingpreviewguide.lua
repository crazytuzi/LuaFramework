--[[
2级翅膀预览引导
lizhuangzhuang
2015年7月9日22:01:43
]]
local t = 0;
local flyOver = false;

QuestScriptCfg:Add(
{
	name = "wingpreviewguide",
	--stopQuestGuide = true,--停下来
	
	steps = {
		
		--等1s
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
		
		--等过了剧情
		[2] = {
			type = "normal",
			execute = function() 
				t = 0;
				return true; 
			end,
			complete = function() t=0; return not StoryController:IsStorying(); end,
			Break = function() return false; end
		},
		
		--技能栏上方显示
		[3] = {
			type = "normal",
			execute = function() return true; end,
			complete = function() UIWingRightOpen:Show("guide"); return true; end,
			Break = function() return false; end
		},
		
		--等待界面打开
		[4] = {
			type = "normal",
			execute = function() return true; end,
			complete = function() return UIWingRightOpen:IsFullShow(); end,
			Break = function() return false; end
		},
		
		[5] = {
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
		
		--飞特效
		[6] = {
			type = "normal",
			execute = function()
						t = 0;
						local flyVO = {};
						flyVO.startPos = {x=_rd.w/2,y=_rd.h/2};
						flyVO.endPos = UIWingRightOpen:GetStarEndPos();
						flyVO.time = 0.5;
						flyVO.url = ResUtil:GetWingStarEffect();
						flyVO.tweenParam = {};
						flyVO.tweenParam.delay = 0.2;
						flyVO.onComplete = function()
							UIWingRightOpen:PlayBombEff();
							flyOver = true;
						end
						FlyManager:FlyEffect(flyVO);
						return true; 
					end,
			complete = function() return flyOver; end,
			Break = function() return false; end
		},
		
		[7] = {
			type = "normal",
			execute = function() flyOver=false; t = GetCurTime();  return true; end,
			complete = function() 
				if t == 0 then
					t = GetCurTime();
				end
				return GetCurTime()-t > 2000; 
			end,
			Break = function() return false; end
		},
		

	}
});