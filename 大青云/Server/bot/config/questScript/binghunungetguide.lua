--[[
失去假兵魂的引导
lizhuangzhuang
2015-10-5 15:56:52
]]

local t = 0;

QuestScriptCfg:Add(
{
	name = "binghunungetguide",
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
		
		--删掉假兵魂
		--移除技能栏假兵魂技能
		--显示冰魂被抢ui
		[3] = {
			type = "normal",
			execute = function() return true; end,
			complete = function()
						if not FuncManager:GetFuncIsOpen(FuncConsts.BingHun) then
							MainPlayerController:DeleteBinghun()
							SkillModel:SetShortCut(18,0);
							Notifier:sendNotification(NotifyConsts.SkillShortCutChange,{pos=18,skillId=0});
							local cfg = t_binghun[999];
							if cfg then
								AutoBattleModel:RemoveSkill(cfg.skill);
							end
						end
						UIBinghunQiangView:Show();
						return true; 
					end,
			Break = function() return false; end
		},
	}
});