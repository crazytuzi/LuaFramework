--[[
获得假兵魂引导
lizhuangzhuang
2015-10-5 15:49:31
]]

local t = 0;

QuestScriptCfg:Add(
{
	name = "binghungetguide",
	stopQuestGuide = false,
	disableFuncKey = false,
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
		
		--启用假兵魂
		--在技能栏播放技能开启特效
		[3] = {
			type = "normal",
			execute = function() return true; end,
			complete = function()
						MainPlayerController:AddBinghun(999) 
						UIMainSkill:PlayEffZhuan()
						return true; 
					end,
			Break = function() return false; end
		},
		--等一会
		[4] = {
			type = "normal",
			execute = function() t = GetCurTime();  return true; end,
			complete = function() 
				if t == 0 then
					t = GetCurTime();
				end
				return GetCurTime()-t > 500; 
			end,
			Break = function() return false; end,
		},
		
		--在技能栏增加兵魂技能
		[5] = {
			type = "normal",
			execute = function() return true; end,
			complete = function()
						t = 0;
						if not FuncManager:GetFuncIsOpen(FuncConsts.BingHun) then
							local cfg = t_binghun[999];
							if cfg then
								local skillVO = SkillVO:new( cfg.skill )
								SkillModel:AddSkill(skillVO)
								SkillModel:SetShortCut(18,cfg.skill);
								Notifier:sendNotification(NotifyConsts.SkillShortCutChange,{pos=18,skillId=cfg.skill});
								AutoBattleModel:AddSkill(cfg.skill);
							end
						end
						return true; 
					end,
			Break = function() return false; end
		},
	}
});